#include <cmath>

#include <QDateTime>

#include "adapter/engine_adapter.h"
#include "core/buff/runtime.h"
#include "fsm/game_state.h"

using namespace Qt::StringLiterals;

void EngineAdapter::updateReflectionFallback() {
  if (m_hasAccelerometerReading) {
    return;
  }
  const float t = static_cast<float>(QDateTime::currentMSecsSinceEpoch()) / 1000.0F;
  m_reflectionOffset = QPointF(std::sin(t * 0.8F) * 0.01F, std::cos(t * 0.7F) * 0.01F);
  emit reflectionOffsetChanged();
}

void EngineAdapter::update() {
  if (m_fsmState) {
    dispatchStateCallback([](GameState& state) -> void { state.update(); });
    if (m_state == AppState::Playing || m_state == AppState::Replaying) {
      const auto runtimeUpdate = m_sessionCore.beginRuntimeUpdate();
      if (runtimeUpdate.buffExpired) {
        deactivateBuff();
      }
      applyPostTickTasks();
    }
  }
  updateReflectionFallback();
}
