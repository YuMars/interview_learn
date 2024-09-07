//
//  ViewController.m
//  Interview-KVO
//
//  Created by Red-Fish on 2021/12/8.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>

@interface ViewController ()

@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) Person *person2;

@end

@implementation ViewController

- (void)printMethodNamesOfClass:(Class)cls {
    unsigned int count;
    Method *methodList = class_copyMethodList(cls, &count);
    
    // 遍历所有方法
    for (int i = 0 ; i < count; i++) {
        // 获得方法
        Method method = methodList[i];
        // 获得方法名
        SEL sel = method_getName(method);
        NSString *selName = NSStringFromSelector(sel);
        NSLog(@"%@",selName);
    }
    
    // 释放
    free(methodList);
}

- (void)test2 {
    NSLog(@"3-%@",[NSThread currentThread]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"1-%@",[NSThread currentThread]);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSLog(@"2-%@", [NSThread currentThread]);
        
//        [self performSelector:@selector(test2) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
        [self performSelector:@selector(test2) withObject:nil afterDelay:0.0];
        [[NSRunLoop currentRunLoop] run];
        
        NSLog(@"4-%@", [NSThread currentThread]);
    });
    
    NSLog(@"5-%@",[NSThread currentThread]);
    // Q:iOS用什么方式实现一个对象的KVO？（KVO的本质是什么）
    
    /*
     KVO: Key Value Observing： 键值监听
     */
    
    self.person = [[Person alloc] init];
    self.person.age = 10;
    self.person.weight = 100;
    self.person -> _height = 1;
    
    self.person2 = [[Person alloc] init];
    self.person2.age = 20;
    self.person2 -> _height = 2;
    
    // getClass
    NSLog(@"class %@ %@", [self.person class], [self.person2 class]);
    
    // class对象
    NSLog(@"类%p %@",object_getClass(self.person), object_getClass(self.person));
    
    // meta-class对象
    NSLog(@"元类%p %@", object_getClass(object_getClass(self.person)), object_getClass(object_getClass(self.person)));
    
    NSLog(@"监听之前%p", [self.person methodForSelector:@selector(setAge:)]);
    // p (IMP)+上面的方法地址可以打印方法
    
    [self printMethodNamesOfClass:object_getClass(self.person)];
    
    // NSKVONotifing_Person Class
    [self.person addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.person addObserver:self forKeyPath:@"height" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.person addObserver:self forKeyPath:@"weight" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // getClass
    NSLog(@"class %@ %@", [self.person class], [self.person2 class]);
    
    NSLog(@"类%p %@",object_getClass(self.person), object_getClass(self.person));
    
    NSLog(@"元类%p %@", object_getClass(object_getClass(self.person)), object_getClass(object_getClass(self.person)));
    
    NSLog(@"监听之后%p", [self.person methodForSelector:@selector(setAge:)]);
    
    // NSSet*ValueForKey 执行顺序
    
    /*
     [self willChangeValueForKey:@""];
     
     [self didChangeValueForKey:@""];
     
     NSLog(@"didChangeValueForKey - begin");
     
     [super didChangeValueForKey:key];  <<< 调用了监听方法
     
     NSLog(@"didChangeValueForKey - end");
     
     */
    
    [self printMethodNamesOfClass:object_getClass(self.person)];
    
    
    /*
     A:1.利用runtime Api动态生成一个子类，并且让instance对象的isa指向这个全新的子类
       2.当修改instance对象的属性时，会调用Foundation的_NSSetXXXValueAndNotify函数
        willChangeValueForKey:
        父类的setter
        didChangeValueForKey:
        内部会出发监听器Oberser的监听方法（observeValueForKeyPath:ofObject:change:context:）
     */
    
    // Q:如何手动触发KVO？
    
    // A:手动调用下面的方法
    // [self willChangeValueForKey:@""];
    // [self didChangeValueForKey:@""];
    
    // Q:直接修改成员变量会触发KVO吗
    
    // A:不会触发KVO
    // 
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    // self.person.isa = NSKVONotifing_Person 是使用runtime动态创建的一个类
    // IMP [self.person methodForSelector:@selector(setAge:)]
    self.person.age = 20 + random();
    self.person -> _height = 200;
    self.person.weight = 300;
    self.person2.age = 30;
    
    
//    [self.person willChangeValueForKey:@"height"];
//    self.person -> _height = 30;
//    [self.person didChangeValueForKey:@"height"];
}

// 当监听对象的属性值发生改变，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"监听到%@的%@属性值改变了 -- %@", object, keyPath, change);
}

- (void)dealloc {
    [self.person removeObserver:self forKeyPath:@"age"];
}

@end
