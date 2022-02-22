//
//  ViewController.m
//  Interview-KVC
//
//  Created by Red-Fish on 2021/12/10.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // KVC:Key Value Coding "键值编程"，可以通过一个key来访问某个属性
    
    // setValue:forKeyPath:
    // setValue:forKey:
    // valueForKeyPath:
    // valueForKey:
    
    self.person = [[Person alloc] init];
    
    Person *p = [[Person alloc] init];
    [p setValue:@22 forKey:@"age"];
    
    [self.person setValue:@(10) forKey:@"age"];
    [self.person setValue:@(15) forKeyPath:@"age"];
    [self.person setValue:@(22) forKeyPath:@"cat.num"];
    [self.person setValue:@(22) forKeyPath:@"cat.data"];
    NSLog(@"%ld", (long)self.person.cat.num);
    NSLog(@"%@", self.person.cat.data);
    
    self.person.cat = [[QKCat alloc] init];
    [self.person setValue:@(22) forKeyPath:@"cat.num"];
    [self.person setValue:@(22) forKeyPath:@"cat.data"];
    
    //NSLog(@"%ld", (long)self.person.age);
    NSLog(@"%ld", (long)self.person.cat.num);
    NSLog(@"%@", self.person.cat.data);
    
    // Q:通过KVC修改属性会触发KVO吗
    
    [self.person addObserver:self forKeyPath:@"age" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    // A:会触发
    
    /*
     [person willChangeValueForKey:@""];
     [person didChangeValueForKey:@""];
     */
    
    // Q:KVC的赋值和取值过程是怎么样的？原理是什么？
    
    /*
     A:按照setKey: _setKey顺序查找方法（传递参数调用方法）
     查看accessInstanceVariablesDirectlu方法的返回值
     按照_key,_isKey,key,isKey（找到成员变量赋值）
     
     setValue:forUndefinedKey:
     */
    
    /*
     valueForKey:
     按照getKey,key,isKey,_key 找到方法
     按照_key,_isKey,key,isKey顺序查找成员变量
     */
    
    self.person -> _age = 10;
    self.person -> _isAge = 11;
    self.person -> age = 12; 
    self.person -> isAge = 13;
    
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"age"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.person setValue:@(30) forKey:@"age"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"监听%@的%@ -- %@", object, keyPath, change);
}

@end
