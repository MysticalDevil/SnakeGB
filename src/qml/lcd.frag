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
    // 1. Moderate barrel distortion (0.012 for a balanced CRT look)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.012;
    
    // 2. High-quality edge mask with rounded corners effect
    float edgeMask = smoothstep(0.0, 0.02, uv.x) * 
                     smoothstep(1.0, 0.98, uv.x) * 
                     smoothstep(0.0, 0.02, uv.y) * 
                     smoothstep(1.0, 0.98, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 3. Re-introducing Chromatic Aberration (The Rainbow effect)
    // Very tight shift (0.0015) for subtle color fringing on edges
    float r = texture(source, uv + vec2(0.0015, 0.0)).r;
    float g = texture(source, uv).g;
    float b = texture(source, uv - vec2(0.0015, 0.0)).b;
    vec4 tex = vec4(r, g, b, 1.0);
    
    // 4. Physically consistent scanlines (following the curve)
    float scanline = 0.94 + 0.06 * sin(uv.y * 216.0 * 3.14159 * 2.0 + time * 2.0);

    // 5. Subtle RGB subpixel mask
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.05, 0.95, 0.95);
    else if (m == 1) mask = vec3(0.95, 1.05, 0.95);
    else mask = vec3(0.95, 0.95, 1.05);

    // 6. Grid gap simulation
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.12 + 0.88;

    // 7. Vignette for depth
    vec2 vigUV = uv * (1.0 - uv.yx);
    float vignette = pow(vigUV.x * vigUV.y * 15.0, 0.15);

    // Final Composition
    vec3 finalRGB = tex.rgb * mask * scanline * grid * vignette;
    
    // Slight over-brightness boost to compensate for the mask
    finalRGB = pow(finalRGB, vec3(0.85)) * 1.15;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
