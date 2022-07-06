//
//  Student.m
//  6-Interview-Runtime
//
//  Created by Red-Fish on 2022/4/16.
//

#import "Student.h"

@implementation Student


- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"%@", [self class]);
        NSLog(@"%@", [super class]);
        NSLog(@"%@", [self superclass]);
        NSLog(@"%@", [super superclass]);
    }
    return self;
}

@end
