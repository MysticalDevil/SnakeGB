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
    // 1. Subtle distortion
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.003;
    
    float edgeMask = smoothstep(0.0, 0.015, uv.x) * 
                     smoothstep(1.0, 0.985, uv.x) * 
                     smoothstep(0.0, 0.015, uv.y) * 
                     smoothstep(1.0, 0.985, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 tex = texture(source, uv);
    
    // 2. Soft LCD pixel structure
    float pixelX = uv.x * 240.0;
    float pixelY = uv.y * 216.0;
    
    // Dim the gaps between pixels by 15%
    float grid = (0.85 + 0.15 * step(0.1, fract(pixelX))) * 
                 (0.85 + 0.15 * step(0.1, fract(pixelY)));

    // 3. Subtle scanline effect
    float scanline = 0.98 + 0.02 * sin(uv.y * 216.0 * 3.14159 * 2.0);

    // 4. Brightness compensation: ensures background color (p0) is well-rendered
    vec3 finalRGB = tex.rgb * grid * scanline;
    
    // Boost brightness slightly
    finalRGB = pow(finalRGB, vec3(0.85));

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
