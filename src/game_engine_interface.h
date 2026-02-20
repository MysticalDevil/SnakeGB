#pragma once

#include <QPoint>
#include <QVariantList>
#include <deque>

class SnakeModel;
struct ReplayFrame;

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
    virtual SnakeModel* snakeModel() = 0;
    virtual QPoint& direction() = 0;
    virtual std::deque<QPoint>& inputQueue() = 0;
    virtual QList<ReplayFrame>& currentInputHistory() = 0;
    virtual QList<ReplayFrame>& bestInputHistory() = 0;
    virtual int& gameTickCounter() = 0;
    virtual QPoint foodPos() const = 0;
    virtual bool hasSave() const = 0;

    // --- Logic & Physics ---
    virtual bool checkCollision(const QPoint &head) = 0;
    virtual void handleFoodConsumption(const QPoint &head) = 0;
    virtual void handlePowerUpConsumption(const QPoint &head) = 0;
    virtual void applyMovement(const QPoint &newHead, bool grew) = 0;

    // --- Game Actions ---
    virtual void restart() = 0;
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
    virtual void forceUpdate() = 0;
};
