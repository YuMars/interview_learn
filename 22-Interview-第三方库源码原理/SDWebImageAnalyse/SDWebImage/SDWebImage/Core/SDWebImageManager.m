/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "UIImage+Metadata.h"
#import "SDAssociatedObject.h"
#import "SDWebImageError.h"
#import "SDInternalMacros.h"
#import "SDCallbackQueue.h"

static id<SDImageCache> _defaultImageCache;
static id<SDImageLoader> _defaultImageLoader;

@interface SDWebImageCombinedOperation ()

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (strong, nonatomic, readwrite, nullable) id<SDWebImageOperation> loaderOperation;
@property (strong, nonatomic, readwrite, nullable) id<SDWebImageOperation> cacheOperation;
@property (weak, nonatomic, nullable) SDWebImageManager *manager;

@end

@interface SDWebImageManager () {
    SD_LOCK_DECLARE(_failedURLsLock); // a lock to keep the access to `failedURLs` thread-safe
    SD_LOCK_DECLARE(_runningOperationsLock); // a lock to keep the access to `runningOperations` thread-safe
}

@property (strong, nonatomic, readwrite, nonnull) SDImageCache *imageCache;
@property (strong, nonatomic, readwrite, nonnull) id<SDImageLoader> imageLoader;
@property (strong, nonatomic, nonnull) NSMutableSet<NSURL *> *failedURLs;
@property (strong, nonatomic, nonnull) NSMutableSet<SDWebImageCombinedOperation *> *runningOperations;

@end

@implementation SDWebImageManager

+ (id<SDImageCache>)defaultImageCache {
    return _defaultImageCache;
}

+ (void)setDefaultImageCache:(id<SDImageCache>)defaultImageCache {
    if (defaultImageCache && ![defaultImageCache conformsToProtocol:@protocol(SDImageCache)]) {
        return;
    }
    _defaultImageCache = defaultImageCache;
}

+ (id<SDImageLoader>)defaultImageLoader {
    return _defaultImageLoader;
}

+ (void)setDefaultImageLoader:(id<SDImageLoader>)defaultImageLoader {
    if (defaultImageLoader && ![defaultImageLoader conformsToProtocol:@protocol(SDImageLoader)]) {
        return;
    }
    _defaultImageLoader = defaultImageLoader;
}

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    id<SDImageCache> cache = [[self class] defaultImageCache];
    if (!cache) {
        cache = [SDImageCache sharedImageCache];
    }
    id<SDImageLoader> loader = [[self class] defaultImageLoader];
    if (!loader) {
        loader = [SDWebImageDownloader sharedDownloader];
    }
    return [self initWithCache:cache loader:loader];
}

- (nonnull instancetype)initWithCache:(nonnull id<SDImageCache>)cache loader:(nonnull id<SDImageLoader>)loader {
    if ((self = [super init])) {
        _imageCache = cache;
        _imageLoader = loader;
        _failedURLs = [NSMutableSet new];
        SD_LOCK_INIT(_failedURLsLock);
        _runningOperations = [NSMutableSet new];
        SD_LOCK_INIT(_runningOperationsLock);
    }
    return self;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    return key;
}

- (nullable NSString *)originalCacheKeyForURL:(nullable NSURL *)url context:(nullable SDWebImageContext *)context {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (context[SDWebImageContextCacheKeyFilter]) {
        cacheKeyFilter = context[SDWebImageContextCacheKeyFilter];
    }
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    return key;
}

