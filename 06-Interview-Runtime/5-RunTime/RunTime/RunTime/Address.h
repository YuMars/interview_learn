//
//  Address.h
//  RunTime
//
//  Created by Red-Fish on 2021/9/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Address : NSObject

/* 国籍 */
@property (nonatomic, copy) NSString *country;
/* 省份 */
@property (nonatomic, copy) NSString *province;
/* 城市 */
@property (nonatomic, copy) NSString *city;

@end

NS_ASSUME_NONNULL_END
