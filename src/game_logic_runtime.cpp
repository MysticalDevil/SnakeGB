#include "game_logic.h"

#include <QDateTime>

#include "core/achievement_rules.h"
#include "core/buff_runtime.h"
#include "core/game_rules.h"
#include "fsm/game_state.h"
#include "profile_manager.h"

#include <algorithm>
#include <cmath>

using namespace Qt::StringLiterals;

namespace
{
constexpr int BuffDurationTicks = 40;
} // namespace

auto GameLogic::checkCollision(const QPoint &head) -> bool
{
    const snakegb::core::CollisionOutcome outcome = snakegb::core::collisionOutcomeForHead(
        head, BOARD_WIDTH, BOARD_HEIGHT, m_obstacles, m_snakeModel.body(), m_activeBuff == Ghost,
        m_activeBuff == Portal, m_activeBuff == Laser, m_shieldActive);

    if (outcome.consumeLaser && outcome.obstacleIndex >= 0 &&
        outcome.obstacleIndex < m_obstacles.size()) {
        m_obstacles.removeAt(outcome.obstacleIndex);
        m_activeBuff = None;
        emit obstaclesChanged();
        triggerHaptic(8);
        emit buffChanged();
    }
    if (outcome.consumeShield) {
        m_shieldActive = false;
        triggerHaptic(5);
        emit buffChanged();
    }
    return outcome.collision;
}

void GameLogic::handleFoodConsumption(const QPoint &head)
{
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (p != m_food) {
        return;
    }

    const int points =
        snakegb::core::foodPointsForBuff(static_cast<snakegb::core::BuffId>(m_activeBuff));

    const int previousScore = m_score;
    m_score += points;
    if (m_profileManager) {
        m_profileManager->logFoodEaten();
    }

    const float pan = (static_cast<float>(p.x()) / BOARD_WIDTH - 0.5F) * 1.4F;
    emit foodEaten(pan);

    m_timer->setInterval(normalTickIntervalMs());
    emit scoreChanged();
    spawnFood();

    if (shouldTriggerRoguelikeChoice(previousScore, m_score)) {
        m_lastRoguelikeChoiceScore = m_score;
        if (m_state == Replaying) {
            generateChoices();
        } else {
            requestStateChange(ChoiceSelection);
        }
    } else if (m_rng.bounded(100) < 15 && m_powerUpPos == QPoint(-1, -1)) {
        spawnPowerUp();
    }

    triggerHaptic(std::min(5, 2 + (m_score / 10)));
}

void GameLogic::handlePowerUpConsumption(const QPoint &head)
{
    const QPoint p = snakegb::core::wrapPoint(head, BOARD_WIDTH, BOARD_HEIGHT);

    if (p != m_powerUpPos) {
        return;
    }

    m_activeBuff = m_powerUpType;
    applyAcquiredBuffEffects(static_cast<int>(m_activeBuff), BuffDurationTicks, true, true);

    m_powerUpPos = QPoint(-1, -1);

    emit powerUpEaten();
    if (m_activeBuff == Slow) {
        m_timer->setInterval(250);
    }

    triggerHaptic(5);
    emit buffChanged();
    emit powerUpChanged();
}

void GameLogic::applyMovement(const QPoint &newHead, const bool grew)
{
    const QPoint p = snakegb::core::wrapPoint(newHead, BOARD_WIDTH, BOARD_HEIGHT);

    m_snakeModel.moveHead(p, grew);
    m_currentRecording.append(p);

    if (m_ghostFrameIndex < static_cast<int>(m_bestRecording.size())) {
        m_ghostFrameIndex++;
        emit ghostChanged();
    }
    applyMagnetAttraction();
    checkAchievements();
}

void GameLogic::applyMiniShrink()
{
    const auto body = m_snakeModel.body();
    if (body.size() <= 3) {
        return;
    }
    std::deque<QPoint> nextBody;
    const size_t targetLength = snakegb::core::miniShrinkTargetLength(body.size(), 3);
    for (size_t i = 0; i < targetLength; ++i) {
        nextBody.push_back(body[i]);
    }
    m_snakeModel.reset(nextBody);
}

auto GameLogic::normalTickIntervalMs() const -> int
{
    if (m_activeBuff == Slow) {
        return 250;
    }
    return snakegb::core::tickIntervalForScore(m_score);
}