- (nullable NSString *)cacheKeyForURL:(nullable NSURL *)url context:(nullable SDWebImageContext *)context {
    if (!url) {
        return @"";
    }
    
    NSString *key;
    // Cache Key Filter
    id<SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
    if (context[SDWebImageContextCacheKeyFilter]) {
        cacheKeyFilter = context[SDWebImageContextCacheKeyFilter];
    }
    // 从缓存key中取，否则就用绝对地址
    if (cacheKeyFilter) {
        key = [cacheKeyFilter cacheKeyForURL:url];
    } else {
        key = url.absoluteString;
    }
    
    // 缩略图size缓存
    // 有缓存就直接取缓存中大小
    // Thumbnail Key Appending
    NSValue *thumbnailSizeValue = context[SDWebImageContextImageThumbnailPixelSize];
    if (thumbnailSizeValue != nil) {
        CGSize thumbnailSize = CGSizeZero;
        thumbnailSize = thumbnailSizeValue.CGSizeValue;
        BOOL preserveAspectRatio = YES;
        NSNumber *preserveAspectRatioValue = context[SDWebImageContextImagePreserveAspectRatio];
        if (preserveAspectRatioValue != nil) {
            preserveAspectRatio = preserveAspectRatioValue.boolValue;
        }
        key = SDThumbnailedKeyForKey(key, thumbnailSize, preserveAspectRatio);
    }
    
    // 转换器缓存
    // 有缓存就直接从transformer取缓存，以context优先
    // Transformer Key Appending
    id<SDImageTransformer> transformer = self.transformer;
    if (context[SDWebImageContextImageTransformer]) {
        transformer = context[SDWebImageContextImageTransformer];
        if ([transformer isEqual:NSNull.null]) {
            transformer = nil;
        }
    }
    if (transformer) {
        key = SDTransformedKeyForKey(key, transformer.transformerKey);
    }
    
    return key;
}

- (SDWebImageCombinedOperation *)loadImageWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDImageLoaderProgressBlock)progressBlock completed:(SDInternalCompletionBlock)completedBlock {
    return [self loadImageWithURL:url options:options context:nil progress:progressBlock completed:completedBlock];
}

- (SDWebImageCombinedOperation *)loadImageWithURL:(nullable NSURL *)url
                                          options:(SDWebImageOptions)options
                                          context:(nullable SDWebImageContext *)context
                                         progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                        completed:(nonnull SDInternalCompletionBlock)completedBlock {
    // Invoking this method without a completedBlock is pointless
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // 常见错误适配
    // 强制转换NSString成NSURL
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }

    // 保护：做其他类型判断
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    operation.manager = self;

    BOOL isFailedUrl = NO;
    if (url) {
        // 判断是已经尝试过失败的URL集合里的数据，下一步处理中直接报错，并且结束操作
        SD_LOCK(_failedURLsLock);
        isFailedUrl = [self.failedURLs containsObject:url];
        SD_UNLOCK(_failedURLsLock);
    }
    
    // Preprocess the options and context arg to decide the final the result for manager
    // 预处理选项和上下文参数,以决定管理器的最终结果。
    // 1.Transformer，图片动画
    // 2.cacheKeyFilter 缓存key过滤
    // 3.cacheSerializer 将解码的图像、源下载的数据转换为并存储到磁盘缓存，用于已经加载到的大数据图片比较慢，可以转换成其他格式存储到磁盘缓存中
    // 4.如果有全局控制options处理操作，按照全局控制options处理操作优先，否则就用设置的操作进行
    SDWebImageOptionsResult *result = [self processedResultForURL:url options:options context:context];

    // 如果URL空，或者options是不需要重试的失败url，直接报错，返回对应的操作，失败的结果
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        NSString *description = isFailedUrl ? @"Image url is blacklisted" : @"Image url is nil";
        NSInteger code = isFailedUrl ? SDWebImageErrorBlackListed : SDWebImageErrorInvalidURL;
        [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:SDWebImageErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : description}] queue:result.context[SDWebImageContextCallbackQueue] url:url];
        return operation;
    }

    SD_LOCK(_runningOperationsLock);
    // 下载操作中的集合添加新的操作任务
    [self.runningOperations addObject:operation];
    SD_UNLOCK(_runningOperationsLock);
    
    // 从缓存加载图像的入口
    // 1.没有图片转场的步骤->从缓存查询图像->下载数据和图像->将图像存储在缓存中
    
    // 2.有图片转场的步骤->从缓存查询转换后的图像->从缓存查询原始图像->下载数据和图像->在CPU上进行变换->将原始图像存储在缓存中->将转换后的图像存储在缓存中
    
    [self callCacheProcessForOperation:operation url:url options:result.options context:result.context progress:progressBlock completed:completedBlock];

    return operation;
}

- (void)cancelAll {
    SD_LOCK(_runningOperationsLock);
    NSSet<SDWebImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
    SD_UNLOCK(_runningOperationsLock);
    [copiedOperations makeObjectsPerformSelector:@selector(cancel)]; // This will call `safelyRemoveOperationFromRunning:` and remove from the array
}

