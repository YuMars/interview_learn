/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+WebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import "SDWebImageError.h"
#import "SDInternalMacros.h"
#import "SDWebImageTransitionInternal.h"
#import "SDImageCache.h"

const int64_t SDWebImageProgressUnitCountUnknown = 1LL;

@implementation UIView (WebCache)

- (nullable NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, @selector(sd_imageURL));
}

- (void)setSd_imageURL:(NSURL * _Nullable)sd_imageURL {
    objc_setAssociatedObject(self, @selector(sd_imageURL), sd_imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable NSString *)sd_latestOperationKey {
    return objc_getAssociatedObject(self, @selector(sd_latestOperationKey));
}

- (void)setSd_latestOperationKey:(NSString * _Nullable)sd_latestOperationKey {
    objc_setAssociatedObject(self, @selector(sd_latestOperationKey), sd_latestOperationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSProgress *)sd_imageProgress {
    NSProgress *progress = objc_getAssociatedObject(self, @selector(sd_imageProgress));
    if (!progress) {
        progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.sd_imageProgress = progress;
    }
    return progress;
}

- (void)setSd_imageProgress:(NSProgress *)sd_imageProgress {
    objc_setAssociatedObject(self, @selector(sd_imageProgress), sd_imageProgress, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable id<SDWebImageOperation>)sd_internalSetImageWithURL:(nullable NSURL *)url
                                              placeholderImage:(nullable UIImage *)placeholder
                                                       options:(SDWebImageOptions)options
                                                       context:(nullable SDWebImageContext *)context
                                                 setImageBlock:(nullable SDSetImageBlock)setImageBlock
                                                      progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                                     completed:(nullable SDInternalCompletionBlock)completedBlock {
    if (context) {
        // copy to avoid mutable object
        context = [context copy];
    } else {
        context = [NSDictionary dictionary];
    }
    
    // 先取了context里面的配置参数，context没有，则从NSStringFromClass([self class])取类本身，并且给context赋值{@"setImageOperationKey":validOperationKey}
    NSString *validOperationKey = context[SDWebImageContextSetImageOperationKey];
    if (!validOperationKey) {
        // pass through the operation key to downstream, which can used for tracing operation or image view class
        validOperationKey = NSStringFromClass([self class]);
        SDWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[SDWebImageContextSetImageOperationKey] = validOperationKey;
        context = [mutableContext copy];
    }
    self.sd_latestOperationKey = validOperationKey;
    
    // 从sd_operationDictionary中取出SDOperationsDictionary对应的operation，并且取消
    [self sd_cancelImageLoadOperationWithKey:validOperationKey];
    self.sd_imageURL = url;
    
    SDWebImageManager *manager = context[SDWebImageContextCustomManager];
    if (!manager) {
        manager = [SDWebImageManager sharedManager];
    } else {
        // 防止传入的context循环引用SDWebImageManager
        // remove this manager to avoid retain cycle (manger -> loader -> operation -> context -> manager)
        SDWebImageMutableContext *mutableContext = [context mutableCopy];
        mutableContext[SDWebImageContextCustomManager] = nil;
        context = [mutableContext copy];
    }
    
    // 弱引用Cache,当内存警告时候缓存memoryCahce中的数据被清除，一些图片就需要重新下载，用了shouldUseWeakCache后清理缓存后也可以从NSMapTable类型的weakCache表中获取数据
    BOOL shouldUseWeakCache = NO;
    if ([manager.imageCache isKindOfClass:SDImageCache.class]) {
        shouldUseWeakCache = ((SDImageCache *)manager.imageCache).config.shouldUseWeakMemoryCache;
    }
    if (!(options & SDWebImageDelayPlaceholder)) { // 没有设置延迟placeHolder（加载过程取消或者失败的情况）
        if (shouldUseWeakCache) {
            NSString *key = [manager cacheKeyForURL:url context:context];
            // call memory cache to trigger weak cache sync logic, ignore the return value and go on normal query
            // this unfortunately will cause twice memory cache query, but it's fast enough
            // in the future the weak cache feature may be re-design or removed
            [((SDImageCache *)manager.imageCache) imageFromMemoryCacheForKey:key];
        }
        dispatch_main_async_safe(^{// 判断了当前线程是不是在主线程，确保在主线程执行
            // 设置placehodler
            [self sd_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock cacheType:SDImageCacheTypeNone imageURL:url];
        });
    }
    
    // 遵循的（可取消）协议的对象-下载功能
    id <SDWebImageOperation> operation = nil;
    
    // 1.有URL开始下载，开始加载动画、并且同步进度
    // 2.没URL，停止加载动画、回调进度、同时报错
    if (url) {
        // reset the progress // 设置加载进度
        NSProgress *imageProgress = objc_getAssociatedObject(self, @selector(sd_imageProgress));
        if (imageProgress) {
            imageProgress.totalUnitCount = 0;
            imageProgress.completedUnitCount = 0;
        }
        
        // check and start image indicator
        // 图片加载转菊花，有设置就开始动画，没有设置就return
        [self sd_startImageIndicator];
        id<SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;
        
        // 加载进度回调
        // 对外部的imageProgress设置:已经加载的数据量和还需要的数据量
        // 同时对转菊花的进行进度更新
        SDImageLoaderProgressBlock combinedProgressBlock = ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (imageProgress) {
                imageProgress.totalUnitCount = expectedSize;
                imageProgress.completedUnitCount = receivedSize;
            }
            
            if ([imageIndicator respondsToSelector:@selector(updateIndicatorProgress:)]) {
                double progress = 0;
                if (expectedSize != 0) {
                    progress = (double)receivedSize / expectedSize;
                }
                progress = MAX(MIN(progress, 1), 0); // 0.0 - 1.0
                dispatch_async(dispatch_get_main_queue(), ^{
                    [imageIndicator updateIndicatorProgress:progress];
                });
            }
            
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize, targetURL);
            }
        };
        @weakify(self);
        
        operation = [manager loadImageWithURL:url options:options context:context progress:combinedProgressBlock completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            // 加载完成后操作、设置加载动画、设置图片转场效果、设置最终图片
            
            @strongify(self);
            if (!self) { return; }
            
            // 纠错，如果已经完成并且没有报错，将已下载总数据量和总数据量标记成完成状态(可能是那种数据量很少，直接下载完成无进度回调的情况)
            if (imageProgress && finished && !error && imageProgress.totalUnitCount == 0 && imageProgress.completedUnitCount == 0) {
                imageProgress.totalUnitCount = SDWebImageProgressUnitCountUnknown;
                imageProgress.completedUnitCount = SDWebImageProgressUnitCountUnknown;
            }
            
            // 结束加载菊花动画
            if (finished) {
                [self sd_stopImageIndicator];
            }
            
            // SDWebImageAvoidAutoSetImage手动设置加载完成后操作
            BOOL shouldCallCompletedBlock = finished || (options & SDWebImageAvoidAutoSetImage);
            // SDWebImageDelayPlaceholder手动设置加载成功后动作
            BOOL shouldNotSetImage = ((image && (options & SDWebImageAvoidAutoSetImage)) ||
                                      (!image && !(options & SDWebImageDelayPlaceholder)));
            
            // 设置SDWebImageAvoidAutoSetImage和SDWebImageDelayPlaceholder的回调
            SDWebImageNoParamsBlock callCompletedBlockClosure = ^{
                if (!self) { return; }
                if (!shouldNotSetImage) {
                    [self sd_setNeedsLayout];
                }
                if (completedBlock && shouldCallCompletedBlock) {
                    completedBlock(image, data, error, cacheType, finished, url);
                }
            };
            
            // 有图片，但是需要手动设置图片
            // 无图片，但是placeHolder没设置
            if (shouldNotSetImage) {
                dispatch_main_async_safe(callCompletedBlockClosure);
                return;
            }
            
            UIImage *targetImage = nil;
            NSData *targetData = nil;
            if (image) {
                // 有图，自动设置图片
                targetImage = image;
                targetData = data;
            } else if (options & SDWebImageDelayPlaceholder) {
                // 无图，设置了PlaceHolder
                targetImage = placeholder;
                targetData = nil;
            }
            
            // 加载成功后动画专场效果

            SDWebImageTransition *transition = nil;
            BOOL shouldUseTransition = NO;
            if (options & SDWebImageForceTransition) {
                // 强制转场效果
                shouldUseTransition = YES;
            } else if (cacheType == SDImageCacheTypeNone) {
                // 没有缓存，需要转场效果
                shouldUseTransition = YES;
            } else {
                // 从缓存中取的，不需要转场
                // 从磁盘中取的，如果是缓存同步或者磁盘同步，不需要转场，否则需要转场
                if (cacheType == SDImageCacheTypeMemory) {
                    shouldUseTransition = NO;
                } else if (cacheType == SDImageCacheTypeDisk) {
                    if (options & SDWebImageQueryMemoryDataSync || options & SDWebImageQueryDiskDataSync) {
                        shouldUseTransition = NO;
                    } else {
                        shouldUseTransition = YES;
                    }
                } else {
                    // 其他情况不需要转场
                    shouldUseTransition = NO;
                }
            }
            if (finished && shouldUseTransition) {
                transition = self.sd_imageTransition;
            }

            dispatch_main_async_safe(^{
                [self sd_setImage:targetImage imageData:targetData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:transition cacheType:cacheType imageURL:imageURL];

                // 加载成功回调
                callCompletedBlockClosure();
            });
        }];
        // 设置operation和validOperationKey关联、用于取消某次加载图片
        [self sd_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
        // 停止图片加载动画
        [self sd_stopImageIndicator];
        if (completedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorInvalidURL userInfo:@{NSLocalizedDescriptionKey : @"Image url is nil"}];
                completedBlock(nil, nil, error, SDImageCacheTypeNone, YES, url);
            });
        }
    }
    
    return operation;
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:self.sd_latestOperationKey];
    self.sd_latestOperationKey = nil;
}

