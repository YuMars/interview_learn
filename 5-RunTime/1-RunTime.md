RunTime

1.什么是Runtime
	将源代码转换为可执行的程序，通常需要经过三个步骤：编译，链接，运行。不同的编译语言，在这三个步骤中所进行的操作有不同。
	Ojbective-C是一门动态语言，在编译阶段并不知道变量的具体数据类型，也不知道所真正调用的哪个函数。只有在运行时间才检查变量的数据类型，同时在运行时才能根据函数名查找要调用的具体函数。

2.消息机制的基本原理
	OC中，对象方法调用都是类似[receiver selector],其本质就是让对象在运行时发送消息的过程。
	1.编译阶段：[receiver selector]方法被编译器转换为：
		1.objc_msgSend(receiver, selector)  -- 不带参数
		2.pbjc_msgSend(receiver, selector, vlg1, vg2) -- 带参数

	2.运行时阶段：消息接受者receiver寻找对应的selector。
		1.通过receiver的isa指针找到receiver的Class
		2.在Class的cache（方法缓存）的散列表中寻找对应的IMP（方法实现）
		3.如果在cache（方法缓存）中没有找到对应的IMP（方法实现）的话，就继续在Class的objc_method_list中找到对应的selector，如果找到，填充到cache（方法缓存）中，并返回selector
		4.如果在Class中没有找到这个selector，就继续在他的superClass中寻找
		5.一旦找到对应的selector，直接执行receiver对应selector方法实现的IMP（方法实现）
		6.若找不到对应的selector，消息被转发或者临时向receiver添加这个selector对应的实现方法，否则就会发生崩溃。

