[TOC]

# 一、Runtime

## 什么是Runtime

Objective-C是一门动态性比较强的编程语言，允许很多操作推迟到程序运行时再进行，OC的动态性就是由Runtime来支撑和实现，Runtime是一套C语言编写的API，封装了很多动态性相关的函数，平时编写的OC代码，底层都是通过转成了Runtime API进行调用，只有在运行时才知道真正调用了哪个函数。比如调用方法[person eat],实际转成了  [person objc_msgSend(@selector(eat))] 函数的调用。

其中objc_msgSend底层有3大阶段，消息发送、动态方法解析、消息转发。在消息发送阶段有当前类或者父类或者缓存(cache)中查找方法。

其他的应用还有：方法交换、动态添加方法、属性等

## 1.介绍下runtime的内存模型（isa、对象、类、metaclass、结构体的存储信息等）

### isa

在OC中每一个对象本质都是一个有isa指针的结构体，实例对象的isa指针指向所属的类对象，类对象的isa指针指向所属的元类(meta-class)对象，元类对象(meta-class)的isa指针指向自己。`[图runtime-001]`

1.  实例对象的结构体是isa指针和其成员对象。
2.  类对象的结构体是isa指针、superclass指针、类的属性信息（ @property)、类的对象方法信息（instance method）、类的协议信息（protocol）、类的成员变量信息（ivar）、方法缓存
3.  元类对象的结构体是isa指针、superclass指针，类的类方法信息（class method）

> isa结构体信息

    union isa_t {
        isa_t() { }
        isa_t(uintptr_t value) : bits(value) { }
        Class cls;
        uintptr_t bits;
        struct {
            ISA_BITFIELD;  // defined in isa.h
            /*
             uintptr_t nonpointer        : 1; //(0：普通指针，存储Class、Meta-Class对象 1：优化过使用位域存储更多信息)
             uintptr_t has_assoc         : 1; //(是否有设置过关联对象,如果没有，释放会更快）
             uintptr_t has_cxx_dtor      : 1; //(是否有C++析构函数，如果没有，释放更快）
             uintptr_t shiftcls          : 33; //MACH_VM_MAX_ADDRESS 0x1000000000(存储Class、Meta-Classs对象的内存地址)
             uintptr_t magic             : 6; // (用于在调试的时候分辨对象是否有初始化)
             uintptr_t weakly_referenced : 1; // (是否有被弱引用指向，如果没有，释放会更快)
             uintptr_t deallocating      : 1; // (对象是否正在释放)
             uintptr_t has_sidetable_rc  : 1; // (引用计数器是否很大无法存储在isa中、如果为1，那么引用计数器会存储在一个叫SideTable的类的属性中)
             uintptr_t extra_rc          : 19 // (里面存储的值是引用计数器减一)
             */
        };
    };

> 实例对象结构体

    struct objc_object {
    private:
        isa_t isa;
    }

> 类对象结构体(元类对象的结构体和类对象是相同的，在class_rw_t的flag标记是否是元类对象)

    struct  objc_class : objc_object { // 
        Class superclass;
        cache_t cache; // 方法缓存            // formerly cache pointer and vtable //
        class_data_bits_t bits;// 用于获取具体的类信息    // class_rw_t * plus custom rr/alloc flags
        class_rw_t *data();
    }

### superclass

类(class)对象的superclass指针指向superclass的类（class）对象，如果没有superclass，则指向nil
元类(meta-class)对象的superclass指针指向superclass的元类对象，基类的元类对象的superclass指针指向基类的class对象

## 2.为什么要设计metaclass

1.  保持一致性

*   实例对象isa 指针指向其所属的类。
*   类对象isa 指针指向其对应的元类。
*   元类元类的 isa 指针指向根元类（例如 NSObject 的元类）。

1.  IMP lookUpImpOrForward(id inst, SEL sel, Class cls, int behavior) { }函数需要传入参数cls，这个参数并不知道是实例对象还是类对象，查找缓存的时候需要判断cls是什么对象。通过元类对象就可以巧妙的解决这个问题，实例对象存储属性值，类对象存储实例方法列表，元类对象存储类方法列表，更加符合单一原则【编程六大原则1.单一职责2.里氏替换则3.接口隔离4.依赖倒置5.依赖倒置6.开闭】

## 3.class_copyIvarList & class_copyPropertyList区别

ivar = property + @interface大括号里面声明的变量
property是@property修饰过的变量
ivar在底层，从cls->data->ro下获取，property是cls->data->rw下获取

## 4.class_rw_t 和 class_ro_t 的区别

class_ro_t 在运行时，通常不会直接修改这部分数据。
class_rw_t 运行时通过这个结构体支持类的动态扩展能力，动态添加的方法、属性等，Category添加的方法、属性等，并且class_rw_t包含了class_ro_t

```
// （成员变量）
class_ro_t {
    const char * name;
    method_list_t * baseMethodList;
    protocol_list_t * baseProtocols;
    const ivar_list_t * ivars;

    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;
}

// (实例方法、实例属性、协议)
class_rw_t { 
    const class_ro_t *ro;
    method_array_t methods;
    property_array_t properties;
    protocol_array_t protocols;
}


```

## 5.category如何被加载的,两个category的同名⽅法的加载顺序，两个category的+load⽅法的加载顺序，两个category的+initialize⽅法的加载顺序

> category结构体

    struct category_t {
        const char *name;
        classref_t cls;
        struct method_list_t *instanceMethods;
        struct method_list_t *classMethods;
        struct protocol_list_t *protocols;
        struct property_list_t *instanceProperties;
        struct property_list_t *_classProperties;
        
        //***判断是是否是元类还是类对象的方法、属性
    }

* `这里需要延伸Mach-O的加载流程，其中也会涉及到dyld3、dyld4的区别，具体细节在Mach-O部分查看`
    app启动加载Mach-O到objc_init流程后(从上往下顺序执行)：
```
    objc-os.mm
    objc_init               
    _dyld_objc_notify_register(&map_images/*加载mach-O*/, load_images/*加载分类等镜像*/, unmap_image)
    
    map_images
    map_images_nolock
    
    objc-runtime-new.mm
    _read_images
    remethodizeClass
    attachCategories
    attachLists
    realloc、memmove、 memcpy
    ------------------------
    上面是Category的加载顺序，下面是+load的加载顺序
    ------------------------
    load_images

    prepare_load_methods
    schedule_class_load  /*会从父类开始遍历加载(cls->superclass)*/
    add_class_to_loadable_list
    add_category_to_loadable_list
    
    call_load_methods
    call_class_loads /*优先调用类的 + (void)load*/
    call_category_loads  /*再调用分类的 +load()*/
    (*load_method)(cls, SEL_load)
    +load方法是根据方法地址直接调用，并不是经过objc_msgSend函数调用
    ------------------------
    下面是+initialize的加载顺序
    ------------------------
    objc-msg-arm64.s
    objc_msgSend
    
    objc-runtime-new.mm
    class_getInstanceMethod
    lookUpImpOrNil
    lookUpImpOrForward
    _class_initialize
    callInitialize
    objc_msgSend(cls, SEL_initialize)

```


### 5.1 category如何被加载的


```
void attachLists(List* const * addedLists, uint32_t addedCount) {
    if (addedCount == 0) return;

    if (hasArray()) {// 多->多
        uint32_t oldCount = array()->count;
        uint32_t newCount = oldCount + addedCount;
        setArray((array_t *)realloc(array(), array_t::byteSize(newCount))); // 重新分配内存
        array()->count = newCount;
        memmove(array()->lists + addedCount, array()->lists, 
                oldCount * sizeof(array()->lists[0])); // 扩容
        memcpy(array()->lists, addedLists, 
               addedCount * sizeof(array()->lists[0]));// 扩容后复制新增的(也就意味着相同方法，会先调用后编译的分类)
    } else if (!list  &&  addedCount == 1) { // 0 -> 1
        list = addedLists[0];
    } else { // 1 -> 多
        List* oldList = list;
        uint32_t oldCount = oldList ? 1 : 0;
        uint32_t newCount = oldCount + addedCount;
        setArray((array_t *)malloc(array_t::byteSize(newCount)));
        array()->count = newCount;
        if (oldList) array()->lists[addedCount] = oldList;
        memcpy(array()->lists, addedLists, 
               addedCount * sizeof(array()->lists[0]));
    }
}

```
`memcpy(array()->lists, addedLists,  addedCount * sizeof(array()->lists[0]));// 扩容后复制新增的(也就意味着相同方法，会先调用后编译的分类)`

在添加category的时候会先扩容，然后把旧的内容（属性、方法、协议）往后挪，通过category新添加的内容往前插入。所以category后面添加的内容（属性、方法、协议）总是在优先被调用，baseClass的属性被往后偏移了，即：后编译的category会先add到数组的前面


### 5.2 category的+load⽅法的加载顺序
- +load方法会在runtime加载类、分类时调用
每个类、分类的+load，在程序运行过程中只调用一次

- 先调用类的+load
按照编译先后顺序调用（先编译，先调用）
调用子类的+load之前会先调用父类的+load

- 再调用分类的+load
按照编译先后顺序调用（先编译，先调用）

### 5.3 category的+initialize⽅法的加载顺序
先调用父类的+initialize，再调用子类的+initialize
(先初始化父类，再初始化子类，每个类只会初始化1次)

+initialize是通过objc_msgSend进行调用的，所以有以下特点
如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）
如果分类实现了+initialize，就覆盖类本身的+initialize调用


## 6.category & extension区别，能给NSObject添加Extension吗，结果如何
category:
运行时添加分类属性/协议/方法 
分类添加的方法会“覆盖”原类方法，因为方法查找的话是从头至尾，一旦查找到了就停止了 
同名分类方法谁生效取决于编译顺序，读取的信息是倒叙的，所以编译越靠后的越先读入 
名字相同的分类会引起编译报错;

extension:
编译时决议
只以声明的形式存在，多数情况下就存在于 .m 文件中; 不能为系统类添加扩展


## 7.什么是消息转发机制，消息转发机制和其他语⾔的消息机制优劣对⽐

对C语言来说函数调用在编译的时候已经决定调用哪个函数，OC的函数调用称为消息发送，属于动态调用过程，在编译时不能决定真正调用哪个函数(也就是说，在编译阶段，OC可以调用任何函数，即使这个函数并未实现，只要申明过就不会报错。而C语言在编译阶段就会报错)。
Runtime的方法查找执行调用顺序： 
1. 直接通过objc_msgSend()消息发送进行方法查询 
2. 动态方法解析 +resolveInstanceMethod，+resolveClassMethod
3. 消息转发 -forwardingTargetForSelector，-methodSignatureForSelector，-forwardInvocation

