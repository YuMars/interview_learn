//
//  Student+Test1.m
//  Interview-Category
//
//  Created by Red-Fish on 2021/12/13.
//

#import "Student+Test1.h"

@implementation Student (Test1)

int num_;
NSMutableDictionary *dict_;

+ (void)load {
    dict_ = [[NSMutableDictionary alloc] init];
    NSLog(@"Student (Test1)");
}

- (void)setNum:(int)num {
    NSString *key = [NSString stringWithFormat:@"%p", self];
    dict_[key] = @(num);
    //num_ = num;
}

- (int)num {
    NSString *key = [NSString stringWithFormat:@"%p", self];
    return [dict_[key] intValue];
//    return num_;
}

@end
