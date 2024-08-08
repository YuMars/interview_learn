//
//  Person.m
//  Interview-Category
//
//  Created by Red-Fish on 2021/12/13.
//

#import "Person.h"

@implementation Person

+ (void)initialize {
    NSLog(@"Person initialize");
}

- (void)run {
    NSLog(@"run");
}

- (void)love {
    NSLog(@"love");
}

+ (void)load {
    NSLog(@"Person + (void)load");
}

+ (void)tttt {
    NSLog(@"Person + (void)tttt;");
}

@end
