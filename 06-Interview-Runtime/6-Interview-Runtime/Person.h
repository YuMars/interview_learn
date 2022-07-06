//
//  Person.h
//  6-Interview-Runtime
//
//  Created by Red-Fish on 2022/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

- (void)test;
- (void)print;

@end

NS_ASSUME_NONNULL_END