void GameLogic::applyAcquiredBuffEffects(const int discoveredType, const int baseDurationTicks,
                                         const bool halfDurationForRich, const bool emitMiniPrompt)
{
    if (m_profileManager) {
        m_profileManager->discoverFruit(discoveredType);
    }

    if (m_activeBuff == Shield) {
        m_shieldActive = true;
    }

    if (m_activeBuff == Mini) {
        applyMiniShrink();
        if (emitMiniPrompt) {
            emit eventPrompt(u"MINI BLITZ! SIZE CUT"_s);
        }
        m_activeBuff = None;
    }

    m_buffTicksRemaining =
        halfDurationForRich
            ? snakegb::core::buffDurationTicks(static_cast<snakegb::core::BuffId>(m_activeBuff),
                                               baseDurationTicks)
            : baseDurationTicks;
    m_buffTicksTotal = m_buffTicksRemaining;
}

void GameLogic::applyPostTickTasks()
{
    if (!m_currentScript.isEmpty()) {
        runLevelScript();
    }
    m_gameTickCounter++;
}

void GameLogic::updateReflectionFallback()
{
    if (m_hasAccelerometerReading) {
        return;
    }
    const float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0F;
    m_reflectionOffset = QPointF(std::sin(t * 0.8F) * 0.01F, std::cos(t * 0.7F) * 0.01F);
    emit reflectionOffsetChanged();
}

auto GameLogic::shouldTriggerRoguelikeChoice(const int previousScore, const int newScore) -> bool
{
    const int chancePercent = snakegb::core::roguelikeChoiceChancePercent({
        .previousScore = previousScore,
        .newScore = newScore,
        .lastChoiceScore = m_lastRoguelikeChoiceScore,
    });
    if (chancePercent >= 100) {
        return true;
    }
    if (chancePercent <= 0) {
        return false;
    }
    return m_rng.bounded(100) < chancePercent;
}

void GameLogic::applyMagnetAttraction()
{
    if (m_activeBuff != Magnet || m_food == QPoint(-1, -1) || m_snakeModel.body().empty()) {
        return;
    }

    const QPoint head = m_snakeModel.body().front();
    if (m_food == head) {
        handleFoodConsumption(head);
        return;
    }

    const QList<QPoint> candidates =
        snakegb::core::magnetCandidateSpots(m_food, head, BOARD_WIDTH, BOARD_HEIGHT);

    for (const QPoint &candidate : candidates) {
        if (candidate == m_food) {
            continue;
        }
        if (candidate == head || (!isOccupied(candidate) && candidate != m_powerUpPos)) {
            m_food = candidate;
            emit foodChanged();
            if (m_food == head) {
                handleFoodConsumption(head);
            }
            return;
        }
    }
}

void GameLogic::deactivateBuff()
{
    m_activeBuff = None;
    m_buffTicksRemaining = 0;
    m_buffTicksTotal = 0;
    m_shieldActive = false;
    m_timer->setInterval(normalTickIntervalMs());
    emit buffChanged();
}

void GameLogic::spawnFood()
{
    QPoint pickedPoint;
    const bool found = snakegb::core::pickRandomFreeSpot(
        BOARD_WIDTH, BOARD_HEIGHT,
        [this](const QPoint &point) -> bool { return isOccupied(point) || point == m_powerUpPos; },
        [this](const int size) -> int { return m_rng.bounded(size); }, pickedPoint);
    if (found) {
        m_food = pickedPoint;
        emit foodChanged();
    }
}

void GameLogic::spawnPowerUp()
{
    QPoint pickedPoint;
    const bool found = snakegb::core::pickRandomFreeSpot(
        BOARD_WIDTH, BOARD_HEIGHT,
        [this](const QPoint &point) -> bool { return isOccupied(point) || point == m_food; },
        [this](const int size) -> int { return m_rng.bounded(size); }, pickedPoint);
    if (found) {
        m_powerUpPos = pickedPoint;
        m_powerUpType = static_cast<PowerUp>(static_cast<int>(snakegb::core::weightedRandomBuffId(
            [this](const int maxExclusive) -> int { return m_rng.bounded(maxExclusive); })));
        emit powerUpChanged();
    }
}

auto GameLogic::isOccupied(const QPoint &p) const -> bool
{
    const bool inSnake = std::ranges::any_of(
        m_snakeModel.body(), [&p](const QPoint &bodyPoint) { return bodyPoint == p; });
    if (inSnake) {
        return true;
    }
    return std::ranges::any_of(m_obstacles,
                               [&p](const QPoint &obstaclePoint) { return obstaclePoint == p; });
}

auto GameLogic::isOutOfBounds(const QPoint &p) noexcept -> bool
{
    return !m_boardRect.contains(p);
}

void GameLogic::update()
{
    if (m_fsmState) {
        if (m_activeBuff != None && m_buffTicksRemaining > 0) {
            if (--m_buffTicksRemaining <= 0) {
                deactivateBuff();
            }
        }
        dispatchStateCallback([](GameState &state) -> void { state.update(); });
        applyPostTickTasks();
    }
    updateReflectionFallback();
}
