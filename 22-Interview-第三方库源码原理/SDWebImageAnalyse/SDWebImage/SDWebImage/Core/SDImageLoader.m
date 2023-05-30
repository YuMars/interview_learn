/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageLoader.h"
#import "SDWebImageCacheKeyFilter.h"
#import "SDImageCodersManager.h"
#import "SDImageCoderHelper.h"
#import "SDAnimatedImage.h"
#import "UIImage+Metadata.h"
#import "SDInternalMacros.h"
#import "SDImageCacheDefine.h"
#import "objc/runtime.h"

SDWebImageContextOption const SDWebImageContextLoaderCachedImage = @"loaderCachedImage";

static void * SDImageLoaderProgressiveCoderKey = &SDImageLoaderProgressiveCoderKey;

id<SDProgressiveImageCoder> SDImageLoaderGetProgressiveCoder(id<SDWebImageOperation> operation) {
    NSCParameterAssert(operation);
    return objc_getAssociatedObject(operation, SDImageLoaderProgressiveCoderKey);
}

void SDImageLoaderSetProgressiveCoder(id<SDWebImageOperation> operation, id<SDProgressiveImageCoder> progressiveCoder) {
    NSCParameterAssert(operation);
    objc_setAssociatedObject(operation, SDImageLoaderProgressiveCoderKey, progressiveCoder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

UIImage * _Nullable SDImageLoaderDecodeImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, SDWebImageOptions options, SDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    
    UIImage *image;
    id<SDWebImageCacheKeyFilter> cacheKeyFilter = context[SDWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
    SDImageCoderOptions *coderOptions = SDGetDecodeOptionsFromContext(context, options, cacheKey);
    BOOL decodeFirstFrame = SD_OPTIONS_CONTAINS(options, SDWebImageDecodeFirstFrameOnly);
    CGFloat scale = [coderOptions[SDImageCoderDecodeScaleFactor] doubleValue];
    
    // Grab the image coder
    id<SDImageCoder> imageCoder = context[SDWebImageContextImageCoder];
    if (!imageCoder) {
        imageCoder = [SDImageCodersManager sharedManager];
    }
    
    if (!decodeFirstFrame) {
        // check whether we should use `SDAnimatedImage`
        Class animatedImageClass = context[SDWebImageContextAnimatedImageClass];
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(SDAnimatedImage)]) {
            image = [[animatedImageClass alloc] initWithData:imageData scale:scale options:coderOptions];
            if (image) {
                // Preload frames if supported
                if (options & SDWebImagePreloadAllFrames && [image respondsToSelector:@selector(preloadAllFrames)]) {
                    [((id<SDAnimatedImage>)image) preloadAllFrames];
                }
            } else {
                // Check image class matching
                if (options & SDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        image = [imageCoder decodedImageWithData:imageData options:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !SD_OPTIONS_CONTAINS(options, SDWebImageAvoidDecodeImage);
        BOOL lazyDecode = [coderOptions[SDImageCoderDecodeUseLazyDecoding] boolValue];
        if (lazyDecode) {
            // lazyDecode = NO means we should not forceDecode, highest priority
            shouldDecode = NO;
        }
        if (shouldDecode) {
            image = [SDImageCoderHelper decodedImageWithImage:image];
        }
        // assign the decode options, to let manager check whether to re-decode if needed
        image.sd_decodeOptions = coderOptions;
    }
    
    return image;
}

UIImage * _Nullable SDImageLoaderDecodeProgressiveImageData(NSData * _Nonnull imageData, NSURL * _Nonnull imageURL, BOOL finished,  id<SDWebImageOperation> _Nonnull operation, SDWebImageOptions options, SDWebImageContext * _Nullable context) {
    NSCParameterAssert(imageData);
    NSCParameterAssert(imageURL);
    NSCParameterAssert(operation);
    
    UIImage *image;
    /// 缓存过滤器,来过滤和修改用于缓存的密钥
    id<SDWebImageCacheKeyFilter> cacheKeyFilter = context[SDWebImageContextCacheKeyFilter];
    NSString *cacheKey;
    if (cacheKeyFilter) {
        cacheKey = [cacheKeyFilter cacheKeyForURL:imageURL];
    } else {
        cacheKey = imageURL.absoluteString;
    }
    /// 获取解码配置
    SDImageCoderOptions *coderOptions = SDGetDecodeOptionsFromContext(context, options, cacheKey);
    // 解码第一帧
    BOOL decodeFirstFrame = SD_OPTIONS_CONTAINS(options, SDWebImageDecodeFirstFrameOnly);
    CGFloat scale = [coderOptions[SDImageCoderDecodeScaleFactor] doubleValue];
    
    // 逐步解码解码器
    id<SDProgressiveImageCoder> progressiveCoder = SDImageLoaderGetProgressiveCoder(operation);
    if (!progressiveCoder) {
        id<SDProgressiveImageCoder> imageCoder = context[SDWebImageContextImageCoder];
        // Check the progressive coder if provided
        if ([imageCoder respondsToSelector:@selector(initIncrementalWithOptions:)]) {
            progressiveCoder = [[[imageCoder class] alloc] initIncrementalWithOptions:coderOptions];
        } else {
            // We need to create a new instance for progressive decoding to avoid conflicts
            for (id<SDImageCoder> coder in [SDImageCodersManager sharedManager].coders.reverseObjectEnumerator) {
                if ([coder conformsToProtocol:@protocol(SDProgressiveImageCoder)] &&
                    [((id<SDProgressiveImageCoder>)coder) canIncrementalDecodeFromData:imageData]) {
                    // 生成对应的解码器类型
                    // 因为增量解码需要保留解码上下文,我们将为每个下载操作分配同一类的新实例,以避免冲突。
                    progressiveCoder = [[[coder class] alloc] initIncrementalWithOptions:coderOptions];
                    break;
                }
            }
        }
        SDImageLoaderSetProgressiveCoder(operation, progressiveCoder);
    }
    // If we can't find any progressive coder, disable progressive download
    if (!progressiveCoder) {
        return nil;
    }
    // 当有新的图像数据可用时更新增量解码
    [progressiveCoder updateIncrementalData:imageData finished:finished];
    if (!decodeFirstFrame) {
        // check whether we should use `SDAnimatedImage`
        Class animatedImageClass = context[SDWebImageContextAnimatedImageClass];
        if ([animatedImageClass isSubclassOfClass:[UIImage class]] && [animatedImageClass conformsToProtocol:@protocol(SDAnimatedImage)] && [progressiveCoder respondsToSelector:@selector(animatedImageFrameAtIndex:)]) {
            image = [[animatedImageClass alloc] initWithAnimatedCoder:(id<SDAnimatedImageCoder>)progressiveCoder scale:scale];
            if (image) {
                // Progressive decoding does not preload frames
            } else {
                // Check image class matching
                if (options & SDWebImageMatchAnimatedImageClass) {
                    return nil;
                }
            }
        }
    }
    if (!image) {
        // 增量解码当前图像数据以获取图像。
        image = [progressiveCoder incrementalDecodedImageWithOptions:coderOptions];
    }
    if (image) {
        BOOL shouldDecode = !SD_OPTIONS_CONTAINS(options, SDWebImageAvoidDecodeImage);
        BOOL lazyDecode = [coderOptions[SDImageCoderDecodeUseLazyDecoding] boolValue];
        if (lazyDecode) {
            // lazyDecode = NO means we should not forceDecode, highest priority
            shouldDecode = NO;
        }
        if (shouldDecode) {
            // 使用提供的图像返回解码后的图像。这与`CGImageCreateDecoded:不同,不会解码包含alpha通道或动画图像的图像。在iOS 15+上,这可能会使用UIImage.preparingForDisplay()`来使用CMPhoto进行解码,性能会比旧解决方案好。
            // 根据不同平台和系统版本进行不同的解码
            image = [SDImageCoderHelper decodedImageWithImage:image];
        }
        // assign the decode options, to let manager check whether to re-decode if needed
        image.sd_decodeOptions = coderOptions;
        // mark the image as progressive (completed one are not mark as progressive)
        image.sd_isIncremental = !finished;
    }
    
    return image;
}
