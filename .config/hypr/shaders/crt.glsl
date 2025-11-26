#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D screen_texture; 

out vec4 frag_color;

// Function to generate pseudo-random noise
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// Hyprland Hook Function
vec4 hook() {
    // NOTE: Replace 1920.0, 1080.0 with your actual screen resolution if needed
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec4 col;

    // =============================
    // Curvature (based on the provided logic)
    // =============================
    vec2 crt_uv = uv * 2.0 - 1.0;
    float r = dot(crt_uv, crt_uv);
    crt_uv *= 1.0 + 0.15 * r;    // adjust curvature
    crt_uv = crt_uv * 0.5 + 0.5;

    // If outside bounds, darken
    if (crt_uv.x < 0.0 || crt_uv.x > 1.0 || crt_uv.y < 0.0 || crt_uv.y > 1.0) {
        return vec4(0.02, 0.02, 0.04, 1.0);
    }
    
    // =============================
    // RGB subpixel bleed
    // =============================
    float offset = 0.002;
    float rChan = texture(screen_texture, crt_uv + vec2(offset, 0.0)).r;
    float gChan = texture(screen_texture, crt_uv).g;
    float bChan = texture(screen_texture, crt_uv - vec2(offset, 0.0)).b;
    vec3 color = vec3(rChan, gChan, bChan);

    // =============================
    // Scanlines (horizontal)
    // =============================
    float scan = 0.9 + 0.1 * sin(crt_uv.y * 2400.0);
    color *= scan;

    // =============================
    // Noise
    // =============================
    float noise = (rand(crt_uv * 500.0) - 0.5) * 0.04;
    color += noise;

    // =============================
    // Vignette
    // =============================
    float vig = smoothstep(1.2, 0.6, r);
    color *= vig;

    // Cyberpunk tint
    color *= vec3(0.95, 1.0, 1.05);

    col = vec4(color, 1.0);
    return col;
}

void main() {
    frag_color = hook();
}
