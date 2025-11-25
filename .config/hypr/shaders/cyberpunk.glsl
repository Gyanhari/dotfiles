#version 300 es
precision mediump float;
#pragma shader_stage fragment

uniform float u_timer;          // Hyprland auto-provides this
uniform sampler2D screen_texture; // needed for re-sampling in 300 es

out vec4 frag_color;

// This exact function name + signature is what Hyprland expects in 300 es
vec4 hook();

vec4 hook() {
    vec4 col = texture(screen_texture, gl_FragCoord.xy / vec2(1920.0, 1080.0));

    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);

    // 1. Soft moving scanlines
    float scan = fract(uv.y * 700.0 - u_timer * 42.0);
    col.rgb -= smoothstep(0.0, 0.4, scan) * 0.05;

    // 2. Subtle edge-only chromatic aberration
    float edge = length(uv - 0.5);
    col.r = texture(screen_texture, uv + vec2( edge * 0.0008, 0.0)).r;
    col.b = texture(screen_texture, uv - vec2( edge * 0.0008, 0.0)).b;

    // 3. Neon glow on bright parts (makes your rainbow border bleed)
    float bright = dot(col.rgb, vec3(0.33));
    col.rgb += smoothstep(0.85, 1.0, bright) * vec3(0.8, 0.2, 1.2) * 0.22;

    // 4. Tiny flicker
    col.rgb *= 0.996 + 0.004 * sin(u_timer * 160.0);

    return col;
}

void main() {
    frag_color = hook();
}
