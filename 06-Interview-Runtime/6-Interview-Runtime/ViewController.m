//
//  ViewController.m
//  6-Interview-Runtime
//
//  Created by Red-Fish on 2022/2/21.
//

#import "ViewController.h"
#import "Person.h"
#import "Student.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
    
    id cls = [Person class];
    void *obj = &cls;
    [(__bridge id)obj print];
    
    Person *person = [[Person alloc] init];
    
    objc_setAssociatedObject(person, "name", @"Mike", OBJC_ASSOCIATION_COPY); // isa的has_assoc位 会变成 1

    [person test];
    // ((void (*)(id, SEL))(void *)objc_msgSend)((id)person, sel_registerName("test"));
    
    // Q:讲一下OC的消息机制
    
    // Q:消息转发机制流程
    
    // Q:什么是runtime？平时项目里用过吗？
    
    // OC是一门动态性很强的编程语言 （编写代码->编译->运行），runtime提供的API支撑，源码由C\C++语法编写
    
    // runtime底层，常用的数据结构，如isa指针,在arm64之前，isa指针是指向Class，Mate-Class内存地址的指针
    
    
    NSLog(@"%d" ,[[NSObject class] isKindOfClass:[NSObject class]]); // 1
    
    NSLog(@"%d" ,[[NSObject class] isMemberOfClass:[NSObject class]]);  // 0
    
    NSLog(@"%d" ,[NSObject isMemberOfClass:[NSObject class]]);// 0
    // [Person class] -> isKindOfClass,找到是meta-class
    NSLog(@"%d" ,[[Person class] isKindOfClass:[Person class]]);// 0
    
    NSLog(@"%d" ,[[Person class] isMemberOfClass:[Person class]]);// 0
    
    NSLog(@"%@",[NSObject class]);
}


@end
