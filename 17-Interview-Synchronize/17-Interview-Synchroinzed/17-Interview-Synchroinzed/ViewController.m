//
//  ViewController.m
//  17-Interview-Synchroinzed
//
//  Created by Red-Fish on 2023/2/28.
//

#import "ViewController.h"

#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // xcrun --sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjcruntime=ios-14.2 ViewController.m
    @synchronized (self) {
        NSLog(@"");
    }
    
//    NSString *string1 = [[NSString alloc] initWithFormat:@"1"];
//    NSString *string2 = [string1 copy];
//
//    NSLog(@"%ld", (unsigned long)string1.retainCount);
//    NSLog(@"%ld", (unsigned long)string2.retainCount);
    NSObject *string1 = [[NSObject alloc] init];
//    NSObject *string2 = [string1 copy];
    
//    NSLog(@"%ld", (unsigned long)string1.retainCount);
//    NSLog(@"%ld", (unsigned long)string2.retainCount);
    
    __block NSObject *obj = [NSObject new];
    
    void (^block)(void) = ^ {
        NSLog(@"%@", obj);
    };
    block();
//    NSLog(@"obj retainCount:%lu", obj.retainCount);
    
    [self run];
}


- (void)run {
    dispatch_queue_t queue = dispatch_queue_create ("queue", DISPATCH_QUEUE_CONCURRENT) ;
    dispatch_async (queue, ^{
        NSLog (@"1");
        //[[NSRunLoop currentRunLoop] run];
        // 1放在这 [[NSRunLoop currentRunLoop] run];
        [self performSelector:@selector (delayAction) withObject:nil afterDelay:1];
        //[[NSRunLoop currentRunLoop] run];
        // 2放在这 [[NSRunLoop currentRunLoop] run];
        NSLog(@"2");
        [[NSRunLoop currentRunLoop] run];
        // 3放在这 [[NSRunLoop currentRunLoop] run];
    });
}

- (void)delayAction {
    sleep(3);
    NSLog (@"3") ;
    
}

@end
