// Shared helpers for Hype's GLSL slide backgrounds.
//
// GLSL ES 1.00 only: no array constructors, integer bit operations, switch, or
// dynamic loops, so the same source compiles in Qt Quick's ShaderEffect and in
// a WebGL 1 context. The scenes are ported from gl.js, and keep its helpers.

// One stable pseudo-random value per cell, after gl.js's own hash. The name
// stays apart from hash21 so each helper keeps one meaning.
float bgHash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Value noise, after gl.js's noise: broad and soft, so a drift reads as one
// surface instead of a gradient.
float bgNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = bgHash(i);
    float b = bgHash(i + vec2(1.0, 0.0));
    float c = bgHash(i + vec2(0.0, 1.0));
    float d = bgHash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Four octaves of the noise above, as gl.js's fbm: enough depth for an ink
// warp at a cost a background animating every frame can carry.
float fbm(vec2 p) {
    float v = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 4; i++) {
        v += amp * bgNoise(p);
        p = p * 2.03 + vec2(11.7, 5.3);
        amp *= 0.5;
    }
    return v;
}

// The space the scenes work in: centered on the slide and scaled by its
// shorter side, as gl.js derives from the fragment coordinates, so circles
// stay round on the 16:9 frame. uv arrives as [0, 1] across the slide.
vec2 slideCoords(vec2 uv) {
    return (uv - 0.5) * vec2(1.777778, 1.0);
}
