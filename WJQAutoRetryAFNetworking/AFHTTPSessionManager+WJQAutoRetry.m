//
//  AFHTTPSessionManager+WJQAutoRetry.m
//  WJQAutoRetryAFNetworking
//
//  Created by WJQ on 2021/1/19.
//

#import "AFHTTPSessionManager+WJQAutoRetry.h"
#import "AFURLSessionManager+WJQAutoRetry.h"
#import "NetworkErrorUtil.h"

@implementation AFHTTPSessionManager (WJQAutoRetry)

- (NSURLSessionDataTask *)requestWithOriginalRequestCreator:(NSURLSessionDataTask * (^)(void (^)(NSURLSessionDataTask *, NSError*)))taskCreator
                                            originalFailure:(void(^)(NSURLSessionDataTask *, NSError *))failure
                                                  autoRetry:(NSInteger)retryCount
                                              retryInterval:(NSInteger)intervalInSeconds {
    
    __block id orgTaskCreator = (id)taskCreator;
    if (!self.tasksDict) {
        self.tasksDict = [NSMutableDictionary new];
    }
    // request retry Block
    void (^retryBlock)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        // fatal error, not retry
        if ([NetworkErrorUtil isCFNetworkError:error]) {
            WNSLog(@"WJQAutoRetry->not retry,error: %@", error.localizedDescription);
            failure(task, error);
            return;
        }
        NSDictionary *taskDict = self.tasksDict[orgTaskCreator];
        NSInteger orgRetryCount = [taskDict[@"retryCount"] integerValue];
        NSInteger retryRemainCount = [taskDict[@"retryRemainCount"] integerValue];
        if (retryRemainCount == 0) {  //reach the maximum retry count
            WNSLog(@"WJQAutoRetry->retry error: %@ retry times: %ld",error.localizedDescription, (long)orgRetryCount);
            failure(task, error);
            WNSLog(@"WJQAutoRetry->done");
            return;
        }
        
        WNSLog(@"WJQAutoRetry->error: %@, retry %ld/%ld start...",
               error.localizedDescription, (long)(orgRetryCount - retryRemainCount + 1), (long)orgRetryCount);
  
        if (intervalInSeconds > 0) {
            WNSLog(@"WJQAutoRetry->dealy retry for %ld seconds...", (long)intervalInSeconds);
            dispatch_after(dispatch_time(0, (int64_t)(intervalInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                [self requestWithOriginalRequestCreator:orgTaskCreator originalFailure:failure autoRetry:retryRemainCount - 1 retryInterval:intervalInSeconds];
            });
        } else {
            [self requestWithOriginalRequestCreator:orgTaskCreator originalFailure:failure autoRetry:retryRemainCount - 1  retryInterval:intervalInSeconds];
        }
    };
    
    // original request
    NSURLSessionDataTask *task = taskCreator(retryBlock);
    
    NSMutableDictionary *taskDict = self.tasksDict[orgTaskCreator];
    if (!taskDict) {
        taskDict = [NSMutableDictionary new];
        taskDict[@"retryCount"] = @(retryCount);
    }
    taskDict[@"retryRemainCount"] = @(retryCount);
    
    self.tasksDict[orgTaskCreator] = taskDict;
    
    return task;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(nullable id)parameters
                      headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                     progress:(nullable void (^)(NSProgress * _Nonnull))downloadProgress
                      success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
                    autoRetry:(int)retryCount
                retryInterval:(int)intervalInSeconds {
    
    NSURLSessionDataTask *task = [self requestWithOriginalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self GET:URLString parameters:parameters headers:headers progress:downloadProgress success:success failure:retryBlock];
    } originalFailure:failure autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
                              autoRetry:(int)retryCount
                          retryInterval:(int)intervalInSeconds {
    NSURLSessionDataTask *task = [self requestWithOriginalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self POST:URLString parameters:parameters headers:headers progress:uploadProgress success:success failure:retryBlock];
    } originalFailure:failure autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure
                              autoRetry:(int)retryCount
                          retryInterval:(int)intervalInSeconds {
    
    NSURLSessionDataTask *task = [self requestWithOriginalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self POST:URLString parameters:parameters headers:headers constructingBodyWithBlock:block progress:uploadProgress success:success failure:retryBlock];
    } originalFailure:failure autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

@end