- (BOOL)isRunning {
    BOOL isRunning = NO;
    SD_LOCK(_runningOperationsLock);
    isRunning = (self.runningOperations.count > 0);
    SD_UNLOCK(_runningOperationsLock);
    return isRunning;
}

- (void)removeFailedURL:(NSURL *)url {
    if (!url) {
        return;
    }
    SD_LOCK(_failedURLsLock);
    [self.failedURLs removeObject:url];
    SD_UNLOCK(_failedURLsLock);
}

- (void)removeAllFailedURLs {
    SD_LOCK(_failedURLsLock);
    [self.failedURLs removeAllObjects];
    SD_UNLOCK(_failedURLsLock);
}

#pragma mark - Private

// 查询缓存
- (void)callCacheProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                 url:(nonnull NSURL *)url
                             options:(SDWebImageOptions)options
                             context:(nullable SDWebImageContext *)context
                            progress:(nullable SDImageLoaderProgressBlock)progressBlock
                           completed:(nullable SDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    //
    id<SDImageCache> imageCache = context[SDWebImageContextImageCache];
    if (!imageCache) {
        imageCache = self.imageCache;
    }
    
    // 默认支持从缓存、磁盘取
    SDImageCacheType queryCacheType = SDImageCacheTypeAll;
    if (context[SDWebImageContextQueryCacheType]) {
        queryCacheType = [context[SDWebImageContextQueryCacheType] integerValue];
    }
    
    // 查询缓存
    BOOL shouldQueryCache = !SD_OPTIONS_CONTAINS(options, SDWebImageFromLoaderOnly);
    if (shouldQueryCache) { // 取缓存过程
        // 根据URL返回缓存的key
        // 1.优先从cacheKeyFilter取key
        // 2.没有保底用url.absoluteString作为key
        // 3.取地址和缩略图尺寸宽高比的作为key
        // 4.取transformer作为作为key
        NSString *key = [self cacheKeyForURL:url context:context];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:queryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, SDImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) { // 取消组合操作 -> 直接结束，并且报错 -> 删除running的queue
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] queue:context[SDWebImageContextCallbackQueue] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            } else if (!cachedImage) { // 未取到缓存图片(并且已经有缓存key，说明在解码过程中或者在图形转换过程) -> 走下载流程
                NSString *originKey = [self originalCacheKeyForURL:url context:context];
                BOOL mayInOriginalCache = ![key isEqualToString:originKey];
                // 有机会查询原始缓存而不是下载,然后应用变换
                // 缩略图解码是在SDImageCache的解码部分完成的,不需要变换的后期处理
                if (mayInOriginalCache) {
                    // 如果原始缓存中有，则查询原始缓存
                    [self callOriginalCacheProcessForOperation:operation url:url options:options context:context progress:progressBlock completed:completedBlock];
                    return;
                }
            }
            // 下载流程
            [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:cachedImage cachedData:cachedData cacheType:cacheType progress:progressBlock completed:completedBlock];
        }];
    } else { // 下载过程
        // Continue download process
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:SDImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

// 查询原始缓存过程
- (void)callOriginalCacheProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                         url:(nonnull NSURL *)url
                                     options:(SDWebImageOptions)options
                                     context:(nullable SDWebImageContext *)context
                                    progress:(nullable SDImageLoaderProgressBlock)progressBlock
                                   completed:(nullable SDInternalCompletionBlock)completedBlock {
    // 获取要使用的图像缓存,首先选择独立的原始缓存
    id<SDImageCache> imageCache = context[SDWebImageContextOriginalImageCache];
    if (!imageCache) {
        // 如果没有独立缓存可用,使用默认缓存
        imageCache = context[SDWebImageContextImageCache];
        if (!imageCache) {
            imageCache = self.imageCache;
        }
    }
    
    // 默认从磁盘查询
    SDImageCacheType originalQueryCacheType = SDImageCacheTypeDisk;
    if (context[SDWebImageContextOriginalQueryCacheType]) {
        originalQueryCacheType = [context[SDWebImageContextOriginalQueryCacheType] integerValue];
    }
    
    // 确认是否需要需要查询原始缓存
    BOOL shouldQueryOriginalCache = (originalQueryCacheType != SDImageCacheTypeNone);
    if (shouldQueryOriginalCache) {
        // 获取没有变换器的原始缓存键生成
        NSString *key = [self originalCacheKeyForURL:url context:context];
        @weakify(operation);
        operation.cacheOperation = [imageCache queryImageForKey:key options:options context:context cacheType:originalQueryCacheType completion:^(UIImage * _Nullable cachedImage, NSData * _Nullable cachedData, SDImageCacheType cacheType) {
            @strongify(operation);
            if (!operation || operation.isCancelled) {// 已经取消，直接结束并且报错
                
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during querying the cache"}] queue:context[SDWebImageContextCallbackQueue] url:url];
                [self safelyRemoveOperationFromRunning:operation];
                return;
            } else if (!cachedImage) {
                // 无缓存，走下载流程
                [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:SDImageCacheTypeNone progress:progressBlock completed:completedBlock];
                return;
            }

            // 跳过下载并继续变换过程,暂时忽略.refreshCached选项
            [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:cachedImage originalData:cachedData cacheType:cacheType finished:YES completed:completedBlock];
            
            [self safelyRemoveOperationFromRunning:operation];
        }];
    } else {
        // 继续下载流程
        [self callDownloadProcessForOperation:operation url:url options:options context:context cachedImage:nil cachedData:nil cacheType:SDImageCacheTypeNone progress:progressBlock completed:completedBlock];
    }
}

// Download process
- (void)callDownloadProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                    url:(nonnull NSURL *)url
                                options:(SDWebImageOptions)options
                                context:(SDWebImageContext *)context
                            cachedImage:(nullable UIImage *)cachedImage
                             cachedData:(nullable NSData *)cachedData
                              cacheType:(SDImageCacheType)cacheType
                               progress:(nullable SDImageLoaderProgressBlock)progressBlock
                              completed:(nullable SDInternalCompletionBlock)completedBlock {
    // 进入下载流程，结束查缓存流程
    @synchronized (operation) {
        operation.cacheOperation = nil;
    }
    
    id<SDImageLoader> imageLoader = context[SDWebImageContextImageLoader];
    if (!imageLoader) {
        imageLoader = self.imageLoader;
    }
    
    // 是否需要下载
    // 非仅从缓存加载、需要强制刷新、响应shouldDownloadImageForURL、canRequestImageForURL、
    BOOL shouldDownload = !SD_OPTIONS_CONTAINS(options, SDWebImageFromCacheOnly);
    shouldDownload &= (!cachedImage || options & SDWebImageRefreshCached);
    shouldDownload &= (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url]);
    if ([imageLoader respondsToSelector:@selector(canRequestImageForURL:options:context:)]) {
        shouldDownload &= [imageLoader canRequestImageForURL:url options:options context:context];
    } else {
        shouldDownload &= [imageLoader canRequestImageForURL:url];
    }
    
    // 下载的情况
    // 有缓存，但是需要强制刷新-重新下载
    
    if (shouldDownload) {
        if (cachedImage && options & SDWebImageRefreshCached) {
            // 如果在缓存中找到图像但提供了SDWebImageRefreshCached,则通知缓存中的图像, 并尝试重新下载它,以便让NSURLCache有机会从服务器重新刷新它。
            [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES queue:context[SDWebImageContextCallbackQueue] url:url];
            // 将缓存的图像传入图像加载器。图像加载器应检查远程图像是否等于缓存图像
            SDWebImageMutableContext *mutableContext;
            if (context) {
                mutableContext = [context mutableCopy];
            } else {
                mutableContext = [NSMutableDictionary dictionary];
            }
            mutableContext[SDWebImageContextLoaderCachedImage] = cachedImage;
            context = [mutableContext copy];
        }
        
        @weakify(operation);
        operation.loaderOperation = [imageLoader requestImageWithURL:url options:options context:context progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
            
            // 取消或者其他错误判断后走callCompletionBlockForOperation回调
            // 成功后走callTransformProcessForOperation进行所有参数回调
            // 需要transform，做transform
            // 根据context的缓存策略做SDImageCache的缓存
            // 如果需要做磁盘缓存，先做磁盘缓存（存在磁盘diskCache缓存中，同时归档拓展信息extendedData）
            // 没data数据，SDImageCodersManager解码
            // 做内存缓存imageCache
            // 将原始图片和transform后的图片都存到磁盘和缓存中
            // 最后走callCompletionBlockForOperation回调
            
            
            // 结束running序列中当前operation
            
            @strongify(operation);
            if (!operation || operation.isCancelled) { // 取消下载
                [self callCompletionBlockForOperation:operation completion:completedBlock error:[NSError errorWithDomain:SDWebImageErrorDomain code:SDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}] queue:context[SDWebImageContextCallbackQueue] url:url];
            } else if (cachedImage && options & SDWebImageRefreshCached && [error.domain isEqualToString:SDWebImageErrorDomain] && error.code == SDWebImageErrorCacheNotModified) {
                // 图像刷新命中NSURLCache缓存,不调用completion块
            } else if ([error.domain isEqualToString:SDWebImageErrorDomain] && error.code == SDWebImageErrorCancelled) {
                // 在发送请求之前由用户取消的下载操作,不要封锁失败的URL
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error queue:context[SDWebImageContextCallbackQueue] url:url];
            } else if (error) { // 下载失败，将URL放入失败池中
                [self callCompletionBlockForOperation:operation completion:completedBlock error:error queue:context[SDWebImageContextCallbackQueue] url:url];
                BOOL shouldBlockFailedURL = [self shouldBlockFailedURLWithURL:url error:error options:options context:context];
                
                if (shouldBlockFailedURL) {
                    SD_LOCK(self->_failedURLsLock);
                    [self.failedURLs addObject:url];
                    SD_UNLOCK(self->_failedURLsLock);
                }
            } else { // 下载成功，移除失败池中的URL -> 继续转场效果
                if ((options & SDWebImageRetryFailed)) {
                    SD_LOCK(self->_failedURLsLock);
                    [self.failedURLs removeObject:url];
                    SD_UNLOCK(self->_failedURLsLock);
                }
                [self callTransformProcessForOperation:operation url:url options:options context:context originalImage:downloadedImage originalData:downloadedData cacheType:SDImageCacheTypeNone finished:finished completed:completedBlock];
            }
            
            if (finished) {
                [self safelyRemoveOperationFromRunning:operation];
            }
        }];
    } else if (cachedImage) { // 取到缓存，直接用缓存数据
        [self callCompletionBlockForOperation:operation completion:completedBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES queue:context[SDWebImageContextCallbackQueue] url:url];
        [self safelyRemoveOperationFromRunning:operation];
    } else {// 即不成功，也不失败，其他情况下回调
        
        [self callCompletionBlockForOperation:operation completion:completedBlock image:nil data:nil error:nil cacheType:SDImageCacheTypeNone finished:YES queue:context[SDWebImageContextCallbackQueue] url:url];
        [self safelyRemoveOperationFromRunning:operation];
    }
}

