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
    // 1. 适当的球面畸变 (物理基础坐标)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    // 0.01 是一个既能看出弧度又不会干扰辨识的黄金比例
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.01;
    
    // 软边缘处理
    float edgeMask = smoothstep(0.0, 0.005, uv.x) * 
                     smoothstep(1.0, 0.995, uv.x) * 
                     smoothstep(0.0, 0.005, uv.y) * 
                     smoothstep(1.0, 0.995, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 2. 采样（基于畸变坐标）
    vec4 tex = texture(source, uv);
    
    // 3. 物理同步扫描线 (跟随坐标弯曲)
    float scanline = 0.96 + 0.04 * step(0.5, fract(uv.y * 216.0));

    // 4. 物理同步 RGB 掩模 (跟随坐标弯曲)
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.02, 0.98, 0.98);
    else if (m == 1) mask = vec3(0.98, 1.02, 0.98);
    else mask = vec3(0.98, 0.98, 1.02);

    // 5. 物理同步像素网格 (跟随坐标弯曲)
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.1 + 0.9;

    // 6. 合成颜色
    vec3 finalRGB = tex.rgb * mask * scanline * grid;
    // 增加微弱的亮度呼吸感
    float flicker = 1.0 + sin(time * 8.0) * 0.003;
    finalRGB *= (1.05 * flicker);

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