## 8.在⽅法调⽤的时候，⽅法查询-> 动态解析-> 消息转发之前做了什么
·首先检查selector是不是要忽略（MacOS有了垃圾回收就不会理会retain，release）
·检查这个selector的target是不是nil，如果是nil就不会crash运行时被忽略

## 9.IMP、SEL、Method的区别和使⽤场景

IMP：
// 指向一个方法实现的指针
typedef id (*IMP)(id, SEL, ...); 

SEL：
// 代表一个方法的不透明类型
typedef struct objc_selector *SEL;

Method：
// Method和我们平时理解的函数是一致的，就是表示能够独立完成一个功能的一段代码，比如：-(void )message{}
struct objc_method {
    SEL method_name;
    char *method_types;
    IMP method_imp;
}

- IMP 是指向方法实现的指针，用于直接调用方法。
- SEL 是方法的选择器，表示方法的名字或标识符。
- Method 是对方法的整体封装，包含了方法的 SEL、IMP 以及其他元数据。

## 10.load、initialize⽅法的区别什么？在继承关系中他们有什么区别
调用时机不同：
+load是App启动过程中加载类或者分类到内存的时候调用，会自动调用+load里面的实现，且只会调用1次
+initialize是通过objc_msgSend进行调用的，所以有以下特点
如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）

调用顺序不同：
+load 先调用类的方法，在调用分类的方法，按照编译先后顺序调用（先编译，先调用），调用子类的+load之前会先调用父类的+load
+initialize 先调用父类的+initialize，再调用子类的+initialize(先初始化父类，再初始化子类，每个类只会初始化1次)

### load、initialize继承关系：
load 方法不会继承。如果父类和子类都实现了 load 方法，那么它们各自的 load 方法都会被独立调用。即使子类不实现 load 方法，也不会调用父类的 load 方法作为替代

initialize 方法遵循正常的继承规则。子类可以继承父类的 initialize 方法，但如果子类实现了自己的 initialize 方法，那么就会覆盖父类的 initialize 方法。
如果子类实现了 initialize 方法，父类的 initialize 方法就不会被自动调用，除非子类显式调用 [super initialize]。

## 11.说说消息转发机制的优劣
优点：
- 灵活，有高度的动态性，允许方法拦截和替换
- 方便，方法无法响应时可以转发给其他对象处理。

缺点：
- 性能开销大，消息发送的流程长执行的代码多
- 会有方法交换的隐患，增加代码的不确定性

# 二、NSNotification

## 1.NSNotification实现原理（结构设计、通知如何存储的、 name&observer&SEL 之间的关系等）
全局有一个NCTable结构体类型的table,NCTable里面有3个字段分别记录了named,nameless,wildcard代表了通知的三种类型：
named：发送通知的时候有name，有object
nameless：发送通知的时候只有name，没有object
wildcard：发送通知的时候没有name，没有object

> named是一个Maptable结构体

NSNotification添加的时候selector和Observer存储在一个Observation结构体中。
named表中以NSNotification的name作为key，MapNode作为value存储，MapNode以object作为key，Observation作为value存储。
NSNotification发送的时候，则以对应的方式从named表中取出对应name，object，selector，observer的，通过[observer performSelector:selector withObject:notification]的方式发送通知

> nameless是一个Maptable结构体

NSNotification添加的时候selector和Observer存储在一个Observation结构体中。
nameless以NSNotification的object作为key，Observation作为value存储。
NSNotification发送的时候则跟named逻辑相同

> wildcard则是一个Observation链表结构。

NSNotification添加的时候selector和Observer存储在一个Observation结构体中
wildcard链表有一个next指向下一个存储的Observation结构体。
NSNotification发送的时候则跟named逻辑相同。

这里值得注意的是，不管发送哪种类型的通知，通知发送的时候都会把所有wildcard链表中存储的通知发送出去。因为在查找通知的时候，会优先查找wildcard存储的通知，然后根据object判断nameless表中的通知，最右判断named表中name和object分别作为key的通知。

## 2.通知的发送时同步的，还是异步的
通知队列NSNotificationQueue发送NSPostingStyle有种，分别是NSPostWhenIdle，NSPostASAP，NSPostNow。对应runloop空闲时发送，runloop事件完成中间尽快发送，立即发送。
发送的时候，NSPostNow会在当前线程的runloop同步发送。
NSPostWhenIdle会添加到idleQueue队列中发送，NSPostASAP会添加到asapQueue队列中发送。
所以Post是同步的，但会根据runloop延时发送。

## 3.NSNotificationCenter 接受消息和发送消息是在⼀个线程⾥吗？如何异步发送消息
异步线程发送通知则响应函数也是在异步线程,主线程发送则在主线程.
开启异步线程发送通知

## 4.NSNotificationQueue 是异步还是同步发送？在哪个线程响应
NSNotificationCenter都是同步发送的，NSNotificationQueue的异步发送，从线程的角度看并不是真正的异步发送，或可称为延时发送，它是利用了runloop的时机来触发的.
异步线程发送通知则响应函数也是在异步线程,主线程发送则在主线程.

## 5.NSNotificationQueue 和 runloop 的关系
NSNotificationQueue依赖runloop. 因为通知队列要在runloop回调的某个时机调用通知中心发送通知.


## 6.如何保证通知接收的线程在主线程
1.在主线程指定队列 addObserverForName:object:queue:usingBlock:
2.NSMachPort的方式 通过在主线程的runloop中添加machPort，设置这个port的delegate，通过这个Port其他线程可以跟主线程通信，在这个port的代理回调中执行的代码肯定在主线程中运行，所以，在这里调用NSNotificationCenter发送通知即可

## 7.⻚⾯销毁时不移除通知会崩溃吗
iOS9.0之前，会crash，原因：通知中心对观察者的引用是unsafe_unretained，导致当观察者释放的时候，观察者的指针值并不为nil，出现野指针.
iOS9.0之后，不会crash，原因：通知中心对观察者的引用是weak。

## 8.多次添加同⼀个通知会是什么结果？多次移除通知呢
多次添加：多次添加发送一次通知，接收多次通知回调。
多次移除通知不会产生crash。

## 9.下⾯的⽅式能接收到通知吗？为什么
```
// 发送通知
[[NSNotificationCenter defaultCenter] addObserver:self
selector:@selector(handleNotification:) name:@"TestNotification" object:@1];
// 接收通知
[NSNotificationCenter.defaultCenter postNotificationName:@"TestNotification"
object:nil];
```
不能。name、object、observer、selector唯一对应性

下面为什么能接收到通知
```
// 接收通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"TestNotification" object:nil];
// 发送通知
[NSNotificationCenter.defaultCenter postNotificationName:@"TestNotification" object:@1];
```
发送通知的时候底层代码对object，object == nil，object =! nil的时候都发送了通知

# 三、内存 && weak指针 && 关联对象

## 1.weak的实现原理？SideTable的结构是什么样的
```
NSObject *obj = [[NSObject alloc] init];
id weak *obj1 = obj;
↓
id objc_initWeak(id *location/* 弱指针地址 */, id newObj/* 对象指针*/) 
storeWeak()
```
全局有一个SideTables(StripedMap<SideTable> &SideTables),object对象作为key，SideTable作为value。
> SideTable结构体

```
struct SideTable {
    spinlock_t slock; // 保证原子操作的自旋锁
    RefcountMap refcnts; // 引用计数hash表(协助isa指针的extra_rc共同引用技术的变量)
    weak_table_t weak_table; // weak 引用全局 hash 表
}
```
SideTable有一个weak_table_t结构体记录了obj的全局弱引用

> weak_table_t结构体

```
struct weak_table_t {
    weak_entry_t *weak_entries; // 保存了所有指向指针对象的weak指针
    size_t    num_entries; // entries的数量
    uintptr_t mask; // hash数组的长度-1
    uintptr_t max_hash_displacement; // hashkey的 最大散列偏移
};
```
weak_table_t里面num_entries记录了objc弱引用的数量，weak_entry_t *weak_entries里保存了所有指向obj对象的weak指针，随着弱引用数量的增多会对weak_table_t进行扩容或者缩减


## 2.关联对象的应⽤？系统如何实现关联对象的
```
objc_getAssociatedObject(id object, const void *key)
objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
```
AssociationsManager是一个关联对象管理类，内部_mapStorage是个静态变量。
以object作为key，AssociationsManager在_mapStorage中找到对应的AssociationsHashMap，然后以key作为key找到ObjectAssociationMap，在ObjectAssociationMap有ObjectAssociation，存储policy和value

## 3.关联对象的如何进⾏内存管理的？关联对象如何实现weak属性

### 3.1关联对象结构

```
AssociationsManager {
    AssociationHashMap *_map;
}
    
AssociationsMap: {
    disguised_ptr_t ObjectAssociationMap
    disguised_ptr_t ObjectAssociationMap
          ↑
    &(id  _Nonnull object) 
    ....
}
    

ObjectAssociationMap: {
    void *      ObjectAssociation
    void *         ObjectAssociation
    ↑
    const void * _Nonnull key
    ...
}   
    
ObjectAssociation: {
    unitptr_t _policy
        id    _value
}
```
### 3.2 关联对象如何实现weak属性：
1.用__weak修饰对象,并将其用block包裹,关联时,关联block对象
```
-(void)setWeakvalue:(NSObject *)weakvalue {
    __weak typeof(weakvalue) weakObj = weakvalue;
    typeof(weakvalue) (^block)() = ^(){
        return weakObj;
    };
    objc_setAssociatedObject(self, weakValueKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSObject *)weakvalue {
    id (^block)() = objc_getAssociatedObject(self, weakValueKey);
    return block();
}
```

