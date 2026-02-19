#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time; 
};

layout(binding = 1) uniform sampler2D source;

void main() {
    // 1. 坐标系完全扁平化（移除球面畸变以获得绝对直线）
    vec2 uv = qt_TexCoord0;
    
    // 2. 采样原始纹理
    vec4 tex = texture(source, uv);
    
    // 3. 模拟直线扫描线 (Scanlines)
    // 使用简单的 floor 或 mod 确保线是笔直的
    float scanlineY = uv.y * 216.0;
    float scanline = 0.95 + 0.05 * step(0.5, fract(scanlineY));

    // 4. 模拟垂直像素掩模 (RGB Mask)
    // 同样使用笔直的垂直线
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.03, 0.97, 0.97);
    else if (m == 1) mask = vec3(0.97, 1.03, 0.97);
    else mask = vec3(0.97, 0.97, 1.03);

    // 5. 模拟像素网格 (Grid)
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    // 锐利的网格边缘，不带任何波动
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.1 + 0.9;

    // 合成颜色
    vec3 finalRGB = tex.rgb * mask * scanline * grid;
    
    // 最终亮度微调
    finalRGB *= 1.05;

    fragColor = vec4(finalRGB, tex.a) * qt_Opacity;
}
