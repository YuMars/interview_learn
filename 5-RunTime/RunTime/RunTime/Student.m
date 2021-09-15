//
//  Student.m
//  RunTime
//
//  Created by Red-Fish on 2021/9/2.
//

#import "Student.h"
#import "Course.h"

@implementation Student

+ (NSDictionary *)modelContainerPropertyGenericClass {
    //需要特别处理的属性
    return @{
             @"courses" : [Course class],
             @"uid" : @"id"
             };
}


@end
