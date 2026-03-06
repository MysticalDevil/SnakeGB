.pragma library

function isMatch(id, needle) {
    return id && id.indexOf(needle) !== -1
}

function draw(ctx, w, h, achievementId, color) {
    ctx.clearRect(0, 0, w, h)
    ctx.lineWidth = Math.max(1, Math.floor(Math.min(w, h) * 0.10))
    ctx.strokeStyle = color
    ctx.fillStyle = color

    if (isMatch(achievementId, "Gold Medal")) {
        ctx.beginPath()
        ctx.arc(w * 0.50, h * 0.44, w * 0.18, 0, Math.PI * 2)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.42, h * 0.58)
        ctx.lineTo(w * 0.34, h * 0.82)
        ctx.lineTo(w * 0.48, h * 0.72)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.58, h * 0.58)
        ctx.lineTo(w * 0.66, h * 0.82)
        ctx.lineTo(w * 0.52, h * 0.72)
        ctx.stroke()
        return
    }

    if (isMatch(achievementId, "Silver Medal")) {
        ctx.beginPath()
        ctx.arc(w * 0.50, h * 0.48, w * 0.18, 0, Math.PI * 2)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.50, h * 0.20)
        ctx.lineTo(w * 0.50, h * 0.34)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.40, h * 0.24)
        ctx.lineTo(w * 0.60, h * 0.24)
        ctx.stroke()
        return
    }

    if (isMatch(achievementId, "Centurion")) {
        ctx.beginPath()
        ctx.moveTo(w * 0.24, h * 0.32)
        ctx.lineTo(w * 0.76, h * 0.32)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.32, h * 0.24)
        ctx.lineTo(w * 0.32, h * 0.76)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.42, h * 0.24)
        ctx.lineTo(w * 0.42, h * 0.76)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.52, h * 0.24)
        ctx.lineTo(w * 0.52, h * 0.76)
        ctx.stroke()
        return
    }

    if (isMatch(achievementId, "Gourmet")) {
        ctx.beginPath()
        ctx.arc(w * 0.48, h * 0.42, w * 0.18, 0, Math.PI * 2)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.48, h * 0.60)
        ctx.lineTo(w * 0.48, h * 0.82)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.60, h * 0.24)
        ctx.lineTo(w * 0.74, h * 0.38)
        ctx.stroke()
        return
    }

    if (isMatch(achievementId, "Untouchable")) {
        ctx.strokeRect(w * 0.24, h * 0.28, w * 0.52, h * 0.44)
        ctx.clearRect(w * 0.44, h * 0.34, w * 0.12, h * 0.30)
        return
    }

    if (isMatch(achievementId, "Speed Demon")) {
        ctx.beginPath()
        ctx.moveTo(w * 0.30, h * 0.20)
        ctx.lineTo(w * 0.56, h * 0.20)
        ctx.lineTo(w * 0.44, h * 0.48)
        ctx.lineTo(w * 0.68, h * 0.48)
        ctx.lineTo(w * 0.34, h * 0.82)
        ctx.lineTo(w * 0.46, h * 0.56)
        ctx.lineTo(w * 0.28, h * 0.56)
        ctx.closePath()
        ctx.fill()
        return
    }

    if (isMatch(achievementId, "Pacifist")) {
        ctx.beginPath()
        ctx.arc(w * 0.46, h * 0.48, w * 0.16, Math.PI * 0.20, Math.PI * 1.70)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.42, h * 0.60)
        ctx.lineTo(w * 0.62, h * 0.34)
        ctx.stroke()
        return
    }

    ctx.beginPath()
    ctx.arc(w * 0.50, h * 0.50, w * 0.18, 0, Math.PI * 2)
    ctx.stroke()
}
