//
//  Course.h
//  RunTime
//
//  Created by Red-Fish on 2021/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Course : NSObject

/* 课程名 */
@property (nonatomic, copy) NSString *name;
/* 课程介绍 */
@property (nonatomic, copy) NSString *desc;

@end

NS_ASSUME_NONNULL_END
