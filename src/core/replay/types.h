#pragma once

#include <QDataStream>

struct ReplayFrame {
  int frame = 0;
  int dx = 0;
  int dy = 0;

  friend auto operator<<(QDataStream& out, const ReplayFrame& value) -> QDataStream& {
    return out << value.frame << value.dx << value.dy;
  }
  friend auto operator>>(QDataStream& in, ReplayFrame& value) -> QDataStream& {
    return in >> value.frame >> value.dx >> value.dy;
  }
};

struct ChoiceRecord {
  int frame = 0;
  int index = 0;

  friend auto operator<<(QDataStream& out, const ChoiceRecord& value) -> QDataStream& {
    return out << value.frame << value.index;
  }
  friend auto operator>>(QDataStream& in, ChoiceRecord& value) -> QDataStream& {
    return in >> value.frame >> value.index;
  }
};
