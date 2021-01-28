//
//  NetworkErrorUtil.h
//  WJQAutoRetryAFNetworking
//
//  Created by 云睿 on 2021/1/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
  #define WNSLog(...) NSLog(__VA_ARGS__)
#else
  #define WNSLog(...)
#endif


@interface NetworkErrorUtil : NSObject

+ (BOOL)isCFNetworkError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
