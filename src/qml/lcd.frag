#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    // 1. 极轻微的球面畸变
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 distortedUV = qt_TexCoord0 + centeredUV * (dist * dist) * 0.02;
    
    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 2. 采样
    vec4 tex = texture(source, distortedUV);
    
    // 3. 修正像素网格：使缝隙变暗 (0.85)，像素主体保持原色
    vec2 ps = distortedUV * vec2(240.0, 216.0);
    float grid = (0.85 + 0.15 * step(0.1, fract(ps.x))) * (0.85 + 0.15 * step(0.1, fract(ps.y)));
    
    // 4. 增强对比度
    vec4 finalColor = tex * grid;
    // 调亮
    finalColor.rgb = pow(finalColor.rgb, vec3(0.9)); 

    fragColor = finalColor * qt_Opacity;
}