2.额外创造一个类WeakObjectContainer，在这个类里实现weak属性 weakObject ，虽然 分类里 retain 了一个 WeakObjectContainer，但是 WeakObjectContainer 最终会随着属性的持有对象一起销毁，不存在泄露。
```
WeakObjectContainer.h
@property (nonatomic, readonly, weak) id weakObject;
- (instancetype)initWithWeakObject:(id)object;

WeakObjectContainer.m

- (instancetype)initWithWeakObject:(id)object {
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    
    return self;
}

NSObject+AssociateWeak.h

@property(weak, nonatomic) NSObject *weakObject;

NSObject+AssociateWeak.m

#import <objc/runtime.h>
#import "WeakObjectContainer.h"

NSString const *kKeyWeakObject = @"kKeyWeakObject";
-(void)setWeakObject:(NSObject *)weakObject {
    WeakObjectContainer *container = [[WeakObjectContainer alloc] initWithWeakObject:weakObject];
    objc_setAssociatedObject(self, &kKeyWeakObject, (id)container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSObject *)weakObject {
    WeakObjectContainer *container = objc_getAssociatedObject(self, &kKeyWeakObject);
    return container.weakObject;
}
```
## 4.Autoreleasepool的原理？所使⽤的的数据结构是什么
调用了Autorelease的对象是通过AutoreleasePoolPage对象来管理的。
> `@autoreleasepool`转成中间代码如下

```
struct __AtAutoreleasePool {
  __AtAutoreleasePool() {
      atautoreleasepoolobj = objc_autoreleasePoolPush();
  }
    
  ~__AtAutoreleasePool() {
      objc_autoreleasePoolPop(atautoreleasepoolobj);
  }
    
  void * atautoreleasepoolobj;
};
```

AutoreleasePoolPage继承自AutoreleasePoolPageData结构体
```
struct AutoreleasePoolPageData {
    magic_t const magic;
    __unsafe_unretained id *next; // 下一个将要自动释放的对象的指针
    pthread_t const thread;
    AutoreleasePoolPage * const parent; //上一页AutoreleasePoolPageData表的地址
    AutoreleasePoolPage *child;//下一页AutoreleasePoolPageData表的地址
    uint32_t const depth;// 当前页在链表中的深度
    uint32_t hiwat; // 当前页内存使用的最高点
}
```
AutoreleasePoolPageData的child、parent记录下一页和上一页AutoreleasePoolPageData的地址，next指向下一个将要自动释放的对象。有一个hotpage标记当前正在使用的页
每生成一个AutoReleasepool就会设置一个POOL_BOUNDARY。
在当前线程所属的那次runloop休眠之前AutoreleasePool会释放对象


## 5.ARC的实现原理？ARC下对retain & release做了哪些优化
在iOS5以前使用的是MRC，需要手动管理对象的内存在什么时候释放，ARC称为自动引用计数，是一种内存管理机制，在ARC环境下编译器会自动插入retain、release和autorelease的内存管理方法以管理对象的声明周期。
每一个OC对象都一个引用计数器，表示有多少个对象强引用指向该对象，当一个对象的引用计数变成0时，表示没有任何对象强引用该对象，该对象会被释放。retain：引用计数加1。release：引用计数减1。dealloc：当引用计数器变成0时系统会自动调用对象的dealloc方法，释放对象占用的内存。

### ARC下对retain & release做了哪些优化
ARC编译器有两部分，分别是前端编译器和优化器

- 前端编译器:前端编译器会为“拥有的”每一个对象插入相应的release语句。如果对象的所有权修饰符是`__strong`，那么它就是被拥有的。1.如果在某个方法内创建了一个对象，前端编译器会在方法末尾自动插入release语句以销毁它。2.而类拥有的对象（实例变量/属性）会在dealloc方法内被释放。，ARC编译器会自动帮完成dealloc方法或调用父类的dealloc方法。由编译器在生成的代码的时候会一些假设，让releasse语句性能更好。
在ARC中，没有类可以覆盖release方法，也没有调用它的必要。ARC会通过直接使用`objc_release`来优化调用过程。而对于retain也是同样的方法。ARC会调用objc_retain来取代保留消息

- ARC优化器: 前端编在代码中有时仍会出现几个对retain和release的重复调用。ARC优化器负责移除多余的retain和release语句，确保生成的代码运行速度高于手动引用计数的代码


## 6.ARC下哪些情况会造成内存泄漏
1.NSTimer CADisplayLink。 VC(self)中持有Timer定时器，Timer定时器中又持有VC(self)
    解决办法：1.用Proxy2.用Block处理
2.vc和model都有对方的属性，并且互相strong引用。解决：其中一个使用weak
3.引用了单例对象的某个属性，导致无法释放。解决：手动控制释放
4.delegate是修饰用了strong。解决：用weak
5.非OC对象。解决：CGImageRef手动创建之后需要release
6.block引起的循环引用。解决：1.用`__weak`修饰 2.用`__block`修饰3.使用proxy

## 7.Method Swizzle 注意事项
1.避免交换父类的方法
2.交换方法应在+load方法
3.交换方法应该放到dispatch_once中执行
4.交换的分类方法应该添加自定义前缀，避免冲突
5.交换的分类方法应调用原实现

## 8.属性修饰符atomic的内部实现是怎么样的?能保证线程安全吗
```
void objc_setProperty_atomic(id self, SEL _cmd, id newValue, ptrdiff_t offset)
↓
static inline void reallySetProperty(id self, SEL _cmd, id newValue, ptrdiff_t offset, bool atomic, bool copy, bool mutableCopy) {
    if (offset == 0) {
        object_setClass(self, newValue);
        return;
    }

    id oldValue;
    id *slot = (id*) ((char*)self + offset);

    if (copy) {
        newValue = [newValue copyWithZone:nil];
    } else if (mutableCopy) {
        newValue = [newValue mutableCopyWithZone:nil];
    } else {
        if (*slot == newValue) return;
        newValue = objc_retain(newValue);
    }

    if (!atomic) {
        oldValue = *slot;
        *slot = newValue;
    } else {
        spinlock_t& slotlock = PropertyLocks[slot];
        slotlock.lock();
        oldValue = *slot;
        *slot = newValue;        
        slotlock.unlock();
    }

    objc_release(oldValue);
}

```
使用atomic 修饰属性，编译器会设置默认读写方法为原子读写，并使用互斥锁添加保护。

单独的原子操作绝对是线程安全的，但是组合一起的操作就不能保证。

## 9.iOS中内省的⼏个⽅法有哪些？内部实现原理是什么
对象在运行时获取其类型的能力称为内省。
1、对象是不是某个类型的对象 
```
+ (BOOL)isMemberOfClass:(Class)cls {
    return self->ISA() == cls;
}
```
2、对象是不是某个类型或某个类型子类的对象 
```
+ (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = self->ISA(); tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}
```
3、某个类对象是不是另外一个类型的子类 
```
+ (BOOL)isSubclassOfClass:(Class)cls {
    for (Class tcls = self; tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}
```
4、某个类对象是不是另外一个类型的父类 
```
+ (BOOL)isAncestorOfObject:(NSObject *)obj {
    for (Class tcls = [obj class]; tcls; tcls = tcls->superclass) {
        if (tcls == self) return YES;
    }
    return NO;
}
```
5、是否能响应某个方法 
```
BOOL objc_opt_respondsToSelector(id obj, SEL sel) {
#if __OBJC2__
    if (slowpath(!obj)) return NO;
    Class cls = obj->getIsa();
    if (fastpath(!cls->hasCustomCore())) {
        return class_respondsToSelector_inst(obj, sel, cls);
    }
#endif
    return ((BOOL(*)(id, SEL, SEL))objc_msgSend)(obj, @selector(respondsToSelector:), sel);
}
```
6、是否遵循某个协议 
```
- (BOOL)conformsToProtocol:(Protocol *)protocol {
    if (!protocol) return NO;
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
        if (class_conformsToProtocol(tcls, protocol)) return YES;
    }
    return NO;
}
```

## 10.class_、objc_getClass、object_getclass ⽅法有什么区别?
```
+ (Class)class { // 返回类本身
    return self;
}

- (Class)class { // 对象返回类对象，类对象返回元类对象，元类对象返回元类对象的基类
    return object_getClass(self);
}

Class object_getClass(id obj) { // 同上
    if (obj) return obj->getIsa();
    else return Nil;
}

Class objc_getClass(const char *aClassName) { // 返回类对象
    if (!aClassName) return Nil;
    // NO unconnected, YES class handler
    return look_up_class(aClassName, NO, YES);
}

```

# 四、Runloop

## 1.app如何接收到触摸事件的

> 1.物理层面

iPhone采⽤电容触摸传感器，利⽤⼈体的电流感应⼯作，由⼀块四层复合玻璃屏的内表⾯和夹层各涂有⼀层导电层，最外层是⼀层矽⼟玻璃保护层。当我们⼿指触摸感应屏的时候，⼈体的电场让⼿指和触摸屏之间形成⼀个`耦合电容`，对⾼频电流来说电容是直接导体。于是⼿指从接触点吸⾛⼀个很⼩的电流，这个电流分从触摸屏的四角上的电极流出，并且流经这四个电极的电流和⼿指到四个电极的距离成正⽐。控制器通过对这四个电流的⽐例做精确的计算，得出触摸点的距离。
> 2.iOS操作系统下封装和分发时间

iOS操作系统在不同进程采用IPC通信，触摸后的事件交由IOKit.framework处理封装成IOHIDEvent对象；通过消息发送⽅式将事件传递出去，发送给SpringBoard.app，它接收到封装好的IOHIDEvent对象，经过逻辑判断后做进⼀步的调度分发。例如，它会判断前台是否运⾏有应⽤程序，有则将封装好的事件采⽤ mach port 机制传递给该应⽤的主线程

（Port 机制在 IPC 中的应⽤是 Mach 与其他传统内核的区别之⼀，在 Mach中，⽤户进程调⽤内核交由IPC 系统。与直接系统调⽤不同，⽤户进程⾸先向内核申请⼀个 port的访问许可；然后利⽤ IPC 机制向这个 port 发送消息，本质还是系统调⽤，⽽处理是交由其他进程完成的。）
> 3.IOHIDEvent -> UIEvent

应⽤程序主线程的runloop申请了⼀个 mach port ⽤于监听 IOHIDEvent 的 Source1 事件，回调⽅法是 `__IOHIDEventSystemClientQueueCallback()` ，内部⼜进⼀步分发 Source0 事件，⽽Source0 事件都是⾃定义的，⾮基于端⼝ port，包括触摸，滚动，selector选择器事件，它的回调⽅法是 __UIApplicationHandleEventQueue() ，将接收到的 IOHIDEvent 事件对象封装成我们熟悉的UIEvent 事件；然后调⽤ UIApplication 实例对象的 sendEvent: ⽅法，将 UIEvent 传递给UIWindow 做⼀些逻辑判断⼯作：⽐如触摸事件产⽣于哪些视图上，有可能有多个，那⼜要确定哪个是最佳选项呢？ 等等⼀系列操作。这⾥先按下不表。

