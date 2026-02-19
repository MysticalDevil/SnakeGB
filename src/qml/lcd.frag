#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time; 
};

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D history; 

void main() {
    // 1. Subtle Curvature (Balanced at 0.008)
    vec2 centeredUV = qt_TexCoord0 * 2.0 - 1.0;
    float dist = length(centeredUV);
    vec2 uv = qt_TexCoord0 + centeredUV * (dist * dist) * 0.008;
    
    float edgeMask = smoothstep(0.0, 0.015, uv.x) * 
                     smoothstep(1.0, 0.985, uv.x) * 
                     smoothstep(0.0, 0.015, uv.y) * 
                     smoothstep(1.0, 0.985, uv.y);

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // 2. Main Frame Sampling
    vec4 currentTex = texture(source, uv);

    // 3. Balanced LCD Ghosting (0.45 persistence)
    vec4 historyTex = texture(history, uv);
    vec4 tex = mix(currentTex, historyTex, 0.45);
    
    // 4. Subtle Scanline & Grid
    float scanline = 0.97 + 0.03 * sin(uv.y * 216.0 * 3.14159 * 2.0);
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * 0.08 + 0.92;

    // 5. Procedural Ambient Reflection (Glass Glare)
    // Simulate a soft window/light reflection from top-left
    float reflection = 0.0;
    // Main soft glare
    float distRef = length(uv - vec2(0.2, 0.2));
    reflection += smoothstep(0.5, 0.0, distRef) * 0.08;
    // Sharp specular highlight
    reflection += smoothstep(0.1, 0.0, distRef) * 0.05;

    // 6. Final Composition
    vec3 finalRGB = tex.rgb * scanline * grid;
    
    // Add reflection (Glass sits on top of pixels)
    finalRGB += vec3(reflection * 0.6, reflection * 0.7, reflection * 0.8); // Slight blue tint for glass

    // Gamma correction
    finalRGB = pow(finalRGB, vec3(0.85)) * 1.05;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