// Transform process
- (void)callTransformProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                     url:(nonnull NSURL *)url
                                 options:(SDWebImageOptions)options
                                 context:(SDWebImageContext *)context
                           originalImage:(nullable UIImage *)originalImage
                            originalData:(nullable NSData *)originalData
                               cacheType:(SDImageCacheType)cacheType
                                finished:(BOOL)finished
                               completed:(nullable SDInternalCompletionBlock)completedBlock {
    id<SDImageTransformer> transformer = context[SDWebImageContextImageTransformer];
    if ([transformer isEqual:NSNull.null]) {
        transformer = nil;
    }
    
    // 是否需要转场特效
    BOOL shouldTransformImage = originalImage && transformer;
    shouldTransformImage = shouldTransformImage && (!originalImage.sd_isAnimated || (options & SDWebImageTransformAnimatedImage));
    shouldTransformImage = shouldTransformImage && (!originalImage.sd_isVector || (options & SDWebImageTransformVectorImage));
    
    BOOL isThumbnail = originalImage.sd_isThumbnail;
    NSData *cacheData = originalData;
    UIImage *cacheImage = originalImage;
    if (isThumbnail) { // 缩略图无全图数据和尺寸
        cacheData = nil; // thumbnail don't store full size data
        originalImage = nil; // thumbnail don't have full size image
    }
    
    if (shouldTransformImage) {
        
        NSString *key = [self cacheKeyForURL:url context:context];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // Case that transformer on thumbnail, which this time need full pixel image
            UIImage *transformedImage = [transformer transformedImageWithImage:cacheImage forKey:key];
            // 有转场特效原图用transformedImage原图，否则就用cacheImage缓存图
            if (transformedImage) { // 转场图
                transformedImage.sd_isTransformed = YES;
                [self callStoreOriginCacheProcessForOperation:operation url:url options:options context:context originalImage:originalImage cacheImage:transformedImage originalData:originalData cacheData:nil cacheType:cacheType finished:finished completed:completedBlock];
            } else {
                [self callStoreOriginCacheProcessForOperation:operation url:url options:options context:context originalImage:originalImage cacheImage:cacheImage originalData:originalData cacheData:cacheData cacheType:cacheType finished:finished completed:completedBlock];
            }
        });
    } else {
        [self callStoreOriginCacheProcessForOperation:operation url:url options:options context:context originalImage:originalImage cacheImage:cacheImage originalData:originalData cacheData:cacheData cacheType:cacheType finished:finished completed:completedBlock];
    }
}

