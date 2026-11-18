// Halftone: the incoming slide arrives through a printed dot screen, lifted
// from gl.js's compositing stack. Luminance sets each dot's radius, so light
// areas open up and shadows stay dense while the screen itself fades at both
// ends of the transition.

vec4 transition(vec2 uv) {
    // 0 at the ends, 1 halfway: the screen appears and clears again.
    float strength = sin(progress * 3.14159265);

    // The same noise front as Burn carries the swap behind the dots.
    vec2 p = (uv - 0.5) * vec2(1.777778, 1.0);
    float field = valueNoise(p * 5.0 + vec2(17.0, 5.2));
    float edge = smoothstep(field - 0.18, field + 0.02, progress);
    vec4 color = mix(texture2D(fromTex, uv), texture2D(toTex, uv), edge);

    // Screen-space cells keep the dots round on a 16:9 slide; the cell grows
    // with strength, as gl.js's u_dots scales it.
    float cell = mix(0.012, 0.05, strength);
    vec2 f = fract(p / cell) - 0.5;
    float lum = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    float radius = lum * 0.72 + 0.002;
    float dots = 1.0 - smoothstep(radius * 0.72, radius, length(f));
    color.rgb = mix(color.rgb * (1.0 - 0.72 * strength),
                    color.rgb * 1.8 + vec3(0.05),
                    dots * strength);

    // A cool rim on the front, as on gl.js's dissolve.
    float rim = (1.0 - smoothstep(0.0, 0.10, abs(progress - field))) * strength;
    color.rgb += vec3(0.9, 0.85, 1.0) * rim * 0.25;
    return color;
}
