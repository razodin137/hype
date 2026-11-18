// Horizon: a receding ground grid under a magenta sky, from gl.js's closing
// scene. The perspective divide makes the grid rush by; the stars above it
// hold still, and the sky brightens toward the horizon line.

vec4 background(vec2 uv, float time) {
    vec2 p = slideCoords(uv);
    vec3 col = vec3(0.02, 0.012, 0.05);
    float horizon = -0.18;
    if (p.y < horizon) {
        float z = 1.0 / (horizon - p.y);
        vec2 ground = vec2(p.x * z, z * 1.2 - time * 0.9);
        float lx = abs(fract(ground.x * 3.0) - 0.5);
        float lz = abs(fract(ground.y * 3.0) - 0.5);
        float lines = max(smoothstep(0.47, 0.495, lx), smoothstep(0.47, 0.495, lz));
        col += vec3(0.25, 0.6, 0.95) * lines * clamp(z * 0.2, 0.0, 0.85);
    } else {
        float star = step(0.9975, bgHash(floor((p + 13.7) * 260.0)));
        col += vec3(0.8, 0.85, 1.0) * star * 0.4;
        col += vec3(0.9, 0.25, 0.55) * exp(-(p.y - horizon) * 5.0) * 0.45;
    }
    return vec4(col, 1.0);
}
