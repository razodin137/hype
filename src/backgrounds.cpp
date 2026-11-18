#include "backgrounds.h"
#include <QFile>
#include <QHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMutex>
#include <QMutexLocker>

// The one list of shaders. "none" is the default: the slide keeps the theme's
// background color. A new background is one more name here and one more .glsl
// file.
QStringList backgroundNames() {
    return {QStringLiteral("none"),     QStringLiteral("waves"), QStringLiteral("ink"),
            QStringLiteral("glow"),     QStringLiteral("rings"), QStringLiteral("blueprint"),
            QStringLiteral("horizon")};
}

static QString readBackgroundResource(const QString &name) {
    QFile file(":/backgrounds/" + name + ".glsl");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    return QString::fromUtf8(file.readAll());
}

// Each body is shared, so both platforms compile the identical GLSL. The helpers
// are prepended once per body, which keeps every shader self-contained.
static QString composeBody(const QString &name) {
    if (name == "none" || !backgroundNames().contains(name))
        return {};
    const QString common = readBackgroundResource("common");
    const QString body = readBackgroundResource(name);
    if (common.isEmpty() || body.isEmpty())
        return {};
    return common + "\n" + body;
}

QString backgroundBody(const QString &name) {
    static QMutex mutex;
    static QHash<QString, QString> cache;
    QMutexLocker locker(&mutex);
    const auto cached = cache.constFind(name);
    if (cached != cache.cend())
        return *cached;
    const QString body = composeBody(name);
    cache.insert(name, body);
    return body;
}

QString qtBackgroundFragmentShader(const QString &name) {
    static QMutex mutex;
    static QHash<QString, QString> cache;
    QMutexLocker locker(&mutex);
    const auto cached = cache.constFind(name);
    if (cached != cache.cend())
        return *cached;
    const QString body = backgroundBody(name);
    QString shader;
    if (!body.isEmpty()) {
        shader = QStringLiteral("uniform float qt_Opacity;\n"
                                "uniform float time;\n"
                                "uniform float seed;\n"
                                "varying vec2 qt_TexCoord0;\n\n") +
                 body +
                 QStringLiteral("\nvoid main() {\n"
                                "    gl_FragColor = background(qt_TexCoord0, time) * qt_Opacity;\n"
                                "}\n");
    }
    cache.insert(name, shader);
    return shader;
}

QByteArray backgroundsJson() {
    QJsonObject shaders;
    for (const QString &name : backgroundNames()) {
        const QString body = backgroundBody(name);
        if (!body.isEmpty())
            shaders.insert(name, body);
    }
    QByteArray json = QJsonDocument(shaders).toJson(QJsonDocument::Compact);
    // JSON leaves '<' alone; in a <script> block it could spell the end tag.
    return json.replace('<', "\\u003c");
}
