// Halftone: the incoming slide arrives through a printed dot screen, lifted
// from gl.js's compositing stack. Luminance sets each dot's radius, so light
// areas open up and shadows stay dense while the screen itself fades at both
// ends of the transition.
//
// Everything the eye reads as the screen's character is drawn from `seed`,
// which the host sets fresh for each run: the screen angle, the cell sizes, the
// ink gain and tint, and the shape of the front. Without it every halftone in a
// deck would play the identical motion, whatever slides it joined.

// One seeded value in [0, 1). The salt keeps the parameters independent, so a
// run does not always pair, say, a coarse screen with a fast front.
float halftoneRandom(float salt) {
    return hash21(vec2(seed, salt));
}

vec4 transition(vec2 uv) {
    // A dot grid has no upright to keep, so the angle takes the full turn.
    float angle = halftoneRandom(1.0) * 6.28318530718;
    // The cell the screen starts and grows to. The ranges stay well apart, so
    // the screen always opens up rather than closing as it peaks.
    float baseCell = mix(0.010, 0.017, halftoneRandom(2.0));
    float wideCell = mix(0.038, 0.060, halftoneRandom(3.0));
    // How hard the dots burn through the slide, and in which light.
    float gain = mix(0.58, 0.80, halftoneRandom(4.0));
    float ink = mix(1.55, 1.95, halftoneRandom(5.0));
    vec3 rimTint = mix(vec3(0.90, 0.85, 1.00), vec3(1.00, 0.90, 0.72),
                       halftoneRandom(6.0));
    float rimGain = mix(0.20, 0.32, halftoneRandom(7.0));
    // The noise front that carries the swap: turned, drifted and scaled per
    // run, so it does not sweep the same way twice.
    float turn = halftoneRandom(8.0) * 6.28318530718;
    float scale = mix(4.0, 6.5, halftoneRandom(9.0));
    vec2 drift = vec2(halftoneRandom(10.0), halftoneRandom(11.0)) * 32.0;

    // 0 at the ends, 1 halfway: the screen appears and clears again.
    float strength = sin(progress * 3.14159265);

    // Centered, shorter-side-normalized coordinates, as gl.js works in.
    vec2 p = (uv - 0.5) * vec2(1.777778, 1.0);
    float tc = cos(turn), ts = sin(turn);
    float field = valueNoise((mat2(tc, -ts, ts, tc) * p) * scale + drift);

    float edge = smoothstep(field - 0.18, field + 0.02, progress);
    vec4 color = mix(texture2D(fromTex, uv), texture2D(toTex, uv), edge);

    // Screen-space cells keep the dots round on a 16:9 slide; the cell grows
    // with strength, as gl.js's u_dots scales it.
    float cell = mix(baseCell, wideCell, strength);
    float ca = cos(angle), sa = sin(angle);
    vec2 f = fract((mat2(ca, -sa, sa, ca) * p) / cell) - 0.5;
    float lum = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    float radius = lum * gain + 0.002;
    float dots = 1.0 - smoothstep(radius * 0.72, radius, length(f));
    color.rgb = mix(color.rgb * (1.0 - 0.72 * strength),
                    color.rgb * ink + rimTint * 0.05,
                    dots * strength);

    // A rim on the front, as on gl.js's dissolve, in the run's own light.
    float rim = (1.0 - smoothstep(0.0, 0.10, abs(progress - field))) * strength;
    color.rgb += rimTint * rim * rimGain;
    return color;
}