// 存储原始缓存过程
- (void)callStoreOriginCacheProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                            url:(nonnull NSURL *)url
                                        options:(SDWebImageOptions)options
                                        context:(SDWebImageContext *)context
                                  originalImage:(nullable UIImage *)originalImage
                                     cacheImage:(nullable UIImage *)cacheImage
                                   originalData:(nullable NSData *)originalData
                                      cacheData:(nullable NSData *)cacheData
                                      cacheType:(SDImageCacheType)cacheType
                                       finished:(BOOL)finished
                                      completed:(nullable SDInternalCompletionBlock)completedBlock {
    // 获取要使用的图像缓存,首先选择独立的原始缓存
    id<SDImageCache> imageCache = context[SDWebImageContextOriginalImageCache];
    if (!imageCache) {
        imageCache = context[SDWebImageContextImageCache];
        if (!imageCache) {
            imageCache = self.imageCache;
        }
    }
    
    // 默认存到磁盘
    SDImageCacheType originalStoreCacheType = SDImageCacheTypeDisk;
    if (context[SDWebImageContextOriginalStoreCacheType]) {
        originalStoreCacheType = [context[SDWebImageContextOriginalStoreCacheType] integerValue];
    }
    id<SDWebImageCacheSerializer> cacheSerializer = context[SDWebImageContextCacheSerializer];
    
    // 如果原始cacheType是磁盘,因为我们不需要再次存储原始数据，从原始StoreCacheType中剥离磁盘
    if (cacheType == SDImageCacheTypeDisk) {
        if (originalStoreCacheType == SDImageCacheTypeDisk) originalStoreCacheType = SDImageCacheTypeNone;
        if (originalStoreCacheType == SDImageCacheTypeAll) originalStoreCacheType = SDImageCacheTypeMemory;
    }
    
    // 获取没有变换器的原始缓存键生成
    NSString *key = [self originalCacheKeyForURL:url context:context];
    if (finished && cacheSerializer && (originalStoreCacheType == SDImageCacheTypeDisk || originalStoreCacheType == SDImageCacheTypeAll)) { // 缓存需要序列化（转成Data数据）
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // 对图片按照指定的格式jpg/png进行缓存
            NSData *newOriginalData = [cacheSerializer cacheDataWithImage:originalImage originalData:originalData imageURL:url];
            // 存原始数据和图片
            [self storeImage:originalImage imageData:newOriginalData forKey:key options:options context:context imageCache:imageCache cacheType:originalStoreCacheType finished:finished completion:^{
                // 继续存储缓存过程,变换的数据为nil
                [self callStoreCacheProcessForOperation:operation url:url options:options context:context image:cacheImage data:cacheData cacheType:cacheType finished:finished completed:completedBlock];
            }];
        });
    } else {
        // 存原始数据和图片
        [self storeImage:originalImage imageData:originalData forKey:key options:options context:context imageCache:imageCache cacheType:originalStoreCacheType finished:finished completion:^{
            // 存缓存数据和图片
            [self callStoreCacheProcessForOperation:operation url:url options:options context:context image:cacheImage data:cacheData cacheType:cacheType finished:finished completed:completedBlock];
        }];
    }
}

