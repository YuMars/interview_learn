#  Category

1.分类的对象方法都会放在一个class对象中
2.分类的类方法都会放在一个meta-class对象中
3.通过runtime动态将分类的方法合并到类对象、元类对象中

    struct _category_t {
        const char *name;                              // 类名
        struct _class_t *cls;                          // 类结构体
        const struct _method_list_t *instance_methods; // 实例方法
        const struct _method_list_t *class_methods;    // 类方法
        const struct _protocol_list_t *protocols;      // 协议
        const struct _prop_list_t *properties;         // 属性
     };

    static struct _category_t _OBJC_$_  __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        "Person",
        0, // &OBJC_CLASS_$_Person,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Test,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Test,
        (const struct _protocol_list_t *)&_OBJC_CATEGORY_PROTOCOLS_$_Person_$_Test,
        (const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Person_$_Test,
    };
    
    
    // instance_methods 实例方法
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[2];
    } _OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        2,
        {{(struct objc_selector *)"test", "v16@0:8", (void *)_I_Person_Test_test},
        {(struct objc_selector *)"test2", "v16@0:8", (void *)_I_Person_Test_test2}}
    };
    
    // class_methods 类方法
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[1];
    } _OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        1,
        {{(struct objc_selector *)"classTest", "v16@0:8", (void *)_C_Person_Test_classTest}}
    };
    
    // protocols 协议
    
    static struct /*_protocol_list_t*/ {
        long protocol_count;  // Note, this is 32/64 bit
        struct _protocol_t *super_protocols[2];
    } _OBJC_CATEGORY_PROTOCOLS_$_Person_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        2,
        &_OBJC_PROTOCOL_NSCopying,
        &_OBJC_PROTOCOL_NSCoding
    };


    // properties 属性

    static struct /*_prop_list_t*/ {
        unsigned int entsize;  // sizeof(struct _prop_t)
        unsigned int count_of_properties;
        struct _prop_t prop_list[1];
    } _OBJC_$_PROP_LIST_Person_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_prop_t),
        1,
        {{"height","Ti,N"}}
    };
    
    {
        objc-os.mm
        objc_init -> map_images -> map_image_nolock
        objc_runtime-new.mm
        _read_images -> remethodizeClass（重新组织方法） -> attachCategories() ->attachList() -> realloc -> memmove -> memcpy
        
        attachCategories: method_list_t(instance_method、 class_method) 
                          property_list_t 
                          protocol_list_t
                          
        导致了后加入的分类对象优先调用（编译顺序）
        
        1.通过runtime加载某个类的所有category数据
        2.把所有Category的方法、属性、协议数据合并到一个数组中（后参与编译的category数据，会优先在数组中，并且优先调用）
        3.将合并后的分类数据（方法、属性、协议）插入到类原来数据的前面
        
    }
    
    //Q: Category的实现原理 
    //A: Category在编译之后的底层结构是struct category_t,里面存储着分类的对象方法、类方法、属性、协议信息。在runtime的时候，会将category的数据，合并到类信息中（class对象，meta-class对象）
    
    //Q: Category和Class Extension的区别是什么
    //A: Class Extension在编译的时候，它的数据就已经包含在类信息中
         Category是在运行时，才会将数据合并到类信息
         
#  Load

    +load方法在runtime加载类，分类时调用
    每个类、分类的+load，在程序运行过程中只调用一次
    
    {
        源码顺序
            objc_init -> load_images ->
            prepare_load_methods -> schedule_class_load -> add_class_to_loadalble_list -> add_category_to_loadable_list
            call_load_methods -> call_class_loads -> call_category_loads
        +load方法是根据方法地址直接调用，不是通过objc_msgSend()函数调用
    }
    
    {
        load调用顺序：
        1.先调用类的+load
            按照编译先后顺序调用（先编译，先调用）
            调用子类的+load之前会先调用superclass的+load
        2.再调用分类的+load
            按照编译先后顺序调用（先编译，先调用）
    } 
    
    // Q: Category 中有load方法吗？load方法是什么时候调用的？load方法能继承吗
    // A: 有load方法
          load方法在runtime加载分类、类的时候调用
          load方法可以继承，但是一般情况下不会主动去调用load，让系统自动调用
