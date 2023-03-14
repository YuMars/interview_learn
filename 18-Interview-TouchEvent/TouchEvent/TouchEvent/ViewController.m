//
//  ViewController.m
//  TouchEvent
//
//  Created by Red-Fish on 2023/3/13.
//

#import "ViewController.h"

#import "HitTestView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HitTestView *view = [[HitTestView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 2.0)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
}


@end