> 4.Hit-Testing 寻找最佳响应者

Source0 回调中将封装好的触摸事件 UIEvent（⾥⾯有多个UITouch 即⼿势点击对象），传递给视图UIWindow ，其⽬的在于找到最佳响应者，这个过程称之为 Hit-Testing。
1.事件是⾃下⽽上传递，即UIApplication -> UIWindow -> ⼦视图 -> ...->⼦视图的⼦视图;
2.后加的视图响应程度更⾼，即更靠近我们的视图;
3.如果某个视图不想响应，则传递给⽐它响应程度稍低⼀级的视图，若能响应，你还得继续往下传递，若某个视图能响应了，但是没有⼦视图 它就是最佳响应者。
4.寻找最佳响应者的过程中，UIEvent中的UITouch会不断打上标签：⽐如HitTestView是哪个、superview 是哪个、关联了什么 Gesture Recognizer。

> 5.UIResponder Chain 响应链找到最佳响应者

Hit-Testing 过程中我们⽆法确定当前视图是否为“最佳”响应者，此时⾃然还不能处理事件。因此处理机制应该是找到所有响应者以及最佳响应者(⾃下⽽上)，由它们构成了⼀条响应链；接着将事件沿着响应链⾃上⽽下传递下去 ——最顶端⾃然是最佳响应者，事件除了被响应者消耗，还能被⼿势识别器或
是 target-action 模式捕获并消耗。有时候，最佳响应者可能对处理 Event “毫⽆兴趣”，它们不会重写 touchBegan touchesMove ..等四个⽅法；也不会添加任何⼿势；但如果是 control(控件) ⽐ 如 UIButton ，那么事件还是会被消耗掉的。

## 2.为什么只有主线程的runloop是开启的
主线程需要刷新UI，识别手势事件，一直开启是为了方便最快速的响应，但是runloop也会进入休眠。

以下是runloop的声明周期
1.通知Observer：进入Runloop
2.通知Observer：即将处理timer
3.通知Observer：即将处理sources
4.处理blocks(CFRunLoopPerformBlock)
5.处理Source0(可能会再次处理Blocks)
6.如果存在source1，就跳转到第8步
7.通知Observer是：开始休眠  （切换到内核态层面sleep）
8.通知observers:结束休眠（被某个消息唤醒）
    处理Timer
    处理GCD Async to Main Queue
    处理Source1
9.处理Blocks
10.根据前面的执行结果，决定如何做
    回到第2步
11.通知Observers:退出Runloop

## 3.为什么只在主线程刷新UI
UIKit并不是⼀个线程安全的类，UI操作涉及到渲染访问各种View对象的属性，如果异步操作下会存在读写问题，⽽为其加锁则会耗费⼤量资源并拖慢运⾏速度。
另⼀⽅⾯因为整个程序的起点UIApplication是在主线程进⾏初始化，所有的响应事件都是在主线程上进⾏传递（如点击、拖动），所以view只能在主线程上才能对事件进⾏响应。
⽽在渲染⽅⾯由于图像的渲染需要以60帧的刷新率在屏幕上同时更新，在⾮主线程异步化的情况下⽆法确定这个处理过程能够实现同步更新

## 4.PerformSelector和runloop的关系
```
[self performSelector:@selector(perform) withObject:nil]
[self performSelector:@selector(perform) withObject:nil afterDelay:0]
```
第一种方法相当于[self objc_msgSend]。
第二种方法相当于在当前线程的runloop开启一个定时器timer，当前线程的runloop未开启的话方法不会执行。

### 4.1 以下代码输出了结果是什么
```
- (IBAction)test01:(id)sender {
    dispatch_async(self.concurrencyQueue2, ^{
        NSLog(@"[1] 线程：%@",[NSThread currentThread]);
        // 当前线程没有开启 runloop 所以改⽅法是没办法执⾏的
        [self performSelector:@selector(perform) withObject:nil afterDelay:0];
        NSLog(@"[3]");
    });
}

- (void)perform {
 NSLog(@"[2] 线程：%@",[NSThread currentThread]);
}

```
结果输出[1]....[3]，因为concurrencyQueue2没有保活，无法执行perform函数。


## 5.如何使线程保活
1.加计时器
```
NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer
* _Nonnull timer) {
 NSLog(@"timer 定时任务");
}];
NSRunLoop *runloop = [NSRunLoop currentRunLoop];
[runloop addTimer:timer forMode:NSDefaultRunLoopMode];
[runloop run];
```
2.NSPort
```
NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
[runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
[runLoop run];
```
3.放在do while循环中,while中标记是否终止
```
- (IBAction)testRunLoopKeepAlive:(id)sender {
    self.myThread = [[NSThread alloc] initWithTarget:self selector:@selector(start) object:nil];
    [self.myThread start];
}

- (void)start {
    self.finished = NO;
    do {
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate: [NSDate dateWithTimeIntervalSinceNow:0.1]];
    } while (!self.finished);
}

- (IBAction)closeRunloop:(id)sender {
    self.finished = YES; }- (IBAction)executeTask:(id)sender {
        [self performSelector:@selector(doTask) onThread:self.myThread withObject:nil waitUntilDone:NO];
    }

- (void)doTask {
    NSLog(@"执⾏任务在线程：%@",[NSThread currentThread]);
}
```

## 6.讲讲 RunLoop，项目中有用到吗？
1.线程保活
```
NSThread *backgroundThread = [[NSThread alloc] initWithBlock:^{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}];
[backgroundThread start];
```
2.处理定时器任务的时候，默认定时器是NSDefaultRunLoopMode，设计到UI滚动需要把timer加到runloop当中并且设置成NSRunLoopCommonModes模式。

```
NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update) userInfo:nil repeats:YES];

[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```

3.监听UI层面的卡顿，runloop可以监听系统层面的事件，可以通过runloop回调的事件来判断当前UI有无卡顿。

4.大量耗性能操作的话，延迟处理
[self performSelector:@selector(doHeavyTask) withObject:nil afterDelay:0.0];

## 7.Runloop内部实现逻辑？
```
struct __CFRunLoop {
    CFRuntimeBase _base;
    pthread_mutex_t _lock; // locked for  accessing mode list */
    __CFPort _wakeUpPort;  // used for CFRunLoopWakeUp 
    Boolean _unused;
    volatile _per_run_data *_perRunData; // reset for runs of the run loop
    pthread_t _pthread;
    uint32_t _winthread;
    CFMutableSetRef _commonModes;
    CFMutableSetRef _commonModeItems;
    CFRunLoopModeRef _currentMode; // 当前模式
    CFMutableSetRef _modes;        // 模式集合
    struct _block_item *_blocks_head;
    struct _block_item *_blocks_tail;
    CFAbsoluteTime _runTime;
    CFAbsoluteTime _sleepTime;
    CFTypeRef _counterpart;
};

struct __CFRunLoopMode {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;// must have the run loop locked before locking this
    CFStringRef _name;
    Boolean _stopped;
    char _padding[3];
    CFMutableSetRef _sources0;  // CFRunloopSourceRef 
    CFMutableSetRef _sources1;  // CFRunloopSourceRef
    CFMutableArrayRef _observers; // CFRunloopObserverRef 
    CFMutableArrayRef _timers; // CFRunloopTimerRef 定时器
    CFMutableDictionaryRef _portToV1SourceMap;
}
```
    
## 8.Runloop和线程的关系？
> CFRunLoop

- 每条线程都有唯一的一个与之对应的RunLoop对象
- RunLoop保存在一个全局的Dictionary里，线程作为key，RunLoop作为value
- 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建
- RunLoop会在线程结束时销毁
- 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop

> CFRunLoopModeRef

- CFRunLoopModeRef代表RunLoop的运行模式
- 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
- RunLoop启动时只能选择其中一个Mode，作为currentMode
- 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
- 不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
- 如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出


## 9.timer 与 runloop 的关系？
当 NSTimer 被添加到 RunLoop 中时，RunLoop 会按照 NSTimer 的设定时间间隔执行其任务。RunLoop 每次处理完事件后，会进入休眠状态，直到有新的事件到来（包括定时器到达时间时的触发）。
    
## 10.Runloop 是怎么响应用户操作的， 具体流程是什么样的？
1.手势操作事件传递，系统将捕获的事件封装成UIEvnet，通过mach port通知应用，UIApplication接手后传递到主线程的runloop中处理。
2.UI刷新是在每一次主线程当前runloop生命周期休眠前执行。

> - 触摸事件响应：用户触摸操作通过 RunLoop 被分发到相应的视图对象，并执行响应链中的方法。
> - UI刷新：每次 RunLoop 的循环结束时，系统会检查是否有 UI 需要更新，如果有，则执行绘制操作。
> - 定时器管理：NSTimer 依赖于 RunLoop 来控制定时事件的触发，通过 RunLoop 精确控制任务的定时执行。
> - 手势识别：RunLoop 管理手势识别器（UIGestureRecognizer）的触发，确保用户手势操作的响应顺畅。

## 11.说说RunLoop的几种状态

1.通知Observer：进入Runloop
2.通知Observer：即将处理timer
3.通知Observer：即将处理sources
4.处理blocks(CFRunLoopPerformBlock)
5.处理Source0(可能会再次处理Blocks)
6.如果存在source1，就跳转到第8步
7.通知Observer是：开始休眠  （切换到内核态层面sleep）
8.通知observers:结束休眠（被某个消息唤醒）
    处理Timer
    处理GCD Async to Main Queue
    处理Source1
9.处理Blocks
10.根据前面的执行结果，决定如何做
    回到第2步
11.通知Observers:退出Runloop

source0是非内核事件：dispatch_async，手动触发的事件、通知
source1是基于内核事件：mach_port，CFRunLoopSource
    
## 12.Runloop的mode作用是什么？
一个RunLoop包含若干个Mode，每个Mode又包含若干个Source/Timer/Observer。每次调用RunLoop 的主函数时，只能指定其中一个Mode，这个Mode被称作CurrentMode。如果需要切换Mode，只能退出 当前Loop，再重新指定一个Mode进入。这样做主要是为了分隔开不同组的Source/Timer/Observer，让其互不影响

# 五、Block

