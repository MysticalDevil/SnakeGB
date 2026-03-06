.pragma library

function draw(ctx, w, h, palette) {
    ctx.clearRect(0, 0, w, h)

    const px = Math.max(1, Math.floor(Math.min(w, h) / 10))
    const stroke = Math.max(1, px)

    ctx.strokeStyle = palette.stroke
    ctx.lineWidth = stroke

    ctx.fillStyle = palette.core
    ctx.fillRect(w * 0.22, h * 0.32, w * 0.56, h * 0.48)
    ctx.fillRect(w * 0.14, h * 0.42, w * 0.16, h * 0.24)
    ctx.fillRect(w * 0.70, h * 0.42, w * 0.16, h * 0.24)
    ctx.fillRect(w * 0.30, h * 0.24, w * 0.12, h * 0.10)
    ctx.fillRect(w * 0.58, h * 0.24, w * 0.12, h * 0.10)

    ctx.strokeRect(w * 0.22, h * 0.32, w * 0.56, h * 0.48)
    ctx.strokeRect(w * 0.14, h * 0.42, w * 0.16, h * 0.24)
    ctx.strokeRect(w * 0.70, h * 0.42, w * 0.16, h * 0.24)

    ctx.fillStyle = palette.highlight
    ctx.fillRect(w * 0.28, h * 0.40, w * 0.18, h * 0.14)
    ctx.fillRect(w * 0.54, h * 0.38, w * 0.14, h * 0.12)

    ctx.fillStyle = palette.stem
    ctx.fillRect(w * 0.48, h * 0.10, Math.max(1, w * 0.10), Math.max(2, h * 0.18))
    ctx.fillRect(w * 0.58, h * 0.14, Math.max(1, w * 0.14), Math.max(1, h * 0.08))

    ctx.fillStyle = palette.spark
    ctx.fillRect(w * 0.22, h * 0.70, Math.max(1, px), Math.max(1, px))
    ctx.fillRect(w * 0.74, h * 0.68, Math.max(1, px), Math.max(1, px))
}
