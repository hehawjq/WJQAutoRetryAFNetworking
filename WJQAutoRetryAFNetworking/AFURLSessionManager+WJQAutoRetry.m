//
//  AFURLSessionManager+WJQAutoRetry.m
//  WJQAutoRetryAFNetworking
//
//  Created by 云睿 on 2021/1/27.
//

#import "AFURLSessionManager+WJQAutoRetry.h"
#import <objc/runtime.h>
#import "NetworkErrorUtil.h"

@implementation AFURLSessionManager (WJQAutoRetry)

- (NSMutableDictionary *)tasksDict {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTasksDict:(NSMutableDictionary *)tasksDict {
    objc_setAssociatedObject(self, @selector(tasksDict), tasksDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionTask *)requestTaskWithOriginalRequestCreator:(NSURLSessionTask * (^)(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error)))taskCreator
                                              completionHandler:(void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler
                                                      autoRetry:(NSInteger)retryCount
                                                  retryInterval:(NSInteger)intervalInSeconds {
    
    __block id orgTaskCreator = (id)taskCreator;
    if (!self.tasksDict) {
        self.tasksDict = [NSMutableDictionary new];
    }
    // request retry Block
    void (^retryBlock)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) = ^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
        // no error, not retry
        if (!error) {
            completionHandler(response, responseObject, error);
            return;
        }
        // fatal error, not retry
        if ([NetworkErrorUtil isCFNetworkError:error]) {
            WNSLog(@"WJQAutoRetry->not retry, error: %@", error.localizedDescription);
            completionHandler(response, responseObject, error);
            return;
        }
        NSDictionary *taskDict = self.tasksDict[orgTaskCreator];
        NSInteger orgRetryCount = [taskDict[@"retryCount"] integerValue];
        NSInteger retryRemainCount = [taskDict[@"retryRemainCount"] integerValue];
        if (retryRemainCount == 0) {  //reach the maximum retry count
            WNSLog(@"WJQAutoRetry->retry error: %@ retry times: %ld",error.localizedDescription, (long)orgRetryCount);
            completionHandler(response, responseObject, error);
            WNSLog(@"WJQAutoRetry->done");
            return;
        }
        
        WNSLog(@"WJQAutoRetry->error: %@, retry %ld/%ld start...",
               error.localizedDescription, (long)(orgRetryCount - retryRemainCount + 1), (long)orgRetryCount);
  
        if (intervalInSeconds > 0) {
            WNSLog(@"WJQAutoRetry->dealy retry for %ld seconds...", (long)intervalInSeconds);
            dispatch_after(dispatch_time(0, (int64_t)(intervalInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
                [self requestTaskWithOriginalRequestCreator:orgTaskCreator completionHandler:completionHandler autoRetry:retryRemainCount - 1 retryInterval:intervalInSeconds];
            });
        } else {
            [self requestTaskWithOriginalRequestCreator:orgTaskCreator completionHandler:completionHandler autoRetry:retryRemainCount - 1 retryInterval:intervalInSeconds];
        }
    };
    
    // original task request
    NSURLSessionTask *task = taskCreator(retryBlock);
    
    NSMutableDictionary *taskDict = self.tasksDict[orgTaskCreator];
    if (!taskDict) {
        taskDict = [NSMutableDictionary new];
        taskDict[@"retryCount"] = @(retryCount);
    }
    taskDict[@"retryRemainCount"] = @(retryCount);
    
    self.tasksDict[orgTaskCreator] = taskDict;
    
    if (taskDict[@"retryCount"] != taskDict[@"retryRemainCount"]) {
        [task resume]; //retry auto request
    }
    
    return task;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler
                                    autoRetry:(int)retryCount
                                retryInterval:(int)intervalInSeconds {
    NSURLSessionDataTask *task = (NSURLSessionDataTask *)[self requestTaskWithOriginalRequestCreator:^NSURLSessionTask *(void (^retryBlock)(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error)) {
        return [self dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:retryBlock];
    } completionHandler:completionHandler autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
                                            autoRetry:(int)retryCount
                                        retryInterval:(int)intervalInSeconds {
    NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)[self requestTaskWithOriginalRequestCreator:^NSURLSessionTask *(void (^retryBlock)(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error)) {
        return [self downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:retryBlock];
    } completionHandler:completionHandler autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler
                                        autoRetry:(int)retryCount
                                    retryInterval:(int)intervalInSeconds {
    NSURLSessionUploadTask *task = (NSURLSessionUploadTask *)[self requestTaskWithOriginalRequestCreator:^NSURLSessionTask *(void (^retryBlock)(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error)) {
        return [self uploadTaskWithRequest:request fromFile:fileURL progress:uploadProgressBlock completionHandler:retryBlock];
    } completionHandler:completionHandler autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(nullable NSData *)bodyData
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler
                                        autoRetry:(int)retryCount
                                    retryInterval:(int)intervalInSeconds {
    NSURLSessionUploadTask *task = (NSURLSessionUploadTask *)[self requestTaskWithOriginalRequestCreator:^NSURLSessionTask *(void (^retryBlock)(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error)) {
        return [self uploadTaskWithRequest:request fromData:bodyData progress:uploadProgressBlock completionHandler:retryBlock];
    } completionHandler:completionHandler autoRetry:retryCount retryInterval:intervalInSeconds];
    
    return task;
}

@end
