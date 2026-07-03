#pragma once

#include <QObject>
#include <QString>

namespace bt {

class LanguageManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool rtl READ rtl NOTIFY languageChanged)
    Q_PROPERTY(int revision READ revision NOTIFY languageChanged)
public:
    explicit LanguageManager(QObject* parent = nullptr);

    QString language() const { return m_language; }
    bool rtl() const { return m_language == "ar"; }
    int revision() const { return m_revision; }

    Q_INVOKABLE QString text(const QString& arabic, const QString& english, int revision = 0) const;
    Q_INVOKABLE void setLanguage(const QString& language);

signals:
    void languageChanged();

private:
    void applyLayoutDirection() const;

    QString m_language;
    int m_revision = 0;
};

} // namespace bt
