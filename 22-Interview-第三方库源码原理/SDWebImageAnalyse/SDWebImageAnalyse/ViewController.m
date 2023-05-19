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
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:@""]];
}


@end
