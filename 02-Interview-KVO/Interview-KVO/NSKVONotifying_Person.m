//
//  NSKVONotifing_Person.m
//  Interview-KVO
//
//  Created by Red-Fish on 2021/12/8.
//

#import "NSKVONotifying_Person.h"

@implementation NSKVONotifying_Person

- (void)setAge:(NSInteger)age {
    _NSSetIntValueAndNotify();
    
    
}

// 伪代码
void _NSSetIntValueAndNotify() {
//    [self willChangeValueForKey:@"age"];
//    [super setAge:age];
//    [self didChangeValueForKey:@"age"];
}

//- (Class)class {
//    return [Person class];
//}
//
//- (BOOL)_isKVOA {
//    return YES;
//}

- (void)didChangeValueForKey:(NSString *)key {
    //[oberser observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

@end
