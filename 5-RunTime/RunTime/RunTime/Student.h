//
//  Student.h
//  RunTime
//
//  Created by Red-Fish on 2021/9/2.
//

#import <Foundation/Foundation.h>

@class Address, Course;

NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject

/* 姓名 */
@property (nonatomic, copy) NSString *name;
/* 学生号 id */
@property (nonatomic, copy) NSString *uid;
/* 年龄 */
@property (nonatomic, assign) NSInteger age;
/* 体重 */
@property (nonatomic, assign) NSInteger weight;
/* 地址（嵌套模型） */
@property (nonatomic, strong) Address *address;
/* 课程（嵌套模型数组） */
@property (nonatomic, strong) NSArray *courses;

@end

NS_ASSUME_NONNULL_END