## 1. block 的内部实现，结构体是什么样的
block也是一个对象，主要分为`__block_impl`和`Block_descriptor`结构体
```
struct __block_impl {
    void *isa;           // block类型,gloableBlock-全局,mallocBlock-堆,stackBlock-栈
    int Flags;
    int Reserved;
    void *FuncPtr;    // block括号内部要执行的代码
    (void *(void *,...))invoke
    variables
    (struct Block_descriptor *)descriptor
};
```
```
Block_descriptor: {
    (unsigned long int)reserved
    (unsigned long int)size   // 函数大小
    (void *(void *, void *))copy
    (void *(void *))dispose
}
```
## 2. block是类吗，有哪些类型
有3种类。
NSConcreteGloalBlock，NSConcreteStackBlock，NSConcreteMallocBlock。根据Block对象创建时所处数据区不同⽽进⾏区别。

_NSGlobalBlock_             没有访问auto变量
_NSStackBlock_              访问了auto变量
_NSMallocBlock_             _NSStackBlock调用类copy

## 3. ⼀个int变量被__block修饰与否的区别？block的变量截获
在block中引用的int，无`__block`修饰的时候是值拷贝，有`__block`修饰的时候int是指针拷贝

block的变量截获有4种类型：
    ⾃动变量 auto
    静态变量 static
    静态全局变量 static (int)
    全局变量 (int)

静态、全局变量会自动引用，不需要通过结构体传入
static静态变量直接在block中保存了指针
auto自动变量在最开始的时候直接捕获值

## 4. block 在修改 NSMutableArray ，需不需要添加 __block
不需要。本身block内部就捕获了NSMutableArray指针，除非需要修改指针指向的对象。NSMutableArray一般只修改内存数据

## 5. block怎么进⾏内存管理的

> copy
判断block->flag按位与&如果是NSGloablBlock的时候，直接返回block，如果是NSMallocBlock,flag+1，返回block，如果是NSStackBlock的话，复制到堆上，更新flag为BLOCK_NEED_FREE，引用计数+1,更新isa。

> release
判断block->flag，如果是NSMallocBlock,flag-1，并且count>0，返回block。如果count == 0，释放堆上block以及捕获的对象变量。如果是NSGloablBlock的时候，直接返回block

```
//这里传入的参数实际上就是Block
void *_Block_copy(const void *arg) {
    return _Block_copy_internal(arg, WANTS_ONE);
}

static void *_Block_copy_internal(const void *arg, const int flags) {
    struct Block_layout *aBlock;

    //1.如果传递的参数为NULL，返回NULL。
    if (!arg) return NULL;
    
    //2.参数类型转换。转为指向Block_layout结构体的指针。Block_layout结构体请回顾文章开头，相当于clang转换后的__main_block_impl_0结构体，包括指向block的实现功能的指针和各种数据。
    aBlock = (struct Block_layout *)arg;

    //3.如果block的flags包含BLOCK_NEEDS_FREE，表明它是堆上的Block（为什么？见第7步注释）
    //增加引用计数，返回相同的block
    if (aBlock->flags & BLOCK_NEEDS_FREE) {
        // latches on high
        latching_incr_int(&aBlock->flags);
        return aBlock;
    
    //这里删掉了与垃圾回收（GC）相关的代码，GC不做讨论

    //4.如果是全局block，什么也不做，返回相同的block
    else if (aBlock->flags & BLOCK_IS_GLOBAL) {
        return aBlock;
    }

    // Its a stack block.  Make a copy.
    if (!isGC) {
        //5.能够走到这里，表明是一个栈Block。需要复制到堆上。第一步申请内存
        struct Block_layout *result = malloc(aBlock->descriptor->size);
        if (!result) return (void *)0;
        //6.将栈数据复制到堆上
        memmove(result, aBlock, aBlock->descriptor->size); // bitcopy first
        //7.更新block的flags
        //第一句后面的注释说它不是必须的。
        result->flags &= ~(BLOCK_REFCOUNT_MASK);    // XXX not needed
        //设置flags为BLOCK_NEEDS_FREE，表明它是一个堆block。内存支持它一旦引用计数=0，
        //就进行释放。 “|1”是用来把block的引用计数设置为1。
        result->flags |= BLOCK_NEEDS_FREE | 1;
        //8.block的isa指针设置为_NSConcreteMallocBlock
        result->isa = _NSConcreteMallocBlock;
        //9.如果block有copy helper函数就调用它（和block所持有对象的内存管理有关，文章后面会讲到这部分）
        if (result->flags & BLOCK_HAS_COPY_DISPOSE) {
            //printf("calling block copy helper %p(%p, %p)...\n", aBlock->descriptor->copy, result, aBlock);
            (*aBlock->descriptor->copy)(result, aBlock); // do fixup
        }
        return result;
    }
    else {
        //GC相关
    }
}

void _Block_release(void *arg) {
    //1.参数类型转换，转换为一个指向Block_layout结构体的指针。
    struct Block_layout *aBlock = (struct Block_layout *)arg;
    if (!aBlock) return;

    //2.取出flags中表示引用计数的部分，并且对它递减。
    int32_t newCount;
    newCount = latching_decr_int(&aBlock->flags) & BLOCK_REFCOUNT_MASK;
    //3.如果引用计数>0，表明仍然有对block的引用，block不需要释放
    if (newCount > 0) return;

    if (aBlock->flags & BLOCK_IS_GC) {
        //GC相关
    } else if (aBlock->flags & BLOCK_NEEDS_FREE) { //4.flags包含BLOCK_NEEDS_FREE（堆block），且引用计数=0
    
    //如果有copy helper函数就调用，释放block捕获的一些对象，对应_Block_copy_internal中的第9步
    if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE)(*aBlock->descriptor->dispose)(aBlock);
    _Block_deallocator(aBlock);    //释放block
    } else if (aBlock->flags & BLOCK_IS_GLOBAL) { //5.全局Block，什么也不做
        ;
    }
    //6.发生了一些奇怪的事情导致堆栈block视图被释放，打印日志警告开发者
    else {
        printf("Block_release called upon a stack Block: %p, ignored\n", (void *)aBlock);
    }
}

```

## 6. block可以⽤ strong 修饰吗
可以。类似copy，把block拷贝到堆上。

## 7. 解决循环引⽤时为什么要⽤ __strong、__weak 修饰
`__weak` 为了避免循环引用，⽽block 内部 __strong 则是在作⽤域 retain 持有当前对象
做⼀些操作，结束后会释放掉它。
具体可以看__weak原理

## 8. block 发⽣ copy 时机
block 从栈上拷⻉到堆上⼏种情况：
    调⽤Block的copy⽅法
    将Block作为函数返回值时
    将Block赋值给__strong修饰的变量或Block类型成员变量时
    向Cocoa框架含有usingBlock的⽅法或者GCD的API传递Block参数时
    
## 9. block访问对象类型的 auto变量 时，在 ARC和MRC 下有什么区别
简单来说：ARC下会对这个对象强引用，MRC下不会。
ARC下，由于block被自动copy到了堆区，从而对外部的对象进行强引用，如果这个对象同样强引用这个block，就会形成循环引用。
MRC下，由于访问的外部变量是auto修饰的，所以这个block属于栈区的，如果不对block手动进行copy操作，在运行完block的定义代码段后，block就会被释放，而由于没有进行copy操作，所以这个变量也不会经过Block_object_assign处理，也就不会对变量强引用。


## 10. _block的作用是什么？有什么使用注意点
将__block修饰的变量包装成对象,解决block内部无法修改auto变量的问题。需要注意内存管理



## 121.block的属性修饰符为什么是copy？使用block是哪些使用注意
block不使用copy，在栈上不会再堆上。

# 六、事件响应链

## 1. 说说事件的响应链
1.流程同 `4.1 app如何接收到触摸事件的`
总结：
1、当一个事件发生后，事件会从父控件传给子控件，也就是说由UIApplication -> UIWindow -> UIView -> initial view,以上就是事件的传递，也就是寻找最合适的view的过程。
2、接下来是事件的响应。首先看initialview能否处理这个事件，如果不能则会将事件传递给其上级视图（inital view的superView）；如果上级视图仍然无法处理则会继续往上传递；一直传递到视图控制器view controller，首先判断视图控制器的根视图view是否能处理此事件；如果不能则接着判断该视图控制器能否处理此事件，如果还是不能则继续向上传递；（对于第二个图视图控制器本身还在另一个视图控制器中，则继续交给父视图控制器的根视图，如果根视图不能处理则交给父视图控制器处理）；一直到 window，如果window还是不能处理此事件则继续交给application处理，如果最后application还是不能处理此事件则将其丢弃
3、在事件的响应中，如果某个控件实现了touches...方法，则这个事件将由该控件来接受，如果调用了[supertouches….];就会将事件顺着响应者链条往上传递，传递给上一个响应者；接着就会调用上一个响应者的touches….方法

# 七、KVO & KVC

## 1.KVO的实现原理
KVO全称Key Value Observer。一个对象被addObserver:forKeyPath添加监听后：
1.利用runtime动态生成一个继承当前类的NSKVONotifying_类名的类，并且让instance对象isa指向全新的子类
2.当修改instance对象的属性时（setter方法），实际调用Foundation的_NSSetxxxValueAndNotify函数
3._NSSetxxxValueAndNotify：
    1.willChangeValueForKey: 
    2.[super setXXX:] 
    3.didChangeValueForKey:
4.didChangeValueForKey内部再调用observeValueForKeyPath:ofObject:change:context:
5.重写+class（返回原先的子类），+dealloc（对象销毁时确保移除所有观察者），+isKVO（return yes）

例子：
NSKVONotifying_Person是Person的一个子类
[person setAge:] 调用了 [NSKVONotifying_Person setAge:], 调用了_NSSetIntValueAndNotify

_NSSet*ValueAndNotify的内部实现:
[self willChangeValueForKey:@""];
[super setValue:];
[self didChangeValueForKey:@""];(调用了- observeValueForKeyPath:keyPath ofObject:object change:change context:context)

## 2.如何⼿动关闭kvo
+automaticallyNotifiesObserversForKey:返回 NO

## 3.如何手动触发KVO
手动调用willChangeValueForKey:和didChangeValueForKey:

KVO在添加Observer的时候会先调用+automaticallyNotifiesObserversForKey:,判断能否自动通知。
但是可以通过1.willChangeValueForKey: 2.[supet setXXX:] 3.didChangeValueForKey:方式手动通知

