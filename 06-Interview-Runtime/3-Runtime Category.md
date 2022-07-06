3-Runtime Category

1.Category(分类)简介
	1.1 什么是Category
		Category主要作用是为已经存在的类添加方法.Category可以做到在既不子类化,也不侵入一个类的源码情况下,为原有的类添加新的方法,从而实现拓展一个类或者分离一个类的目的.

		虽然继承也能为已有的类添加新的方法,而且还能直接添加属性,但继承关系增加了不必要的代码复杂度,在运行时也无法与父类的原始方法进行区分.所以我们可以优先考虑使用自定义Category.
		1.把类的不同实现方法分开到不同的文件里
		2.声明私有方法.
		3.模拟多继承
		4.将framework私有方法公开化

	1.2 Category(分类)和Extension(扩展)
		Extension在编译阶段与该类同时编译,是类的一部分.而且Extension(扩展)中声明的方法只能在该类的@impelementation中实现.也就意味着无法对系统的类进行扩展.Extension不但可以声明方法,也可以声明成员变量.
		Category的特性:可以在运行时阶段动态的为已有类添加新行为.是在运行时决定的,而成员变量的内存布局已经在编译阶段就确定好了,如果在运行时阶段添加成员变量的话,就会破坏原来类的内存布局,所以Category无法添加成员

