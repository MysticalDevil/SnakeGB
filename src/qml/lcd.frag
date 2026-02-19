#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    // 模拟色差 (Chromatic Aberration)
    vec2 shift = vec2(0.002, 0.0);
    float r = texture(source, qt_TexCoord0 - shift).r;
    float g = texture(source, qt_TexCoord0).g;
    float b = texture(source, qt_TexCoord0 + shift).b;
    vec4 tex = vec4(r, g, b, 1.0);
    
    // 模拟像素网格 (Pixel Grid)
    vec2 ps = qt_TexCoord0 * vec2(240.0, 216.0) * 2.0;
    float gridX = abs(sin(ps.x * 3.14159));
    float gridY = abs(sin(ps.y * 3.14159));
    float grid = clamp(gridX * gridY + 0.2, 0.0, 1.0);
    
    // 模拟暗角 (Vignette)
    vec2 uv = qt_TexCoord0 * (1.0 - qt_TexCoord0.yx);
    float vig = uv.x * uv.y * 15.0;
    vig = pow(vig, 0.15);

    fragColor = tex * grid * vig * qt_Opacity;
}
