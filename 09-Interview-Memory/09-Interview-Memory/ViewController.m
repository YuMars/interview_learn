//
//  ViewController.m
//  09-Interview-Memory
//
//  Created by Red-Fish on 2022/5/11.
//

#import "ViewController.h"
#import "OneVC.h"

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)pushNextVC:(id)sender {
    OneVC *vc = [[OneVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
