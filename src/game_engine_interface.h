#pragma once

#include <QPoint>
#include <QVariantList>
#include <deque>

class SnakeModel;
struct ReplayFrame;
struct ChoiceRecord;

/**
 * @brief Unified Interface for Game Logic operations.
 * Decouples FSM States from the concrete GameLogic implementation.
 */
class IGameEngine {
public:
    virtual ~IGameEngine() = default;

    // --- State Transitions ---
    virtual void setInternalState(int state) = 0;
    virtual void requestStateChange(int newState) = 0;

    // --- Core Data Access ---
    virtual auto snakeModel() -> SnakeModel* = 0;
    virtual auto direction() -> QPoint& = 0;
    virtual auto inputQueue() -> std::deque<QPoint>& = 0;
    virtual auto currentInputHistory() -> QList<ReplayFrame>& = 0;
    virtual auto bestInputHistory() -> QList<ReplayFrame>& = 0;
    virtual auto currentChoiceHistory() -> QList<ChoiceRecord>& = 0;
    virtual auto bestChoiceHistory() -> QList<ChoiceRecord>& = 0;
    virtual auto gameTickCounter() -> int& = 0;
    [[nodiscard]] virtual auto foodPos() const -> QPoint = 0;
    [[nodiscard]] virtual auto hasSave() const -> bool = 0;
    [[nodiscard]] virtual auto hasReplay() const -> bool = 0;

    // --- Logic & Physics ---
    virtual auto checkCollision(const QPoint &head) -> bool = 0;
    virtual void handleFoodConsumption(const QPoint &head) = 0;
    virtual void handlePowerUpConsumption(const QPoint &head) = 0;
    virtual void applyMovement(const QPoint &newHead, bool grew) = 0;

    // --- Game Actions ---
    virtual void restart() = 0;
    virtual void startReplay() = 0;
    virtual void loadLastSession() = 0;
    virtual void togglePause() = 0;
    virtual void nextLevel() = 0;
    
    // --- Timer Control ---
    virtual void startEngineTimer(int intervalMs = -1) = 0;
    virtual void stopEngineTimer() = 0;

    // --- Side Effects ---
    virtual void triggerHaptic(int magnitude) = 0;
    virtual void playEventSound(int type, float pan = 0.0f) = 0;
    virtual void updatePersistence() = 0;
    virtual void lazyInit() = 0;
    virtual void lazyInitState() = 0;
    virtual void forceUpdate() = 0;
    
    // --- Roguelike Selection ---
    [[nodiscard]] virtual auto choiceIndex() const -> int = 0;
    virtual void setChoiceIndex(int index) = 0;
    [[nodiscard]] virtual auto libraryIndex() const -> int = 0;
    virtual void setLibraryIndex(int index) = 0;
    [[nodiscard]] virtual auto medalIndex() const -> int = 0;
    virtual void setMedalIndex(int index) = 0;
    virtual void generateChoices() = 0;
    virtual void selectChoice(int index) = 0;
};
