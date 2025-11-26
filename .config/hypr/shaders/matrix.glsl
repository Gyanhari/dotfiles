#version 300 es
precision highp float;
#pragma shader_stage fragment

uniform float u_timer;
uniform sampler2D screen_texture;

out vec4 frag_color;

float hash(float n){ return fract(sin(n)*43758.5453123); }
float noise(vec2 p){
    vec2 i=floor(p); vec2 f=fract(p);
    float a=hash(i.x+ i.y*57.0);
    float b=hash(i.x+1.0 + i.y*57.0);
    float c=hash(i.x + (i.y+1.0)*57.0);
    float d=hash(i.x+1.0 + (i.y+1.0)*57.0);
    vec2 u=f*f*(3.0-2.0*f);
    return mix(a,b,u.x)+ (c-a)*u.y*(1.0-u.x) + (d-b)*u.x*u.y;
}

vec4 hook(){
    // NOTE: Replace 1920.0, 1080.0 with your actual screen resolution if needed
    vec2 uv = gl_FragCoord.xy / vec2(1920.0, 1080.0);
    
    // background dark
    vec3 bg = vec3(0.01,0.005,0.02);

    // coordinates for falling strips
    float cols = 120.0;
    float col = floor(uv.x * cols);
    float t = u_timer * 0.8 + col * 0.08;
    float speed = fract(sin(col*12.9898)*43758.5453) * 0.6 + 0.2;

    // vertical position
    float y = mod(uv.y + t*speed, 1.0);
    // characters as thin bright segments
    float width = 1.0/cols * 0.9;
    float stripe = smoothstep(0.0, 0.02, 1.0 - abs(y - 0.15));
    stripe += smoothstep(0.0, 0.03, 1.0 - abs(y - 0.45)) * 0.6;
    stripe = clamp(stripe, 0.0, 1.0);

    // glow and color (Green-Cyan mix)
    vec3 colNeon = vec3(0.2,0.9,0.6) * 0.8 + vec3(0.6,0.2,0.9) * 0.2;
    float flick = 0.7 + 0.3 * sin(u_timer*12.0 + col);
    vec3 glow = colNeon * stripe * flick;

    // sample original texture faintly behind
    vec3 base = texture(screen_texture, uv).rgb * 0.12;

    // screen noise
    float n = (noise(uv*120.0 + u_timer*0.5) - 0.5) * 0.06;

    // final mix with additive bloom feel
    vec3 color = base + glow + bg * 0.2 + vec3(n);

    // slight vignette
    float r = distance(uv, vec2(0.5));
    color *= smoothstep(0.9,0.3,r);

    return vec4(clamp(color,0.0,1.0),1.0);
}

void main() {
    frag_color = hook();
}