// Store normal cache process
- (void)callStoreCacheProcessForOperation:(nonnull SDWebImageCombinedOperation *)operation
                                      url:(nonnull NSURL *)url
                                  options:(SDWebImageOptions)options
                                  context:(SDWebImageContext *)context
                                    image:(nullable UIImage *)image
                                     data:(nullable NSData *)data
                                cacheType:(SDImageCacheType)cacheType
                                 finished:(BOOL)finished
                                completed:(nullable SDInternalCompletionBlock)completedBlock {
    // Grab the image cache to use
    id<SDImageCache> imageCache = context[SDWebImageContextImageCache];
    if (!imageCache) {
        imageCache = self.imageCache;
    }
    // the target image store cache type
    SDImageCacheType storeCacheType = SDImageCacheTypeAll;
    if (context[SDWebImageContextStoreCacheType]) {
        storeCacheType = [context[SDWebImageContextStoreCacheType] integerValue];
    }
    id<SDWebImageCacheSerializer> cacheSerializer = context[SDWebImageContextCacheSerializer];
    
    // transformed cache key
    NSString *key = [self cacheKeyForURL:url context:context];
    if (finished && cacheSerializer && (storeCacheType == SDImageCacheTypeDisk || storeCacheType == SDImageCacheTypeAll)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *newData = [cacheSerializer cacheDataWithImage:image originalData:data imageURL:url];
            // Store image and data
            [self storeImage:image imageData:newData forKey:key options:options context:context imageCache:imageCache cacheType:storeCacheType finished:finished completion:^{
                [self callCompletionBlockForOperation:operation completion:completedBlock image:image data:data error:nil cacheType:cacheType finished:finished queue:context[SDWebImageContextCallbackQueue] url:url];
            }];
        });
    } else {
        // Store image and data
        [self storeImage:image imageData:data forKey:key options:options context:context imageCache:imageCache cacheType:storeCacheType finished:finished completion:^{
            [self callCompletionBlockForOperation:operation completion:completedBlock image:image data:data error:nil cacheType:cacheType finished:finished queue:context[SDWebImageContextCallbackQueue] url:url];
        }];
    }
}

