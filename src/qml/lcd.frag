#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time; 
};

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D history; // Previous frame feedback

void main() {
    // 1. CRT Physical Curvature
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

    // 2. Sample Current Frame with Chromatic Aberration
    float r = texture(source, uv + vec2(0.001, 0.0)).r;
    float g = texture(source, uv).g;
    float b = texture(source, uv - vec2(0.001, 0.0)).b;
    vec4 currentTex = vec4(r, g, b, 1.0);

    // 3. LCD Ghosting (Motion Blur)
    // Sample history and blend with current frame
    // Persistence factor of 0.4 creates a distinct retro drag
    vec4 historyTex = texture(history, uv);
    vec4 tex = mix(currentTex, historyTex, 0.4);
    
    // 4. Dynamic Curved Scanlines
    float scanline = 0.95 + 0.05 * sin(uv.y * 216.0 * 3.14159 * 2.0 + time * 3.0);

    // 5. Subtle RGB subpixel mask
    float pixelX = uv.x * 240.0 * 3.0;
    vec3 mask = vec3(1.0);
    int m = int(mod(pixelX, 3.0));
    if (m == 0) mask = vec3(1.03, 0.97, 0.97);
    else if (m == 1) mask = vec3(0.97, 1.03, 0.97);
    else mask = vec3(0.97, 0.97, 1.03);

    // 6. Pixel Grid Gap
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.1 + 0.9;

    // 7. Overall Composition
    vec3 finalRGB = tex.rgb * mask * scanline * grid;
    finalRGB = pow(finalRGB, vec3(0.85)) * 1.1;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
