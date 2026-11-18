# Composes one background into the modern GLSL that qsb bakes for Qt Quick's
# ShaderEffect. The ES 1.00 body stays the single source both renderers
# compile; only the wrapper differs from the HTML exports' WebGL one.
#
#   cmake -DCOMMON=<common.glsl> -DBODY=<name>.glsl -DOUTPUT=<name>.frag -P ...
#
# Qt Quick supplies the vertex shader, whose output is qt_TexCoord0. ShaderEffect
# packs the effect's properties into a std140 block bound at 0; time and seed
# match the QML properties of the same names. A background has no textures of
# its own: it paints the slide's backdrop from uv and time alone. The main
# multiplies by qt_Opacity, so the editor can fade one background out over
# another while a slide changes. seed is drawn by the host per slide; a body
# that does not use it ignores it.

foreach(input COMMON BODY)
    if(NOT EXISTS "${${input}}")
        message(FATAL_ERROR "wrap-background: ${input} not found: ${${input}}")
    endif()
endforeach()

file(READ "${COMMON}" common)
file(READ "${BODY}" body)

set(wrapper [=[#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float seed;
};
#define varying in
#define texture2D texture
#define gl_FragColor fragColor
]=])

file(WRITE "${OUTPUT}"
    "${wrapper}\n${common}\n${body}\n\nvoid main() { gl_FragColor = background(qt_TexCoord0, time) * qt_Opacity; }\n")
