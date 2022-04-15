//
//  Person.m
//  6-Interview-Runtime
//
//  Created by Red-Fish on 2022/4/10.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Person

- (void)test {
    
}

- (void)other {
    
}

// 消息转发
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(test)) {
        Method method = class_getInstanceMethod(self, @selector(other));
        class_addMethod(self, sel, method_getImplementation(method), method_getTypeEncoding(method));
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    return [super resolveClassMethod:sel];
}

// 消息转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if (aSelector == @selector(test)) {
        return [[NSObject alloc] init];
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

// 方法签名：返回值类型、参数类型
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    if (aSelector == @selector(test)) {
        return [NSMethodSignature signatureWithObjCTypes:"v16@0:8"];
    }
    
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    //anInvocation.target; 方法调用者
    //anInvocation.selector;方法名
    //[anInvocation getArgument:NULL atIndex:0];
}

@end
