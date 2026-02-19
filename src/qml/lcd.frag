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
    // 1. 审美修正：极轻微的球面畸变 (0.005)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 distortedUV = qt_TexCoord0 + centeredUV * (dist * dist) * 0.005;
    
    // 边缘柔和裁剪
    float edgeMask = smoothstep(0.0, 0.01, distortedUV.x) * 
                     smoothstep(1.0, 0.99, distortedUV.x) * 
                     smoothstep(0.0, 0.01, distortedUV.y) * 
                     smoothstep(1.0, 0.99, distortedUV.y);

    vec4 tex = texture(source, distortedUV);
    
    // 2. 模拟 RGB 子像素掩模 (调淡强度)
    float pixelX = distortedUV.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.02, 0.98, 0.98);
    else if (m == 1) mask = vec3(0.98, 1.02, 0.98);
    else mask = vec3(0.98, 0.98, 1.02);

    // 3. 扫描线
    float scanline = sin(distortedUV.y * 216.0 * 3.14159 * 2.0) * 0.03 + 0.97;
    
    // 4. 像素网格
    vec2 gridUV = fract(distortedUV * vec2(240.0, 216.0));
    float grid = step(0.08, gridUV.x) * step(0.08, gridUV.y) * 0.1 + 0.9;

    // 合成
    vec3 finalRGB = tex.rgb * mask * scanline * grid;
    // 轻微亮度补正
    finalRGB *= 1.05;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
