#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D u_texture;

out vec4 frag_color;

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec4 col = texture(u_texture, uv);

    // ── Very soft drifting scanlines (barely visible) ─────
    float scan = fract(uv.y * 900.0 - u_timer * 38.0);
    col.rgb -= smoothstep(0.0, 0.35, scan) * 0.035;   // reduced from 0.05

    // ── Ultra-faint CRT grid (optional soul) ─────────────
    float grid = fract(uv.y * 1080.0 * 3.6 + u_timer * 6.0);
    col.rgb -= smoothstep(0.0, 0.15, grid) * 0.006;   // reduced from 0.009

    // ── EXTREMELY subtle edge CA (only noticeable on very bright borders) ─────
    vec2 q = uv - 0.5;
    float ca_dist = length(q);
    float ca = ca_dist * 0.004;                       // reduced ×3 (was 0.012)
    col.r = texture(u_texture, uv + q * ca * 0.7).r;
    col.b = texture(u_texture, uv - q * ca * 1.0).b;

    // ── Gentle neon bloom (still pops on your rainbow borders) ─────
    float bright = dot(col.rgb, vec3(0.33));
    float bloom = smoothstep(0.85, 1.0, bright);      // threshold a bit higher
    col.rgb += bloom * bloom * vec3(0.85, 0.2, 1.3) * 0.26;  // reduced from 0.38

    // ── Soft vignette (no hard darkening at corners) ─────
    vec2 crt = uv * 2.0 - 1.0;
    crt *= 1.0 + 0.008 * dot(crt, crt);                // barely any curvature
    float vignette = 1.0 - length(crt) * 0.18;        // reduced from 0.34
    col.rgb *= vignette * 0.97 + 0.03;                // almost flat

    // ── Tiny flicker (feels alive but never annoying) ─────
    col.rgb *= 0.997 + 0.003 * sin(u_timer * 150.0);

    // ── Final light grade ───────────────────────────────
    col.rgb = pow(col.rgb, vec3(0.97));

    frag_color = col;
}
