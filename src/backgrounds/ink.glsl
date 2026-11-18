// Ink: domain-warped noise in a slow drift, from gl.js's second scene. Two
// passes of fbm, the second warped by the first, give a marbling that never
// repeats, with a faint seam of light where the field folds over itself.

vec4 background(vec2 uv, float time) {
    vec2 p = slideCoords(uv) * 1.7;
    vec3 dark = vec3(0.03, 0.02, 0.09);
    vec3 light = vec3(0.28, 0.55, 0.8);
    float warp = fbm(p + vec2(time * 0.07, -time * 0.05));
    float w = fbm(p * 1.4 + warp * 1.6 + vec2(-time * 0.05, time * 0.06));
    vec3 col = mix(dark, light, smoothstep(0.3, 0.78, w));
    col += light * 0.12 * (1.0 - smoothstep(0.0, 0.05, abs(w - 0.5)));
    return vec4(col, 1.0);
}
