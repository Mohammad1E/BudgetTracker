#pragma once
#include <QString>

namespace bt {

// A person an income/expense can be linked to (e.g. "أحمد", "محل البقالة").
struct Person {
    qint64  id       = 0;
    QString name;
    QString phone;
    QString note;
    bool    archived = false;
};

} // namespace bt
