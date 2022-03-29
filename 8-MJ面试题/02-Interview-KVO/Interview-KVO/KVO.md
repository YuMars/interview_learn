#  KVO

    KVO全称Key-Value-Observing,俗称"键值监听"，可以用于监听某个对象属性值的改变
    
    `使用KVO监听后,会生成NSKVONotifying_类名的一个类,是一个继承自原先类的子类，由runtime在运行过程中动态生成的一个类`
    重写了class,dealloc, _isKVO 三个方法
    
    NSKVONotifying_Person是Person的一个子类 
    `[person setAge:]` 调用了`[NSKVONotifying_Person setage:]`,调用了`_NSSetIntValueAndNotify`
    p (IMP)+内存地址 可以打印调用的方法名
    
    // 获取class对象
    object_getClass()
    // 获取meta-class对象
    object_getClass(object_getClass())
    
    `_NSSet*ValueAndNotify`的内部实现
    [self willChangeValueForKey:@""];
    [super setValue:];
    [self didChangeValueForKey:@""];

    Q: KVO的本质是什么
    A: 利用Runtime 1.API动态生成一个子类，并且让instance对象的isa指向这个全新的子类，子类NSKVONotifying_类名
        2.当修改instance对象的属性时，会调用Foundation的_NSSet*ValueaAndNofity函数
            _NSSet*ValueAndNotify:{ 1.willChangeValueForKey: 2.[super setValue:] 3.didChangeValueForKey:} 
        3.内部调用observeValueForKeyPath:ofObject:change:context:
        
    Q: 如何手动触发KVO
    A: [self willChangeValueForKey:@""] ,[self didChangeValueForKey:@""]
