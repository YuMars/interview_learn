//
//  Student+Addition.h
//  RunTime
//
//  Created by Red-Fish on 2021/9/2.
//

#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@protocol StudentProtocol <NSObject>

- (void)PersonProtocolMethod;

+ (void)PersonProtocolClassMethod;

@end

@interface Student (Addition) <StudentProtocol>


/* name 属性 */
@property (nonatomic, copy) NSString *personName;

// 类方法
+ (void)printClassName;

// 对象方法
- (void)printName;


@end

NS_ASSUME_NONNULL_END
