//
//  ViewController.m
//  UI_Related
//
//  Created by Red-Fish on 2022/5/25.
//

#import "ViewController.h"
#import "objc/runtime.h"
#import <malloc/malloc.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] init];
    CALayer *layer = [CALayer layer];
    CALayer *layer2 = [[CALayer alloc] init];
    
    NSLog(@"v对象需要的内存大小:%zd", class_getInstanceSize([view class]));
    NSLog(@"layer1对象需要的内存大小:%zd", class_getInstanceSize([layer class]));
    NSLog(@"layer2对象需要的内存大小:%zd", class_getInstanceSize([layer2 class]));
    
    NSLog(@"v对象实际分配的内存大小:%zd", malloc_size((__bridge const void *)(view)));
    NSLog(@"layer1对象实际分配的内存大小:%zd", malloc_size((__bridge const void *)(view)));
    NSLog(@"layer2对象实际分配的内存大小:%zd", malloc_size((__bridge const void *)(view)));
}


@end
