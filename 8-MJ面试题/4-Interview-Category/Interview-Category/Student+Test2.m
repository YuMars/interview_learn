//
//  Student+Test2.m
//  Interview-Category
//
//  Created by Red-Fish on 2021/12/13.
//

#import "Student+Test2.h"
#import "objc/runtime.h"

@implementation Student (Test2)

+ (void)load {
    NSLog(@"Student (Test1)");
}

- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name {
    return objc_getAssociatedObject(self, @selector(name));
}

@end
