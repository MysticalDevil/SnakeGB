#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 tex = texture(source, qt_TexCoord0);
    
    // 模拟 240x216 的像素网格
    vec2 ps = qt_TexCoord0 * vec2(240.0, 216.0) * 2.0;
    float grid = (sin(ps.x * 3.14159) * 0.5 + 0.5) * (sin(ps.y * 3.14159) * 0.5 + 0.5);
    
    fragColor = tex * (0.85 + 0.15 * grid) * qt_Opacity;
}
