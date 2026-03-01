#pragma once

#include <QtGlobal>

namespace nenoserpent::adapter::haptics {

class Controller final {
public:
  void trigger(int magnitude);

private:
  qint64 m_lastHapticMs = 0;
};

} // namespace nenoserpent::adapter::haptics
