.pragma library

function draw(ctx, w, h, type, accent) {
    ctx.clearRect(0, 0, w, h)
    ctx.lineWidth = Math.max(1, Math.floor(w * 0.12))
    ctx.strokeStyle = accent
    ctx.fillStyle = accent

    if (type === 1) {
        ctx.strokeRect(2, 2, w - 4, h - 4)
        ctx.clearRect(Math.floor(w * 0.42), Math.floor(h * 0.30), Math.floor(w * 0.16),
                      Math.floor(h * 0.44))
        return
    }

    if (type === 2) {
        ctx.beginPath()
        ctx.arc(w / 2, h / 2, w * 0.34, 0, Math.PI * 2)
        ctx.stroke()
        ctx.fillRect(w * 0.26, h * 0.46, w * 0.48, Math.max(1, h * 0.1))
        return
    }

    if (type === 3) {
        ctx.beginPath()
        ctx.moveTo(w * 0.25, h * 0.20)
        ctx.lineTo(w * 0.25, h * 0.70)
        ctx.quadraticCurveTo(w * 0.50, h * 0.92, w * 0.75, h * 0.70)
        ctx.lineTo(w * 0.75, h * 0.20)
        ctx.stroke()
        return
    }

    if (type === 4) {
        ctx.beginPath()
        ctx.moveTo(w * 0.50, h * 0.12)
        ctx.lineTo(w * 0.80, h * 0.28)
        ctx.lineTo(w * 0.72, h * 0.72)
        ctx.lineTo(w * 0.50, h * 0.90)
        ctx.lineTo(w * 0.28, h * 0.72)
        ctx.lineTo(w * 0.20, h * 0.28)
        ctx.closePath()
        ctx.stroke()
        return
    }

    if (type === 5) {
        ctx.beginPath()
        ctx.arc(w / 2, h / 2, w * 0.34, 0, Math.PI * 2)
        ctx.stroke()
        ctx.beginPath()
        ctx.arc(w * 0.68, h * 0.34, w * 0.08, 0, Math.PI * 2)
        ctx.fill()
        return
    }

    if (type === 6) {
        ctx.save()
        ctx.translate(w * 0.38, h * 0.52)
        ctx.rotate(Math.PI / 4)
        ctx.strokeRect(-w * 0.12, -h * 0.12, w * 0.24, h * 0.24)
        ctx.restore()
        ctx.save()
        ctx.translate(w * 0.62, h * 0.48)
        ctx.rotate(Math.PI / 4)
        ctx.strokeRect(-w * 0.12, -h * 0.12, w * 0.24, h * 0.24)
        ctx.restore()
        return
    }

    if (type === 7) {
        ctx.beginPath()
        ctx.moveTo(w * 0.26, h * 0.22)
        ctx.lineTo(w * 0.55, h * 0.22)
        ctx.lineTo(w * 0.42, h * 0.52)
        ctx.lineTo(w * 0.70, h * 0.52)
        ctx.lineTo(w * 0.34, h * 0.85)
        ctx.lineTo(w * 0.46, h * 0.60)
        ctx.lineTo(w * 0.24, h * 0.60)
        ctx.closePath()
        ctx.fill()
        return
    }

    if (type === 8) {
        ctx.strokeRect(w * 0.30, h * 0.30, w * 0.40, h * 0.40)
        ctx.fillRect(w * 0.16, h * 0.16, w * 0.10, 1)
        ctx.fillRect(w * 0.16, h * 0.16, 1, h * 0.10)
        ctx.fillRect(w * 0.74, h * 0.74, w * 0.10, 1)
        ctx.fillRect(w * 0.84, h * 0.74, 1, h * 0.10)
        return
    }

    if (type === 9) {
        ctx.beginPath()
        ctx.moveTo(w * 0.50, h * 0.10)
        ctx.lineTo(w * 0.60, h * 0.34)
        ctx.lineTo(w * 0.86, h * 0.38)
        ctx.lineTo(w * 0.66, h * 0.54)
        ctx.lineTo(w * 0.72, h * 0.84)
        ctx.lineTo(w * 0.50, h * 0.68)
        ctx.lineTo(w * 0.28, h * 0.84)
        ctx.lineTo(w * 0.34, h * 0.54)
        ctx.lineTo(w * 0.14, h * 0.38)
        ctx.lineTo(w * 0.40, h * 0.34)
        ctx.closePath()
        ctx.stroke()
        return
    }

    if (type === 10) {
        ctx.beginPath()
        ctx.moveTo(w * 0.18, h * 0.50)
        ctx.lineTo(w * 0.64, h * 0.50)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.52, h * 0.34)
        ctx.lineTo(w * 0.68, h * 0.50)
        ctx.lineTo(w * 0.52, h * 0.66)
        ctx.stroke()
        ctx.strokeRect(w * 0.16, h * 0.24, w * 0.18, h * 0.18)
        return
    }

    if (type === 11) {
        ctx.beginPath()
        ctx.arc(w * 0.52, h * 0.52, w * 0.22, Math.PI * 0.20, Math.PI * 1.85)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.30, h * 0.28)
        ctx.lineTo(w * 0.18, h * 0.18)
        ctx.lineTo(w * 0.20, h * 0.34)
        ctx.closePath()
        ctx.fill()
        return
    }

    if (type === 12) {
        ctx.beginPath()
        ctx.moveTo(w * 0.50, h * 0.16)
        ctx.lineTo(w * 0.50, h * 0.62)
        ctx.stroke()
        ctx.beginPath()
        ctx.arc(w * 0.50, h * 0.68, w * 0.20, 0, Math.PI)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.30, h * 0.68)
        ctx.lineTo(w * 0.18, h * 0.82)
        ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(w * 0.70, h * 0.68)
        ctx.lineTo(w * 0.82, h * 0.82)
        ctx.stroke()
    }
}
