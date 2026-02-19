#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time; // 从 QML 传入的动态时间
};

layout(binding = 1) uniform sampler2D source;

void main() {
    // 1. 球面畸变
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 distortedUV = qt_TexCoord0 + centeredUV * (dist * dist) * 0.02;
    
    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 tex = texture(source, distortedUV);
    
    // 2. 模拟 RGB 子像素掩模
    float pixelX = distortedUV.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.05, 0.9, 0.9);
    else if (m == 1) mask = vec3(0.9, 1.05, 0.9);
    else mask = vec3(0.9, 0.9, 1.05);

    // 3. 增强扫描线 + 微弱的亮度波动 (模拟旧式屏幕供电不稳)
    float flicker = 1.0 + sin(time * 10.0) * 0.005;
    float scanline = sin(distortedUV.y * 216.0 * 3.14159 * 2.0) * 0.04 + 0.96;
    
    // 4. 模拟 LCD 像素缝隙
    vec2 gridUV = fract(distortedUV * vec2(240.0, 216.0));
    float grid = step(0.1, gridUV.x) * step(0.1, gridUV.y) * 0.15 + 0.85;

    // 合成颜色
    vec3 finalRGB = tex.rgb * mask * scanline * grid * flicker;
    finalRGB = pow(finalRGB, vec3(0.9)) * 1.05;

    fragColor = vec4(finalRGB, tex.a) * qt_Opacity;
}
