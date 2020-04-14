//
//  ECWBSSError.h
//  WBSSiPhoneSDK
//
//  Created by jiazy on 16/6/25.
//  Copyright © 2016年 yuntongxun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 错误码枚举
 */
typedef NS_ENUM(NSInteger,ECErrorCode) {
    
    /** 成功 */
    ECErrorCode_Success = 200,
    
};

/**
 * 错误码类
 */
@interface ECWBSSError : NSObject

/**
 @brief 错误类型
 */
@property (nonatomic, readonly) ECErrorCode code;

/**
 @brief 错误类型描述
 */
@property (nonatomic, copy) NSString *information;

/**
 @param errorCode 错误类型
 @return 实例
 */

+ (ECWBSSError *)errorWithCode:(ECErrorCode)errorCode;

/**
 @param error 错误
 @return 实例
 */
+ (ECWBSSError *)errorWithNSError:(NSError *)error;

@end
