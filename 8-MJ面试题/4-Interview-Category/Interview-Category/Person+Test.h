//
//  Person+Test.h
//  Interview-Category
//
//  Created by Red-Fish on 2021/12/13.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person (Test) <NSCopying, NSCoding>

@property (nonatomic, assign) int height;

- (void)test;
- (void)test2;

+ (void)classTest;

@end

NS_ASSUME_NONNULL_END
