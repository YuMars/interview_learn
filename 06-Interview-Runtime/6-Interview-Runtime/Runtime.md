#  Runtime

    {
        isa详解
            在arm64之前，isa是一个普通的指针，存储这Class,Meta-Class对象的内存地址
            在arm64之后，isa进行了优化，变成了一个共同体（union）结构，还是用位运算来存储更多的信息
            
        isa struct:
             uintptr_t nonpointer        : 1; // (0：普通指针，存储Class、Meta-Class对象 1：优化过使用位域存储更多信息)
             uintptr_t has_assoc         : 1; // (是否有设置过关联对象,如果没有，释放会更快）
             uintptr_t has_cxx_dtor      : 1; // (是否有C++西沟函数，如果没有，释放更快）
             uintptr_t shiftcls          : 33; //MACH_VM_MAX_ADDRESS 0x1000000000(存储Class、Meta-Classs对象的内存地址)
             uintptr_t magic             : 6; // (用于在调试的时候分辨对象是否有初始化)
             uintptr_t weakly_referenced : 1; // (是否有被弱引用指向，如果没有，释放会更快)
             uintptr_t deallocating      : 1; // (对象是否正在释放)
             uintptr_t has_sidetable_rc  : 1; // (引用计数器是否多大无法存储在isa中、如果为1，那么引用计数器会存储在一个叫SideTable的类的属性中)
             uintptr_t extra_rc          : 19 // (里面存储的值是引用计数器减一)
    }


    {
        class_rw_t里面的methods、properties、protocols是二维数组，是可读可写的，包含了类的初试内容
        class_ro_t里面的baseMethodList、baseProtocols、ivars、baseProperties是一维数组，是只读的，包含了类的初始化内容
    }
    
    
    {
        struct method_t {
            SEL name;  // 函数名
            const char *types;// 编码（返回类型、参数类型）
            MethodListIMP imp; // 指向函数的指针（函数地址）

            struct SortBySELAddress :
                public std::binary_function<const method_t&,
                                            const method_t&, bool>
            {
                bool operator() (const method_t& lhs,
                                 const method_t& rhs)
                { return lhs.name < rhs.name; }
            };
        };
        
        IMP代表函数的具体实现
        typeof id _Nullable (*IMP)()
        SEL代表方法名、函数名，一般叫选择器，底层结构跟char*类似(不同类中相同名字的方法，所对应的方法选择器是相同的)
        
        Type Encoding(详看type_encoding)
    }
    
    {
        // 用散列表类缓存曾经调用过的方法，提高方法的查找速度
        struct cache_t {
            explicit_atomic<struct bucket_t *> _buckets; // 散列表
            explicit_atomic<mask_t> _mask; // 散列表的长度-1
            uint16_t _occupied; // 已经缓存的方法数量
        }
        
        struct bucket_t {
            explicit_atomic<uintptr_t> _imp; // IMP作为value
            explicit_atomic<SEL> _sel; // SEL作为key
        }
        
        1.先从class对象中找到cache，是否存在将被调用的方法method
            如果存在就直接使用
            如果不存在，就通过bits到class_rw_t结构体里找到methods(方法列表里面遍历)是否存在method
                找到方法，就调用method，然后把method放在cache缓存中，下次直接调用
        2.如果当前class对象中找不到，通过superclass，找父类，重复步骤1
        
        源码：
        objc-msg-arm64.s
            ENTRY _objc_msgSend
            b.le    LNilOrTagged
            CacheLookup NORMAL
            .macro CacheLookup
            .macro CheckMiss
            STATIC_ENTRY __objc_msgSend_uncached
            .macro MethodTableLookup
            __class_lookupMethodAndLoadCache3
            
        objc-runtime-new.mm
            _class_lookupMethodAndLoadCache3
            lookUpImpOrForward
            getMethodNoSuper_nolock、search_method_list、log_and_fill_cache
            cache_getImp、log_and_fill_cache、getMethodNoSuper_nolock、log_and_fill_cache
            _class_resolveInstanceMethod
            _objc_msgForward_impcache
            
            
        objc-msg-arm64.s
            STATIC_ENTRY __objc_msgForward_impcache
            ENTRY __objc_msgForward

            Core Foundation
            __forwarding__（不开源）
    }
    
    {
        objc_msgSend执行流程
            1.OC中的方法调用，都是转换为objc_msgSend函数的调用
            2.objc_msSend的执行流程可分为3大阶段
                1.消息发送(同上一段有点类似)
                2.动态方法解析
                3.消息转发
                
        
    }

    {
        动态方法解析
            1.是否已经动态解析
                已经解析：消息转发
                还未解析：调用+resolveInstanceMethod、+resolveClassMethod,标记已经解析过
            2.都失败：尝试消息转发
    }
    
    {
        消息转发
            1.调用forwardingTargetForSelector
                返回不为nil：objc_msgSend()
                返回为nil：调用methodSignatureForSelector
            2.调用methodSignatureForSelector
                返回不为nil:调用forwardInvocation
                返回nil：调用doesNotRecognizeSelector
    }


    {
        @dynamic: 不会对属性自动生成getter ，setter方法
            @synthesize age = _age 会自动生成 setAge 和 age方法
        
    }
    
    {
        // Q:讲一下OC的消息机制
        // A:OC是中的方法调用，都是转成了objc_msgSend函数调用，给receiver发送一条消息（方法名）
            objc_msgSend有3大阶段
                1.消息发送
                2.动态方法解析
                3.消息转发
        
        // Q:消息转发机制
        // A:
        
        
    }
    
    {
        面试题：
            Student：Person
            
            - (instancetype)init {
                if (self = [super init]) {
                    NSLog(@"%@", [self class]); // Student
                    NSLog(@"%@", [super class]); // Student
                    NSLog(@"%@", [self superclass]); // Person
                    NSLog(@"%@", [super superclass]); // Person
                }
                return self;
            }
            
            struct objc_super {
                __unsafe_unretained _Nonnull id receiver; // 消息接受者
                __unsafe_unretained _Nonnull Class super_class; // 消息接受者的父类
            };
            
            objc_msgSend(self, @selector(class))
            ((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("class"))

            objc_msgSendSuper(self, [Person class], @selector(class))
            ((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Student"))}, sel_registerName("class")) 

            ((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("superclass"))

            ((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Student"))}, sel_registerName("superclass"))

        [super message]
        1.消息接受者还是子类的self
        2.找方法的时候从super优先开始查找
    }

{
    NSLog(@"%d" ,[[NSObject class] isKindOfClass:[NSObject class]]); // 1

    NSLog(@"%d" ,[[NSObject class] isMemberOfClass:[NSObject class]]);  // 0

    NSLog(@"%d" ,[NSObject isMemberOfClass:[NSObject class]]);// 0
    // [Person class] -> isKindOfClass,找到是meta-class
    NSLog(@"%d" ,[[Person class] isKindOfClass:[Person class]]);// 0

    NSLog(@"%d" ,[[Person class] isMemberOfClass:[Person class]]);// 0
}

    {
        id cls = [Person class];
        void *obj = &cls;
        [(__bridge id)obj print];
        
        person -> isa -> class
        obj -> cls -> [Person class]
        
        [Person]    [obj]
        isa          cls
        _name       [print: self.name] -> self
                                          [UiViewController class]
        
        上面的转换
        
        // 局部变量分配在栈空间
        // 栈空间分配，从高地址到低地址
        
        [super viewDidLoad]
        obj_msdSendSuper(self, [UiViewController class], @selector(viewDidLoad))
        
        
    }
    
    {
        // Q:什么是Runtime，平时项目用过吗
        // A: OC是一门动态性比较强大语言，允许很堵操作推迟到程序运行时在操作
              OC的动态性就是有Runtime来支撑和实现的，Runtime是一套C语言的API，封装了很多动态性相关的函数
             1.利用关联对象给分类添加属性
             2.遍历类的所有成员变量
             3.交换方法实现
        
        
        动态创建一个类（参数：父类，类名，额外的内存空间）
        Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)

        注册一个类（要在类注册之前添加成员变量）
        void objc_registerClassPair(Class cls) 

        销毁一个类
        void objc_disposeClassPair(Class cls)

        获取isa指向的Class,入参：instance对象，返回class对象， 入参：class对象，返回meta-class对象
        Class object_getClass(id obj)

        设置isa指向的Class
        Class object_setClass(id obj, Class cls)

        判断一个OC对象是否为Class
        BOOL object_isClass(id obj)

        判断一个Class是否为元类
        BOOL class_isMetaClass(Class cls)

        获取父类
        Class class_getSuperclass(Class cls)
        
        获取一个实例变量信息
        Ivar class_getInstanceVariable(Class cls, const char *name)

        拷贝实例变量列表（最后需要调用free释放）
        Ivar *class_copyIvarList(Class cls, unsigned int *outCount)

        设置和获取成员变量的值
        void object_setIvar(id obj, Ivar ivar, id value)
        id object_getIvar(id obj, Ivar ivar)

        动态添加成员变量（已经注册的类是不能动态添加成员变量的）
        BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types)

        获取成员变量的相关信息
        const char *ivar_getName(Ivar v)
        const char *ivar_getTypeEncoding(Ivar v)
        
        获取一个属性
        objc_property_t class_getProperty(Class cls, const char *name)

        拷贝属性列表（最后需要调用free释放）
        objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)

        动态添加属性
        BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
                          unsigned int attributeCount)

        动态替换属性
        void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
                              unsigned int attributeCount)

        获取属性的一些信息
        const char *property_getName(objc_property_t property)
        const char *property_getAttributes(objc_property_t property)
    }
