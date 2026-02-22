#include "buff_runtime.h"

#include <algorithm>
#include <array>
#include <utility>

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

auto weightedRandomBuffId(const std::function<int(int)> &pickBounded) -> BuffId {
    // Lower Mini probability while keeping other fruits reasonably common.
    static constexpr std::array<std::pair<BuffId, int>, 9> weightedTable{{
        {BuffId::Ghost, 3},
        {BuffId::Slow, 3},
        {BuffId::Magnet, 3},
        {BuffId::Shield, 3},
        {BuffId::Portal, 3},
        {BuffId::Double, 3},
        {BuffId::Rich, 2},
        {BuffId::Laser, 2},
        {BuffId::Mini, 1},
    }};

    int totalWeight = 0;
    for (const auto &item : weightedTable) {
        totalWeight += item.second;
    }
    int pick = pickBounded(totalWeight);
    for (const auto &item : weightedTable) {
        if (pick < item.second) {
            return item.first;
        }
        pick -= item.second;
    }
    return BuffId::Ghost;
}

auto tickBuffCountdown(int &remainingTicks) -> bool
{
    if (remainingTicks <= 0) {
        return false;
    }
    remainingTicks -= 1;
    return remainingTicks <= 0;
}

} // namespace snakegb::core
