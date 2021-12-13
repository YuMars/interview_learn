//
//  ViewController.m
//  Interview-Category
//
//  Created by Red-Fish on 2021/12/13.
//

#import "ViewController.h"
#import "Person.h"

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
     load方法在runtime加载类、分类的时候调用
     */
    
    // Q:load,initialize方法的区别是什么？他们在Category中的调用顺序，以及出现继承时他们之间的调用过程
    
    // Q:Category是否能添加成员变量？如果可以，如何给Category添加成员变量
}


@end
