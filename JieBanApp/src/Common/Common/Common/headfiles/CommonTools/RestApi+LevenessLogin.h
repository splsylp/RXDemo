//
//  RestApi+LevenessLogin.h
//  Common
//
//  Created by 王文龙 on 2017/4/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "RestApi.h"

@interface RestApi (LevenessLogin)
/**
 *
 * 人脸识别登录
 * account 唯一标识
 * faceImage 图片
 * loginType 登录类型为2
 **/
+ (void) userLevenessLoginAccount:(NSString *)account loginType:(int )loginType levenessImage:(UIImage *)image didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 *
 * 注册人脸
 * account 唯一标识
 * faceImage 图片
 **/
+ (void)registerFace:(NSString *)account faceImage:(UIImage *)faceImage didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;


/**
 *
 * 注册人脸监测
 * userId 登录账号
 **/+ (void)checkLevenessRegister:(NSString *)userId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;

@end
