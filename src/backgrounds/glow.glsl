// Glow: a drifting radial light with a breathing ring, from gl.js's glow
// scene. The light wanders above center, the ring swells around it, and a
// second, dimmer glow holds the lower left corner.

vec4 background(vec2 uv, float time) {
    vec2 p = slideCoords(uv);
    vec3 base = vec3(0.03, 0.035, 0.065);
    vec3 accent = vec3(0.45, 0.55, 1.0);
    vec2 c = vec2(0.0, 0.08 + 0.12 * sin(time * 0.27));
    float d = length(p - c);
    vec3 col = base + accent * exp(-d * 2.4) * 0.55;
    float ring = 1.0 - smoothstep(0.0, 0.02, abs(d - (0.52 + 0.1 * sin(time * 0.4))));
    col += accent * ring * 0.3;
    col += accent * exp(-length(p - vec2(-0.8, -0.55)) * 2.0) * 0.25;
    return vec4(col, 1.0);
}
