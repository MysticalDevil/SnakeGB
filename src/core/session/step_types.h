#pragma once

#include <QPoint>

namespace nenoserpent::core {

struct SessionAdvanceConfig {
  int boardWidth = 20;
  int boardHeight = 18;
  bool consumeInputQueue = true;
  bool pauseOnChoiceTrigger = true;
};

struct SessionAdvanceResult {
  bool consumedInput = false;
  QPoint consumedDirection = {0, 0};
  QPoint nextHead = {0, 0};
  bool collision = false;
  bool consumeShield = false;
  bool consumeLaser = false;
  int obstacleIndex = -1;
  bool grew = false;
  bool ateFood = false;
  bool triggerChoice = false;
  bool spawnPowerUp = false;
  float foodPan = 0.0F;
  bool atePowerUp = false;
  bool miniApplied = false;
  bool slowMode = false;
  bool appliedMovement = false;
  bool movedFood = false;
  bool magnetAteFood = false;
  bool triggerChoiceAfterMagnet = false;
  bool spawnPowerUpAfterMagnet = false;
  float magnetFoodPan = 0.0F;
};

} // namespace nenoserpent::core
