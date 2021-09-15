//
//  Student+Addition.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/2.
//

#import "Student+Addition.h"

@implementation Student (Addition)

+ (void)printClassName {
    NSLog(@"printClassName");
}

- (void)printName {
    NSLog(@"printName");
}

#pragma mark - <PersonProtocol> 方法

- (void)PersonProtocolMethod {
    NSLog(@"PersonProtocolMethod");
}

+ (void)PersonProtocolClassMethod {
    NSLog(@"PersonProtocolClassMethod");
}

@end
