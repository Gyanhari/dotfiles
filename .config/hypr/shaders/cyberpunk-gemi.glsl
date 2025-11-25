#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D u_texture;

out vec4 frag_color;

// Function to generate pseudo-random noise
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec4 col = texture(u_texture, uv);

    // ── Center Mask Calculation ──────────────────────────
    // q is the UV coordinate centered at (0, 0) and ranging from -0.5 to 0.5
    vec2 q = uv - 0.5;
    float dist = length(q);
    
    // Mask that is 1.0 (full effect) in the center and smoothly fades to 0.0 near the border (dist ≈ 0.5)
    float center_mask = 1.0 - smoothstep(0.35, 0.48, dist); 
    // We will multiply effects by this mask

    // ── Ultra-Faint, Green/Blue scanlines (Subtle background noise) ─────
    float scanline_y = fract(uv.y * 700.0 + u_timer * 8.0);
    float scanline_effect = smoothstep(0.0, 0.4, scanline_y) * 0.04; 
    
    // Apply the center mask here
    col.rgb -= scanline_effect * vec3(0.05, 0.15, 0.1) * center_mask; 

    // ── Low-Resolution Digital Grid (Subtle overlay) ─────────────
    float grid_x = fract(uv.x * 40.0);
    float grid_y = fract(uv.y * 25.0);
    float grid_alpha = smoothstep(0.0, 0.08, grid_x) * smoothstep(0.0, 0.08, grid_y) * 0.02;
    
    // Apply the center mask here
    col.rgb -= grid_alpha * vec3(0.1, 0.1, 0.2) * center_mask; 

    // ── Focused Chromatic Aberration (Fades out quickly at edges) ─────
    // CA strength is naturally based on distance, but we reduce it further here.
    float ca_strength = dist * 0.008 * center_mask * 1.5; // Multiply by mask

    // Sample channels with a tight, stylized separation
    col.r = texture(u_texture, uv + q * ca_strength * 0.8).r;
    col.b = texture(u_texture, uv - q * ca_strength * 1.0).b;

    // ── NEON/CYBER GLOW (Targeted Bloom) ─────
    float bright = dot(col.rgb, vec3(0.15, 0.35, 0.5)); 
    float bloom = smoothstep(0.75, 0.95, bright); 
    
    // Add glow with center mask applied
    vec3 neon_color = mix(vec3(0.0, 0.7, 1.0), vec3(1.0, 0.1, 0.8), sin(u_timer * 0.5) * 0.5 + 0.5);
    col.rgb += bloom * bloom * neon_color * 0.15 * center_mask; // Multiply by mask

    // ── DIGITAL GLITCH (Quick, sharp, localized flicker/jump) ─────
    float rand_val = random(floor(uv * vec2(100.0, 50.0)) + floor(u_timer * 100.0)); 
    
    // Store original color before glitch
    vec4 glitched_col = col;

    // Quick, subtle vertical jump/shift (only apply if rand_val is high AND in the center)
    if (rand_val > 0.99 && center_mask > 0.5) { 
        float jump_amount = random(uv * 1.5) * 0.02;
        glitched_col = texture(u_texture, uv + vec2(0.0, jump_amount)); 
    }
    
    // Horizontal line static/flicker (very fast)
    if (fract(u_timer * 10.0) > 0.8 && center_mask > 0.2) {
        float line_flicker = sin(uv.y * 300.0 + u_timer * 200.0) * 0.005;
        glitched_col.rgb += line_flicker;
    }
    
    col = glitched_col; // Commit glitched color

    // ── Minimal Vignette and Curvature (Original) ─────
    vec2 crt = uv * 2.0 - 1.0;
    crt *= 1.0 + 0.005 * dot(crt, crt); 
    float vignette = 1.0 - length(crt) * 0.1; 
    col.rgb *= vignette * 0.95 + 0.05; 

    // ── Final Gradiing: Increase Saturation and Blue Shift ────────────────
    col.rgb = mix(col.rgb, col.rgb * vec3(0.9, 0.95, 1.1), 0.15); 
    col.rgb = pow(col.rgb, vec3(1.05)); 

    frag_color = col;
}