3.Runtime中的概念解析
	3.1 objc_msgSend
		所有的Objective-C方法调用在编译时都会转化为对C函数objc_msgSend的调用，objc_msgSend(receiver，selector); 是 [receiver selector]; 对应的 C 函数。
	3.2 Class（类）typedef struct objc_class *Class;
		在obc/rumtime.h中，Class被定义为指向objc_class

		struct objc_class {
    		Class _Nonnull isa  OBJC_ISA_AVAILABILITY;                   // 保存所属类的结构体的实例的指针

		#if !__OBJC2__
    		Class _Nullable super_class                                  // 指向父类的指针
   			const char * _Nonnull name                                   // 类的名称
    		long version                                                 // 类的版本号，默认为0
    		long info                                                    // 类的信息，供运行时期使用的一些标识
    		long instance_size                                           // 该类的实例变量大小
    		struct objc_ivar_list * _Nullable ivars                      // 该类的实力变量列表
    		struct objc_method_list * _Nullable * _Nullable methodLists  // 方法定义的列表
    		struct objc_cache * _Nonnull cache                           // 方法缓存
    		struct objc_protocol_list * _Nullable protocols              // 遵守的协议列表
		#endif

		} OBJC2_UNAVAILABLE;

	3.3 Object
		objc/objc.h

		struct objc_object {
    		Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
		};

		typedef struct objc_object *id;

		`id定义为一个指向objc_object结构提的指针。可以看出objc_object只包含一个Class类型的isa指针。换句话说，一个object唯一保存的就是它所属Class的地址。当我们对一个对象进行方法调用时，比如[receiver selector]，它会通过obj_object结构体的isa指针去找对应的objc_class结构体，然后在objc_class结构体的objc_method_list（方法列表）中找到调用对应的方法，然后执行。
		`
	3.4 Meta class
		objc_object的isa指针指向对应的objc_class（类对象）
		objc_class的isa指针指向什么？
		objc_class结构体的isa指针实际上指向的是类对象自身的meta_class。Meta class（元类）就是一个类对象所属的类，一个对象所属的类叫做类对象，而一个类对象所属的类叫做元类

			Runtime 中把类对象所属类型就叫做 Meta Class（元类），用于描述类对象本身所具有的特征，而在元类的 methodLists 中，保存了类的方法链表，即所谓的「类方法」。并且类对象中的 isa 指针 指向的就是元类。每个类对象有且仅有一个与之相关的元类。

		类方法的调用过程和对象方法调用差不多：
			1.通过类对象isa指针找到所属的meta_class
			2.在meta_class的objc_method_list（方法列表）中找到对应的selector
			3.执行对应的selector

		eg:
			NSString *string = [NSString stringWithFormat:@"%@ %s", @"1", 3];

			stringWithFormat被发送给了NSString类，NSString类通过isa指针找到NSString元类，然后该元类的方法列表中找到对应的stringWithFormat方法，然后执行该方法

	3.5 实例对象，类，元类对象的关系

			⬆ 父类   -----> isa指针

		根类   object实例对象   ---->  object类对象  ----> 	NSObject元类
										⬆						⬆
		父类   Person实例对象	  ---->	 Person类对象  ---->		Person元类
										⬆						⬆
		子类   Man实例对象	  ---->  man类对象	  ---->		Man元类

		isa指针:
			1.水平方向:每一级中的实力对象的isa指针指向对应的类对象,而类对象的isa指针指向了对应的元类.而所有的元类isa指针最终指向了NSObject元类,因此NSObject也被成为根元类
			2.垂直方向:元类的isa指针和父类元类的isa指针都指向了根元类.而根元类的isa指针又指向了自己.

		父类指针:
			1.类对象的父类指针指向了父类的类对象,父类的类对象又指向了根类的类对象,根类的类对象最终指向了nil
			2.元类的父类指针指向父类对象的元类.父类对象的元类的父类指针指向了根类对象的元类,也就是根元类.根元类的父类指针指向了根类对象,最终指向了nil

	3.6 Method(方法)
		objc_class 结构体的objc_method_list(方法列表)中存放的元素就是objc_method

		objc/runtime.h中 objc_method的objc_method的数据结构

		typedef struct objc_method *Method;

		struct objc_method {
    		SEL _Nonnull method_name       // 方法名
    		char * _Nullable method_types  // 方法类型
   		 	IMP _Nonnull method_imp        // 方法实现
		} 		

		可以看到objc_method结构体中包含了 method_name(方法名), mthod_types(方法类型),method_imp(方法实现)

		1.SEL method_name 
			typedef struct objc_selector *SEL;

			SEL是一个指向objc_selector结构体的指针,但是在runtime相关头文件理没有找到明确的定义.经过测试可以得出:SEL只是一个保存方法名的字符串.

		2.IMP method_imp
			#if !OBJC_OLD_DISPATCH_PROTOTYPES
				typedef void (*IMP)(void /* id, SEL, ... */ ); 
			#else
				typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...); 
			#endif

			IMP的实质是一个函数指针,所指向的就是方法的实现.IMP用来找函数地址,然后执行函数

		3.char * _Nullable method_types 
			方法类型method_types是个字符串,用来存储方法的参数类型和返回值

		Method将SEL和IMP关联起来,当对一个对象发送消息时,会通过给出的SEL去找到IMP,然后执行

