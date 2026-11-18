// Blueprint: drafting paper with a slow vertical sweep, from gl.js's seventh
// scene. A fine grid and a bold one under a highlight that travels down the
// sheet, with a soft glow spread from its center.

vec4 background(vec2 uv, float time) {
    vec2 p = slideCoords(uv);
    vec3 col = vec3(0.02, 0.04, 0.075);
    vec2 fine = abs(fract(p * 6.0) - 0.5);
    vec2 bold = abs(fract(p * 1.5) - 0.5);
    float fineLine = 1.0 - smoothstep(0.0, 0.05, min(fine.x, fine.y));
    float boldLine = 1.0 - smoothstep(0.0, 0.03, min(bold.x, bold.y));
    col += vec3(0.15, 0.42, 0.68) * (fineLine * 0.22 + boldLine * 0.5);
    float sweep = 1.0 - smoothstep(0.0, 0.25, abs(p.y - (-1.25 + fract(time * 0.045) * 2.5)));
    col += vec3(0.2, 0.55, 0.8) * sweep * 0.18;
    col += vec3(0.35, 0.6, 0.9) * exp(-length(p) * 1.8) * 0.2;
    return vec4(col, 1.0);
}
