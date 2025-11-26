#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D screen_texture;

out vec4 frag_color;

vec4 hook(){
    // NOTE: Replace 1920.0, 1080.0 with your actual screen resolution if needed
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec2 p = uv * 2.0 - 1.0;
    p.x *= 16.0/9.0; // assume widescreen aspect ratio

    // simulate horizon perspective
    float horizon = 0.15;
    float depth = (1.0 - (uv.y - horizon)) * 2.5;
    depth = clamp(depth, 0.0, 1.0);

    // grid lines: combine x and z lines
    float gridScale = mix(6.0, 120.0, depth);
    float gx = abs(fract((p.x * gridScale) - 0.5) - 0.5);
    float gy = abs(fract(( (1.0/ (uv.y+0.001)) * gridScale*0.5 ) - 0.5) - 0.5);
    float line = (1.0 - smoothstep(0.0, 0.02, min(gx, gy)));

    // animate glow pulses
    float pulse = 0.5 + 0.5 * sin(u_timer*1.2 + uv.x*8.0);

    // color palette
    vec3 horizonColor = vec3(0.18,0.02,0.28); 
    vec3 gridColor = vec3(1.0,0.35,0.9) * 0.9 + vec3(0.0,0.7,1.0)*0.2;
    vec3 fog = vec3(0.06,0.01,0.08);

    vec3 sample = texture(screen_texture, uv).rgb * 0.15;

    // combine: grid stronger near horizon, faint near viewer
    float gridStrength = smoothstep(0.0, 1.0, depth) * line * (0.8 + 0.6*pulse);
    vec3 color = mix(sample, horizonColor * 0.4 + gridColor * gridStrength, 0.85);

    // distance fog and vignette
    float vign = smoothstep(1.0, 0.45, distance(uv, vec2(0.5)));
    color = mix(color, fog, (1.0 - depth)*0.7);
    color *= vign;

    return vec4(clamp(color,0.0,1.0), 1.0);
}

void main() {
    frag_color = hook();
}