## 3.通过KVC修改属性会触发KVO么
会触发。
1.KVC会先查询对应的getter、setter方法
2.没找到就会调用accessInstanceVariablesDirectly:
3.如果return YES.会按照: 
getter流程： getKey:  key:  isKey:  _key: _key  _isKey  key  isKey 顺序查找
setter流程：setKey:  _setKey:  _key  _isKey  key  isKey 顺序查找

## 4.哪些情况下使⽤kvo会崩溃，怎么防护崩溃
1.dealloc没有移除KVO观察者。解决方案：创建一个中间对象，将其做为某个属性的观察者，然后dealloc的时候去除观察者。调用者是持有中间对象，调用者释放，中间对象也就释放，dealloc也就移除观察者
2.多次重复移除同一属性的观察者，或者移除了未添加过的观察者
3.被观察者提前被释放，被观察者在dealloc时仍然注册着KVO，导致崩溃。例如：被观察者是局部变量，weak
4.添加观察者，但是未实现+observeValueForKeyPath:ofObject:change:context:方法，导致崩溃
5.添加或者移除时，keyPath:nil ，导致崩溃

## 5.KVO的优缺点

优点：
1.运用了设计模式：观察者模式
2.支持多个观察者观察同一属性，或者同一观察者监听不同属性
3.不需要实现属性变化的通知发送
4.对创建的对象的状态改变做出响应，不要改变对象的实现（比如SDK对象）
5.能够提供观察的属性新值和旧值
6.可以用key path来观察属性，所以可以观察嵌套对象
7.完成了对观察对象的抽象，因为不需要额外的代码来允许观察值能够被观察

缺点：
1.观察的属性键值硬编码（字符串），编译器无法发出警告
2.允许一对多观察属性，回调方法中可能有很多分支情况

# 八、UI视图 & Autolayout 

## 1. AutoLayout的原理，性能如何
AutoLayout源于Cassary算法，算法主要将基于约束系统的布局规则（本质上是表示视图布局关系的线性方程组）转化为表示规则的视图几何参数。

- Autolayout本质就是一个线程方程解析Engine，将视图间布局关系的约束集合由engine解析出最终数值。
- 一个约束对象NSLayoutConstraint，本质上是表示两个视图之间布局关系的线程方程，该方程可以是线性等式，也可以是线性不等式。
- 多个约束对象组成是一个约束集合，本质上是表示某个界面上多个视图之间布局关系的线性方程组。方程组中的多个线性方程，以数字标识的优先级进行排序。
- AutoLayout Engine根据按照线性方程的优先级从高到低对线性方程组进行解析，求的方程组的解

RedView-------|8|------BluView

RedView.Leading          =           1.0    x    BlueView.trailing      +       8.0
   |        |            |            |             |       |                   |
Item1  Attribute1    Relationship   Multiplier      Item2  Attribute2          Constant

- Item1、Item2：一般是UIView，表示该约束关系对应的两个视图，当约束等式表示尺寸时，其中一个Item为nil。
- Attribute1、Attribute2：NSLayoutAttribute类型，表示约束属性。当约束等式表示尺寸时，其中一个Attribute为NSLayoutAttributeNotAnAttribute，表示占位，无任何意义。
- Relationship：NSLayoutRelation类型，表示约束关系，可以是=、>=、<=。
- Multiplier：CGFloat类型，表示倍数关系，一般用于尺寸（eg：Item1的宽度为Item2的两倍，则Multiplier为2.0）
- Constant：CGFloat类型，表示常数。

## 2. UIView & CALayer的区别
UIView 为 CALayer 提供内容，以及负责处理触摸等事件，参与响应链；
CALayer 负责显示内容 contents
单⼀职责原则

## 3. drawrect & layoutsubviews调⽤时机

layoutsubviews:
1. init初始化不会触发layoutSubviews。
2. addSubview会触发layoutSubviews。
3. 改变一个UIView的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化。
4. 滚动一个UIScrollView引发UIView的重新布局会触发layoutSubviews。
5. 旋转Screen会触发父UIView上的layoutSubviews事件。
6. 直接调用setNeedsLayout 或者 layoutIfNeeded。

layoutIfNeeded会马上调用layoutsubviews
setNeedsLayout会标记下一个runloop要调用layoutsubviews

drawrect:
1、如果在UIView初始化时没有设置rect大小，将直接导致drawRect不被自动调用。drawRect 掉用是在Controller->loadView, Controller->viewDidLoad 两方法之后掉用的.所以不用担心在 控制器中,这些View的drawRect就开始画了.这样可以在控制器中设置一些值给View(如果这些View draw的时候需要用到某些变量值).
2、该方法在调用sizeToFit后被调用，所以可以先调用sizeToFit计算出size。然后系统自动调用drawRect:方法。
3、通过设置contentMode属性值为UIViewContentModeRedraw。那么将在每次设置或更改frame的时候自动调用drawRect:。
4、直接调用setNeedsDisplay，或者setNeedsDisplayInRect:触发drawRect:，但是有个前提条件是rect不能为0。

## 4. 隐式动画 & 显示动画区别


隐式动画是由系统自动触发CALayer层的动画。
显示动画指开发者通过代码明确定义和触发的动画，如[uiview animation], CABasicAnimation 等 Core Animation 动画类。

默认屏幕上看到的所有东西都可以做动画，动画不需要手动打开，但是需要明确关闭，否则动画会一直存在。隐式动画，其实是指我们可以在不设定任何动画类型的情况下，仅仅改变CALayer的一个可做动画的属性，就能实现动画效果。默认UIView的没有开启隐式动画。
隐式动画原理：动画执行的时间取决于当前事务(CATransaction)的设置，动画类型则取决于图层行为。CALayer自动执行的动画叫做行为，

隐式动画的触发：
1.CALayer实现了CALayerDelegate协议里面-actionForLayer:forKey方法
2.CALayer层检查包含属性名称对应行为映射的actions字典
3.CALayer在style字典里搜索属性名
4.CALayer直接调用定义了每个属性的标准行为的+defaultActionForKey:方法

开关隐式动画：
+setDisableActions:(BOOL)flag;
使用UIView的动画函数(而不是依赖CATransaction)
继承UIView，并覆盖-actionforLayer:forkey:方法
直接创建显式动画

## 5. 什么是离屏渲染
CPU Center Processing Unit,中央处理器
GPU Graphics Processing Unit，图形处理器

CPU ----计算----> GPU ----渲染----> 帧缓冲区----读取----> 视频控制器

CPU计算好数据之后传输给GPU，GPU开始渲染画面，过程中下一个垂直同步信号已经来到，但是CPU和GPU还没处理好数据，只能等待下一个垂直同步信号到来。
由于垂直同步的机制，如果在一个 HSync 时间内，CPU 或者 GPU 没有完成内容提交，则那一帧就会被丢弃，等待下一次机会再显示，而这时显示屏会保留之前的内容不变。这就是界面卡顿的原因。

On-Screen Rendering（当前屏幕渲染）指的是GPU的渲染操作是在当前用于显示的屏幕缓冲区中进行。
Off-Screen Rendering（离屏渲染）指的是GPU在当前屏幕缓冲区以外新开辟一个（离屏）缓冲区进行渲染操作。

哪些情况会产生离屏渲染：
1.光栅化 shouldRasterize
2.遮罩 mask
3.圆角 cornerRadius
4.阴影 shadowPath

以上效果无法直接绘制在视图上，避免影响视图内部的内容绘制，CoreAnimation需要先将该控件的内容在离屏缓冲区渲染，生成一个带有圆角的图层。然后，再将这个带有圆角的图层合成到主屏幕上。

苹果在iOS9以后做了一些优化：
1.只设置contents或者UIImageView的image，并加上圆角+裁剪，是不会产生离屏渲染的。但如果加上了背景色、边框或其他有图像内容的图层，还是会产生离屏渲染。
2.UIButton设置了图片的添加圆角和裁剪，则会触发离屏渲染。UIButton只设置了背景色添加圆角和裁剪，不会触发离屏渲染。为UIButton的imageview添加圆角和裁剪不会触发离屏渲染
3.

优化方式：
·对于图片的圆角，统一采用“precomposite”的策略，也就是不经由容器来做剪切，而是预先使用CoreGraphics为图片裁剪圆角
·对于视频的圆角，由于实时剪切非常消耗性能，我们会创建四个白色弧形的layer盖住四个角，从视觉上制造圆角的效果
·对于view的圆形边框，如果没有backgroundColor，可以放心使用cornerRadius来做
·对于所有的阴影，使用shadowPath来规避离屏渲染
·对于特殊形状的view，使用layer mask并打开shouldRasterize来对渲染结果进行缓存
·对于模糊效果，不采用系统提供的UIVisualEffect，而是另外实现模糊效果（CIGaussianBlur），并手动管理渲染结果

