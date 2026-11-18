// Burn: the slide-to-slide dissolve from gl.js. A broad value-noise field
// decides when each point flips, and the front carries a thin, hot rim, so the
// outgoing slide appears to burn away from the incoming one.

vec4 transition(vec2 uv) {
    // gl.js works in centered, shorter-side-normalized coordinates. Matching
    // them keeps the noise the same size on Hype's 16:9 slide.
    vec2 p = (uv - 0.5) * vec2(1.777778, 1.0);
    float field = valueNoise(p * 5.0 + vec2(17.0, 5.2));

    // The field's own slope softens the front. The 0.02 shift puts the rim on
    // the incoming side, as it does in gl.js.
    float edge = smoothstep(field - 0.18, field + 0.02, progress);
    vec4 color = mix(texture2D(fromTex, uv), texture2D(toTex, uv), edge);

    // gl.js adds the rim on every frame. Gate it here so progress 0 and 1 are
    // exactly the two slides, which both renderers rely on.
    float ends = smoothstep(0.0, 0.04, progress) * (1.0 - smoothstep(0.96, 1.0, progress));
    float d = (progress - field - 0.02) * 24.0;
    color.rgb += vec3(0.9, 0.85, 1.0) * exp(-d * d) * 0.55 * ends;
    return color;
}
