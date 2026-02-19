#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time; 
};

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D history; // Feedback buffer

void main() {
    // 1. Physical Curvature
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.01;
    
    float edgeMask = smoothstep(0.0, 0.02, uv.x) * 
                     smoothstep(1.0, 0.98, uv.x) * 
                     smoothstep(0.0, 0.02, uv.y) * 
                     smoothstep(1.0, 0.98, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 2. Sample Current Frame with subtle Chromatic Aberration
    float r = texture(source, uv + vec2(0.0008, 0.0)).r;
    float g = texture(source, uv).g;
    float b = texture(source, uv - vec2(0.0008, 0.0)).b;
    vec4 currentTex = vec4(r, g, b, 1.0);

    // 3. Heavy LCD Ghosting (Motion Drag)
    // 0.7 persistence creates a very strong, authentic retro smear
    vec4 historyTex = texture(history, uv);
    // Ghosting should only affect the "ink" (darker parts) for realism
    vec4 tex = mix(currentTex, historyTex, 0.7);
    
    // 4. Subtle Scanlines
    float scanline = 0.96 + 0.04 * sin(uv.y * 216.0 * 3.14159 * 2.0);

    // 5. RGB subpixel mask
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.02, 0.98, 0.98);
    else if (m == 1) mask = vec3(0.98, 1.02, 0.98);
    else mask = vec3(0.98, 0.98, 1.02);

    // 6. Composition
    vec3 finalRGB = tex.rgb * mask * scanline;
    finalRGB = pow(finalRGB, vec3(0.85)) * 1.1;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
