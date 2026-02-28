#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 texelStep;
    float blurScale;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 step = texelStep * blurScale;
    vec4 tex = texture(source, qt_TexCoord0) * 0.18;

    tex += texture(source, qt_TexCoord0 + vec2(step.x, 0.0)) * 0.12;
    tex += texture(source, qt_TexCoord0 - vec2(step.x, 0.0)) * 0.12;
    tex += texture(source, qt_TexCoord0 + vec2(0.0, step.y)) * 0.12;
    tex += texture(source, qt_TexCoord0 - vec2(0.0, step.y)) * 0.12;

    tex += texture(source, qt_TexCoord0 + vec2(step.x * 2.0, 0.0)) * 0.05;
    tex += texture(source, qt_TexCoord0 - vec2(step.x * 2.0, 0.0)) * 0.05;
    tex += texture(source, qt_TexCoord0 + vec2(0.0, step.y * 2.0)) * 0.05;
    tex += texture(source, qt_TexCoord0 - vec2(0.0, step.y * 2.0)) * 0.05;

    tex += texture(source, qt_TexCoord0 + vec2(step.x, step.y)) * 0.035;
    tex += texture(source, qt_TexCoord0 + vec2(step.x, -step.y)) * 0.035;
    tex += texture(source, qt_TexCoord0 + vec2(-step.x, step.y)) * 0.035;
    tex += texture(source, qt_TexCoord0 - vec2(step.x, step.y)) * 0.035;

    fragColor = tex * qt_Opacity;
}
