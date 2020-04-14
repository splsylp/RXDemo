//
//  CommonUserTools.h
//  Common
//
//  Created by liyj on 2017/8/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 通用工具类方法
 */
@interface CommonUserTools : NSObject

/**
 判断用户相册是否受权
 
 @return yes 用户授权相册权限
 */
+ (BOOL)userPhotosAuthorization;

/**
 判断用户相机是否受权

 @return yes 用户授权相机权限
 */
+ (BOOL)userCameraAuthorization;

/**
 判断用户相册是否受权
 无权限时弹出引导提示窗
 @return yes 用户授权相册权限
 */
+ (BOOL)userPhotosAuthorizationForAlert;

/**
 判断用户相机是否受权
 无权限时弹出引导提示窗

 @return yes 用户授权相机权限
 */
+ (BOOL)userCameraAuthorizationForAlert;

/**
 获取当前APP名称

 @return <#return value description#>
 */
+ (NSString *)appName;

/**
 显示单按钮无需操作反馈的AlertView
 
 @param title <#title description#>
 @param message <#message description#>
 @param cancelTitle <#cancelTitle description#>
 */
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle;

@end
