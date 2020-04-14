//
//  YXPPlayerError.h
//  Common
//
//  Created by yuxuanpeng on 2017/9/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kMediaPlayerErrorCodeCannotPlay -1111800        // 源不能播放
#define kMediaPlayerErrorCodePlayerTimeOut -1111801     // 播放器超时
#define KMediaPlayerErrorCodeNotAllowNetwork -1111802   // 禁止访问网络
#define KMediaPlayerErrorCodeTaskCanceled -1111803      // 任务被取消

NS_INLINE NSError *sqr_errorWithCode(int errorCode, NSString *reason)
{
    return [NSError errorWithDomain:@"ios.sqrrader.com" code:errorCode userInfo:@{
                                                                                  NSLocalizedDescriptionKey : @"The operation couldn’t be completed.",
                                                                                  NSLocalizedFailureReasonErrorKey : reason,
                                                                                  }];
}

@protocol YXPPlayerNetworkChangedProtocol <NSObject>

@required
/**
 Whether or not player allowed access network。default is YES;
 *  NO 所有需要使用网络的数据段均失败。
 *  YES  播放器会请求网络完成预加载
 
 @param url 当前需要使用网络的url
 @return 是否允许使用网络
 */
- (BOOL)mediaPlayerCanUseNetwork:(NSURL *)url;

@end

@interface YXPPlayerError : NSObject

@end
