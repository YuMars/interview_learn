

#include "../kmod.h"

__attribute__((visibility(("hidden"))))
int startKext() {
	return 0;
}

__attribute__((visibility(("hidden"))))
int endKext() {
	return 0;
}

KMOD_EXPLICIT_DECL(com.apple.bar1, "1.0.0", (void*)startKext, (void*)endKext)

#include "bar1.h"

OSDefineMetaClassAndStructors( Bar1, Foo2 )

int Bar1::foo() {
	return 1;
}
