#pragma once

#include "core/session_step_types.h"

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
    enum StateId {
        Splash = 0,
        StartMenu = 1,
        Playing = 2,
        Paused = 3,
        GameOver = 4,
        Replaying = 5,
        ChoiceSelection = 6,
        Library = 7,
        MedalRoom = 8
    };

    virtual ~IGameEngine() = default;

    // --- State Transitions ---
    virtual void setInternalState(int state) = 0;
    virtual void requestStateChange(int newState) = 0;

    // --- Core Data Access ---
    // The state layer can read immutable snapshots, but cannot mutate
    // engine-owned containers directly.
    [[nodiscard]] virtual auto snakeModel() const -> const SnakeModel* = 0;
    [[nodiscard]] virtual auto headPosition() const -> QPoint = 0;
    [[nodiscard]] virtual auto currentDirection() const -> QPoint = 0;
    virtual void setDirection(const QPoint &direction) = 0;
    [[nodiscard]] virtual auto currentTick() const -> int = 0;
    // Consume one queued input command if available.
    virtual auto consumeQueuedInput(QPoint &nextInput) -> bool = 0;
    // Persist an input sample for ghost replay determinism.
    virtual void recordInputAtCurrentTick(const QPoint &input) = 0;
    [[nodiscard]] virtual auto bestInputHistorySize() const -> int = 0;
    // Read replay frame data without exposing the underlying container.
    virtual auto bestInputFrameAt(int index, int &frame, int &dx, int &dy) const -> bool = 0;
    [[nodiscard]] virtual auto bestChoiceHistorySize() const -> int = 0;
    // Read replay choice data without exposing the underlying container.
    virtual auto bestChoiceAt(int index, int &frame, int &choiceIndex) const -> bool = 0;
    [[nodiscard]] virtual auto foodPos() const -> QPoint = 0;
    [[nodiscard]] virtual auto currentState() const -> int = 0;
    [[nodiscard]] virtual auto hasPendingStateChange() const -> bool = 0;
    [[nodiscard]] virtual auto hasSave() const -> bool = 0;
    [[nodiscard]] virtual auto hasReplay() const -> bool = 0;

    // --- Logic & Physics ---
    virtual auto checkCollision(const QPoint &head) -> bool = 0;
    virtual void handleFoodConsumption(const QPoint &head) = 0;
    virtual void handlePowerUpConsumption(const QPoint &head) = 0;
    virtual void applyMovement(const QPoint &newHead, bool grew) = 0;
    virtual auto advanceSessionStep(const snakegb::core::SessionAdvanceConfig &config)
        -> snakegb::core::SessionAdvanceResult = 0;

    // --- Game Actions ---
    virtual void restart() = 0;
    virtual void startReplay() = 0;
    virtual void loadLastSession() = 0;
    virtual void togglePause() = 0;
    virtual void nextLevel() = 0;
    virtual void nextPalette() = 0;
    
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
    [[nodiscard]] virtual auto fruitLibrarySize() const -> int = 0;
    virtual void setLibraryIndex(int index) = 0;
    [[nodiscard]] virtual auto medalIndex() const -> int = 0;
    [[nodiscard]] virtual auto medalLibrarySize() const -> int = 0;
    virtual void setMedalIndex(int index) = 0;
    virtual void generateChoices() = 0;
    virtual void selectChoice(int index) = 0;
};
