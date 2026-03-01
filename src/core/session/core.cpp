#include "core/session/core.h"

#include <utility>

namespace nenoserpent::core {

namespace {
constexpr int PowerUpLifetimeTicks = 100;
}

auto MetaAction::resetTransientRuntime() -> MetaAction {
  return {
    .kind = Kind::ResetTransientRuntime,
    .obstacles = {},
    .snapshot = {},
    .previewSeed = {},
    .boardWidth = 0,
    .boardHeight = 0,
  };
}

auto MetaAction::resetReplayRuntime() -> MetaAction {
  return {
    .kind = Kind::ResetReplayRuntime,
    .obstacles = {},
    .snapshot = {},
    .previewSeed = {},
    .boardWidth = 0,
    .boardHeight = 0,
  };
}

auto MetaAction::bootstrapForLevel(QList<QPoint> obstacles,
                                   const int boardWidth,
                                   const int boardHeight) -> MetaAction {
  return {
    .kind = Kind::BootstrapForLevel,
    .obstacles = std::move(obstacles),
    .snapshot = {},
    .previewSeed = {},
    .boardWidth = boardWidth,
    .boardHeight = boardHeight,
  };
}

auto MetaAction::restorePersistedSession(const StateSnapshot& snapshot) -> MetaAction {
  return {
    .kind = Kind::RestorePersistedSession,
    .obstacles = {},
    .snapshot = snapshot,
    .previewSeed = {},
    .boardWidth = 0,
    .boardHeight = 0,
  };
}

auto MetaAction::seedPreviewState(const PreviewSeed& seed) -> MetaAction {
  return {
    .kind = Kind::SeedPreviewState,
    .obstacles = {},
    .snapshot = {},
    .previewSeed = seed,
    .boardWidth = 0,
    .boardHeight = 0,
  };
}

auto MetaAction::restoreSnapshot(const StateSnapshot& snapshot) -> MetaAction {
  return {
    .kind = Kind::RestoreSnapshot,
    .obstacles = {},
    .snapshot = snapshot,
    .previewSeed = {},
    .boardWidth = 0,
    .boardHeight = 0,
  };
}

void SessionCore::setDirection(const QPoint& direction) {
  m_state.direction = direction;
}

auto SessionCore::direction() const -> QPoint {
  return m_state.direction;
}

auto SessionCore::tickCounter() const -> int {
  return m_state.tickCounter;
}

auto SessionCore::currentTickIntervalMs() const -> int {
  if (m_state.activeBuff == static_cast<int>(BuffId::Slow)) {
    return 250;
  }
  return tickIntervalForScore(m_state.score);
}

auto SessionCore::headPosition() const -> QPoint {
  return m_body.empty() ? QPoint() : m_body.front();
}

void SessionCore::incrementTick() {
  m_state.tickCounter++;
}

auto SessionCore::enqueueDirection(const QPoint& direction, const std::size_t maxQueueSize)
  -> bool {
  if (m_inputQueue.size() >= maxQueueSize) {
    return false;
  }

  const QPoint lastDirection = m_inputQueue.empty() ? m_state.direction : m_inputQueue.back();
  if (((direction.x() != 0) && lastDirection.x() == -direction.x()) ||
      ((direction.y() != 0) && lastDirection.y() == -direction.y())) {
    return false;
  }

  m_inputQueue.push_back(direction);
  return true;
}

auto SessionCore::consumeQueuedInput(QPoint& nextInput) -> bool {
  if (m_inputQueue.empty()) {
    return false;
  }

  nextInput = m_inputQueue.front();
  m_inputQueue.pop_front();
  return true;
}

void SessionCore::clearQueuedInput() {
  m_inputQueue.clear();
}

void SessionCore::setBody(const std::deque<QPoint>& body) {
  m_body = body;
}

void SessionCore::applyMovement(const QPoint& newHead, const bool grew) {
  m_body.push_front(newHead);
  if (!grew && !m_body.empty()) {
    m_body.pop_back();
  }
}

auto SessionCore::checkCollision(const QPoint& head, const int boardWidth, const int boardHeight)
  -> CollisionOutcome {
  const auto outcome =
    collisionOutcomeForHead(head,
                            boardWidth,
                            boardHeight,
                            m_state.obstacles,
                            m_body,
                            m_state.activeBuff == static_cast<int>(BuffId::Ghost),
                            m_state.activeBuff == static_cast<int>(BuffId::Portal),
                            m_state.activeBuff == static_cast<int>(BuffId::Laser),
                            m_state.shieldActive);

  if (outcome.consumeLaser && outcome.obstacleIndex >= 0 &&
      outcome.obstacleIndex < m_state.obstacles.size()) {
    m_state.obstacles.removeAt(outcome.obstacleIndex);
    m_state.activeBuff = static_cast<int>(BuffId::None);
  }

  if (outcome.consumeShield) {
    m_state.shieldActive = false;
  }

  return outcome;
}

auto SessionCore::consumeFood(const QPoint& head,
                              const int boardWidth,
                              const int boardHeight,
                              const std::function<int(int)>& randomBounded)
  -> FoodConsumptionResult {
  const auto result = planFoodConsumption(head, m_state, boardWidth, boardHeight, randomBounded);
  if (!result.ate) {
    return result;
  }

  m_state.score = result.newScore;
  if (result.triggerChoice) {
    m_state.lastRoguelikeChoiceScore = m_state.score;
  }
  return result;
}

auto SessionCore::consumePowerUp(const QPoint& head,
                                 const int baseDurationTicks,
                                 const bool halfDurationForRich) -> PowerUpConsumptionResult {
  const auto result = planPowerUpConsumption(head, m_state, baseDurationTicks, halfDurationForRich);
  if (!result.ate) {
    return result;
  }

  applyPowerUpResult(result);
  m_state.powerUpPos = QPoint(-1, -1);
  m_state.powerUpTicksRemaining = 0;
  return result;
}

auto SessionCore::applyChoiceSelection(const int powerUpType,
                                       const int baseDurationTicks,
                                       const bool halfDurationForRich) -> PowerUpConsumptionResult {
  m_state.lastRoguelikeChoiceScore = m_state.score;
  const auto result = planPowerUpAcquisition(powerUpType, baseDurationTicks, halfDurationForRich);
  applyPowerUpResult(result);
  return result;
}

auto SessionCore::selectChoice(const int powerUpType,
                               const int baseDurationTicks,
                               const bool halfDurationForRich) -> PowerUpConsumptionResult {
  return applyChoiceSelection(powerUpType, baseDurationTicks, halfDurationForRich);
}

auto SessionCore::tickBuffCountdown() -> bool {
  if (m_state.activeBuff == static_cast<int>(BuffId::None) ||
      !nenoserpent::core::tickBuffCountdown(m_state.buffTicksRemaining)) {
    return false;
  }

  m_state.activeBuff = static_cast<int>(BuffId::None);
  m_state.buffTicksRemaining = 0;
  m_state.buffTicksTotal = 0;
  m_state.shieldActive = false;
  return true;
}

auto SessionCore::spawnFood(const int boardWidth,
                            const int boardHeight,
                            const std::function<int(int)>& randomBounded) -> bool {
  QPoint pickedPoint;
  const bool found = pickRandomFreeSpot(
    boardWidth,
    boardHeight,
    [this](const QPoint& point) -> bool {
      return isOccupied(point) || point == m_state.powerUpPos;
    },
    randomBounded,
    pickedPoint);
  if (found) {
    m_state.food = pickedPoint;
  }
  return found;
}

auto SessionCore::spawnPowerUp(const int boardWidth,
                               const int boardHeight,
                               const std::function<int(int)>& randomBounded) -> bool {
  QPoint pickedPoint;
  const bool found = pickRandomFreeSpot(
    boardWidth,
    boardHeight,
    [this](const QPoint& point) -> bool { return isOccupied(point) || point == m_state.food; },
    randomBounded,
    pickedPoint);
  if (found) {
    m_state.powerUpPos = pickedPoint;
    m_state.powerUpType = static_cast<int>(weightedRandomBuffId(randomBounded));
    m_state.powerUpTicksRemaining = PowerUpLifetimeTicks;
  }
  return found;
}

auto SessionCore::applyMagnetAttraction(const int boardWidth, const int boardHeight)
  -> MagnetAttractionResult {
  if (m_state.activeBuff != static_cast<int>(BuffId::Magnet) || m_state.food == QPoint(-1, -1) ||
      m_body.empty()) {
    return {};
  }

  auto result = nenoserpent::core::applyMagnetAttraction(
    headPosition(), boardWidth, boardHeight, m_state, [this](const QPoint& pos) {
      return isOccupied(pos);
    });
  if (result.moved) {
    m_state.food = result.newFood;
  }
  return result;
}

auto SessionCore::applyReplayTimeline(const QList<ReplayFrame>& inputFrames,
                                      int& inputHistoryIndex,
                                      const QList<ChoiceRecord>& choiceFrames,
                                      int& choiceHistoryIndex) -> ReplayTimelineApplication {
  ReplayTimelineApplication result;

  while (inputHistoryIndex < inputFrames.size()) {
    const auto& frame = inputFrames[inputHistoryIndex];
    if (frame.frame == m_state.tickCounter) {
      result.appliedInput = true;
      result.appliedDirection = QPoint(frame.dx, frame.dy);
      setDirection(result.appliedDirection);
      inputHistoryIndex++;
    } else if (frame.frame > m_state.tickCounter) {
      break;
    } else {
      inputHistoryIndex++;
    }
  }

  while (choiceHistoryIndex < choiceFrames.size()) {
    const auto& frame = choiceFrames[choiceHistoryIndex];
    if (frame.frame == m_state.tickCounter) {
      result.choiceIndex = frame.index;
      choiceHistoryIndex++;
      break;
    }
    if (frame.frame > m_state.tickCounter) {
      break;
    }
    choiceHistoryIndex++;
  }

  return result;
}

auto SessionCore::beginRuntimeUpdate() -> RuntimeUpdateResult {
  return {
    .buffExpired = tickBuffCountdown(),
    .powerUpExpired = tickPowerUpCountdown(),
  };
}

void SessionCore::finishRuntimeUpdate() {
  incrementTick();
}

auto SessionCore::tick(const TickCommand& command, const std::function<int(int)>& randomBounded)
  -> TickResult {
  TickResult result;

  if (command.applyRuntimeHooks) {
    result.runtimeUpdate = beginRuntimeUpdate();
  }

  if (command.replayInputFrames != nullptr && command.replayInputHistoryIndex != nullptr &&
      command.replayChoiceFrames != nullptr && command.replayChoiceHistoryIndex != nullptr) {
    result.replayTimeline = applyReplayTimeline(*command.replayInputFrames,
                                                *command.replayInputHistoryIndex,
                                                *command.replayChoiceFrames,
                                                *command.replayChoiceHistoryIndex);
  }

  result.step = advanceSessionStep(command.advanceConfig, randomBounded);

  if (command.applyRuntimeHooks) {
    finishRuntimeUpdate();
  }

  return result;
}

void SessionCore::applyMetaAction(const MetaAction& action) {
  switch (action.kind) {
  case MetaAction::Kind::ResetTransientRuntime:
    resetTransientRuntimeState();
    break;
  case MetaAction::Kind::ResetReplayRuntime:
    resetReplayRuntimeState();
    break;
  case MetaAction::Kind::BootstrapForLevel:
    bootstrapForLevel(action.obstacles, action.boardWidth, action.boardHeight);
    break;
  case MetaAction::Kind::RestorePersistedSession:
    restorePersistedSession(action.snapshot);
    break;
  case MetaAction::Kind::SeedPreviewState:
    seedPreviewState(action.previewSeed);
    break;
  case MetaAction::Kind::RestoreSnapshot:
    restoreSnapshot(action.snapshot);
    break;
  }
}

auto SessionCore::advanceSessionStep(const SessionAdvanceConfig& config,
                                     const std::function<int(int)>& randomBounded)
  -> SessionAdvanceResult {
  SessionAdvanceResult result;

  if (config.consumeInputQueue) {
    QPoint nextInput;
    if (consumeQueuedInput(nextInput)) {
      setDirection(nextInput);
      result.consumedInput = true;
      result.consumedDirection = nextInput;
    }
  }

  result.nextHead = headPosition() + direction();
  const auto collisionOutcome =
    checkCollision(result.nextHead, config.boardWidth, config.boardHeight);
  result.consumeShield = collisionOutcome.consumeShield;
  result.consumeLaser = collisionOutcome.consumeLaser;
  result.obstacleIndex = collisionOutcome.obstacleIndex;
  if (collisionOutcome.collision) {
    result.collision = true;
    return result;
  }

  result.grew = (result.nextHead == m_state.food);

  const auto foodResult =
    consumeFood(result.nextHead, config.boardWidth, config.boardHeight, randomBounded);
  result.ateFood = foodResult.ate;
  result.triggerChoice = foodResult.triggerChoice;
  result.spawnPowerUp = foodResult.spawnPowerUp;
  result.foodPan = foodResult.pan;
  if (result.triggerChoice && config.pauseOnChoiceTrigger) {
    return result;
  }

  const auto powerResult = consumePowerUp(result.nextHead, 40, true);
  result.atePowerUp = powerResult.ate;
  result.miniApplied = powerResult.miniApplied;
  result.slowMode = powerResult.slowMode;

  applyMovement(wrapPoint(result.nextHead, config.boardWidth, config.boardHeight), result.grew);
  result.appliedMovement = true;

  const auto magnetResult = applyMagnetAttraction(config.boardWidth, config.boardHeight);
  result.movedFood = magnetResult.moved;
  result.magnetAteFood = magnetResult.ate;
  if (magnetResult.ate) {
    const auto magnetFoodResult =
      consumeFood(headPosition(), config.boardWidth, config.boardHeight, randomBounded);
    result.triggerChoiceAfterMagnet = magnetFoodResult.triggerChoice;
    result.spawnPowerUpAfterMagnet = magnetFoodResult.spawnPowerUp;
    result.magnetFoodPan = magnetFoodResult.pan;
  }

  return result;
}

void SessionCore::bootstrapForLevel(QList<QPoint> obstacles,
                                    const int boardWidth,
                                    const int boardHeight) {
  m_state = {};
  m_state.direction = {0, -1};
  m_state.powerUpPos = QPoint(-1, -1);
  m_state.lastRoguelikeChoiceScore = -1000;
  m_state.obstacles = std::move(obstacles);
  m_body = buildSafeInitialSnakeBody(m_state.obstacles, boardWidth, boardHeight);
  m_inputQueue.clear();
}

void SessionCore::restorePersistedSession(const StateSnapshot& snapshot) {
  m_state = snapshot.state;
  m_body = snapshot.body;
  m_inputQueue.clear();

  const QPoint persistedDirection = m_state.direction;
  const QPoint persistedFood = m_state.food;
  const int persistedScore = m_state.score;
  const QList<QPoint> persistedObstacles = m_state.obstacles;

  resetTransientRuntimeState();
  resetReplayRuntimeState();

  m_state.direction = persistedDirection;
  m_state.food = persistedFood;
  m_state.score = persistedScore;
  m_state.obstacles = persistedObstacles;
}

void SessionCore::seedPreviewState(const PreviewSeed& seed) {
  m_state = {};
  m_state.food = seed.food;
  m_state.direction = seed.direction;
  m_state.powerUpPos = seed.powerUpPos;
  m_state.powerUpType = seed.powerUpType;
  m_state.powerUpTicksRemaining = seed.powerUpTicksRemaining;
  m_state.score = seed.score;
  m_state.obstacles = seed.obstacles;
  m_state.tickCounter = seed.tickCounter;
  m_state.activeBuff = seed.activeBuff;
  m_state.buffTicksRemaining = seed.buffTicksRemaining;
  m_state.buffTicksTotal = seed.buffTicksTotal;
  m_state.shieldActive = seed.shieldActive;
  m_state.lastRoguelikeChoiceScore = -1000;
  m_body = seed.body;
  m_inputQueue.clear();
}

void SessionCore::resetTransientRuntimeState() {
  m_state.direction = {0, -1};
  m_inputQueue.clear();
  m_state.activeBuff = 0;
  m_state.buffTicksRemaining = 0;
  m_state.buffTicksTotal = 0;
  m_state.shieldActive = false;
  m_state.powerUpPos = QPoint(-1, -1);
  m_state.powerUpType = 0;
  m_state.powerUpTicksRemaining = 0;
}

void SessionCore::resetReplayRuntimeState() {
  m_state.tickCounter = 0;
  m_state.lastRoguelikeChoiceScore = -1000;
}

auto SessionCore::snapshot(const std::deque<QPoint>& body) const -> StateSnapshot {
  return {
    .state = m_state,
    .body = body.empty() ? m_body : body,
  };
}

void SessionCore::restoreSnapshot(const StateSnapshot& snapshot) {
  m_state = snapshot.state;
  m_body = snapshot.body;
  m_inputQueue.clear();
}

void SessionCore::applyPowerUpResult(const PowerUpConsumptionResult& result) {
  if (result.shieldActivated) {
    m_state.shieldActive = true;
  }
  if (result.miniApplied) {
    m_body = applyMiniShrink(m_body, 3);
  }
  m_state.activeBuff = result.activeBuffAfter;
  m_state.buffTicksRemaining = result.buffTicksRemaining;
  m_state.buffTicksTotal = result.buffTicksTotal;
}

auto SessionCore::tickPowerUpCountdown() -> bool {
  if (m_state.powerUpPos == QPoint(-1, -1) || m_state.powerUpTicksRemaining <= 0) {
    return false;
  }
  m_state.powerUpTicksRemaining -= 1;
  if (m_state.powerUpTicksRemaining > 0) {
    return false;
  }
  m_state.powerUpPos = QPoint(-1, -1);
  m_state.powerUpType = 0;
  return true;
}

auto SessionCore::isOccupied(const QPoint& point) const -> bool {
  const bool inSnake =
    std::ranges::any_of(m_body, [&point](const QPoint& bodyPoint) { return bodyPoint == point; });
  if (inSnake) {
    return true;
  }
  return std::ranges::any_of(
    m_state.obstacles, [&point](const QPoint& obstaclePoint) { return obstaclePoint == point; });
}

} // namespace nenoserpent::core
