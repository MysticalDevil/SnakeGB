#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    // 1. 极轻微的球面畸变 (减小系数从 0.05 -> 0.02)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 distortedUV = qt_TexCoord0 + centeredUV * (dist * dist) * 0.02;
    
    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 2. 采样（移除色差以提升清晰度）
    vec4 tex = texture(source, distortedUV);
    
    // 3. 优化像素网格：使其不再模糊整体画面，仅在像素边缘留出微小的缝隙
    vec2 ps = distortedUV * vec2(240.0, 216.0);
    // 使用 step 函数产生锐利的网格边缘
    float grid = (0.9 + 0.1 * step(0.1, fract(ps.x))) * (0.9 + 0.1 * step(0.1, fract(ps.y)));
    
    // 4. 全局增益：调亮画面
    vec4 finalColor = tex * grid;
    finalColor.rgb *= 1.1; 

    fragColor = finalColor * qt_Opacity;
}
