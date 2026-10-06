#include "counter.hpp"
#include <QMetaProperty>

int main() {
    Counter counter;
    const auto *meta = counter.metaObject();
    const int index = meta->indexOfProperty("value");
    return index >= 0 && meta->property(index).read(&counter).toInt() == 7 ? 0 : 1;
}
