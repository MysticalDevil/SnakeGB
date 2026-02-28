#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float reflectionX;
    float reflectionY;
    float lumaBoost;
    float ghostMix;
    float scanlineStrength;
    float gridStrength;
    float vignetteStrength;
};

layout(binding = 1) uniform sampler2D source;
layout(binding = 2) uniform sampler2D history;

void main() {
    // 1. Subtle Curvature
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

    // 3. Balanced LCD Ghosting
    vec4 historyTex = texture(history, uv);
    vec4 tex = mix(currentTex, historyTex, ghostMix);
    
    // 4. Scanline & Grid
    float scanline = 1.0 - scanlineStrength + scanlineStrength * sin(uv.y * 216.0 * 3.14159 * 2.0);
    vec2 gridUV = fract(uv * vec2(240.0, 216.0));
    float grid = step(0.05, gridUV.x) * step(0.05, gridUV.y) * gridStrength + (1.0 - gridStrength);

    // 5. Handheld Breathing Simulation (Dynamic Glare)
    // We simulate the micro-shakes of a human holding a device.
    // Multiple sine waves at different frequencies create a non-repetitive look.
    vec2 breathingOffset = vec2(
        sin(time * 0.8) * 0.015 + cos(time * 1.3) * 0.008,
        cos(time * 0.7) * 0.015 + sin(time * 1.1) * 0.008
    );
    
    vec2 sensorOffset = vec2(reflectionX, reflectionY);
    vec2 lightPos = vec2(0.2, 0.2) + breathingOffset + sensorOffset;
    float reflection = 0.0;
    float distRef = length(uv - lightPos);
    reflection += smoothstep(0.5, 0.0, distRef) * 0.08;
    reflection += smoothstep(0.1, 0.0, distRef) * 0.05;

    // 6. Vignetting (Physical Light Loss)
    float vignette = smoothstep(1.2, 0.5, dist);
    vignette = mix(1.0 - vignetteStrength, 1.0, vignette);

    // 7. Final Composition
    vec3 finalRGB = tex.rgb * scanline * grid * vignette;
    finalRGB += vec3(reflection * 0.6, reflection * 0.7, reflection * 0.8);

    // Gamma correction
    finalRGB = pow(finalRGB, vec3(0.85)) * 1.05 * lumaBoost;

    fragColor = vec4(finalRGB, tex.a) * edgeMask * qt_Opacity;
}
