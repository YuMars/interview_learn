//
//  ViewController.m
//  17-Interview-Synchroinzed
//
//  Created by Red-Fish on 2023/2/28.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // xcrun --sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjcruntime=ios-14.2 ViewController.m
    @synchronized (self) {
        NSLog(@"");
    }
}


@end