#pragma mark - Helper

- (void)safelyRemoveOperationFromRunning:(nullable SDWebImageCombinedOperation*)operation {
    if (!operation) {
        return;
    }
    SD_LOCK(_runningOperationsLock);
    [self.runningOperations removeObject:operation];
    SD_UNLOCK(_runningOperationsLock);
}

- (void)storeImage:(nullable UIImage *)image
         imageData:(nullable NSData *)data
            forKey:(nullable NSString *)key
           options:(SDWebImageOptions)options
           context:(nullable SDWebImageContext *)context
        imageCache:(nonnull id<SDImageCache>)imageCache
         cacheType:(SDImageCacheType)cacheType
          finished:(BOOL)finished
        completion:(nullable SDWebImageNoParamsBlock)completion {
    BOOL waitStoreCache = SD_OPTIONS_CONTAINS(options, SDWebImageWaitStoreCache);
    // 忽略渐进式数据缓存
    if (!finished) {
        if (completion) {
            completion();
        }
        return;
    }
    // 检查是否应等待存储缓存完成。如果不是,立即回调
    if ([imageCache respondsToSelector:@selector(storeImage:imageData:forKey:options:context:cacheType:completion:)]) {
        [imageCache storeImage:image imageData:data forKey:key options:options context:context cacheType:cacheType completion:^{
            if (waitStoreCache) {
                if (completion) {
                    completion();
                }
            }
        }];
    } else {
        [imageCache storeImage:image imageData:data forKey:key cacheType:cacheType completion:^{
            if (waitStoreCache) {
                if (completion) {
                    completion();
                }
            }
        }];
    }
    if (!waitStoreCache) {
        if (completion) {
            completion();
        }
    }
}

- (void)callCompletionBlockForOperation:(nullable SDWebImageCombinedOperation*)operation
                             completion:(nullable SDInternalCompletionBlock)completionBlock
                                  error:(nullable NSError *)error
                                  queue:(nullable SDCallbackQueue *)queue
                                    url:(nullable NSURL *)url {
    [self callCompletionBlockForOperation:operation completion:completionBlock image:nil data:nil error:error cacheType:SDImageCacheTypeNone finished:YES queue:queue url:url];
}

