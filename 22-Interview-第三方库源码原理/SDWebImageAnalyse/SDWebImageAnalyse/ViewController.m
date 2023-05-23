//
//  ViewController.m
//  SDWebImageAnalyse
//
//  Created by Red-Fish on 2023/5/19.
//

#import "ViewController.h"
#import "SDWebImage.h"
@interface ViewController ()

@property (nonatomic, strong) UIImageView *imgV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 300.0)];
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:@"https://p.upyun.com/demo/webp/animated-gif/0.gif"]];
    [self.view addSubview:self.imgV];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imgV sd_setImageWithURL:[NSURL URLWithString:@"https://p.upyun.com/demo/webp/animated-gif/0.gif"]];
    });
}


@end
