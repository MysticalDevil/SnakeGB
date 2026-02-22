#include "game_logic.h"

#include "core/buff_runtime.h"
#include "core/game_rules.h"

#include <algorithm>

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
