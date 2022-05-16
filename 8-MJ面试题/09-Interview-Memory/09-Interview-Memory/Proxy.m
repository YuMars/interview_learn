//
//  Proxy.m
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import "Proxy.h"

@implementation Proxy

+ (instancetype)proxyWithTarget:(id)target {
    Proxy *proxy = [[Proxy alloc] init];
    proxy.target = target;
    return proxy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}

@end
