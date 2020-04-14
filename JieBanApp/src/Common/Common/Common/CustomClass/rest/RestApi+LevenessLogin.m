//
//  RestApi+LevenessLogin.m
//  Common
//
//  Created by 王文龙 on 2017/4/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "RestApi+LevenessLogin.h"
#import "RXThirdPart.h"
#import "KCConstants_API.h"
#import "KCConstants_string.h"
#import "NSString+Ext.h"
#import "RX_MKNetworkKit.h"
#import "UIImage+deal.h"

@implementation RestApi (LevenessLogin)

//人脸识别登录
+ (void) userLevenessLoginAccount:(NSString *)account loginType:(int )loginType levenessImage:(UIImage *)image didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:[NSNumber numberWithInt:loginType] forKey:@"type"];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"loginName"];
    }
    
    if(image)
    {
        NSData *imgData = [image fixCurrentImage];
        [bodyDict setObject:[imgData base64EncodedString] forKey:@"faceImgBase64"];
    }
    
#if kHttpSAndHttp
    
    //客户端完整性校验
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *app_Identifier = [infoDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
#if DEBUG
    app_Identifier = @"com.hfbank.im";//开发
#endif
    NSString *md5Identifier = [app_Identifier MD5EncodingString];
    //md5Identifier = [[DemoGlobalClass sharedInstance] FileMD5HashCreateWithPath:[[NSBundle mainBundle] executablePath]];// 计算hash值
    [bodyDict setObject:app_Version forKey:@"version"];
    [bodyDict setObject:md5Identifier forKey:@"completeCode"];
    [bodyDict setObject:@"1" forKey:@"appType"]; //0/1/2 andorid/ios/pc
#endif
    
    [RestApi requestWithPath:kAPI_Auth body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}



//人脸注册
+ (void)registerFace:(NSString *)account faceImage:(UIImage *)faceImage didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(faceImage)
    {
        NSData *imgData = [faceImage fixCurrentImage];
        [bodyDict setObject:[imgData base64EncodedString] forKey:@"faceImgBase64"];
    }
    
    [RestApi requestWithPathAtAuthorization:KAPI_LevenessFace body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
//人脸是否注册过  userId  登录账号
+ (void)checkLevenessRegister:(NSString *)userId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(userId)
    {
        [bodyDict setObject:userId forKey:@"loginName"];
    }
    
    [RestApi requestWithPathAtAuthorization:KAPI_LevenessRegister body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}




@end
