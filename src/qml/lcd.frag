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
    // 1. Subtle barrel distortion (0.003 is very organic and unobtrusive)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.003;
    
    // 2. High-quality edge masking with smooth transition
    // Increased range for a softer, more professional look
    float edgeMask = smoothstep(0.0, 0.015, uv.x) * 
                     smoothstep(1.0, 0.985, uv.x) * 
                     smoothstep(0.0, 0.015, uv.y) * 
                     smoothstep(1.0, 0.985, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 tex = texture(source, uv);
    
    // 3. Subtle scanlines (perfectly horizontal, but mapped to distorted UV)
    float scanline = 0.97 + 0.03 * step(0.5, fract(uv.y * 216.0));

    // 4. Subtle RGB subpixel mask (Aperture Grille simulation)
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.01, 0.99, 0.99);
    else if (m == 1) mask = vec3(0.99, 1.01, 0.99);
    else mask = vec3(0.99, 0.99, 1.01);

    // 5. Pixel grid gap simulation
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.08 + 0.92;

    // 6. Color composition
    vec3 finalRGB = tex.rgb * mask * scanline * grid;
    
    // Slight brightness flicker for analog feel
    float flicker = 1.0 + sin(time * 6.0) * 0.002;
    finalRGB *= (1.04 * flicker);

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
