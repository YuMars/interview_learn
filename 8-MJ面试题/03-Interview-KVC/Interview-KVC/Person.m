//
//  Person.m
//  Interview-KVC
//
//  Created by Red-Fish on 2021/12/10.
//

#import "Person.h"

@implementation Person

//- (void)setAge:(NSInteger)age {
//    _age = age;
//
//    NSLog(@"setAge: - %ld", age);
//}

- (void)_setAge:(NSInteger)age {
    _age = age;
    
    NSLog(@"_setAge: - %ld", age);
}

//+ (BOOL)accessInstanceVariablesDirectly {
//    return NO;
//}

@end

@implementation QKCat



@end
