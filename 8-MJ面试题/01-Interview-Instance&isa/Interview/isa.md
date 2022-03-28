#  isa和OC对象

代码运行原理： Objective-C -> C/C++ -> 汇编语言 -> 机器语言

Objective-C的面相对象都是基于 C/C+的数据结构实现

clang -rewrite-objc main.m -o main.m
xcrun -sdk iphonesimulator clang -rewrite-objc ViewController.m (讲.m文件转换成cpp文件)
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main-arm64.cpp
xcrun -sdk iphoneos(手机) clang -arch(架构) arm64(模拟器:i386，32bit:armv7，64bit：arm64) -rewrite-objc main.m -o main-arm64.cpp

     struct NSObject_IMPL {
         Class isa; // 指针（8个字节）(64位下是8个字节，32位下是4个字节)
     };

    NSObject *object = [[NSObject alloc] init]; -> object本质就是isa指针的地址

    alloc里面有以下
    `#define fastpath(x) (__builtin_expect(bool(x), 1))` 大概率可能为真
    `#define slowpath(x) (__builtin_expect(bool(x), 0))` 大概率可能为假

    // 返回实例的类的所指向的内存占用大小(Class's ivar size rounded up to a pointer-size boundary.)
    class_getInstanceSize()
    // 获取实例所指向的内存的占用大小
    malloc_size()
    
    // NSObject类的实例对象的成员变量所占用的大小 -> 8
    size_t size = class_getInstanceSize([NSObject class]); 
    
    // object所指向的内存大小 -> 16
    NSObject *object = [[NSObject alloc] init];
    size_t size2 = malloc_size((__bridge const void *)(object));

    !! // TODO:这里可以研究一下alloc的流程，最终allocWithZone

    // Q: 1.一个NSObject对象占用多少内存
    // A:系统分配了16个字节给NSObject对象(通过malloc_size函数获得,if (size < 16) size = 16; 最少16个字节)
 但NSObject对象内部只使用了8个字节的空间（64bit环境下,通过class_getInstanceSize函数获得）

     struct Stcccccccudent_IMPL {
         struct NSObject_IMPL NSObject_IVARS;
         int _age;
         int _no;
     };
     
     1.子类的结构体包含父类的结构体，后面是子类自己的成员变量
     2.结构体的大小必须是最大成员变量大小的倍数(结构体内存对齐)
     
     {
        @interface Person : NSObject
            @property (nonatomic, assign) int no;
            @property (nonatomic, assign) int height;
            @property (nonatomic, assign) int width;
        @end

        Person *person = [[Person alloc] init];
        NSLog(@"%zd", %zd", class_getInstanceSize([Person class]), malloc_size((__bridge const void *)(person)));
        // 输出： 24 32

        struct Person_IMPL {
            Class isa; // 8
            int _no; // 4
            int _age; // 4
            int _height; // 4
        }; // 24 bit

        calloc里面，有一个bucket_size{16,32, 48, 64, 80, 96, 112}，操作系统分配内存的时候，会分配16的倍数
        24是Person_IMPL结构体内存对齐后只需要24bit，但是实际操作系统分配了32bit
    }
    
    {
        Objective-C中的对象，即OC对象,主要可以分为3种
        1.instance对象（实例对象）
        2.class对象（类对象）
        3.meta-class对象（元类对象）
        
        instance对象就是通过类alloc出来的对象，每次调用alloc都会产生新的对象
        instance对象在内存中存储的信息包括：
            1.isa指针(也是instance对象的内存地址)
            2.其他成员变量
            
        class对象
        class对象在内存中存储的信息主要包括：
            1.isa指针
            2.superclass指针
            3.类的属性信息（@property）,类的对象方法信息（instance method）
            4.类的协议信息（protocol），类的成员变量信息（ivar-描述信息 ）
        class对象获取的方法：
                NSObject *obj1 = [[NSObject alloc] init];
                NSObject *obj2 = [[NSObject alloc] init];
                
                Class objectClass = [obj1 class];
                Class objectClass2 = [NSObject class];
                Class objectClass3 = object_getClass(obj1);
                NSLog(@"%p %p %p", objectClass, objectClass2, objectClass3);
                
        meta-class对象
        meta-data(描述数据的数据)
        meta-class在内存中存储的信息主要包括：
            1.isa指针
            2.superclass指针
            3.类的方法信息+(void)
        meta-class对象的获取方法：
            object_getClass([NSObject class]);
        
        class_isMetaClass()判断是否是元类对象
        
        
            instance                   class                        meta-class
              isa                       isa                             isa
           其他成员变量                superclass                      superclass
                            属性、对象方法、协议、成员变量信息               类方法
    }
    
    {
        isa指针
        instance的isa指向class
        当调用对象方法时，通过instance的isa找到class，最后找到对象方法的实现进行调用
        class的isa指针指向meta-class
        当调用类方法时，通过class的isa找到meta-class，最后找到类方法的实现进行调用
        superclass指针指向父类的对应c指针
    }
    
    {
         创建一个实例对象，至少需要多少内存？
         #import <objc/runtime.h>
         class_getInstanceSize([NSObject class]);
         
         创建一个实例对象，实际上分配了多少内存
         #import <malloc/malloc.h>
         malloc_size((__bridge const void *) obj);
     }
