//
//  ViewController.m
//  04-Interview-02-Association
//
//  Created by Red-Fish on 2022/4/1.
//

#import "ViewController.h"
#import "Person+Test.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *person = [[Person alloc] init];
    person.age = 10;
    person.name = @"jack";
    
    NSLog(@"age:%d weight:%d", person.age, person.name);
}


@end