- (void)sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock cacheType:(SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
#if SD_UIKIT || SD_MAC
    [self sd_setImage:image imageData:imageData basedOnClassOrViaCustomSetImageBlock:setImageBlock transition:nil cacheType:cacheType imageURL:imageURL];
#else
    // watchOS does not support view transition. Simplify the logic
    if (setImageBlock) {
        setImageBlock(image, imageData, cacheType, imageURL);
    } else if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        [imageView setImage:image];
    }
#endif
}

#if SD_UIKIT || SD_MAC
- (void)sd_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(SDSetImageBlock)setImageBlock transition:(SDWebImageTransition *)transition cacheType:(SDImageCacheType)cacheType imageURL:(NSURL *)imageURL {
    UIView *view = self;
    SDSetImageBlock finalSetImageBlock;
    if (setImageBlock) {
        finalSetImageBlock = setImageBlock;
    } else if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, SDImageCacheType setCacheType, NSURL *setImageURL) {
            imageView.image = setImage;
        };
    }
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        finalSetImageBlock = ^(UIImage *setImage, NSData *setImageData, SDImageCacheType setCacheType, NSURL *setImageURL) {
            [button setImage:setImage forState:UIControlStateNormal];
        };
    }
    
    if (transition) {
        NSString *originalOperationKey = view.sd_latestOperationKey;
        
        [UIView transitionWithView:view duration:0 options:0 animations:^{
            if (!view.sd_latestOperationKey || ![originalOperationKey isEqualToString:view.sd_latestOperationKey]) {
                return;
            }
            // 0 duration to let UIKit render placeholder and prepares block
            if (transition.prepares) {
                transition.prepares(view, image, imageData, cacheType, imageURL);
            }
        } completion:^(BOOL tempFinished) {
            [UIView transitionWithView:view duration:transition.duration options:transition.animationOptions animations:^{
                if (!view.sd_latestOperationKey || ![originalOperationKey isEqualToString:view.sd_latestOperationKey]) {
                    return;
                }
                if (finalSetImageBlock && !transition.avoidAutoSetImage) {
                    finalSetImageBlock(image, imageData, cacheType, imageURL);
                }
                if (transition.animations) {
                    transition.animations(view, image);
                }
            } completion:^(BOOL finished) {
                if (!view.sd_latestOperationKey || ![originalOperationKey isEqualToString:view.sd_latestOperationKey]) {
                    return;
                }
                if (transition.completion) {
                    transition.completion(finished);
                }
            }];
        }];

    } else {
        if (finalSetImageBlock) {
            finalSetImageBlock(image, imageData, cacheType, imageURL);
        }
    }
}
#endif