4.RunTime消息转发
	若找不到对应的selector,消息被转发或者临时向receiver添加这个selector对应的实现方法,否则就会发生崩溃.
	当一个方法找不到的时候,Runtime提供了消息动态解析,消息接受者重定向,消息重定向等三步处理,具体流程如下:

	+resolveInstanceMethod/+resolveClassMethod   
	+forwardingTargetForSelector/-forwardingTargetForSelector  
	+methodSignatureForSelector/-methodSignatureForSelector
						消息成功处理
	4.1 消息动态解析
		Objective-C运行时会调用+resolveInstanceMethod或者+resolveClassMethod,前者在对象方法未找到时,后者在类方法未找到时调用,可以通过重写这两个方法,添加其他函数实现,并返回YES,运行时系统会重新启动一次消息发送的过程.

		+ (BOOL)resolveClassMethod:(SEL)sel;
		+ (BOOL)resolveInstanceMethod:(SEL)sel;
		BOOL class_addMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp, const char * _Nullable types) 

	4.2 消息接受者重定向
		如果上一步中+resolveInstanceMethod 或者 +resolveClassMethod没有添加其他函数实现,运行时就会进行下一步:消息接受者重定向

		如果当前对象实现了forwardingTargetForSelector或者forwardingTargetForSelector方法,Runtime就会调用这个方法,允许我们将消息的接受者转发给其他对象.

		- (id)forwardingTargetForSelector:(SEL)aSelector;
		- (void)forwardInvocation:(NSInvocation *)anInvocation;

		1.类方法和对象方法消息转发的第二步调用的方法不一样,前者是+forwardingTargetForSelector方法,后者是-forwardingTargetForSelector
		2.这里resolveInstanceMethod或者resolveClassMethod无论是返回YES还是返回NO,只要其中没返回其他函数实现,运行时都会进行下一步.

	4.3 消息重定向
		如果经过的消息动态解析,消息接受者重定向,Runtime系统还是找不到相应的方法实现而无法响应消息,Runtime系统会利用-methodSignatureForSelector:或者+methodSignatureForSelector方法获取函数的参数和返回值类型.
			·如果methodSignatureForSelector返回一个NSMethodSignature对象(函数签名),Runtime系统就会创建一个NSInvocation对象,并通过forwardInvocation:消息通知当前对象,给予此次消息发送最后一次寻找IMP机会
			·如果methodSignatureForSelector:返回nil,则Runtime系统会发出doesNotRecognizeSelector:消息,程序也就崩溃.

			所以我们可以在forwardInvocation:方法中对消息进行转发
			类方法
				1.+methodSignatureForSelector
				2.+forwardInvocation:
				3.+doesNotRecognizeSelector:
			对象方法
				1.-methodSignatureForSelector:
				2.-forwardInvocation:
				3.-doesNotRecognizeSelector:

		forwardingTargetForSelector:和forwarInvocation:都可以将消息转发给其他对象处理,forwardingTargetForSelector:只能将消息转发给一个对象,而forwardInvocation:可以将消息发给对个对象  

	5 消息发送已经转发机制总结

		调用[receiver selector];

		1.编译阶段:[receiver selector]; 方法被编译器转换为
			1.objc_msgSend(receiver, selector);          ---不带参数
			2.objc_msgSend(receiver, selector, vg1, vg2, ...) ---带参数

		2.运行阶段:消息接受者receiver 寻找对应的selector.
			1.通过receiver的isa指针找打receiver的class(类)
			2.在Class(类)的cache(方法缓存)的散列表中寻找到对应的IMP(方法实现)
			3.如果在cache(方法缓存)中没有找到对应的IMP(方法实现),就继续在Class的objc_method_list中找对应的selector,如果找到填充到cache中并返回selector
			4.如果在Class(类中)没有找到selector,就继续在他的super_class中寻找
			5.一旦找到对应的selector,直接执行receiver对应的selector方法实现的IMP
			6.若找不到对应的selector,Runtime系统进入消息转发机制

		3.运行时消息转发机制:
			1.动态解析: 通过重写resolveInstanceMethod:或者resolveClassMethod方法,利用class_addMethod方法添加其他函数实现
			2.消息接受者重定向:如果上一步添加其他函数实现,可在当前对象中利用forwardingTargetForSelector:方法将消息的接受者转发给其他对象
			3.消息重定向:如果上一步没有返回值为nil,则利用methodSignatureForSelector:方法获取函数的参数和返回值类型.
				1.如果methodSignatureForSelector:返回一个NSMethodSignature对象,Runtime系统就会创建一个NSInvocation对象,并通过forwardInvocation:消息通知当前对象,给予此次消息发送最后一次寻找IMP的机会
				2.如果methodSignatureForSelector返回nil,则Runtime系统会发出doesNotRecognizeSelector:消息,程序就崩溃 

















https://www.jianshu.com/p/633e5d8386a8