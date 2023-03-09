//
//  ViewController.m
//  16-Interview-NSNotification
//
//  Created by Red-Fish on 2023/3/8.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:@"TestNotification" object:@1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:@"TestNotification" object:nil];

    // 接收通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"TestNotification" object:@2];

    // 发送通知
    [NSNotificationCenter.defaultCenter postNotificationName:@"TestNotification" object:@2];
    [NSNotificationCenter.defaultCenter postNotificationName:@"TestNotification" object:nil];
    
}

- (void)handleNotification:(NSNotification *)notifica {
    NSLog(@"%@", notifica);
}

- (void)noti:(NSNotification *)notifica {
    NSLog(@"%@", notifica);
}

@end
