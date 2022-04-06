//
//  Person+Test.m
//  04-Interview-02-Association
//
//  Created by Red-Fish on 2022/4/1.
//

#import "Person+Test.h"
#import <objc/runtime.h>

// const void *KNameKey = &KNameKey;
@implementation Person (Test)

- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSString *)name {
    return objc_getAssociatedObject(self, _cmd);
}

@end
