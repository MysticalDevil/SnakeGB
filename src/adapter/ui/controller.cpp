#include "adapter/ui/controller.h"

#include "adapter/engine_adapter.h"

UiCommandController::UiCommandController(EngineAdapter* engineAdapter, QObject* parent)
    : QObject(parent),
      m_engineAdapter(engineAdapter) {
  if (m_engineAdapter == nullptr) {
    return;
  }

  connect(
    m_engineAdapter, &EngineAdapter::paletteChanged, this, &UiCommandController::paletteChanged);
  connect(
    m_engineAdapter, &EngineAdapter::shellColorChanged, this, &UiCommandController::shellChanged);
  connect(m_engineAdapter,
          &EngineAdapter::achievementEarned,
          this,
          &UiCommandController::achievementEarned);
  connect(m_engineAdapter, &EngineAdapter::eventPrompt, this, &UiCommandController::eventPrompt);
}

void UiCommandController::dispatch(const QString& action) const {
  if (m_engineAdapter != nullptr) {
    m_engineAdapter->dispatchUiAction(action);
  }
}

void UiCommandController::requestStateChange(const int state) const {
  if (m_engineAdapter != nullptr) {
    m_engineAdapter->requestStateChange(state);
  }
}

void UiCommandController::cycleBgm() const {
  if (m_engineAdapter != nullptr) {
    m_engineAdapter->cycleBgm();
  }
}

void UiCommandController::seedChoicePreview(const QVariantList& types) const {
  if (m_engineAdapter != nullptr) {
    m_engineAdapter->debugSeedChoicePreview(types);
  }
}

void UiCommandController::seedReplayBuffPreview() const {
  if (m_engineAdapter != nullptr) {
    m_engineAdapter->debugSeedReplayBuffPreview();
  }
}
