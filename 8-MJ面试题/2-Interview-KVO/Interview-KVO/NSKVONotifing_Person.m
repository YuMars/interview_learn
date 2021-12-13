//
//  NSKVONotifing_Person.m
//  Interview-KVO
//
//  Created by Red-Fish on 2021/12/8.
//

#import "NSKVONotifing_Person.h"

@implementation NSKVONotifing_Person

- (void)setAge:(NSInteger)age {
    _NSSetIntValueAndNotify();
    
    
}

void _NSSetIntValueAndNotify() {
//    [self willChangeValueForKey:@"age"];
//    [super setAge:age];
//    [self didChangeValueForKey:@"age"];
}

//- (Class)class {
//    return [Person class];
//}
//
//- (BOOL)isKVOA {
//    return YES;
//}

- (void)didChangeValueForKey:(NSString *)key {
    //[oberser observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

@end
