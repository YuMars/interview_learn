//
//  YJTOperation.m
//  NSOperation
//
//  Created by Red-Fish on 2021/8/23.
//

#import "YJTOperation.h"

@implementation YJTOperation

- (void)main {
    if (!self.isCancelled) {
        for (int i = 0; i < 3; i++) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    }
}

@end
