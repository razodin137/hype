#pragma once
#include <QByteArray>
#include <QString>
#include <QStringList>

// Animated slide backgrounds, each one a GLSL ES 1.00 fragment body:
//
//     vec4 background(vec2 uv, float time)
//
// uv spans the slide as [0, 1] and time advances in seconds, so a body paints
// a living background under the slide's text and media. The same source runs
// in the Qt Quick app (ShaderEffect) and in the HTML exports (WebGL 1); the
// two wrappers below add only the platform's preamble and main.
QStringList backgroundNames();
// The shared helpers followed by the named body, or empty for "none" and
// names that have no shader.
QString backgroundBody(const QString &name);
// The body wrapped as a ShaderEffect fragment shader. The main multiplies by
// qt_Opacity, so the editor can fade one background out over another.
QString qtBackgroundFragmentShader(const QString &name);
// Every body keyed by name, as compact JSON for the exported page's WebGL
// renderer. "none" is absent: it means the slide keeps its theme background.
// '<' is escaped as JSON's < so the block cannot close its <script>.
QByteArray backgroundsJson();
