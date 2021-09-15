2-Runtime  Method Swizzling(动态方法交换)

1.Method Swizzling简介
	Method Swizzling 用于改变一个已经存在的selector实现.我们在程序运行时,通过改变selector所在Class(类)的objc_method_list(方法列表)的映射从而改变方法的调用.其实质就是交换两个方法的IMP(方法实现).

	Method(方法)就是objc_method结构体

	// objc_method 结构体
	typedef struct objc_method *Method;

	struct objc_method {
    	SEL _Nonnull method_name;                    // 方法名
    	char * _Nullable method_types;               // 方法类型
    	IMP _Nonnull method_imp;                     // 方法实现
	};

	在运行时,Class(类)维护了一个methodLists(方法列表)来确定消息的正确发送.methodLists(方法列表)存放的元素就是method(方法),而method中映射了一对键值对:SEL(方法名), IMP(方法实现).

	Method Swizzling修改了methodLists(方法列表),使得不同的method中不同的键值对发生了交换.比如交换前两个键值对分别为SEL A, IMP A | SEL B, IMP B,交换之后就变成了SEL A, IMP B | SEL B, IMP B.

2.Method Swizzling 使用方法
	假如当前类中有两个方法:-(void)originalFunction;和-(void)swizzlingFunction; 如果我们想要交换两个方法的实现,从而实现调用-(void)originalFunction;的时候实际上调用的是-(void)swizzlingFunction; ,而调用-(void)swizzlingFunction; 实际上是-(void)originalFunction;.

	2.1 Method Swizzling 简单使用
		在当前类+ (void)load;方法中添加Method Swizzling

	2.2 Method Swizzling 方法A -- 添加Method Swizzling 交换方法,用普通方式

	2.3 Method Swizzling 方法B -- 使用函数指针的方式。

	2.4 AFNetworking交换方法

	2.5 JRSwizzle 和 RSSwizzle 

3.Method Swizzle 使用注意
	Method Swizzle 之所以被大家称为黑魔法,就是因为使用Method Swizzling进行方法交换是一个危险动作.

	1.应该只在+ (void)load中执行Method swizzling
		程序在启动的时候,会先加载所有的类,这时会调用每个类的+ (void)load方法,而且在整个程序运行周期只会调整一次.所以在+(void)load方法进行Method Swizzling再好不过

		为什么不用+ (void)initialize方法?
		因为+ (void)initialize方法的调用时机是在第一次向该类发送第一个消息的时候才会被调用.如果该类只是引用,没有调用,则不会执行+ (void)initialize.Method Swizzling影响的是全局状态,+ (void)load方法能保证在加载类的时候就进行交换,保证交换结果.而使用+ (void)initialize方法则不能保证这一点,有可能在使用的时候起不到交换方法的作用

	2.Method Swizzling 在+ (void)load中执行,不要调用[super load]
		程序在启动的时候,会加载所有的类,如果在+ (void)load方法中调换[super load]方法,,就会导致父类 的Method Swizzling 被重复两次,而方法交换也被执行了两次,相当于互换了一次方法之后,两次又叫换回去了

	3.Method Swizzling应该总是在dispatch_once中执行
		Method Swizzling不是原子操作,dispatch_once可以保证在不同的线程中也能确保代码只执行一次.

	4.使用Method Swizzling后要记得调用原声方法的实现
		在交换方法实现后记得要调用原生方法的实现（除非你非常确定可以不用调用原生方法的实现）：APIs 提供了输入输出的规则，而在输入输出中间的方法实现就是一个看不见的黑盒。交换了方法实现并且一些回调方法不会调用原生方法的实现这可能会造成底层实现的崩溃。

	5.避免命名冲突和参数_cmd被篡改
		避免命名冲突一个比较好的做法是为替换的方法加个前缀以区别原生方法。一定要确保调用了原生方法的所有地方不会因为自己交换了方法的实现而出现意料不到的结果。
		在使用 Method Swizzling 交换方法后记得要在交换方法中调用原生方法的实现。在交换了方法后并且不调用原生方法的实现可能会造成底层实现的崩溃。

		避免方法命名冲突另一个更好的做法是使用函数指针，也就是上边提到的 方案 B，这种方案能有效避免方法命名冲突和参数 _cmd 被篡改.

	6.谨慎对待 Method Swizzling。
		使用 Method Swizzling，会改变非自己拥有的代码。我们使用 Method Swizzling 通常会更改一些系统框架的对象方法，或是类方法。我们改变的不只是一个对象实例，而是改变了项目中所有的该类的对象实例，以及所有子类的对象实例。所以，在使用 Method Swizzling 的时候，应该保持足够的谨慎。

		例如，你在一个类中重写一个方法，并且不调用 super 方法，则可能会出现问题。在大多数情况下，super 方法是期望被调用的（除非有特殊说明）。如果你是用同样的思想来进行 Method Swizzling ，可能就会引起很多问题。如果你不调用原始的方法实现，那么你 Method Swizzling 改变的越多代码就越不安全。

	7.对于 Method Swizzling 来说，调用顺序 很重要。
		 load 方法的调用规则为：
		1.先调用主类，按照编译顺序，顺序地根据继承关系由父类向子类调用；
		2.再调用分类，按照编译顺序，依次调用；
		3.+ load 方法除非主动调用，否则只会调用一次。
		这样的调用规则导致了 + load 方法调用顺序并不一定确定。一个顺序可能是：父类 -> 子类 -> 父类类别 -> 子类类别，也可能是 父类 -> 子类 -> 子类类别 -> 父类类别。所以 Method Swizzling 的顺序不能保证，那么就不能保证 Method Swizzling 后方法的调用顺序是正确的。

		所以被用于 Method Swizzling 的方法必须是当前类自身的方法，如果把继承父类来的 IMP 复制到自身上面可能会存在问题。如果 + load 方法调用顺序为：父类 -> 子类 -> 父类类别 -> 子类类别，那么造成的影响就是调用子类的替换方法并不能正确调起父类分类的替换方法

4.Method Swizzling 应用场景
	4.1 全局页面统计功能












https://www.jianshu.com/p/1ab7e611107c
