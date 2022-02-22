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

struct my_objc_class {
    Class isa;
    Class superClass;
};

@interface Student : NSObject

@property (nonatomic, assign) int age;

- (void)studentInstanceMethod;
+ (void)studentClassMethod;

@end

@implementation Student

- (void)studentInstanceMethod {
    
}

+ (void)studentClassMethod {
    
}

@end

@interface Person : Student

@property (nonatomic, assign) int no;

@end

@implementation Person

@end

@interface Teacher : Person <NSCoding>

@property (nonatomic, assign) int height;

- (void)teacherInstanceMethod;
+ (void)teacherClassMethod;

@end

@implementation Teacher

- (void)teacherInstanceMethod {
    
}

+ (void)teacherClassMethod {
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Q: 1.一个NSObject对象占用多少内存
    
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
       其他成员变量（具体的值）
     
     2. class对象 (类对象)
        isa指针
        superclass指针
        类的属性信息（ @property)
        类的对象方法（instance method）
        类的协议信息 （protocol），
        类的成员变量（ivar，信息）
     
     3. meta-class对象（元类对象） (每个类在内存中只有一个元类对象)
        isa指针
        superclass的指针
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
    
    //NSLog(@"%p %p %d %d %d", objectMetaClass, objectMetaClass2, class_isMetaClass(obj1), class_isMetaClass(objectClass), class_isMetaClass(objectMetaClass));
    
    // objc_getClass(<#const char * _Nonnull name#>) 传入类名
    
    // 如果传入是instance对象，返回class
    // 如果传入是class对象，返回meta-class
    // 如果传入是mete-class，返回NSObject的meta-class
    // object_getClass(<#id  _Nullable obj#>) 传入对象
    
    
    /*
     instance 对象 ：Student *student = [[Student alloc] init];
     class 对象： Class studentClass = [Student class];
     meta-class 对象：Class studentMetaClass = object_getClass(studentClass);
     */
    
    // Q: 2.对象的isa指针指向哪里
    // instance对象的isa指针指向class对象
    // class对象的isa指针指向meta-class对象
    // meta-class的isa指针指向基类的meta-class
    
    /*
     objc_msdSend(person, @selector())
     */
    
    Student *testStudent = [[Student alloc] init];
    [testStudent studentInstanceMethod];
    [Student studentClassMethod];
    
    // Student *testStudent = ((Student *(*)(id, SEL))(void *)objc_msgSend)((id)((Student *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("Student"), sel_registerName("alloc")), sel_registerName("init"));
    // ((void (*)(id, SEL))(void *)objc_msgSend)((id)testStudent, sel_registerName("studentInstanceMethod"));
    // ((void (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("Student"), sel_registerName("studentClassMethod"));
    
    
    // Class对象的superclass指针
    
    Teacher *teacher = [[Teacher alloc] init];
    [teacher studentInstanceMethod];
    // ↑↑↑↑↑↑↑↑↑↑↑↑
    // !!!类对象的superclass指向的是父类的class对象
    // 通过Teacher的instance对象要调用student的对象方法时，
    // 会先调用teacher的isa找到Teacher的class，
    // 然后通过superclass找到Student的class,
    // 最后找到对象方法的实现进行调用
    
    // mete-class对象的superclass指针
    
    [Teacher studentClassMethod];
    // ↑↑↑↑↑↑↑↑↑↑↑↑
    // !!!mete-class对象的superclass指针指向的是父类的元类对象
    // Teacher的class要调用student的类方法
    // 先通过Teacher的isa找到meta-class
    // 然后通过superclass找到student的mete-class
    // 最后找到类方法的实现调用
    
    // isa指针
    // instance对象的isa指针指向class对象
    // class对象的isa指针指向meta-class对象
    // meta-class的isa指针指向基类的meta-class
    
    // class对象的superclass指向superclass的class对象
    // 如果没有superclass，suerclass指针为nil
    // meta-class对象superclass指向superclass的meta-class
    // 基类的meta-class的superclass指向基类的class
    
    // instance调用对象方法的轨迹
    // isa找到class，方法不存在，就通过superclass找到父类
    
    Student *student3 = [[Student alloc] init];
    Class studentClass3 = [student3 class];
    Class metaClassStudent3 = object_getClass(studentClass3);
    
    // ISA_MASK
    // p/x 0x & ISA_MASK:0x00007ffffffffff8
    
    Class studentObjcClass = [Student class];
    struct my_objc_class *studentObjcClass2 = (__bridge struct my_objc_class *)(studentObjcClass);
    
    // p/x studentObjcClass2 -> isa & 0x00007ffffffffff8 = metaClassStudent3
    NSLog(@"%p %p %p", student3, studentClass3, metaClassStudent3);
    
    
    /*
     struct objc_class : objc_object {
         // Class ISA;
         (Class isa)
         Class superclass;
         cache_t cache;             // formerly cache pointer and vtable
         class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
     };
     */
    
    // Q: 3.OC的类信息存放在哪里
    // 对象方法、属性、成员变量、协议 放在class对象中
    // 类方法，存放在meta-class对象中
    // 成员变量的具体值，存放在instance对象
    
}


@end
