// Rings: a high-contrast test pattern, from gl.js's fourth scene. Concentric
// pulses spread through the dark upper half, angular beams sweep the light
// lower one, and the split between them sways with time.

vec4 background(vec2 uv, float time) {
    vec2 p = slideCoords(uv);
    float d = length(p);
    float pulse = 0.5 + 0.5 * sin(d * 14.0 - time * 1.2);
    float beam = 0.5 + 0.5 * sin(atan(p.y, p.x) * 6.0 + time * 0.4);
    vec3 dark = vec3(0.03, 0.04, 0.07);
    vec3 mid = vec3(0.16, 0.4, 0.6);
    float split = step(0.15 * sin(time * 0.3), p.y);
    vec3 upper = dark + mid * pulse * 0.85;
    vec3 lower = mix(mid, vec3(0.9, 0.93, 1.0), pulse) * (0.35 + 0.4 * beam);
    return vec4(mix(upper, lower, split * 0.85), 1.0);
}
