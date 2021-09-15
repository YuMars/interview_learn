//
//  URLSessionTaskSwizzling.m
//  RunTime
//
//  Created by Red-Fish on 2021/8/31.
//

#import "URLSessionTaskSwizzling.h"

@implementation URLSessionTaskSwizzling

//+ (void)load {
//    if (NSClassFromString(@"NSURLSessionTask")) {
//
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
//#pragma GCC diagnostic push
//#pragma GCC diagnostic ignored "-Wnonnull"
//
//        NSURLSessionDataTask *localDataTask = [session dataTaskWithRequest:nil];
//
//#pragma clang diagnostic pop
//        IMP originalAFResumeImp = method_getImplementation(class_getInstanceMethod([self class], @selector(_resume)));
//        Class currentClass = [localDataTask class];
//        while (class_getInstanceMethod(currentClass, @selector(resume))) {
//            Class superClass = [currentClass superclass];
//            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
//            IMP superClassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
//            if (classResumeIMP != superClassResumeIMP && originalAFResumeImp != classResumeIMP) {
//                [self swizzleResumeAndSuspendMethodForClass:currentClass];
//            }
//
//            currentClass = [currentClass superclass];
//        }
//
//        [localDataTask cancel];
//        [session finishTasksAndInvalidate];
//    }
//}

+ (void)swizzleResumeAndSuspendMethodForClass:(Class)theClass {
    Method resumeMethod = class_getInstanceMethod(self, @selector(_resume));
    Method suspendMethod = class_getInstanceMethod(self, @selector(_suspend));
    
    if (_addMethod(theClass, @selector(_resume), resumeMethod)) {
        _swizzleSelector(theClass, @selector(resume), @selector(_resume));
    }
    
    if (_addMethod(theClass, @selector(_suspend), suspendMethod)) {
        _swizzleSelector(theClass, @selector(suspend), @selector(_suspend));
    }
}

- (NSURLSessionTaskState)state {
    NSAssert(NO, @"State method should never be called in the actual dummy class");
    return NSURLSessionTaskStateCanceling;
}

- (void)_resume {
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
    
    NSURLSessionTaskState state = [self state];
    [self _resume];
    
    if (state != NSURLSessionTaskStateRunning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNSURLSessionTaskDidResumeNotification" object:self];
    }
}

- (void)_suspend {
    NSAssert([self respondsToSelector:@selector(state)], @"Does not respond to state");
        NSURLSessionTaskState state = [self state];
        [self _suspend];
        
        if (state != NSURLSessionTaskStateSuspended) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNSURLSessionTaskDidSuspendNotification" object:self];
        }
    
}

@end
