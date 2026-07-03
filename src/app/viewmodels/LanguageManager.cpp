#include "viewmodels/LanguageManager.h"

#include <QGuiApplication>
#include <QSettings>

namespace bt {

LanguageManager::LanguageManager(QObject* parent)
    : QObject(parent)
{
    QSettings settings;
    const QString saved = settings.value("ui/language", "en").toString();
    m_language = (saved == "ar") ? "ar" : "en";
    applyLayoutDirection();
}

QString LanguageManager::text(const QString& arabic, const QString& english, int revision) const
{
    Q_UNUSED(revision)
    return (m_language == "ar") ? arabic : english;
}

void LanguageManager::setLanguage(const QString& language)
{
    const QString normalized = (language == "ar") ? "ar" : "en";
    if (m_language == normalized)
        return;

    m_language = normalized;
    QSettings settings;
    settings.setValue("ui/language", m_language);
    applyLayoutDirection();
    ++m_revision;
    emit languageChanged();
}

void LanguageManager::applyLayoutDirection() const
{
    QGuiApplication::setLayoutDirection(rtl() ? Qt::RightToLeft : Qt::LeftToRight);
}

} // namespace bt
