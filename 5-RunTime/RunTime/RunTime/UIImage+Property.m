//
//  UIImage+Property.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/8.
//

#import "UIImage+Property.h"
#import <objc/runtime.h>

@implementation UIImage (Property)

- (void)setUrlString:(NSString *)urlString {
    objc_setAssociatedObject(self, @selector(urlString), urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)urlString {
    return objc_getAssociatedObject(self, @selector(urlString));
}

- (void)clearAssociatedObject {
    objc_removeAssociatedObjects(self);
}

@end
