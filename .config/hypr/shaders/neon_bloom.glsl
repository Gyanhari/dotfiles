#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D screen_texture;

out vec4 frag_color;

float hash(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }

vec4 hook(){
    // NOTE: Replace 1920.0, 1080.0 with your actual screen resolution if needed
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    vec3 base = texture(screen_texture, uv).rgb;

    // fake bloom: sample offsets
    float spread = 0.012;
    vec3 bloom = vec3(0.0);
    bloom += texture(screen_texture, uv + vec2(0.0, spread)).rgb * 0.6;
    bloom += texture(screen_texture, uv + vec2(spread, 0.0)).rgb * 0.6;
    bloom += texture(screen_texture, uv + vec2(-spread, 0.0)).rgb * 0.6;
    bloom += texture(screen_texture, uv + vec2(0.0, -spread)).rgb * 0.6;
    bloom *= 0.7;

    // animated radial pulse
    vec2 center = vec2(0.5) + vec2(0.05 * sin(u_timer*0.5), 0.03 * cos(u_timer*0.6));
    float d = distance(uv, center);
    float pulse = smoothstep(0.5, 0.0, abs(sin(u_timer*0.9) * 0.6 - d)) * 0.9;

    // neon tint (cyan-magenta mix)
    vec3 tint = vec3(0.1,0.9,0.8) * 0.6 + vec3(1.0,0.2,0.9) * 0.4;

    // combine: boost bright areas and add tint bloom
    vec3 bright = max(base, vec3(0.0)) * 1.2;
    vec3 outc = base + bloom * 0.9 + tint * pulse * 0.6;

    // slight film grain
    float g = (hash(uv*1000.0 + u_timer) - 0.5) * 0.02;
    outc += g;

    // clamp and contrast
    outc = pow(clamp(outc, 0.0, 1.0), vec3(0.95));

    return vec4(outc, 1.0);
}

void main() {
    frag_color = hook();
}
