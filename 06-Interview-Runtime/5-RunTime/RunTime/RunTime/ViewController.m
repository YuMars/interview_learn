//
//  ViewController.m
//  RunTime
//
//  Created by Red-Fish on 2021/8/23.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "UIViewController+DotSwizzling.h"
#import "Student.h"
#import "Course.h"
#import "NSObject+Model.h"
#import "ObjcMsgSend.h"

@interface Person : NSObject

- (void)personFun;

@end

@implementation Person

- (void)personFun {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)fun {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

@end

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [self performSelector:@selector(testFun)];
      
//    [self performSelector:@selector(forwardingFun)];
    
    // [self performSelector:@selector(fun)];
    
    NSString *string = @"";
    
//    {
//        "id": "123412341234",
//        "name": "行走少年郎",
//        "age": "18",
//        "weight": 120,
//        "address": {
//            "country": "中国",
//            "province": "北京"
//        },
//        "courses": [
//            {
//                "name": "Chinese",
//                "desc": "语文课"
//            },
//            {
//                "name": "Math",
//                "desc": "数学课"
//            },
//            {
//                "name": "English",
//                "desc": "英语课"
//            }
//        ]
//    }
    
    [self swizzlingMethod];
    [self originalFunction];
    [self swizzlingFunction];
    
//    [self printIvarList];
//    [self printPropertyList];
//    [self printMethodList];
    [self printTextFileList];
//    [self createLoginTextField];
    
    [self parseJSON];
}

- (void)parseJSON {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"studentA" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];

    // 读取 JSON 数据
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",json);

    // JSON 字典转模型
    Student *student = [Student modelWithDictionary:json];

    NSLog(@"student.uid = %@", student.uid);
    NSLog(@"student.name = %@", student.name);

    for (unsigned int i = 0; i < student.courses.count; i++) {
        Course *courseModel = student.courses[i];
        NSLog(@"courseModel[%d].name = %@ .desc = %@", i, courseModel.name, courseModel.desc);
        NSLog(@"course:%@", courseModel);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"页面展示");
}

- (void)createLoginTextField {
    UITextField *textField = [[UITextField alloc] init];
    textField.frame = CGRectMake(100.0, 100.01, 100.0, 100.0);
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:15.0];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.textColor = [UIColor blueColor];
    
    textField.placeholder = @"啊水电费健康";
    [textField setValue:[UIFont systemFontOfSize:20.0] forKey:@"_placeholderLabel.font"];
    [textField setValue:[UIColor redColor] forKey:@"_placeholderLabel.textColor"];
    [self.view addSubview:textField];
}

- (void)printTextFileList {
    unsigned int count;
    
    Ivar *ivarList = class_copyIvarList([UITextField class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        const char *ivarName = ivar_getName(ivar);
        NSLog(@"TextFiled Ivar(%d) Name:%@", i, [NSString stringWithUTF8String:ivarName]);
    }
    
    free(ivarList);
    
    objc_property_t *propertyList = class_copyPropertyList([UITextField class], &count);
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"TextFiled propertyName(%d):%@", i, [NSString stringWithUTF8String:propertyName]);
    }
    
    free(propertyList);
}

- (void)printIvarList {
    unsigned int count;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"Ivar(%d):%@", i, [NSString stringWithUTF8String:ivarName]);
    }
    
    free(ivarList);
}

- (void)printPropertyList {
    unsigned int count;
    
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"propertyName(%d):%@",i, [NSString stringWithUTF8String:propertyName]);
    }
    
    free(propertyList);
}

- (void)printMethodList {
    unsigned int count;
    Method *methodList = class_copyMethodList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method(%d):%@", i, NSStringFromSelector(method_getName(method)));
    }
    
    free(methodList);
}

- (void)printProtocolList {
    unsigned int count;

    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Protocol *protocol = protocolList[i];
        const char *protocolName = protocol_getName(protocol);
        NSLog(@"protocolName(%d):%@", i, [NSString stringWithUTF8String:protocolName]);
    }
    
    free(protocolList);
}

- (void)swizzlingMethod {
    Class class = [self class];
    
    SEL originalSelector = @selector(originalFunction);
    SEL swizzlingSelector = @selector(swizzlingFunction);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzlingMethod = class_getInstanceMethod(class, swizzlingSelector);
    
    method_exchangeImplementations(originalMethod, swizzlingMethod);
}

- (void)swizzlingFunction {
    NSLog(@"2222%@", NSStringFromSelector(_cmd));
}

- (void)originalFunction {
    NSLog(@"1111%@", NSStringFromSelector(_cmd));
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return YES; // 为了进行下一步 消息接受者重定向，返回YES，代表有动态添加方法
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil; // 为了进行下一步 消息重定向
}

// 获取函数的参数和返回值类型，返回签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"fun"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL seletor = anInvocation.selector; // 从 anInvocation 中获取消息
    
    Person *p = [[Person alloc] init];
    if ([p respondsToSelector:seletor]) {  // 判断 Person 对象方法是否可以响应 sel
        [anInvocation invokeWithTarget:p];  // 若可以响应，则将消息转发给其他对象处理
    } else {
        [self doesNotRecognizeSelector:seletor]; // 若仍然无法响应，则报错：找不到响应方法
    }
}

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(testFun)) {
//        class_addMethod([self class], sel, (IMP)funMethod, "v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

//void funMethod(id obj, SEL _cmd) {
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//}

@end