[iOS离屏渲染原理及优化](https://tenloy.github.io/2021/09/12/iOS-Render.html)

## 6. imageNamed & imageWithContentsOfFile区别

iOS常用的图片加载方法有-imageName: -imageWithContentOfFile:
imageName:
    1.首先会在系统缓存中根据指定的名字寻找图片，如果找到就返回，如果没有找到就在缓存中找到图片，该方法会在指定的文件夹中加载图片数据，并将其缓存起来，然后再返回结果，下次再使用相同名称的图片的时候，就省去了从硬盘中加载图片的过程。相同名称的图片，系统内存只会缓存一次。
    2.iOS4以上如果是PNG格式，使用该方法不用再指定.png的文件后缀，只要写文件名
    3.iOS4以上会根据屏幕的分辨率自动加载@2x,@3x后缀的图片。如果找不到对应的后缀，则加载无后缀的图片

imageWithContentsOfFile或者imageWithData:
    1.简单加载图片，不会缓存图片到内存中，图像会被系统以数据方式加载到app。适合不重用的图片，或者以数据方式存储到数据库中，或者加载网络大图时。
    2.必须传入图片文件的全名（路径+文件名）
    3.无法加载Image.xcassets的图片


总结：
    如果图片较小，并且使用频繁的图片使用imageName：方法来加载
    如果图片较大，并且使用较少，使用imageWithContentOfFile:来加载。
    当你不需要重⽤该图像，或者你需要将图像以数据⽅式存储到数据库，⼜或者你要通过⽹络下载⼀个很⼤的图像时，使⽤ imageWithContentsOfFile ；
    如果在程序中经常需要重⽤的图⽚，⽐如⽤于UITableView的图⽚，那么最好是选择imageNamed⽅法。这种⽅法可以节省出每次都从磁盘加载图⽚的时间；


## 7. 多个相同的图⽚，会重复加载吗
答案同上

## 8. 图⽚是什么时候解码的，如何优化

在未解码的图片数据加载完成后渲染到屏幕之前

一般我们使用的图像是JPEG/PNG，这些图像数据不是位图，而是是经过编码压缩后的数据，需要线将它解码转成位图数据，然后才能把位图渲染到屏幕上。
以+imageWithContentsOfFile为例：从磁盘加载图片时，图片并没直接进行解压，将UIImage传递给UIImageView后，隐式CATransaction捕获倒了UIImageView的图层树变化，在主线程的下一个runloop到来之前，Core Animation提交了这个隐式CATransaction，然后进行真正的解码：
1.分配内存缓冲区用于管理文件 IO 和解压缩操作；
2.将文件数据从磁盘读到内存中；
3.将压缩的图片数据解码成未压缩的位图形式，这是一个非常耗时的 CPU 操作；
4.最后 Core Animation 使用未压缩的位图数据渲染 UIImageView 的图层。
5.CPU计算好图片的Frame，对图片解压之后.就会交给GPU来做图片渲染
渲染流程：
- GPU获取获取图片的坐标
- 将坐标交给顶点着色器（顶点计算）
- 将图片光栅化（获取图片对应屏幕上的像素点）
- 片元着色器计算（计算每个像素点的最终显示的颜色值）
- 从帧缓存区中渲染到屏幕

优化：
1.子线程解码，会主线程渲染
2.提前解压（1.只渲染1像素的图片提前解压并不渲染2.子线程用CGContext先绘制图片，但是并不渲染到屏幕上，用其他图片来替代或者放一个占位图，等解压好后再回主线程渲染）

## 9. 图⽚渲染怎么优化

1.图片尺寸优化，压缩图片资源，选用图片大小跟加载区域大小相通的图片
2.图片缓存，减少重复下载和解码
3.大图提前预加载
4.异步解码图片：避免在主线程上解码图片。通过将图片解码工作放在后台线程中，避免阻塞主线程，提升界面响应速度。使用CGImageSource来逐步解码大图：对于超大图片，可以通过Image I/O库逐步解码，避免一次性占用过多内存。

### 绘制到 UIGraphicsImageRenderer 上


```
func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    guard let image = UIImage(contentsOfFile: url.path) else {
        return nil
    }

    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
}

```

### 绘制到 Core Graphics Context 中

```
func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else {
        return nil
    }

    let context = CGContext(data: nil,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: image.bitsPerComponent,
                            bytesPerRow: image.bytesPerRow,
                            space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: image.bitmapInfo.rawValue)
    context?.interpolationQuality = .high
    context?.draw(image, in: CGRect(origin: .zero, size: size))

    guard let scaledImage = context?.makeImage() else { return nil }

    return UIImage(cgImage: scaledImage)
}

```

### 使用 Image I/O 创建缩略图像

```

func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
    let options: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
    ]

    guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
    else {
        return nil
    }

    return UIImage(cgImage: image)
}
```

### 使用 Core Image 进行 Lanczos 重采样

```
let sharedContext = CIContext(options: [.useSoftwareRenderer : false])

// 技巧 #4
func resizedImage(at url: URL, scale: CGFloat, aspectRatio: CGFloat) -> UIImage? {
    guard let image = CIImage(contentsOf: url) else {
        return nil
    }

    let filter = CIFilter(name: "CILanczosScaleTransform")
    filter?.setValue(image, forKey: kCIInputImageKey)
    filter?.setValue(scale, forKey: kCIInputScaleKey)
    filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)

    guard let outputCIImage = filter?.outputImage,
        let outputCGImage = sharedContext.createCGImage(outputCIImage,
                                                        from: outputCIImage.extent)
    else {
        return nil
    }

    return UIImage(cgImage: outputCGImage)
}

```

## 10. 如果GPU的刷新率超过了iOS屏幕60Hz刷新率是什么现象，怎么解决
屏幕撕裂、丢帧、UI卡顿或延迟

CPU：
1.尽量使用轻量级的对象，用不到事件处理的地方，可以用CALayer取代UIView
2.不要频繁调用UIView的相关属性，比如frame、bounds、transform
3.提前计算好布局，在有需要时一次性调整对应的属性，不要多次修改
4.Autolayout会比直接设置frame消耗更多的CPU资源
5.图片的size最好跟UIImageView的size保持一致
6.控制线程的最大并发量
7.尽量把耗时的操作放到子线程,比如文字size计算，图片处理

GPU：
1.尽量减少视图数量和层次
2.GPU最大尺寸是4096x4096,超过会需要CPU占用资源进行处理
3.减少透明度的视图
4.减少出现离屏渲染

# 九、多线程 & GCD & Cocoapods

## 1.iOS开发中有多少类型的线程？分别对⽐

NSThread：每个NSThread对象对应⼀个线程，量级较轻，通常我们会起⼀个runloop保活，然后通过添加⾃定义source0源或者 perform onThread 来进⾏调⽤。
    优点轻量级，使⽤简单
    缺点：需要⾃⼰管理线程的⽣命周期，保活，另外还会线程同步，加锁、睡眠和唤醒。

GCD：Grand Central Dispatch（派发）是基于C语⾔的框架，可以充分利⽤多核，是苹果推荐使⽤的多线程技术
    优点：GCD更接近底层，⽽NSOperationQueue则更⾼级抽象，所以GCD在追求性能的底层操作来说是速度最快的，有待确认
    缺点：操作之间的事务性，顺序⾏，依赖关系。GCD需要⾃⼰写更多的代码来实现
    
NSOperation
    优点： 
    使⽤者的关注点都放在了 operation 上，⽽不需要线程管理。
    ⽀持在操作对象之间依赖关系，⽅便控制执⾏顺序。
    ⽀持可选的完成块，它在操作的主要任务完成后执⾏。
    ⽀持使⽤KVO通知监视操作执⾏状态的变化。
    ⽀持设定操作的优先级，从⽽影响它们的相对执⾏顺序。
    ⽀持取消操作，允许您在操作执⾏时暂停操作。
    缺点：⾼级抽象，性能⽅⾯相较 GCD 来说不⾜⼀些;
    
## 2.iOS开发中常用的锁有哪些？

1.OSSpinLock
    自旋锁，等待锁的线程会处于忙等状态，一直占用cpu
优先级反转：
线程1（优先级高，后进来，cpu分配的资源在此线程）、线程2（优先级低，先进来）、线程3（时间片轮转调度算法）

2.os_unfair_lock 非忙等锁，会处于休眠状态
3.pthread_mutex
    互斥锁，等待锁的线程会处于休眠状态
    递归锁：允许队同一线程同一把锁重复加锁（怎么实现？）
    条件锁：
4.NSLock 对mutex普通锁的封装
5.NSCondition  对mutex和cont的封装
6.NSConditionLock 对NSCondition的进一步封装
7.dispatch_Semaphore 信号量的初始值可以用来控制线程并发访问的最大数量
8.@synchronized 对mutex的封装
9.NSRecursivelock
10.atomic 用于保证属性setter，getter的原子性操作，相当于在getter，setter内部加了线程同步。不能保证属性的安全
11.pthread_rwlock：读写锁
12.dispatch_barraier_async：异步栅栏读写，传入的并发队列必须是自己通过dispatch_queue_cretate创建的，如果传入的是一个串行或是一个全局的并发队列，那这个函数便等同于dispatch_asnyc

## 3.GCD有哪些队列，默认提供哪些队列

主队列（main queue） - 串⾏
保证所有的任务都在主线程执⾏，⽽主线程是唯⼀⽤于UI更新的线程。此外还⽤于发送消息给视图或发送通知。

四个全局调度队列（high、default、low、background） - 并发
Apple 的接⼝也会使⽤这些队列，所以你添加的任何任务都不会是这些队列中唯⼀的任务

⾃定义队列 - 串行或者并发
1. 多个任务以串⾏⽅式执⾏，但⼜不想在主线程中；2.多个任务以并⾏⽅式执⾏，但不希望队列中有其他系统的任务⼲扰。


## 4.GCD有哪些⽅法api

```
// 同步
dispatch_sync()

// 异步
disaptch_asyn()

// 延迟处理
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (<#delayInSeconds#> * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 <#code to be executed after a specified delay#>
 });
 
// 单例
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
 <#code to be executed once#>
});

// 栅栏同步
dispatch_barrier_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
// 栅栏异步
dispatch_barrier_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)

// dispatch_group_t
dispatch_group_t group_name = dispatch_group_create(); // 实例化⼀个组

//“加⼊”和“离开”是⼀对，就好⽐Objective-C 内存管理⼀样，谁持有(retain)谁释放(release)
dispatch_group_enter(<#dispatch_group_t _Nonnull group#>) 
dispatch_group_leave(<#dispatch_group_t _Nonnull group#>) 

// 阻塞当前线程，等待任务组中的所有任务执⾏完毕。
dispatch_group_wait(<#dispatch_group_t _Nonnull group#>,DISPATCH_TIME_FOREVER) 

// 和上面不同，当组中的全部执⾏完毕，将 block 任务加⼊到队列 queue 执⾏。
dispatch_group_notify(<#dispatch_group_t _Nonnull group#>, <#dispatch_queue_t
_Nonnull queue#>, <#^(void)block#>) 


// 信号量
dispatch_group_t group = dispatch_group_create(); // 1
dispatch_semaphore_t semaphore = dispatch_semaphore_create(10); // 2
dispatch_queue_t queue =
dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); // 3
for (int i = 0; i < 100; i++) {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); // 4
    dispatch_group_async(group, queue, ^{
        NSLog(@"%i",i); // 5
        sleep(2);
        dispatch_semaphore_signal(semaphore); // 6
    });
}
NSLog(@"所有任务完成");

```


## 5.GCD主线程 & 主队列的关系
队列其实就是⼀个数据结构体，主队列由于是串⾏队列，所以⼊队列中的task会逐⼀派发到主线程中执⾏；但是其他队列也可能会派发到主线程执⾏

## 6.如何实现线程同步，有多少⽅式就说多少
1. dispatch_sync
2. dispatch_group，
3. dispatch_semaphore


## 7.dispatch_once实现原理

```

// 精简版
void dispatch_once(dispatch_once_t *predicate, dispatch_block_t block) {
    // 检查是否已经执行过
    if (__c11_atomic_load(predicate, __ATOMIC_ACQUIRE) != DISPATCH_ONCE_DONE) {
        // 加锁，确保多线程下只有一个线程能够执行代码块
        dispatch_once_gate_t l = dispatch_once_gate_for(predicate);
        if (dispatch_once_gate_tryenter(l)) {// os_atomic_cmpxchg
            // 执行代码块
            block();
            // 标记为已经执行
            dispatch_once_gate_broadcast(l);
            __c11_atomic_store(predicate, DISPATCH_ONCE_DONE, __ATOMIC_RELEASE);
        } else {
            // 等待其他线程执行完成
            dispatch_once_gate_wait(l);
        }
    }
}

```

dispatch_once死锁：
1.block中加了锁，在其他线程也加了对应的锁
2.block中调用了其他逻辑，其他逻辑由依赖dispatch_once所初始化对象，所以其他逻辑又在等待dispatch_once执行完毕

## 8.什么情况下会死锁
线程死锁是指由于两个或者多个线程互相持有对⽅所需要的资源，导致这些线程处于等待状态，⽆法前
往执⾏。当线程互相持有对⽅所需要的资源时，会互相等待对⽅释放资源，如果线程都不主动释放所占
有的资源，将产⽣死锁。


## 9.有哪些类型的线程锁，分别介绍下作⽤和使⽤场景
同问题2

## 10.NSOperationQueue中的maxConcurrentOperationCount默认值
默认值为 -1，默认的最⼤操作数由NSOperationQueue对象根据当前系统条件动态确定

## 11.iOS最多可以同时开启多少个线程
64

## 12.NSTimer、CADisplayLink、dispatch_source_t的优劣

> NSTimer 使用方便，但是由于runloop影响计时不精准，并且会出现无法释放的问题。解决办法：
1.封装⼀个中间对象 WeakProxy， 内部使⽤⼀个 weak 属性变量持有 self，所以现在持有关系式 vc->timer->weakProxy ---->vc，所以也没有形成 retainCycle。
2.使用Block回调的方式执行
3.NSTimer加⼀个category，然后以block的⽅式注⼊定时器触发时的执⾏任务，Timer的target此处是⽤Timer类对象，⽽它是常驻内存中的，所以vc->timer->Timer类对象 没有
构成环，但是注意闭包中要⽤ weakSelf；


> CADisplayLink依托于设备屏幕刷新频率触发事件，所以其触发时间上是最准确的。也是最适合做UI不断刷新的事件，过渡相对流畅，⽆卡顿感。由于依托于屏幕刷新频率，若果CPU不堪重负⽽影响了屏幕刷新，那么我们的触发事件也会受到相应影响。并且selector触发的时间间隔只能是duration的整倍数，selector事件如果⼤于其触发间隔就会造成掉帧现象

> dispatch_source_t不受当前runloopMode的影响，时效基本上误差较小。



## pod install之后执行了哪些动作
1.检查Podfile文件里面的依赖和版本号
2.更新或者创建Podfile.lock文件，如果Podfile有无更新则使用之前的版本，否则就更新
3.Cocoapods解析Podfile里面的依赖，如果依赖有冲突则解决冲突或者抛出错误
4.下载远程仓库中的依赖
5.生成Pod文件，创建workspace，生成header文件，生成各个库的配置
6.执行结束后列出新增的、删除的依赖

# 十、性能优化 & OOM治理

## 1. 如何做启动优化，如何监控
## 2. 如何做卡顿优化，如何监控
1. FPS ⽤ CADisplayLinker 来计数
2. 监听 runloop 的 source0 事件和进⼊休眠前，然后设定⼀个阈值，超过⼏次算卡顿
3. ping ⽅案，起⼀个⼦线程，while(1)每次async⼀个task到主线程进⾏标志位置位，然后休眠或者等待⼀定时间在⼦线程检查是否这个task被执⾏了。

## 3. 如何做耗电优化，如何监控

## 4. 如何做⽹络优化，如何监控

# 十一、Http & HTTPs & TCP & UDP & 证书 & 加密

## TCP的握⼿过程？为什么进⾏三次握⼿，四次挥⼿


## HTTPS的握⼿过程

## 什么是中间⼈攻击？怎么预防




## 加密算法：对称加密算法和⾮对称加密算法区别


## MD5、Sha1、Sha256区别


## 1. 苹果使⽤证书的⽬的是什么

## 2. AppStore安装app时的认证流程

## 3. 开发者怎么在debug模式下把app安装到设备呢

# 十二、Mach-O & app启动 & ipa优化

# 十三、架构

## 1. ⼿动埋点、⾃动化埋点、可视化埋点

## 2. MVC、MVP、MVVM 设计模式
## 3. 常⻅的设计模式
## 4. 单例的弊端
## 5. 常⻅的路由⽅案，以及优缺点对⽐
## 6. 如果保证项⽬的稳定性
## 7. 设计⼀个图⽚缓存框架(LRU)
## 8. 如何设计⼀个 git diff
## 9. 设计⼀个线程池？画出你的架构图
## 10. 你的app架构是什么，有什么优缺点、为什么这么做、怎么改进

# 十四、其他

## 堆和栈区的区别？谁的占⽤内存空间⼤

## 进程和线程的区别


# 十五、Swift

# 十六、Flutter
1. Flutter 的渲染机制是怎样的？

    •    Flutter 如何将 Dart 代码转换为原生视图？
    •    Flutter 的渲染管道是如何运作的？包括哪些主要阶段？
    •    解释 Widget、Element、RenderObject 三者之间的区别与联系。

2. Flutter 中的状态管理方式有哪些？

    •    对比 setState、InheritedWidget、Provider、Riverpod 和 Bloc 的使用场景和优缺点。
    •    如何在大型应用中管理复杂的状态？
    •    解释 StatefulWidget 和 StatelessWidget 的生命周期，如何在生命周期内管理资源？

3. Flutter 的性能优化策略有哪些？

    •    如何使用 Flutter DevTools 进行性能分析？
    •    如何避免 Rebuild 频繁触发导致的性能问题？
    •    如何优化 ListView 和 GridView 的性能？
    •    如何避免大图片加载带来的内存问题？
    •    如何减少 UI Jank（卡顿）？

4. Flutter 如何进行跨平台开发？

    •    Flutter 是如何实现跨平台渲染的？它和 React Native、Weex 的区别是什么？
    •    如何在 Flutter 中调用平台特定的 API，如调用 iOS 和 Android 的原生代码？
    •    解释 Platform Channels 的工作原理。

5. Flutter 中的异步编程模型是怎样的？

    •    解释 async/await 和 Future 的工作原理。
    •    什么是 Stream？如何在 Flutter 中处理数据流？
    •    如何处理 Flutter 中的并发操作？比如多个网络请求的并行处理。

6. Flutter 的插件系统如何运作？

    •    如何开发一个跨平台的 Flutter 插件？
    •    Flutter 插件如何调用原生代码？
    •    插件的生命周期是如何管理的？

7. Flutter 热重载和热重启的区别是什么？

    •    解释 Hot Reload 和 Hot Restart 的区别和原理。
    •    在什么情况下使用 Hot Reload？什么情况下需要 Hot Restart？

8. Flutter 的导航管理方式有哪些？

    •    如何使用 Navigator 1.0 和 Navigator 2.0 实现路由管理？
    •    对比两种路由管理方式的优缺点，什么时候应该使用 Navigator 2.0？
    •    如何在 Flutter 中管理深度链接（Deep Linking）？

9. 如何处理 Flutter 应用中的依赖注入？

    •    什么是依赖注入（Dependency Injection）？
    •    如何在 Flutter 中使用依赖注入？例如使用 get_it、injectable 等库。
    •    为什么在大型项目中依赖注入是重要的？

10. 如何处理 Flutter 中的内存泄漏问题？

    •    什么是内存泄漏？如何在 Flutter 中识别和避免内存泄漏？
    •    如何使用 Flutter Inspector 和 DevTools 检测内存使用情况？

11. Flutter 中的键盘适配问题如何解决？

    •    如何避免键盘遮挡输入框？
    •    如何检测键盘的显示和隐藏？
    •    如何处理 Flutter 中的键盘事件？

12. Flutter 的国际化（i18n）和本地化（l10n）如何实现？

    •    如何使用 Flutter 提供的 Intl 包实现国际化？
    •    如何在 Flutter 中动态切换语言？
    •    如何处理文本和日期的本地化？

13. Flutter 中的绘制和自定义控件是如何实现的？

    •    如何使用 CustomPaint 和 Canvas 进行自定义绘制？
    •    解释 Flutter 的绘制机制，包括 Paint、Canvas 和 Layers。
    •    如何优化自定义绘制的性能？

14. 如何处理 Flutter 中的错误和异常？

    •    如何捕获和处理同步和异步的异常？
    •    如何在 Flutter 中进行全局异常捕获？
    •    如何处理 Widget 树中的错误？如何使用 ErrorWidget 来显示错误界面？

15. Flutter 的热更新是如何实现的？

    •    Flutter 官方是否支持热更新？
    •    如何通过第三方方案实现热更新？Flutter 的热更新和其他跨平台框架（如 React Native）的区别是什么？

16. Flutter 中的动画机制是怎样的？

    •    解释 Flutter 中的动画框架，包括 Implicit Animations 和 Explicit Animations 的区别。
    •    如何使用 AnimationController 和 Tween 来创建自定义动画？
    •    如何实现复杂的动画，例如共享元素动画或组合动画？

17. Flutter 的打包和发布流程是怎样的？

    •    如何为 Android 和 iOS 平台打包 Flutter 应用？
    •    如何处理应用中的签名、版本号管理等问题？
    •    如何优化 Flutter 应用的体积？

18. Flutter 中的多线程和并发处理机制是什么？

    •    解释 Flutter 中的单线程模型以及为什么 UI 操作需要在主线程执行。
    •    如何在 Flutter 中使用 Isolates 和 compute 方法进行并发处理？

19. 如何在 Flutter 中进行单元测试和集成测试？

    •    Flutter 提供了哪些类型的测试？
    •    如何编写 Widget 测试、单元测试和集成测试？
    •    如何在 CI/CD 管道中集成 Flutter 的测试流程？

20. 如何优化 Flutter 应用的启动时间？

    •    什么是冷启动和热启动？如何优化 Flutter 应用的冷启动时间？
    •    如何减少 Flutter 应用的初始加载时间？
