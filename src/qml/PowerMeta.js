.pragma library

function buffName(type) {
  if (type === 1)
    return "GHOST"
    if (type === 2) return "SLOW"
    if (type === 3) return "MAGNET"
    if (type === 4) return "SHIELD"
    if (type === 5) return "PORTAL"
    if (type === 6) return "GOLD"
    if (type === 7) return "LASER"
    if (type === 8) return "MINI"
    if (type === 9) return "FREEZE"
    if (type === 10) return "SCOUT"
    if (type === 11) return "VACUUM"
    if (type === 12) return "ANCHOR"
    return "NONE"
}

function powerGlyph(type) {
  if (type === 1)
    return "G"
    if (type === 2) return "S"
    if (type === 3) return "M"
    if (type === 4) return "H"
    if (type === 5) return "P"
    if (type === 6) return "$"
    if (type === 7) return "L"
    if (type === 8) return "m"
    if (type === 9) return "F"
    if (type === 10) return "?"
    if (type === 11) return "V"
    if (type === 12) return "A"
    return "?"
}

function choiceGlyph(type) {
  if (type === 1)
    return "G"
    if (type === 2) return "S"
    if (type === 3) return "M"
    if (type === 4) return "H"
    if (type === 5) return "P"
    if (type === 6) return "2x"
    if (type === 7) return "L"
    if (type === 8) return "m"
    if (type === 9) return "F"
    if (type === 10) return "?"
    if (type === 11) return "V"
    if (type === 12) return "A"
    return "?"
}

function choiceName(type) {
  if (type === 1)
    return "Ghost"
    if (type === 2) return "Slow"
    if (type === 3) return "Magnet"
    if (type === 4) return "Shield"
    if (type === 5) return "Portal"
    if (type === 6) return "Gold"
    if (type === 7) return "Laser"
    if (type === 8) return "Mini"
    if (type === 9) return "Freeze"
    if (type === 10) return "Scout"
    if (type === 11) return "Vacuum"
    if (type === 12) return "Anchor"
    return "Unknown"
}

function choiceDescription(type) {
  if (type === 1)
    return "Pass through self"
    if (type === 2) return "Drop speed by 1 tier"
    if (type === 3) return "Attract food"
    if (type === 4) return "One extra life"
    if (type === 5) return "Phase through walls"
    if (type === 6) return "Double points"
    if (type === 7) return "Break obstacle"
    if (type === 8) return "Shrink body"
    if (type === 9) return "Freeze dynamic hazards"
    if (type === 10) return "Reveal safe next cell"
    if (type === 11) return "Pull nearby targets inward"
    if (type === 12) return "Lock current speed"
    return "Debug preview"
}

function choiceSpec(type) {
  return {
    type: type, name: choiceName(type), description: choiceDescription(type)
  }
}

function rarityTier(type) {
  if (type === 6 || type === 9)
    return 4
    if (type === 7 || type === 11 || type === 12) return 3
    if (type === 4 || type === 5 || type === 10) return 2
    return 1
}

function rarityName(type) {
  const tier = rarityTier(type)
  if (tier === 4) return "EPIC"
  if (tier === 3) return "RARE"
  if (tier === 2) return "UNCOMMON"
  return "COMMON"
}