- (void)callCompletionBlockForOperation:(nullable SDWebImageCombinedOperation*)operation
                             completion:(nullable SDInternalCompletionBlock)completionBlock
                                  image:(nullable UIImage *)image
                                   data:(nullable NSData *)data
                                  error:(nullable NSError *)error
                              cacheType:(SDImageCacheType)cacheType
                               finished:(BOOL)finished
                                  queue:(nullable SDCallbackQueue *)queue
                                    url:(nullable NSURL *)url {
    if (completionBlock) {
        [(queue ?: SDCallbackQueue.mainQueue) async:^{
            completionBlock(image, data, error, cacheType, finished, url);
        }];
    }
}

- (BOOL)shouldBlockFailedURLWithURL:(nonnull NSURL *)url
                              error:(nonnull NSError *)error
                            options:(SDWebImageOptions)options
                            context:(nullable SDWebImageContext *)context {
    id<SDImageLoader> imageLoader = context[SDWebImageContextImageLoader];
    if (!imageLoader) {
        imageLoader = self.imageLoader;
    }
    // Check whether we should block failed url
    BOOL shouldBlockFailedURL;
    if ([self.delegate respondsToSelector:@selector(imageManager:shouldBlockFailedURL:withError:)]) {
        shouldBlockFailedURL = [self.delegate imageManager:self shouldBlockFailedURL:url withError:error];
    } else {
        if ([imageLoader respondsToSelector:@selector(shouldBlockFailedURLWithURL:error:options:context:)]) {
            shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error options:options context:context];
        } else {
            shouldBlockFailedURL = [imageLoader shouldBlockFailedURLWithURL:url error:error];
        }
    }
    
    return shouldBlockFailedURL;
}

- (SDWebImageOptionsResult *)processedResultForURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context {
    SDWebImageOptionsResult *result;
    SDWebImageMutableContext *mutableContext = [SDWebImageMutableContext dictionary];
    
    // Image Transformer from manager
    if (!context[SDWebImageContextImageTransformer]) {
        id<SDImageTransformer> transformer = self.transformer;
        [mutableContext setValue:transformer forKey:SDWebImageContextImageTransformer];
    }
    // Cache key filter from manager
    if (!context[SDWebImageContextCacheKeyFilter]) {
        id<SDWebImageCacheKeyFilter> cacheKeyFilter = self.cacheKeyFilter;
        [mutableContext setValue:cacheKeyFilter forKey:SDWebImageContextCacheKeyFilter];
    }
    // Cache serializer from manager
    if (!context[SDWebImageContextCacheSerializer]) {
        id<SDWebImageCacheSerializer> cacheSerializer = self.cacheSerializer;
        [mutableContext setValue:cacheSerializer forKey:SDWebImageContextCacheSerializer];
    }
    
    if (mutableContext.count > 0) {
        if (context) {
            [mutableContext addEntriesFromDictionary:context];
        }
        context = [mutableContext copy];
    }
    
    // Apply options processor
    if (self.optionsProcessor) {
        result = [self.optionsProcessor processedResultForURL:url options:options context:context];
    }
    if (!result) {
        // Use default options result
        result = [[SDWebImageOptionsResult alloc] initWithOptions:options context:context];
    }
    
    return result;
}

@end


@implementation SDWebImageCombinedOperation

- (BOOL)isCancelled {
    // Need recursive lock (user's cancel block may check isCancelled), do not use SD_LOCK
    @synchronized (self) {
        return _cancelled;
    }
}

- (void)cancel {
    // Need recursive lock (user's cancel block may check isCancelled), do not use SD_LOCK
    @synchronized(self) {
        if (_cancelled) {
            return;
        }
        _cancelled = YES;
        if (self.cacheOperation) {
            [self.cacheOperation cancel];
            self.cacheOperation = nil;
        }
        if (self.loaderOperation) {
            [self.loaderOperation cancel];
            self.loaderOperation = nil;
        }
        [self.manager safelyRemoveOperationFromRunning:self];
    }
}

@end