2.Category的实质
	2.1 Category 结构体简介

	typedef struct category_t *Category;

	struct category_t {
    	const char *name;                                // 类名
    	classref_t cls;                                  // 类，在运行时阶段通过 class_name（类名）对应到类对象
    	struct method_list_t *instanceMethods;           // Category 中所有添加的对象方法列表
    	struct method_list_t *classMethods;              // Category 中所有添加的类方法列表
    	struct protocol_list_t *protocols;               // Category 中实现的所有协议列表
    	struct property_list_t *instanceProperties;      // Category 中添加的所有属性
	};

	·在项目中添加 Person 类文件 Person.h 和 Person.m，Person 类继承自 NSObject 。
	·在项目中添加 Person 类的 Category 文件 Person+Addition.h 和 Person+Addition.m，并在 Category 中添加的相关对象方法，类方法，属性，以及代理。
	·打开『终端』，执行 cd XXX/XXX 命令，其中 XXX/XXX 为 Category 文件 所在的目录。
	·继续在终端执行 clang -rewrite-objc Person+Addition.m
	·执行完命令之后，Person+Addition.m 所在目录下就会生成一个 Person+Addition.cpp 文件，这就是我们需要的 Category（分类） 相关的 C++ 源码。

	2.2.1
		// Person 类的 Category 结构体
		struct _category_t {
    		const char *name;
    		struct _class_t *cls;
    		const struct _method_list_t *instance_methods;
    		const struct _method_list_t *class_methods;
    		const struct _protocol_list_t *protocols;
    		const struct _prop_list_t *properties;
		};

		// Person 类的 Category 结构体赋值
		static struct _category_t _OBJC_$_CATEGORY_Person_$_Addition __attribute__ ((used, section ("__DATA,__objc_const"))) = 
		{
    		"Person",
    		0, // &OBJC_CLASS_$_Person,
    		(const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Addition,
    		(const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Addition,
    		(const struct _protocol_list_t *)&_OBJC_CATEGORY_PROTOCOLS_$_Person_$_Addition,
    		(const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Person_$_Addition,
		};

		// Category 数组，如果 Person 有多个分类，则 Category 数组中对应多个 Category 
		static struct _category_t *L_OBJC_LABEL_CATEGORY_$ [1] __attribute__((used, section ("__DATA, __objc_catlist,regular,no_dead_strip")))= {
    		&_OBJC_$_CATEGORY_Person_$_Addition, 
		};

		从『Category结构体』源码中我们可以看到:
		1.Category结构体
		2.Category结构体的赋值语句
		3.Category结构体数组

	2.2.2 Category中对象方法列表结构体
		// - (void)printName; 对象方法的实现
		static void _I_Person_Addition_printName(Person * self, SEL _cmd) {
    		NSLog((NSString *)&__NSConstantStringImpl__var_folders_ct_0dyw1pvj6k16t5z8t0j0_ghw0000gn_T_Person_Addition_405207_mi_1);
		}

		// - (void)personProtocolMethod; 方法的实现
		static void _I_Person_Addition_personProtocolMethod(Person * self, SEL _cmd) {
   		 NSLog((NSString *)&__NSConstantStringImpl__var_folders_ct_0dyw1pvj6k16t5z8t0j0_ghw0000gn_T_Person_Addition_f09f6a_mi_2);
		}

		// Person 分类中添加的『对象方法列表结构体』
		static struct /*_method_list_t*/ {
    		unsigned int entsize;  // sizeof(struct _objc_method)
    		unsigned int method_count;
    		struct _objc_method method_list[2];
		} _OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Addition __attribute__ ((used, section ("__DATA,__objc_const"))) = {
    		sizeof(_objc_method),
    		2,
    		{{(struct objc_selector *)"printName", "v16@0:8", (void *)_I_Person_Addition_printName},
    		{(struct objc_selector *)"personProtocolMethod", "v16@0:8", (void *)_I_Person_Addition_personProtocolMethod}}
		};

		从 『对象方法列表结构体』源码中我们可以看到:
		1.- (void)printName; 对象方法的实现。
		2.- (void)personProtocolMethod; 方法的实现。
		3.对象方法列表结构体.

		只要是Category中实现了对象方法.都会添加到对象方法_OBJC_$_CATEGORY_INSTANCE_METHODS_Person_$_Addition 中来.如果只是在Persona.h中定义,而没有实现,则不会添加

	2.2.3 Category中『类方法列表结构体』
		// + (void)printClassName; 类方法的实现
		static void _C_Person_Addition_printClassName(Class self, SEL _cmd) {
    		NSLog((NSString *)&__NSConstantStringImpl__var_folders_ct_0dyw1pvj6k16t5z8t0j0_ghw0000gn_T_Person_Addition_c2e684_mi_0);
		}

		// + (void)personProtocolClassMethod; 方法的实现
		static void _C_Person_Addition_personProtocolClassMethod(Class self, SEL _cmd) {
   		 NSLog((NSString *)&__NSConstantStringImpl__var_folders_ct_0dyw1pvj6k16t5z8t0j0_ghw0000gn_T_Person_Addition_c2e684_mi_3);
		}

		// Person 分类中添加的『类方法列表结构体』
		static struct /*_method_list_t*/ {
    		unsigned int entsize;  // sizeof(struct _objc_method)
    		unsigned int method_count;
    		struct _objc_method method_list[2];
		} _OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Addition __attribute__ ((used, section ("__DATA,__objc_const"))) = {
    		sizeof(_objc_method),
    		2,
    		{{(struct objc_selector *)"printClassName", "v16@0:8", (void *)_C_Person_Addition_printClassName},
    		{(struct objc_selector *)"personProtocolClassMethod", "v16@0:8", (void *)_C_Person_Addition_personProtocolClassMethod}}
		};

		·从『类方法列表结构体』源码中我们可以看到：
		·+ (void)printClassName; 类方法的实现。
		·+ (void)personProtocolClassMethod; 类方法的实现。
		·类方法列表结构体。

		只要是Category中实现的类方法，都会添加到 _OBJC_$_CATEGORY_CLASS_METHODS_Person_$_Addition中来。如果只是在Person.h中定义为没有实现则不会添加。

	2.2.4 Category中『协议列表结构体』
		// Person 分类中添加的『协议列表结构体』
		static struct /*_protocol_list_t*/ {
    	long protocol_count;  // Note, this is 32/64 bit
    	struct _protocol_t *super_protocols[1];
		} _OBJC_CATEGORY_PROTOCOLS_$_Person_$_Addition __attribute__ ((used, section ("__DATA,__objc_const"))) = {
    		1,
    		&_OBJC_PROTOCOL_PersonProtocol
		};

		// 协议列表 对象方法列表结构体
		static struct /*_method_list_t*/ {
    		unsigned int entsize;  // sizeof(struct _objc_method)
    		unsigned int method_count;
    		struct _objc_method method_list[1];
		} _OBJC_PROTOCOL_INSTANCE_METHODS_PersonProtocol __attribute__ ((used, section ("__DATA,__objc_const"))) = {
    		sizeof(_objc_method),
    		1,
    		{{(struct objc_selector *)"personProtocolMethod", "v16@0:8", 0}}
		};

		// 协议列表 类方法列表结构体
		static struct /*_method_list_t*/ {
    		unsigned int entsize;  // sizeof(struct _objc_method)
    		unsigned int method_count;
    		struct _objc_method method_list[1];
		} _OBJC_PROTOCOL_CLASS_METHODS_PersonProtocol __attribute__ ((used, section ("__DATA,__objc_const"))) = {
    		sizeof(_objc_method),
    		1,
    		{{(struct objc_selector *)"personProtocolClassMethod", "v16@0:8", 0}}
		};

		// PersonProtocol 结构体赋值
		struct _protocol_t _OBJC_PROTOCOL_PersonProtocol __attribute__ ((used)) = {
    		0,
    		"PersonProtocol",
    		(const struct _protocol_list_t *)&_OBJC_PROTOCOL_REFS_PersonProtocol,
    		(const struct method_list_t *)&_OBJC_PROTOCOL_INSTANCE_METHODS_PersonProtocol,
    		(const struct method_list_t *)&_OBJC_PROTOCOL_CLASS_METHODS_PersonProtocol,
    		0,
    		0,
    		0,
    		sizeof(_protocol_t),
    		0,
    		(const char **)&_OBJC_PROTOCOL_METHOD_TYPES_PersonProtocol
		};
		struct _protocol_t *_OBJC_LABEL_PROTOCOL_$_PersonProtocol = &_OBJC_PROTOCOL_PersonProtocol;

		从『协议列表结构』源码中我们可以看到：
		1.协议列表结构体
		2.协议列表对象方法列表结构体
		3.协议列表 类方法列表结构体
		4.Personprotocol 协议结构体赋值语句

	2.2.5 Category中	『属性列表结构体』
		// Person 分类中添加的属性列表
		static struct /*_prop_list_t*/ {
    		unsigned int entsize;  // sizeof(struct _prop_t)
    		unsigned int count_of_properties;
    		struct _prop_t prop_list[1];
		} _OBJC_$_PROP_LIST_Person_$_Addition __attribute__ ((used, section ("__DATA,__objc_const"))) = {
    		sizeof(_prop_t),
    		1,
    		{{"personName","T@\"NSString\",C,N"}}
		};
		 从『属性』列表结构体 中可以看到
		 只有Person分类中添加的属性列表架构题_OBJC_$_PROP_LIST_Person_$_Addition，没有成员变量结构体_ivar_list_t 结构体，没有set/get方法

3 Category 的加载过程

	3.1 dyld加载大致流程
		Category是在运行阶段动态加载的,而Runtime加载的过程,离不开一个叫dyld的动态链接器
		在MacOS和iOS上,动态链接器dyld用来加载所有的库和可执行文件.而加载Runtime的过程,就在dyld加载的时候方法.
		dyld的大致流程:
			1.配置环境变量
			2.加载共享缓存
			3.初始化主app
			4.插入动态缓存库
			5.链接主程序
			6.链接插入的动态库
			7.初始化主程序,OC,C++全局变量初始化
			8.返回主程序入口函数

		Category在第7步执行

		dyldbootstrap::start ---> dyld::_main ---> initializeMainExecutable ---> runInitializers ---> recursiveInitialization ---> doInitialization ---> doModInitFunctions ---> _objc_init

		在_objc_init这一步中,Runtime向dyly绑定了回调,当image加载到内存后,dyld会通知Runtime进行处理,Runtime接手后调用map_images做解析和处理,调用_read_images方法把Category的对象方法,协议,属性添加到类上,把Category的类方法,协议添加到类的metaclass上,接下来load_images中调用call_load_methods方法,遍历所有加载进来的class,按继承层级和编译顺序一次调用class的load方法和Category的load方法
			加载Category的调用栈如下:
			_objc_init ---> map_images ---> map_images_nolock ---> _read_images（加载分类） ---> load_images。

	3.2 Category 加载过程

		3.2.1 _read_images方法
		// 获取镜像中的分类数组
		category_t **catlist = 
    		_getObjc2CategoryList(hi, &count);
		bool hasClassProperties = hi->info()->hasCategoryClassProperties();

		// 遍历分类数组
		for (i = 0; i < count; i++) {
    		category_t *cat = catlist[i];
    		Class cls = remapClass(cat->cls);
    		// 处理这个分类
    		// 首先，使用目标类注册当前分类
    		// 然后，如果实现了这个类，重建类的方法列表
    		bool classExists = NO;
    		if (cat->instanceMethods ||  cat->protocols   ||  cat->instanceProperties) {
        		addUnattachedCategoryForClass(cat, cls, hi);  
       		 if (cls->isRealized()) {
            	remethodizeClass(cls);
            	classExists = YES;
        	}
    	}

    		if (cat->classMethods  ||  cat->protocols   ||  (hasClassProperties && cat->_classProperties))  {
        		addUnattachedCategoryForClass(cat, cls->ISA(), hi);
        		if (cls->ISA()->isRealized()) {
            		remethodizeClass(cls->ISA());
        		}
    		}
		}

		主要用到两个方法:
		·addUnattachedCategoryForClass(cat, cls, hi); 为类添加未依附的分类
		·remethodizeClass(cls); 重建类的方法列表
		把Category的对象方法、协议、属性添加到类上。
		把Category的类方法、协议、添加到类的metaclass上

		3.2.2 addUnattachedCategoryForClass(cat, cls, hi); 方法
			static void addUnattachedCategoryForClass(category_t *cat, Class cls,  header_info *catHeader)
			{
    			runtimeLock.assertLocked();

    			// 取得存储所有未依附分类的列表：cats
    			NXMapTable *cats = unattachedCategories();
    			category_list *list;
    			// 从 cats 列表中找到 cls 对应的未依附分类的列表：list
    			list = (category_list *)NXMapGet(cats, cls);
    			if (!list) {
        			list = (category_list *)
            		calloc(sizeof(*list) + sizeof(list->list[0]), 1);
    			} else {
        			list = (category_list *)
            		realloc(list, sizeof(*list) + sizeof(list->list[0]) * (list->count + 1));
    			}
    			// 将新增的分类 cat 添加 list 中
    			list->list[list->count++] = (locstamped_category_t){cat, catHeader};
    			// 将新生成的 list 添加重新插入 cats 中，会覆盖旧的 list
    			NXMapInsert(cats, cls, list);
			}

			addUnattachedCategoryForClass(cat, cls, hi);的执行过程可以参考注释代码.执行完这个方法之后,系统将当前分类cat放到该类clas对应的未衣服分类的列表list中.把类和分类做了一个关联映射.

		3.2.3 remethodizeClas(cls)
			static void remethodizeClass(Class cls)
				{
	    			category_list *cats;
	    			bool isMeta;

	    			runtimeLock.assertLocked();

	    			isMeta = cls->isMetaClass();

	    			// 取得 cls 类的未依附分类的列表：cats
	    			if ((cats = unattachedCategoriesForClass(cls, false/*not realizing*/))) {
	        			// 将未依附分类的列表 cats 附加到 cls 类上
	        			attachCategories(cls, cats, true /*flush caches*/);        
	        			free(cats);
	    			}
				}

			remethodizeClas(cls);方法主要就做一件事,调用addachCategories(cls, cats, true)方法将未依附分类的列表cats附加到cls类上.

		3.2.4 attachCategories(cls, cats, true)
				static void 
				attachCategories(Class cls, category_list *cats, bool flush_caches)
				{
				    if (!cats) return;
				    if (PrintReplacedMethods) printReplacements(cls, cats);

				    bool isMeta = cls->isMetaClass();

				    // 创建方法列表、属性列表、协议列表，用来存储分类的方法、属性、协议
				    method_list_t **mlists = (method_list_t **)
				        malloc(cats->count * sizeof(*mlists));
				    property_list_t **proplists = (property_list_t **)
				        malloc(cats->count * sizeof(*proplists));
				    protocol_list_t **protolists = (protocol_list_t **)
				        malloc(cats->count * sizeof(*protolists));

				    // Count backwards through cats to get newest categories first
				    int mcount = 0;           // 记录方法的数量
				    int propcount = 0;        // 记录属性的数量
				    int protocount = 0;       // 记录协议的数量
				    int i = cats->count;      // 从分类数组最后开始遍历，保证先取的是最新的分类
				    bool fromBundle = NO;     // 记录是否是从 bundle 中取的
				    while (i--) { // 从后往前依次遍历
				        auto& entry = cats->list[i];  // 取出当前分类
				    
				        // 取出分类中的方法列表。如果是元类，取得的是类方法列表；否则取得的是对象方法列表
				        method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
				        if (mlist) {
				            mlists[mcount++] = mlist;            // 将方法列表放入 mlists 方法列表数组中
				            fromBundle |= entry.hi->isBundle();  // 分类的头部信息中存储了是否是 bundle，将其记住
				        }

				        // 取出分类中的属性列表，如果是元类，取得的是 nil
				        property_list_t *proplist = 
				            entry.cat->propertiesForMeta(isMeta, entry.hi);
				        if (proplist) {
				            proplists[propcount++] = proplist;
				        }

				        // 取出分类中遵循的协议列表
				        protocol_list_t *protolist = entry.cat->protocols;
				        if (protolist) {
				            protolists[protocount++] = protolist;
				        }
				    }

				    // 取出当前类 cls 的 class_rw_t 数据
				    auto rw = cls->data();

				    // 存储方法、属性、协议数组到 rw 中
				    // 准备方法列表 mlists 中的方法
				    prepareMethodLists(cls, mlists, mcount, NO, fromBundle);
				    // 将新方法列表添加到 rw 中的方法列表中
				    rw->methods.attachLists(mlists, mcount);
				    // 释放方法列表 mlists
				    free(mlists);
				    // 清除 cls 的缓存列表
				    if (flush_caches  &&  mcount > 0) flushCaches(cls);

				    // 将新属性列表添加到 rw 中的属性列表中
				    rw->properties.attachLists(proplists, propcount);
				    // 释放属性列表
				    free(proplists);

				    // 将新协议列表添加到 rw 中的协议列表中
				    rw->protocols.attachLists(protolists, protocount);
				    // 释放协议列表
				    free(protolists);
				}			
			从 attachCategories(cls, cats, true); 方法的注释中可以看出这个方法就是存储分类的方法、属性、协议的核心代码。
			1.Category的方法,属性,协议只是添加到原有类上,并没有将原有类的方法、属性、协议进行完全替换
				举个例子：假设原来类有MethodA方法，分类也拥有MethodA方法，那么加载完分类后，类的方法列表中会拥有两个MethodA方法。
			2.Category的方法、属性、协议会被添加到原有类的方法列表、属性列表、协议列表的最前面，而原有类的方法，属性、协议则被移动到列表后面
				因为在运行时查找的方法的时候是顺着方法列表的顺序依次查找的，所以Category的方法会被搜索到，然后直接执行，而原有类的方法则不被执行，

	4. Category（分类）和Class（类）的+load方法
		Category中的方法、属性、协议附加到类上的操作，是在load方法执行之前进行的,也就是说,在+load方法之前,类中就已经加载了category的方法、属性、协议

		Category（分类）和Class（类）的+load方法的调用顺序规则如下所示：
		1.先调用主类、按照编译顺序、想混序的根据继承关系由父类向子类调用
		2.调用完主类、再调用分类，按照编译顺序、依次调用
		3.+load方法除非主动调用、否则只会调用一次

		通过这样的调用规则，我们可以知道：主类的+load方法调用一定在分类+load方法调用之前。但是+load方法调用顺序并不是按照继承关系调用，而是依照编译顺序确定的，这也导致了+load方法的调用顺序不一样确定，可能是：父类 -> 子类 -> 父类类别 -> 子类类别，也可能是 父类 -> 子类 -> 子类类别 -> 父类类别。

	5.Category与关联对象 
		在Category中虽然可以添加属性,但是不会生产对应的成员变量,也不能生产getter,setter,因此在调用Category中声明的属性会报错.
		可以使用关联对象(Objective-C Associated Objects)来实现getter, setter:

			// 1. 通过 key : value 的形式给对象 object 设置关联属性
			void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
			// 2. 通过 key 获取关联的属性 object
			id objc_getAssociatedObject(id object, const void *key);
			// 3. 移除对象所关联的属性
			void objc_removeAssociatedObjects(id object);
	

















