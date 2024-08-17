//
//  ProxyBaseNSProxy.m
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import "ProxyBaseNSProxy.h"

@implementation ProxyBaseNSProxy

+ (instancetype)proxyWithTarget:(id)target {
    ProxyBaseNSProxy *proxy = [ProxyBaseNSProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
} 

@end
