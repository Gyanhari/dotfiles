#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D screen_texture;

out vec4 frag_color;

float rand(vec2 co){ return fract(sin(dot(co.xy,vec2(12.9898,78.233)))*43758.5453); }

vec4 hook() {
    // NOTE: Replace 1920.0, 1080.0 with your actual screen resolution if needed
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec2 center = vec2(0.5, 0.4);

    // radial ripple
    float dist = distance(uv, center);
    float ripple = 0.003 * sin(30.0 * dist - u_timer*3.0);

    // vertical shimmer lines
    float shimmer = sin((uv.x*80.0 + u_timer*8.0) + dist*40.0) * 0.002;

    // combined offset
    vec2 offset = vec2(ripple + shimmer, ripple*0.6);

    // chromatic aberration
    float ca = 0.004 * smoothstep(0.0, 0.8, dist);
    vec3 col;
    col.r = texture(screen_texture, uv + offset + vec2(ca,0.0)).r;
    col.g = texture(screen_texture, uv + offset).g;
    col.b = texture(screen_texture, uv + offset - vec2(ca,0.0)).b;

    // scanline effect
    float scan = 0.96 + 0.04 * sin((uv.y*1200.0) + u_timer*40.0);
    col *= scan;

    // faint flicker noise
    col += (rand(uv*200.0 + u_timer) - 0.5) * 0.02;

    // hologram tint
    col = col * vec3(0.6, 1.0, 1.2);

    // slight vignette
    float v = smoothstep(0.9, 0.45, dist);
    col *= v;

    return vec4(clamp(col,0.0,1.0), 1.0);
}

void main() {
    frag_color = hook();
}
