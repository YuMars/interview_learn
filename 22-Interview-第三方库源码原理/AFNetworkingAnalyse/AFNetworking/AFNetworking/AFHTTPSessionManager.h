// AFHTTPSessionManager.h
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>
#endif
#import <TargetConditionals.h>

#import "AFURLSessionManager.h"

/**
 `AFHTTPSessionManager` is a subclass of `AFURLSessionManager` with convenience methods for making HTTP requests. When a `baseURL` is provided, requests made with the `GET` / `POST` / et al. convenience methods can be made with relative paths.

 ## Subclassing Notes

 Developers targeting iOS 7 or Mac OS X 10.9 or later that deal extensively with a web service are encouraged to subclass `AFHTTPSessionManager`, providing a class method that returns a shared singleton object on which authentication and other configuration can be shared across the application.

 ## Methods to Override

 To change the behavior of all data task operation construction, which is also used in the `GET` / `POST` / et al. convenience methods, override `dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:`.

 ## Serialization

 Requests created by an HTTP client will contain default headers and encode parameters according to the `requestSerializer` property, which is an object conforming to `<AFURLRequestSerialization>`.

 Responses received from the server are automatically validated and serialized by the `responseSerializers` property, which is an object conforming to `<AFURLResponseSerialization>`

 ## URL Construction Using Relative Paths

 For HTTP convenience methods, the request serializer constructs URLs from the path relative to the `-baseURL`, using `NSURL +URLWithString:relativeToURL:`, when provided. If `baseURL` is `nil`, `path` needs to resolve to a valid `NSURL` object using `NSURL +URLWithString:`.

 Below are a few examples of how `baseURL` and relative paths interact:

    NSURL *baseURL = [NSURL URLWithString:@"http://example.com/v1/"];
    [NSURL URLWithString:@"foo" relativeToURL:baseURL];                  // http://example.com/v1/foo
    [NSURL URLWithString:@"foo?bar=baz" relativeToURL:baseURL];          // http://example.com/v1/foo?bar=baz
    [NSURL URLWithString:@"/foo" relativeToURL:baseURL];                 // http://example.com/foo
    [NSURL URLWithString:@"foo/" relativeToURL:baseURL];                 // http://example.com/v1/foo
    [NSURL URLWithString:@"/foo/" relativeToURL:baseURL];                // http://example.com/foo/
    [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL]; // http://example2.com/

 Also important to note is that a trailing slash will be added to any `baseURL` without one. This would otherwise cause unexpected behavior when constructing URLs using paths without a leading slash.

 @warning Managers for background sessions must be owned for the duration of their use. This can be accomplished by creating an application-wide or shared singleton instance.
 */

NS_ASSUME_NONNULL_BEGIN

@interface AFHTTPSessionManager : AFURLSessionManager <NSSecureCoding, NSCopying>

/**
 The URL used to construct requests from relative paths in methods like `requestWithMethod:URLString:parameters:`, and the `GET` / `POST` / et al. convenience methods.
 */
@property (readonly, nonatomic, strong, nullable) NSURL *baseURL;

/**
 使用`requestWithMethod:URLString:parameters:和multipartFormRequestWithMethod:URLString:parameters:constructingBodyWithBlock:`创建的请求使用这个属性指定的参数序列化构建了一组默认标头。
 默认情况下,此属性设置为`AFHTTPRequestSerializer`的实例,它将查询字符串参数序列化为`GET`、`HEAD`和`DELETE`请求,或者其他情况下URL形式编码HTTP消息正文。
  @warning requestSerializer不能为`nil`。
 */
@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;

/**
 使用`dataTaskWithRequest:success:failure:创建的数据任务以及使用GET`、`POST`等便利方法运行的数据任务,收到的服务器响应会被响应序列化器自动验证和序列化。
 默认情况下,此属性设置为`AFJSONResponseSerializer`的实例。
 @warning responseSerializer不能为`nil`。
 */
@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

///-------------------------------
/// @name Managing Security Policy
///-------------------------------

/**
 创建的session用于评估安全连接的服务器信任的安全策略。除非另有规定,否则`AFURLSessionManager`使用`defaultPolicy`。
 仅可将使用`AFSSLPinningModePublicKey`或`AFSSLPinningModeCertificate`配置的安全策略应用于使用安全基本URL(即https)初始化的会话管理器。
 在不安全的会话管理器上启用钉扎的安全策略会抛出“无效的安全策略”异常。
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns an `AFHTTPSessionManager` object.
 */
+ (instancetype)manager;

/**
 使用指定的基本URL初始化一个`AFHTTPSessionManager`对象。
  @param url HTTP客户端的基本URL。
  @return 新初始化的HTTP客户端。
 */
