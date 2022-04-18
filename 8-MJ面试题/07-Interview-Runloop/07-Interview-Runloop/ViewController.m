//
//  ViewController.m
//  07-Interview-Runloop
//
//  Created by Red-Fish on 2022/4/18.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 当前线程
    NSRunLoop *runloop = [NSRunLoop currentRunLoop]; 
    CFRunLoopRef ref = CFRunLoopGetCurrent();
    
    // 主线程runloop
    [NSRunLoop mainRunLoop];
    CFRunLoopGetMain();
}


@end
