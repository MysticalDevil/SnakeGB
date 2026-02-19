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
    // 1. CRT Physical Curvature (Subtle 0.01 for that tube feel)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.01;
    
    // Smooth high-quality edge vignette/mask
    float edgeMask = smoothstep(0.0, 0.02, uv.x) * 
                     smoothstep(1.0, 0.98, uv.x) * 
                     smoothstep(0.0, 0.02, uv.y) * 
                     smoothstep(1.0, 0.98, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 2. Chromatic Aberration (The Rainbow Edge)
    // Very tight shift (0.001) for artistic glow without losing clarity
    float r = texture(source, uv + vec2(0.001, 0.0)).r;
    float g = texture(source, uv).g;
    float b = texture(source, uv - vec2(0.001, 0.0)).b;
    vec4 tex = vec4(r, g, b, 1.0);
    
    // 3. Dynamic Curved Scanlines
    float scanline = 0.95 + 0.05 * sin(uv.y * 216.0 * 3.14159 * 2.0 + time * 3.0);

    // 4. Subtle RGB subpixel mask (Aperture Grille)
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.03, 0.97, 0.97);
    else if (m == 1) mask = vec3(0.97, 1.03, 0.97);
    else mask = vec3(0.97, 0.97, 1.03);

    // 5. Pixel Grid Gap (Mapped to curved UV)
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.1 + 0.9;

    // 6. Overall Composition & Brightness Correction
    vec3 finalRGB = tex.rgb * mask * scanline * grid;
    
    // Boost brightness to maintain visibility with the CRT effects
    finalRGB = pow(finalRGB, vec3(0.85)) * 1.1;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
