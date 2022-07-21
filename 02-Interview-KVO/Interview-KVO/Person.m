//
//  Person.m
//  Interview-KVO
//
//  Created by Red-Fish on 2021/12/8.
//

#import "Person.h"

@implementation Person

//- (void)willChangeValueForKey:(NSString *)key {
//    [super willChangeValueForKey:key];
//    
//    NSLog(@"willChangeValueForKey");
//}
//
//- (void)didChangeValueForKey:(NSString *)key {
//    
//    NSLog(@"didChangeValueForKey - begin");
//    
//    [super didChangeValueForKey:key];
//    
//    NSLog(@"didChangeValueForKey - end");
//}

- (void)setAge:(NSInteger)age {
    if (_age != age) {
        [self willChangeValueForKey:@"age"];
        _age = age;
        [self didChangeValueForKey:@"age"];
    }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"age"]) {
        return NO;
    } else {
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

+ (BOOL)automaticallyNotifiesObserversOfWeight {
    return NO;
}

@end