- (void)sd_setNeedsLayout {
    [self setNeedsLayout];
}

#if SD_UIKIT || SD_MAC

#pragma mark - Image Transition
- (SDWebImageTransition *)sd_imageTransition {
    return objc_getAssociatedObject(self, @selector(sd_imageTransition));
}

- (void)setSd_imageTransition:(SDWebImageTransition *)sd_imageTransition {
    objc_setAssociatedObject(self, @selector(sd_imageTransition), sd_imageTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Indicator
- (id<SDWebImageIndicator>)sd_imageIndicator {
    return objc_getAssociatedObject(self, @selector(sd_imageIndicator));
}

- (void)setSd_imageIndicator:(id<SDWebImageIndicator>)sd_imageIndicator {
    // Remove the old indicator view
    id<SDWebImageIndicator> previousIndicator = self.sd_imageIndicator;
    [previousIndicator.indicatorView removeFromSuperview];
    
    objc_setAssociatedObject(self, @selector(sd_imageIndicator), sd_imageIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Add the new indicator view
    UIView *view = sd_imageIndicator.indicatorView;
    if (CGRectEqualToRect(view.frame, CGRectZero)) {
        view.frame = self.bounds;
    }
    // Center the indicator view
#if SD_MAC
    [view setFrameOrigin:CGPointMake(round((NSWidth(self.bounds) - NSWidth(view.frame)) / 2), round((NSHeight(self.bounds) - NSHeight(view.frame)) / 2))];
#else
    view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
#endif
    view.hidden = NO;
    [self addSubview:view];
}

- (void)sd_startImageIndicator {
    id<SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator startAnimatingIndicator];
    });
}

- (void)sd_stopImageIndicator {
    id<SDWebImageIndicator> imageIndicator = self.sd_imageIndicator;
    if (!imageIndicator) {
        return;
    }
    dispatch_main_async_safe(^{
        [imageIndicator stopAnimatingIndicator];
    });
}

#endif

@end
