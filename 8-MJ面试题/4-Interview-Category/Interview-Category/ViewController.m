//
//  ViewController.m
//  Interview-Category
//
//  Created by Red-Fish on 2021/12/13.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
#import "Student+Test1.h"
#import "Student+Test2.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Q:Category的使用场合是什么？
    // A:类想要拆解成不同的模块
    
    // Q:Category的实现原理
    
    Person *person = [[Person alloc] init];
    [person run];
    //objc_msgSend(person, @selector(run));
    //[person eat];
    //[person test];
    
    /*
     通过runtime动态将分类的方法合并到类对象、元类对象中
     */
    
    /*
     struct _category_t {
         const char *name;
         struct _class_t *cls;
         const struct _method_list_t *instance_methods;
         const struct _method_list_t *class_methods;
         const struct _protocol_list_t *protocols;
         const struct _prop_list_t *properties;
     };
     */
    
    /*
     1.通过Runtime加载某个类的所有Category数据
     2.把所有Category的方法，属性，协议数据，合并到一个大数组中（后面参与编译的Category数据，会在数据的前面）
        扩容、原方法内存位移、新方法添加
     3.将合并后的分类数据（方法、属性、协议）,插入到类原来的数据前面
     
     objc-os.mm
     objc_init -> map_images -> map_images_nolock
     objc_runtime-new.mm
     _read_images -> remethodizeClass -> attachCategoryis -> attachList -> realloc,memmove,memcpy
     */
    
    /*
     A:Category编译之后的底层结构是strut _category_t，里面存储着分类的对象方法、类方法、属性、协议信息，在程序运行的时候，runtime会将category的数据，合并到类信息中（类对象、元类对象中）
     */
    
    // Q:Category的Extension的区别是什么
    // A: Extension（匿名分类），本来公开的信息可以放在Extension中
    // Extension在编译的时候将所有extension信息合并到class信息中
    // Category在runtime的时候讲所有category信息合并到class信息中
    
    // Q:Category中有load方法吗？load方法是什么时候调用的，load方法能继承吗？
    [Person tttt];
    
    
    /*
     `load方法在runtime加载类、分类的时候调用
     
     `每个类、分类的+load，在程序运行过程中只调用一次
     
     ·调用顺序
     1-先调用类的+load
     按照编译先后顺序调用（先编译先调用）
     调用子类的+load之前会先调用父类的+load
     2-在调用分类的+load
      `按照编译先后顺序调用（先编译，后调用）
     */
    
    // A:有
    // load方法在runtime加载的时候调用。通过函数指针找到函数直接调用。
    // load方法可以继承，一般情况子不会主动调用，让系统调用。
    
    [self printMethodNamesOfClass:object_getClass([Person class])];
    
    // Q:load,initialize方法的区别是什么？他们在Category中的调用顺序，以及出现继承时他们之间的调用过程
    
    /*
      initialize在类第一次接受到消息的时候调用
     ·调用顺序：
        先调用父类的+initialize，再调用子类的+initialize
     
     ·+initialize和+load的很大区别是，+initialize是通过obc_msgSend进行调用的，所以有一下特点：
        如果子类还没实现+initialize，会调用父类的+initialize(所以父类的+initialize可能会被调用多次)
        如果分类实现了+initialize，就会覆盖类本身的+initialize调用
     */
    
    /*
     objc4源码解读过程
     objc-msg-arm64.s:
     objc_msgSend
     
     objc-runtime-new.mm
     class_getInstanceMethod
     lookUpImpOrNil
     _class_initialize
     callInitializ
     obc_msgSend(cls, SEL_initialize)
     */
    
    // A:load,initialize区别：
    // 1.调用方式
    // load是根据函数地址直接调用
    // +initialize是通过objc_msgSend调用
    // 2.调用时刻
    // load是runtime加载类、分类的时候调用，只会调用一次
    // initialize是类第一次接收到消息的时候调用，每一个类只会initialize一次（父类的initialize方法可能会被调用多次）
    
    // load,initialize在category中的调用顺序
    // load
    // 1.先调用类的load
    // 先编译的类，优先调用load
    // 调用子类的load之前，会先调用父类的load
    // 2.再调用分类的load
    // 先编译的分类，优先调用load
    // initialize
    // 1.先初始化父类
    // 2.再初始化子类(可能最终调用的是父类的initialize方法)
    
    // Q:Category是否能添加成员变量？如果可以，如何给Category添加成员变量
    Student *student = [[Student alloc] init];
    student.age = 10;
    student.num = 11;
    NSLog(@"age:%d num:%d name:%@", student.age, student.num, student.name);
    
    /*
     OBJC_ASSOCIATION_ASSIGN = 0,           **< Specifies a weak reference to the associated object.
     !!! assign
     OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, **< Specifies a strong reference to the associated object.  The association is not made atomically. *
     !!! strong, nomatomic
     OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   **< Specifies that the associated object is copied. The association is not made atomically. *
     !!! copy, nomatomic
     OBJC_ASSOCIATION_RETAIN = 01401,       **< Specifies a strong reference to the associated object. The association is made atomically. *
     !!! strong, atomic
     OBJC_ASSOCIATION_COPY = 01403          **< Specifies that the associated object is copied. The association is made atomically. *
     !!! copy, atomic
     */
    
    /*
     实现关联对象技术的核心对象：
        AssociationManager
        AssociationHashMap
        ObjectAssociationMap
        ObjectAssociation
     
     objc_setAssociatedObject(id  _Nonnull object, const void * _Nonnull key, id  _Nullable value, objc_AssociationPolicy policy);
     
     class AssociationsManager {
        AssociationsHashMap *_map;
     }
     
     <id  _Nonnull object, ObjectAssociationMap>
     
     typedef DenseMap<DisguisedPtr<objc_object>, ObjectAssociationMap> AssociationsHashMap;
     
     <const void * _Nonnull key, ObjcAssociation>
     
     typedef DenseMap<const void *, ObjcAssociation> ObjectAssociationMap;
     
     class ObjcAssociation {
         uintptr_t _policy;   < id  _Nullable value
         id _value;           < objc_AssociationPolicy policy
     }
     
     ·关联对象并不是存储在被关联对象本身内存中
     
     */
    
    // A:不能直接添加成员变量，因为分类的_category_t 结构体里不包含ivars成员变量数组，通过objc_setAssociatedObject,objc_getAssociatedObject
}

- (void)printMethodNamesOfClass:(Class)cls {
    
    NSLog(@"start pint -------------");
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


@end
