//
//  ViewController.m
//  5-Interview-Block2
//
//  Created by Red-Fish on 2022/2/12.
//

#import "ViewController.h"

typedef void (^Block)(void);

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block int age = 10;
    Block block = ^{
        age = 20;
        NSLog(@"%d", age);
    };
    
    block();
    
    /*
     __block用于解决block内部无法想改auto变量值的问题
     __block不能修改全局变量，静态变量（static）
     编译器会将__block修饰的变量包装成一个对象
     */
    
    /*
     
     __block 变成下面的对象
     
     struct __Block_byref_age_0 {
       void *__isa;
     __Block_byref_age_0 *__forwarding;
      int __flags;
      int __size;
      int age;
     };
     */
}


@end
