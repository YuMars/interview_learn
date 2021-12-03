//
//  ViewController.m
//  Interview
//
//  Created by Red-Fish on 2021/12/1.
//

#import "ViewController.h"

#import <objc/runtime.h>
#import <malloc/malloc.h>

struct Student_IMPL {
    Class isa;
    int _no;
    int _age;
};

struct Person_IMPL {
    Class isa; // 8
    int _no; // 4
    int _age; // 4
    int _height; // 4
}; // 24 bit

@interface Student : NSObject

@property (nonatomic, assign) int age;


@end

@interface Person : Student

@property (nonatomic, assign) int no;

@end

@implementation Person

@end

@implementation Student

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.一个NSObject对象占用多少内存
    
    /* 代码运行原理
     Objective-C -> C/C++ -> 汇编语言 -> 机器语言
    
     Objective-C的面相对象都是基于 C/C+的数据结构实现
     clang -rewrite-objc main.m -o main.m
     xcrun -sdk iphonesimulator clang -rewrite-objc ViewController.m [讲.m文件转换成cpp文件]
     xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp
     xcrun -sdk iphoneos(手机) clang -arch(架构) arm64(模拟器:i386，32bit:armv7，64bit：arm64) -rewrite-objc main.m -o main-arm64.cpp
     
     struct NSObject_IMPL {
         Class isa; // 指针（8个字节）
     };
     
     Class -> typedef struct objc_class *Class;
     
     NSObject 分配存储空间给结构体 NSObject_IMPL 赋值给object
     
     系统分配了16个字节给NSObject对象(通过malloc_size函数获得)
     但NSObject对象内部只使用了8个字节的空间（64bit环境下,通过class_getInstanceSize函数获得）
    */
    
    NSObject *object = [[NSObject alloc] init];
    
    // NSObject类的实例对象的成员变量所占用的大小 > 8
    size_t size = class_getInstanceSize([NSObject class]);
    NSLog(@"%zu", size);
    
    // object所指向的内存大小 > 16
    object = [[NSObject alloc] init];
    size_t size2 = malloc_size((__bridge const void *)(object));
    NSLog(@"%zu", size2);
    
    /*
     struct Student_IMPL {
         struct NSObject_IMPL NSObject_IVARS;
         int _age;
         int _no;
     };
     
     struct NSObject_IMPL {
         Class isa;
     };
     
     */
    
    Student *student = [[Student alloc] init];
    student.age = 1;
//    student.no = 3;
    size_t studentSize = class_getInstanceSize([Student class]);
    NSLog(@"%zu", studentSize);
    
    size_t studentSize2 = malloc_size((__bridge const void *)(student));
    NSLog(@"%zu", studentSize2);
    
    struct Student_IMPL *studentIMPL = (__bridge  struct Student_IMPL *)student;
    NSLog(@"%d %d", studentIMPL -> _no, studentIMPL -> _age);
    
    Person *person = [[Person alloc] init];
    person.age = 1;
    person.no = 3;
    size_t personSize = class_getInstanceSize([Student class]);
    NSLog(@"%zu", personSize);
    
    size_t personSize2 = malloc_size((__bridge const void *)(person));
    NSLog(@"%zu", personSize2);
    
    struct Person_IMPL *personIMPL = (__bridge  struct Person_IMPL *)person;
    NSLog(@"%d %d", personIMPL -> _no, personIMPL -> _age);
    
    // 结构体
    NSLog(@"size of %zu", sizeof(struct Person_IMPL));
    
    /*
     创建一个实例对象，至少需要多少内存？
     #import <objc/runtime.h>
     class_getInstanceSize([NSObject class]);
     
     创建一个实例对象，实际上分配了多少内存
     #import <malloc/malloc.h>
     malloc_size((__bridge const void *) obj);
     */
    
    /*
     OC对象主要分为3种
     1. instance对象（实例对象）:通过类alloc的对象，每次调用alloc都会产生新的instance，占着不同的内存
       isa指针
       其他成员变量
     
     2. class对象 (类对象)
        isa指针
        superclass指针
        类的属性信息（ @property）,类的对象方法（instance method）
        类的协议信息 （protocol），类的成员变量（ivar）
     
     3. meta-class对象（元类对象）
        每个类在内存中只有一个元类对象
        isa指针 suoerclass的指针
        类的类方法信息（class method）
     */
    
    // 实例对象存储成员变量(isa)
    NSObject *obj1 = [[NSObject alloc] init];
    NSObject *obj2 = [[NSObject alloc] init];
    
    Class objectClass = [obj1 class];
    Class objectClass2 = [NSObject class];
    Class objectClass3 = object_getClass(obj1);
    NSLog(@"%p %p %p", objectClass, objectClass2, objectClass3);
    
    // 元类对象
    Class objectMetaClass = object_getClass(objectClass3);
    Class objectMetaClass2 = object_getClass(objectMetaClass);
    
    NSLog(@"%p %p %d %d %d", objectMetaClass, objectMetaClass2, class_isMetaClass(obj1), class_isMetaClass(objectClass), class_isMetaClass(objectMetaClass));
}


@end
