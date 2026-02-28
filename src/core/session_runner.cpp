#include "session_runner.h"

#include <utility>

namespace snakegb::core {

namespace
{
constexpr int ChoiceBuffDurationTicks = 80;
constexpr int PowerUpBuffDurationTicks = 40;
}

// NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
SessionRunner::SessionRunner(const int boardWidth, const int boardHeight)
    : m_boardWidth(boardWidth), m_boardHeight(boardHeight)
{
}

void SessionRunner::startSession(QList<QPoint> obstacles, const uint randomSeed)
{
    resetRuntimeState();
    m_randomSeed = randomSeed;
    m_rng.seed(randomSeed);
    m_core.bootstrapForLevel(std::move(obstacles), m_boardWidth, m_boardHeight);
    m_core.spawnFood(m_boardWidth, m_boardHeight,
                     [this](const int bound) { return randomBounded(bound); });
    m_mode = SessionMode::Playing;
}

void SessionRunner::startReplay(QList<QPoint> obstacles, const uint randomSeed,
                                QList<ReplayFrame> inputHistory,
                                QList<ChoiceRecord> choiceHistory)
{
    startSession(std::move(obstacles), randomSeed);
    setReplayTimeline(std::move(inputHistory), std::move(choiceHistory));
    m_mode = SessionMode::Replaying;
}

void SessionRunner::seedPreviewState(const PreviewSeed &seed, const SessionMode mode,
                                     const uint randomSeed)
{
    resetRuntimeState();
    m_randomSeed = randomSeed;
    m_rng.seed(randomSeed);
    m_core.seedPreviewState(seed);
    m_mode = mode;
}

void SessionRunner::setReplayTimeline(QList<ReplayFrame> inputHistory,
                                      QList<ChoiceRecord> choiceHistory)
{
    m_replayInputHistory = std::move(inputHistory);
    m_replayChoiceHistory = std::move(choiceHistory);
    m_replayInputHistoryIndex = 0;
    m_replayChoiceHistoryIndex = 0;
}

auto SessionRunner::enqueueDirection(const QPoint &direction, const std::size_t maxQueueSize)
    -> bool
{
    return m_core.enqueueDirection(direction, maxQueueSize);
}

auto SessionRunner::tick() -> SessionTickResult
{
    SessionTickResult tickResult;
    if (m_mode != SessionMode::Playing && m_mode != SessionMode::Replaying) {
        return tickResult;
    }

    const auto runtimeUpdate = m_core.beginRuntimeUpdate();
    tickResult.buffExpired = runtimeUpdate.buffExpired;

    if (m_mode == SessionMode::Replaying) {
        const auto replayResult =
            m_core.applyReplayTimeline(m_replayInputHistory, m_replayInputHistoryIndex,
                                       m_replayChoiceHistory, m_replayChoiceHistoryIndex);
        if (replayResult.choiceIndex.has_value()) {
            tickResult.replayChoiceApplied = selectChoice(*replayResult.choiceIndex);
        }
    }

    const auto stepResult = m_core.advanceSessionStep(
        {
            .boardWidth = m_boardWidth,
            .boardHeight = m_boardHeight,
            .consumeInputQueue = (m_mode == SessionMode::Playing),
            .pauseOnChoiceTrigger = (m_mode != SessionMode::Replaying),
        },
        [this](const int bound) { return randomBounded(bound); });

    if (stepResult.consumedInput && m_mode == SessionMode::Playing) {
        m_inputHistory.append({
            .frame = m_core.tickCounter(),
            .dx = stepResult.consumedDirection.x(),
            .dy = stepResult.consumedDirection.y(),
        });
        tickResult.consumedInput = true;
    }

    if (stepResult.collision) {
        tickResult.collision = true;
        m_mode = (m_mode == SessionMode::Replaying) ? SessionMode::ReplayFinished
                                                    : SessionMode::GameOver;
    } else {
        applyConsumptionEffects(stepResult, tickResult);
        if (stepResult.appliedMovement) {
            appendRecordingPoint();
            tickResult.advanced = true;
        }
    }

    m_core.finishRuntimeUpdate();
    tickResult.replayFinished = (m_mode == SessionMode::ReplayFinished);
    return tickResult;
}

auto SessionRunner::selectChoice(const int index) -> bool
{
    if (index < 0 || index >= m_choices.size()) {
        return false;
    }

    if (m_mode != SessionMode::Replaying) {
        m_choiceHistory.append({.frame = m_core.tickCounter(), .index = index});
    }

    m_core.applyChoiceSelection(m_choices[index].type, ChoiceBuffDurationTicks, false);
    m_choices.clear();

    if (m_mode == SessionMode::ChoiceSelection) {
        m_mode = SessionMode::Playing;
    }
    return true;
}

auto SessionRunner::randomBounded(const int bound) -> int
{
    return m_rng.bounded(bound);
}

void SessionRunner::resetRuntimeState()
{
    m_choices.clear();
    m_recording.clear();
    m_inputHistory.clear();
    m_choiceHistory.clear();
    m_replayInputHistory.clear();
    m_replayChoiceHistory.clear();
    m_replayInputHistoryIndex = 0;
    m_replayChoiceHistoryIndex = 0;
    m_mode = SessionMode::Idle;
}

void SessionRunner::generateChoices()
{
    m_choices = pickRoguelikeChoices(m_rng.generate(), 3);
}

void SessionRunner::appendRecordingPoint()
{
    m_recording.append(m_core.headPosition());
}

void SessionRunner::applyConsumptionEffects(const SessionAdvanceResult &result,
                                            SessionTickResult &tickResult)
{
    auto spawnPowerUp = [this]() {
        m_core.spawnPowerUp(m_boardWidth, m_boardHeight,
                            [this](const int bound) { return randomBounded(bound); });
    };
    auto spawnFood = [this]() {
        m_core.spawnFood(m_boardWidth, m_boardHeight,
                         [this](const int bound) { return randomBounded(bound); });
    };
    auto handleChoiceTrigger = [this, &tickResult]() {
        generateChoices();
        if (m_mode != SessionMode::Replaying) {
            m_mode = SessionMode::ChoiceSelection;
            tickResult.enteredChoice = true;
        }
    };

    if (result.ateFood) {
        spawnFood();
        if (result.triggerChoice) {
            handleChoiceTrigger();
        } else if (result.spawnPowerUp) {
            spawnPowerUp();
        }
    }

    if (result.magnetAteFood) {
        spawnFood();
        if (result.triggerChoiceAfterMagnet) {
            handleChoiceTrigger();
        } else if (result.spawnPowerUpAfterMagnet) {
            spawnPowerUp();
        }
    }
}

} // namespace snakegb::core
