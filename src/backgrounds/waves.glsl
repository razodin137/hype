// Waves: terraced sine bands drifting across the slide, from gl.js's first
// scene. Five terraces rise and fall out of phase, each edge picked out in
// the crest color, over a deep base.

vec4 background(vec2 uv, float time) {
    vec2 p = slideCoords(uv);
    vec3 deep = vec3(0.043, 0.031, 0.12);
    vec3 crest = vec3(0.55, 0.5, 1.0);
    vec3 col = deep;
    for (int i = 4; i >= 0; i--) {
        float fi = float(i);
        float y = -0.62 + fi * 0.27
                + 0.11 * sin(p.x * (1.3 + fi * 0.55) + time * (0.35 + fi * 0.22))
                + 0.05 * bgNoise(vec2(p.x * 2.6 + fi * 13.7, time * 0.14));
        float below = 1.0 - smoothstep(y - 0.0015, y + 0.0015, p.y);
        col = mix(col, mix(deep, crest, 0.06 + fi * 0.1), below * 0.5);
        float line = 1.0 - smoothstep(0.0, 0.012, abs(p.y - y));
        col = mix(col, crest, line * below * 0.75);
    }
    return vec4(col, 1.0);
}