- (instancetype)initWithBaseURL:(nullable NSURL *)url;

/**
 使用指定的基本URL和配置初始化一个`AFHTTPSessionManager`对象。
 这是指定的初始化器。
 @param url HTTP客户端的基本URL。
 @param configuration 用于创建托管会话的配置。
 @return 新初始化的HTTP客户端。
 */
- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

///---------------------------
/// @name Making HTTP Requests
///---------------------------

/**
 创建并运行一个`NSURLSessionDataTask`进行`GET`请求。
  @param URLString 用于创建请求URL的URL字符串。
  @param parameters 根据客户端请求序列化器编码的参数。
  @param headers 附加到此请求的默认标头。
  @param downloadProgress 下载进度更新时执行的块对象。请注意,此块在会话队列上调用,而不是主队列。
  @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
  @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
  @see -dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:
 */
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                               headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 创建并运行一个`NSURLSessionDataTask`进行`HEAD`请求。
  @param URLString 用于创建请求URL的URL字符串。
  @param parameters 根据客户端请求序列化器编码的参数。
  @param headers 附加到此请求的默认标头。
  @param success 任务成功完成时执行的块对象。此块没有返回值,只采用一个参数:数据任务。
  @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
  @see -dataTaskWithRequest:completionHandler:

 */
- (nullable NSURLSessionDataTask *)HEAD:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                success:(nullable void (^)(NSURLSessionDataTask *task))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 创建并运行一个`NSURLSessionDataTask`,进行`POST`请求。
 @param URLString 用来创建请求URL的URL字符串。
 @param parameters 根据客户端请求序列化器编码的参数。
 @param headers 附加到此请求的默认标头。
 @param uploadProgress 上传进度更新时执行的块对象。请注意,此块在会话队列上调用,而不是主队列。
 @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
 @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
 */
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 创建并运行一个`NSURLSessionDataTask`进行多部分`POST`请求。
  @param URLString 用于创建请求URL的URL字符串。
  @param parameters 根据客户端请求序列化器编码的参数。
  @param headers 附加到此请求的默认标头。
  @param block 接收一个参数的块,并向HTTP正文追加数据。该block的参数是一个遵循`AFMultipartFormData`协议的对象。
  @param uploadProgress 上传进度更新时执行的块对象。请注意,此块在会话队列上调用,而不是主队列。
  @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
  @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
 */
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 创建并运行一个`NSURLSessionDataTask`进行`PUT`请求。
  @param URLString 用于创建请求URL的URL字符串。
  @param parameters 根据客户端请求序列化器编码的参数。
  @param headers 附加到此请求的默认标头。
  @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
  @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (nullable NSURLSessionDataTask *)PUT:(NSString *)URLString
                            parameters:(nullable id)parameters
                               headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 创建并运行一个`NSURLSessionDataTask`进行`PATCH`请求。
 @param URLString 用于创建请求URL的URL字符串。
 @param parameters 根据客户端请求序列化器编码的参数。
 @param headers 附加到此请求的默认标头。
 @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
 @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (nullable NSURLSessionDataTask *)PATCH:(NSString *)URLString
                              parameters:(nullable id)parameters
                                 headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                 success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 创建并运行一个`NSURLSessionDataTask`进行`DELETE`请求。
  @param URLString 用于创建请求URL的URL字符串。
  @param parameters 根据客户端请求序列化器编码的参数。
  @param headers 附加到此请求的默认标头。
  @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
  @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。
 
 @see -dataTaskWithRequest:completionHandler:
 */
- (nullable NSURLSessionDataTask *)DELETE:(NSString *)URLString
                               parameters:(nullable id)parameters
                                  headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                  success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/**
 使用自定义的`HTTPMethod`创建一个`NSURLSessionDataTask`。
  @param method 用于创建请求的HTTPMethod字符串。
  @param URLString 用于创建请求URL的URL字符串。
  @param parameters 根据客户端请求序列化器编码的参数。
  @param headers 附加到此请求的默认标头。
  @param uploadProgress 上传进度更新时执行的块对象。请注意,此块在会话队列上调用,而不是主队列。
  @param downloadProgress 下载进度更新时执行的块对象。请注意,此块在会话队列上调用,而不是主队列。
  @param success 任务成功完成时执行的块对象。此块没有返回值,并采用两个参数:数据任务和客户端响应序列化器创建的响应对象。
  @param failure 任务未成功完成时执行的块对象,或者成功完成时在解析响应数据时遇到错误。此块没有返回值,并采用两个参数:数据任务和描述网络或解析错误的错误。


 @see -dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:
 */
- (nullable NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                                URLString:(NSString *)URLString
                                               parameters:(nullable id)parameters
                                                  headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                           uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                                  success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
