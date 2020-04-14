//
//  CommonUserTools.m
//  Common
//
//  Created by liyj on 2017/8/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "CommonUserTools.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation CommonUserTools

/**
 判断用户相册是否受权

 @return yes 用户授权相册权限
 */
+ (BOOL)userPhotosAuthorization{
    if (iOS8) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) { //无权限
            return NO;
        }
    } else {
        ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted ||
            author == kCLAuthorizationStatusDenied) { //无权限
            return NO;
        }
    }
    return YES;
}

/**
 判断用户相机是否受权
 
 @return yes 用户授权相机权限
 */
+ (BOOL)userCameraAuthorization{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted) {
        return NO;
    }
    return YES;
}

/**
 判断用户相册是否受权
 无权限时弹出引导提示窗
 @return yes 用户授权相册权限
 */
+ (BOOL)userPhotosAuthorizationForAlert{
    if (iOS8) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) { //无权限
          
            NSString *message = [NSString stringWithFormat:@"%@[%@]%@", languageStringWithKey(@"请在“设置-隐私-照片”选项中允许"), [CommonUserTools appName], languageStringWithKey(@"访问你的相册")];
            [CommonUserTools showAlertViewWithTitle:languageStringWithKey(@"无法使用相册功能") message:message cancelButtonTitle:languageStringWithKey(@"确定")];
            
            return NO;
        }
    } else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted ||
            author == kCLAuthorizationStatusDenied) { //无权限
            NSString *message = [NSString stringWithFormat:@"%@[%@]%@", languageStringWithKey(@"请在“设置-隐私-照片”选项中允许"),[CommonUserTools appName],languageStringWithKey(@"访问你的相册")];
            [CommonUserTools showAlertViewWithTitle:languageStringWithKey(@"无法使用相册功能") message:message cancelButtonTitle:languageStringWithKey(@"确定")];
            return NO;
        }
    }
    return YES;
}

/**
 判断用户相机是否受权
 无权限时弹出引导提示窗
 
 @return yes 用户授权相机权限
 */
+ (BOOL)userCameraAuthorizationForAlert{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted) {
       
        NSString *message = [NSString stringWithFormat:@"%@[%@]%@",languageStringWithKey(@"请在“设置-隐私-相机”选项中允许"), [CommonUserTools appName], languageStringWithKey(@"访问你的相机")];
        [CommonUserTools showAlertViewWithTitle:languageStringWithKey(@"无法使用相机功能") message:message cancelButtonTitle:languageStringWithKey(@"确定")];
        
        return NO;
    }
    return YES;
}

/**
 获取当前APP名称

 @return
 */
+ (NSString *)appName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return appName;
}

/**
 显示单按钮无需操作反馈的AlertView
 */
+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil] show];
}

@end
