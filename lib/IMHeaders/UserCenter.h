//
//  UserCenter.h
//  UserCenter
//
//  Created by wangming on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KitBaseHeader.h"

typedef void (^didFinishLoaded)(NSDictionary *dict, NSString *path);
typedef void (^didFailLoaded)(NSError *error, NSString *path);

@interface UserCenter : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(UserCenter)
- (void)loginAS:(NSDictionary*) loginInfo didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
- (void)logout:(void(^)(NSError* error)) completion;
-(UIViewController*)getLoginView;

#pragma mark - 插件用的

/// 发送手机验证码
/// @param mobile 手机号
/// @param compId 企业id
/// @param finish 成功回调
/// @param fail 失败回调
- (void)sendSMSVerifyCodeWithMobile:(NSString *)mobile
                             compId:(NSString *)compId
                    didFinishLoaded:(didFinishLoaded)finish
                      didFailLoaded:(didFailLoaded)fail;


/// 重设密码接口
/// @param mobile 手机号
/// @param newpwd 新密码
/// @param verifyCode 手机验证码
/// @param compId 企业id
/// @param finish 成功回调
/// @param fail 失败回调
- (void)findPasswordWithMobile:(NSString *)mobile
                        newpwd:(NSString *)newpwd
                    verifyCode:(NSString *)verifyCode
                        compId:(NSString *)compId
               didFinishLoaded:(didFinishLoaded)finish
                 didFailLoaded:(didFailLoaded)fail;
@end
