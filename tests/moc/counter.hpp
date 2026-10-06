#pragma once
#include <QObject>

class Counter : public QObject {
    Q_OBJECT
    Q_PROPERTY(int value READ value CONSTANT)
public:
    int value() const { return 7; }
};
