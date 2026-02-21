#include "buff_runtime.h"

#include <algorithm>

namespace snakegb::core {

auto foodPointsForBuff(BuffId activeBuff) -> int {
    if (activeBuff == BuffId::Double) {
        return 2;
    }
    if (activeBuff == BuffId::Rich) {
        return 3;
    }
    return 1;
}

auto buffDurationTicks(BuffId acquiredBuff, int baseDurationTicks) -> int {
    if (acquiredBuff == BuffId::Rich) {
        return baseDurationTicks / 2;
    }
    return baseDurationTicks;
}

auto miniShrinkTargetLength(std::size_t currentLength, std::size_t minimumLength) -> std::size_t {
    return std::max(minimumLength, currentLength / 2);
}

} // namespace snakegb::core
