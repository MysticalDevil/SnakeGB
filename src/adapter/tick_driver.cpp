#include "adapter/game_logic.h"

#include <QDateTime>

#include "core/buff_runtime.h"
#include "fsm/game_state.h"

#include <cmath>

using namespace Qt::StringLiterals;

void GameLogic::updateReflectionFallback()
{
    if (m_hasAccelerometerReading) {
        return;
    }
    const float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0F;
    m_reflectionOffset = QPointF(std::sin(t * 0.8F) * 0.01F, std::cos(t * 0.7F) * 0.01F);
    emit reflectionOffsetChanged();
}

void GameLogic::update()
{
    if (m_fsmState) {
        const auto runtimeUpdate = m_sessionCore.beginRuntimeUpdate();
        if (runtimeUpdate.buffExpired) {
            deactivateBuff();
        }
        dispatchStateCallback([](GameState &state) -> void { state.update(); });
        applyPostTickTasks();
    }
    updateReflectionFallback();
}
