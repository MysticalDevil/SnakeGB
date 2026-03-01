#pragma once

#include <QList>
#include <QPoint>
#include <QRandomGenerator>

#include "core/choice/runtime.h"
#include "core/replay/types.h"
#include "core/session/core.h"

namespace snakegb::core {

enum class SessionMode {
  Idle,
  Playing,
  ChoiceSelection,
  GameOver,
  Replaying,
  ReplayFinished,
};

struct SessionTickResult {
  bool advanced = false;
  bool collision = false;
  bool enteredChoice = false;
  bool consumedInput = false;
  bool replayChoiceApplied = false;
  bool replayFinished = false;
  bool buffExpired = false;
};

class SessionRunner {
public:
  SessionRunner(int boardWidth = 20, int boardHeight = 18);

  void startSession(QList<QPoint> obstacles, uint randomSeed);
  void startReplay(QList<QPoint> obstacles,
                   uint randomSeed,
                   QList<ReplayFrame> inputHistory,
                   QList<ChoiceRecord> choiceHistory);
  void seedPreviewState(const PreviewSeed& seed, SessionMode mode, uint randomSeed);
  void setReplayTimeline(QList<ReplayFrame> inputHistory, QList<ChoiceRecord> choiceHistory);

  [[nodiscard]] auto core() -> SessionCore& {
    return m_core;
  }
  [[nodiscard]] auto core() const -> const SessionCore& {
    return m_core;
  }
  [[nodiscard]] auto mode() const -> SessionMode {
    return m_mode;
  }
  [[nodiscard]] auto randomSeed() const -> uint {
    return m_randomSeed;
  }
  [[nodiscard]] auto choices() const -> const QList<ChoiceSpec>& {
    return m_choices;
  }
  [[nodiscard]] auto recording() const -> const QList<QPoint>& {
    return m_recording;
  }
  [[nodiscard]] auto inputHistory() const -> const QList<ReplayFrame>& {
    return m_inputHistory;
  }
  [[nodiscard]] auto choiceHistory() const -> const QList<ChoiceRecord>& {
    return m_choiceHistory;
  }

  auto enqueueDirection(const QPoint& direction, std::size_t maxQueueSize = 2) -> bool;
  auto tick() -> SessionTickResult;
  auto selectChoice(int index) -> bool;

private:
  auto randomBounded(int bound) -> int;
  void resetRuntimeState();
  void generateChoices();
  void appendRecordingPoint();
  void applyConsumptionEffects(const SessionAdvanceResult& result, SessionTickResult& tickResult);

  SessionCore m_core;
  int m_boardWidth = 20;
  int m_boardHeight = 18;
  SessionMode m_mode = SessionMode::Idle;
  uint m_randomSeed = 0;
  QRandomGenerator m_rng;
  QList<ChoiceSpec> m_choices;
  QList<QPoint> m_recording;
  QList<ReplayFrame> m_inputHistory;
  QList<ChoiceRecord> m_choiceHistory;
  QList<ReplayFrame> m_replayInputHistory;
  QList<ChoiceRecord> m_replayChoiceHistory;
  int m_replayInputHistoryIndex = 0;
  int m_replayChoiceHistoryIndex = 0;
};

} // namespace snakegb::core
