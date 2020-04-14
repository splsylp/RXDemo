 //
//  HYTApiClient+Ext.m
//  HIYUNTON
//
//  Created by yuxuanpeng MINA on 14-10-11.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//
#import "HYTApiClient+Ext.h"
#import "NSString+Ext.h"
#import "KCConstants_string.h"
#import "KCConstants_API.h"
#import "NSDate+Ext.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "RxAppStoreData.h"
#import "UIImage+deal.h"
#import "RXThirdPart.h"

#define NetDebug

@implementation HYTApiClient (Ext)

+ (NSString *)userAgent
{
    int width = [[UIScreen mainScreen] bounds].size.width*[[UIScreen mainScreen] scale];
    int hight = [[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] scale];
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@;%@;%d*%d;%@;%@",@"iPhone",[[UIDevice currentDevice] systemVersion],width, hight,version,[[UIDevice currentDevice] model]];
}

+ (NSString *)requestTime:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)requestGMTTime:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss yyyy";
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)countryCode
{
    return @"+86";
}
+(void)showErrorDomain:(NSError *)errorDomain
{
    
    [SVProgressHUD showErrorWithStatus:[HYTApiClient errorDomain:errorDomain.domain withErrorPrompt:[errorDomain localizedDescription]]];
    //[ATMHud showMessage:[HYTApiClient errorDomain:errorDomain.domain withErrorPrompt:[errorDomain localizedDescription]]];
}
+(NSString *)errorDomain:(NSString *)errDomain withErrorPrompt:(NSString *)prompt
{
    if([errDomain isEqualToString:@"NSURLErrorDomain"])
    {
        return prompt;
    }
    
    return errDomain;
}
+ (void)handlerErrorCode:(int)errorcode
{
    [SVProgressHUD showInfoWithStatus:[HYTApiClient errorMessage:errorcode]];
}

+ (NSString *)errorMessage:(int)errorcode
{
    switch (errorcode) {
        case 111003:
            return @"没有权限";
        case 111010:
            return @"没有授权";
        case 111200:
            return @"备份个人联系人失败";
        case 111201:
            return @"备份个人通讯录，写文件失败";
        case 111300:
            return @"下载联系人失败";
        case 111301:
            return @"下载联系人读文件失败";
        case 111400:
            return @"下载企业通讯录，存储执行失败";
        case 111401:
            return @"下载企业通讯录，读通讯录文件失败";
        case 111402:
            return @"下载企业通讯录，无更新，不需要下载";
        case 111403:
            return @"下载企业通讯录，用户不属于任何企业";
        case 111500:
            return @"确认加入企业，存储执行失败";
        case 111501:
            return @"已确认加入企业";
        case 111600:
            return @"设置个人用户信息，存储执行失败";
        case 111601:
            return @"设置个人用户信息，写文件失败";
        case 111700:
            return @"存储执行失败";
        case 111701:
            return @"账号或密码错误";
        case 111702:
            return @"注册失败，创建子账号失败";
        case 111703:
            return @"登陆失败";
        case 111704:
            return @"不存在此账号";
        case 111800:
            return @"获取短信验证码，存储执行失败";
        case 111801:
            return @"获取短信验证码，次数超限，每个号码每天只允许三次";
        case 111802:
            return @"获取短信验证码，用户状态异常";
        case 111900:
            return @"获取企业审核状态，存储执行失败";
        default:
            return @"网络异常";
    }
}
//
////包括给header签名
//+ (void)requestWithPathAtDate:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSAssert(path!=nil, @"the url path can't be null");
//    NSAssert(body!=nil, @"the body can't be null");
//    NSDate* date = [NSDate date];
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8;", @"Content-Type", [self requestGMTTime:date],@"Date",nil];
//    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
//    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
//    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
//    
//    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//    [requestDict setObject:headDict forKey:@"head"];
//    [requestDict setObject:body forKey:@"body"];
//    
//    KXJson *json = [KXJson jsonWithObject:[NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil]];
//    
//    //[json printJson];
//    
//    MKNetworkOperation *operation = [HYTApiClient requestWithPath:path headers:headers postBody:[[json toJsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//       // DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        
//        //[result printJson];
//        KXJson *response = [result getJsonForKey:@"Response"];
//        KXJson *head = [response getJsonForKey:@"head"];
//        if ([head getIntForKey:@"statusCode"] == 0) { // 未知错误
//            if (finish) {
//                finish(response, path);
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, path);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, path);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}
//
////text请求数据
//+(void)requestWithPathAtTextAuthorization:(NSString *)urlPath didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    MKNetworkOperation *operation = [HYTApiClient requestWithPath:urlPath headers:nil params:nil];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        // DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        
//        
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        [result printJson];
//          KXJson *response = nil;
//        if ([result haveJsonValueForKey:@"Response"]) {
//            response = [result getJsonForKey:@"Response"];
//        }else{
//            response = [result getJsonForKey:@"response"];
//        }
//        KXJson *head = [response getJsonForKey:@"head"];
//        if ([head getIntForKey:@"statusCode"] == 0) { // 未知错误
//            if (finish) {
//                finish(response, urlPath);
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, urlPath);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, urlPath);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}
////包括给header签名
//+ (void)requestWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSAssert(path!=nil, @"the url path can't be null");
//    NSDate* date = [NSDate date];
//    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
//    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
//    if (!KCNSSTRING_ISEMPTY([[RXUser sharedInstance] mobile])) {
//        [authorization appendString:[[RXUser sharedInstance] mobile]];
//    }
//    if (!KCNSSTRING_ISEMPTY([[RXUser sharedInstance]clientpwd])) {
//        [authorization appendString:[[RXUser sharedInstance]clientpwd]];
//    }
//    
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8;", @"Content-Type", requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
//    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
//    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
//    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
//    
//    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//    [requestDict setObject:headDict forKey:@"head"];
//   
//    if (body) {
//        [requestDict setObject:body forKey:@"body"];
//        //[requestDict setObject:@"0" forKey:@"flag"];
//    }
//    
//    KXJson *json = [KXJson jsonWithObject:[NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil]];
//    //[json printJson];
//    MKNetworkOperation *operation = [HYTApiClient requestWithPath:path headers:headers postBody:[[json toJsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//       // DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        [result printJson];
//        KXJson *response = nil;
//        if ([result haveJsonValueForKey:@"Response"]) {
//            response = [result getJsonForKey:@"Response"];
//        }else{
//            response = [result getJsonForKey:@"response"];
//        }
//        KXJson *head = [response getJsonForKey:@"head"];
//        if ([head getIntForKey:@"statusCode"] == 0) { // 未知错误
//            if (finish) {
//                finish(response, path);
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, path);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, path);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}
//
//+ (void)requestWithPath:(NSString *)path body:(NSDictionary *)body didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSAssert(path!=nil, @"the url path can't be null");
//    NSAssert(body!=nil, @"the body can't be null");
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8;", @"Content-Type", nil];
//    NSDate* date = [NSDate date];
//    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
//    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
//    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
//    
//    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//    [requestDict setObject:headDict forKey:@"head"];
//    [requestDict setObject:body forKey:@"body"];
//    
//    //KXJson *json = [KXJson jsonWithObject:[NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil]];
//    //[json printJson];
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"Request":requestDict} options:NSJSONWritingPrettyPrinted error:&error];
//    //NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    MKNetworkOperation *operation = [HYTApiClient requestWithPath:path headers:headers postBody:jsonData];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//      //  DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        [result printJson];
//        KXJson *response = [result getJsonForKey:@"Response"];
//        KXJson *head = [response getJsonForKey:@"head"];
//        if ([head getIntForKey:@"statusCode"] == 0) { // 未知错误
//            if (finish) {
//                finish(response, path);
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, path);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, path);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}
////type 1:只支持手机号登陆 3:账号登陆 account withCodeKey 图片验证码的key imgCode :图片验证码的值
//+ (void)userLoginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd userType:(int)type withCodeKey:(NSString *)codeKey imgCode:(NSString *)imgCode didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:mobile forKey:@"loginName"];
//    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
//        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
//    }
//    if (!KCNSSTRING_ISEMPTY(pwd)) {
//        [bodyDict setObject:[[DeviceDelegateHelper sharedInstance] md5PassWord:pwd] forKey:@"userpasswd"];
//    }
//    [bodyDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
//    
//    if(!KCNSSTRING_ISEMPTY(codeKey))
//    {
//        [bodyDict setObject:codeKey forKey:@"codeKey"];
//    }
//    
//    if(!KCNSSTRING_ISEMPTY(imgCode))
//    {
//        [bodyDict setObject:imgCode forKey:@"imgCode"];
//    }
//    
//    
//#if kHttpSAndHttp
//    
//    //客户端完整性校验
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *app_Version = [infoDictionary objectForKey:(__bridge NSString *)kCFBundleVersionKey];
//    NSString *app_Identifier = [infoDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
//#if DEBUG
//    app_Identifier = @"com.hfbank.im";//开发
//#endif
//    NSString *md5Identifier = [app_Identifier MD5EncodingString];
//    //md5Identifier = [[DemoGlobalClass sharedInstance] FileMD5HashCreateWithPath:[[NSBundle mainBundle] executablePath]];// 计算hash值
//    [bodyDict setObject:app_Version forKey:@"version"];
//    [bodyDict setObject:md5Identifier forKey:@"completeCode"];
//    [bodyDict setObject:@"1" forKey:@"appType"]; //0/1/2 andorid/ios/pc
//#endif
//    
//    [HYTApiClient requestWithPath:kAPI_Auth body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)userLoginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd userType:(int)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:mobile forKey:@"loginName"];
//    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
//        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
//    }
//    if (!KCNSSTRING_ISEMPTY(pwd)) {
//        [bodyDict setObject:[[DeviceDelegateHelper sharedInstance] md5PassWord:pwd] forKey:@"userpasswd"];
//    }
//    [bodyDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
//    
//
//    
//#if kHttpSAndHttp
//    
//    //客户端完整性校验
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *app_Version = [infoDictionary objectForKey:(__bridge NSString *)kCFBundleVersionKey];
//    NSString *app_Identifier = [infoDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
//#if DEBUG
//    app_Identifier = @"com.hfbank.im";//开发
//#endif
//    NSString *md5Identifier = [app_Identifier MD5EncodingString];
//    [bodyDict setObject:app_Version forKey:@"version"];
//    [bodyDict setObject:md5Identifier forKey:@"completeCode"];
//    [bodyDict setObject:@"1" forKey:@"appType"]; //0/1/2 andorid/ios/pc
//#endif
//    
//    [HYTApiClient requestWithPath:kAPI_Auth body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//
//+ (void)userOutloginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:mobile forKey:@"mobilenum"];
//    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
//        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
//    }
//    [bodyDict setObject:pwd forKey:@"userpasswd"];
//    [bodyDict setObject:@"1" forKey:@"type"];
//    
//    [HYTApiClient requestWithPath:kAPI_Auth body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)userRegisterWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:ISSTRING_ISSTRING(mobile) forKey:@"mobilenum"];
//    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
//        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
//    }else{
//        [bodyDict setObject:@"" forKey:@"smsverifycode"];    
//    }
//    if(pwd)
//    {
//        [bodyDict setObject:pwd forKey:@"userpasswd"];
//    }
//    [bodyDict setObject:@"0" forKey:@"type"];
//    
//    [HYTApiClient requestWithPath:kAPI_Auth body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
////type  0:短信验证码 1:语音验证码 2:邮箱验证码
//+(void)sendEmailVerifyCodeWithAccount:(NSString *)account withFlag:(int)flag codeKey:(NSString *)codeKey imgCode:(NSString *)imgCode didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:account forKey:@"account"];
//    [bodyDict setObject:[NSNumber numberWithInt:2] forKey:@"type"];
//    [bodyDict setObject:[NSString imei] forKey:@"imei"];
//    [bodyDict setObject:[NSString macAddress] forKey:@"mac"];
//    [bodyDict setObject:[NSNumber numberWithInt:flag] forKey:@"flag"];
//    [bodyDict setObject:codeKey forKey:@"codeKey"];
//    [bodyDict setObject:imgCode forKey:@"imgCode"];
//    
//    [HYTApiClient requestWithPath:KAPI_GETSMS body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)sendSMSVerifyCodeWithMobile:(NSString *)mobile withFlag:(NSString *)flag didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//     NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//     [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:mobile forKey:@"mobilenum"];
//    [bodyDict setObject:[NSNumber numberWithInt:0] forKey:@"type"];
//    [bodyDict setObject:[NSString imei] forKey:@"imei"];
//    [bodyDict setObject:[NSString macAddress] forKey:@"mac"];
//    [bodyDict setObject:flag forKey:@"flag"];
//    
//    [HYTApiClient requestWithPath:KAPI_GETSMS body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)sendTelVerifyCodeWithMobile:(NSString *)mobile withFlag:(NSString *)flag didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[HYTApiClient countryCode] forKey:@"countrycode"];
//    [bodyDict setObject:mobile forKey:@"mobilenum"];
//    [bodyDict setObject:[NSNumber numberWithInt:0] forKey:@"type"];
//    [bodyDict setObject:[NSString imei] forKey:@"imei"];
//    [bodyDict setObject:[NSString macAddress] forKey:@"mac"];
//    [bodyDict setObject:flag forKey:@"flag"];
//    [HYTApiClient requestWithPath:KAPI_GETSMS body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+(void)checkSMSVerifyCodeWithAccount:(NSString *)account verifyCode:(NSString *)code didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    if(!KCNSSTRING_ISEMPTY(account))
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    
//    if(!KCNSSTRING_ISEMPTY(code))
//    {
//        [bodyDict setObject:code forKey:@"countrycode"];
//    }
//    
//    [HYTApiClient requestWithPath:KAPI_CHECKSMS body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//
//}
//
//+ (void)findPasswordWithMobile:(NSString *)mobile newpwd:(NSString *)newpwd verifyCode:(NSString *)verifyCode didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:@"0" forKey:@"type"];
//    [bodyDict setObject:verifyCode forKey:@"auth"];
//    [bodyDict setObject:mobile forKey:@"mobilenum"];
//    [bodyDict setObject:[[DeviceDelegateHelper sharedInstance] md5PassWord:newpwd] forKey:@"new_pwd"];
//    [HYTApiClient requestWithPathAtDate:kAPI_ModifiPassword body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)updatePasswordWithMobile:(NSString *)mobile auth:(NSString *)auth newpwd:(NSString *)newpwd type:(NSString*)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail;
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[NSNumber numberWithInt:[type intValue]] forKey:@"type"];
//    [bodyDict setObject:[[DeviceDelegateHelper sharedInstance] md5PassWord:auth] forKey:@"auth"];
//    if(!KCNSSTRING_ISEMPTY(mobile))
//    {
//        [bodyDict setObject:mobile forKey:@"mobilenum"];
//    }
//    
//    [bodyDict setObject:[[DeviceDelegateHelper sharedInstance] md5PassWord:newpwd] forKey:@"new_pwd"];
//    [HYTApiClient requestWithPathAtDate:kAPI_ModifiPassword body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)feedBackWithMobile:(NSString *)mobile feedback:(NSString *)feedback didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[RXUser sharedInstance].mobile forKey:@"account"];
//    [bodyDict setObject:feedback forKey:@"feedback"];
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_Feedback body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)checkVersionWithMobile:(NSString *)mobile didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    if(!KCNSSTRING_ISEMPTY(mobile))
//    {
//        [bodyDict setObject:mobile forKey:@"account"];
//    }
//    
//    [bodyDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey] forKey:@"version"];
//    [bodyDict setObject:@"1" forKey:@"type"];
//    
//    [HYTApiClient requestWithPath:kAPI_CheckVersion body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)updateUserInfo:(NSString *)mobile nickName:(NSString *)nickName photo:(UIImage *)photo signature:(NSString *)signature didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:[RXUser sharedInstance].mobile forKey:@"account"];
//    
//    if (!KCNSSTRING_ISEMPTY(nickName)) {
//        [dict setObject:nickName forKey:@"nickname"];
//    }
//    
//    if (!KCNSSTRING_ISEMPTY(mobile)) {
//        [dict setObject:mobile forKey:@"mobilenum"];
//    }
//    
//    if (photo) {
//        
//       // [[DeviceDelegateHelper sharedInstance]fixCurrentImage:photo];
//        
//        NSData *imgData = UIImageJPEGRepresentation(photo, 0.5);
//        
//        [dict setObject:@"jpeg" forKey:@"photo_type"];
//        [dict setObject:[imgData base64Encoding] forKey:@"photo_content"];
//    }
//    if (!KCNSSTRING_ISEMPTY(signature)) {
//        [dict setObject:signature forKey:@"signature"];
//    }
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_SetUserInfo body:dict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)getVOIPUserInfoWithMobile:(NSString *)mobile type:(NSString*)type  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSArray* array = [NSArray arrayWithObjects:mobile, nil];
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:array forKey:@"userAccounts"];
//    [bodyDict setObject:[RXUser sharedInstance].mobile forKey:@"account"];
//    [bodyDict setObject:type forKey:@"type"];
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_GetVOIPUserInfo body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)getVOIPUserInfoWithMobile:(NSString *)mobile number:(NSArray*)number type:(NSString*)type  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:number forKey:@"userAccounts"];
//    [bodyDict setObject:[RXUser sharedInstance].mobile forKey:@"account"];
//    [bodyDict setObject:type forKey:@"type"];
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_GetVOIPUserInfo body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//+ (void)downloadCOMAddressBookWithMobile:(NSString *)mobile didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//     //lastreqtime 为@""的时候为全量下载 不为空的适合为增量下载[userDefaults objectForKey:KNotification_ADDCOUNTQUESTTime]
//    NSString *lastreqtime =@"" ;
//   
//    
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:KCNSSTRING_ISEMPTY(mobile)?@"":mobile forKey:@"account"];
//    
//    if([[NSUserDefaults standardUserDefaults] boolForKey:KNotification_ADDCOUNTQUEST])
//    {
//        lastreqtime = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",KNotification_ADDCOUNTQUESTTime,[RXUser sharedInstance].mobile]];
//        
//    }
//    
//#if isZipBaseFile
//        
//        [bodyDict setObject:[NSNumber numberWithInt:1] forKey:@"isZip"];
//#else
//        
//        [bodyDict setObject:[NSNumber numberWithInt:0] forKey:@"isZip"];
//        
//#endif
//    
//    [bodyDict setObject:KCNSSTRING_ISEMPTY(lastreqtime)?@"":lastreqtime forKey:@"synctime"];
//    
//   
//    
//    
//    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GETCOMAddBook] body:bodyDict didFinishLoadedMK:^(KXJson *json, NSString *path) {
//        
//        [userDefaults setObject:[[json  getJsonForKey:@"body"] getStringForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",KNotification_ADDCOUNTQUESTTime,[RXUser sharedInstance].mobile]];
//       // DDLogInfo(@"lastreqtime %@",[[json  getJsonForKey:@"body"] getStringForKey:@"updatetime"]);
//        if (finish) {
//            finish(json, path);
//        }
//    } didFailLoadedMK:fail];
//}
///**
// *
// * 下载企业通讯录文件text
// *
// */
//+(void)downloadComTextWithUrl:(NSString *)textUrl didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    [HYTApiClient  requestWithPathAtTextAuthorization:textUrl didFinishLoadedMK:^(KXJson *json, NSString *path) {
//        if (finish) {
//            finish(json, path);
//        }
//    } didFailLoadedMK:fail];
//   
//}
///**
// *  加入企业通讯录
// *
// *  @param mobile
// */
//+ (void)confirmInvitWithMobile:(NSString *)mobile companyid:(NSString *)companyid didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:companyid forKey:@"companyid"];
//    [bodyDict setObject:@"1" forKey:@"type"];
//    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_ConfirmInvit, mobile] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *  获取企业审核状态
// *
// *  @param mobile
// */
//
//+ (void)confirmInvitStatusWithMobile:(NSString *)mobile  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetComStatus, mobile] body:nil didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *  备份联系人
// *
// *  @param mobile
// */
//+ (void)backupContactsWithMobile:(NSString *)mobile path:(NSString *)path didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSData* data = [NSData dataWithContentsOfFile:path];
//    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_BackupContacts, mobile] withBody:data didFinishLoadedMK:finish didFailLoadedMK:fail];
//    
//}
//
///**
// *  恢复联系人
// *
// *  @param mobile
// */
//+ (void)downloadContactssWithMobile:(NSString *)mobile didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_DownloadContacts, mobile] body:nil didFinishLoadedMK:finish didFailLoadedMK:fail];
//    
//}
//
//+ (void)getNetDistWithMobile:(NSString *)mobile queryid:(NSString*)queryid type:(NSString*)type  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:mobile forKey:@"username"];
//    [bodyDict setObject:queryid forKey:@"queryid"];
//    [bodyDict setObject:type forKey:@"type"];
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_GETNetDistQuery body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//
//上传附件 将文件名字和图片传进来
+ (void)uploadPhoWithFileName:(NSString *)fileName photo:(UIImage *)photo withImageData:(NSData *)imageData fileData:(NSData *)fileData fileType:(NSString *)fileType didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    [HYTApiClient uploadPhoWithFileName:fileName photo:photo withImageData:imageData fileData:fileData fileType:fileType withImageType:-1 didFinishLoadedMK:finish didFailLoadedMK:fail];
}
+ (void)uploadPhoWithFileName:(NSString *)fileName photo:(UIImage *)photo withImageData:(NSData *)imageData fileData:(NSData *)fileData fileType:(NSString *)fileType withImageType:(NSInteger)imageType didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[[Common sharedInstance] getAppid] forKey:@"appId"];
    [bodyDict setObject:fileName forKey:@"filename"];
    
    if (photo) {
        NSData *imgData = [photo fixCurrentImage];
        [bodyDict setObject:imgData forKey:@"data"];
        [bodyDict setObject:fileType forKey:@"photo_type"];
        [bodyDict setObject:[imgData base64Encoding] forKey:@"photo_content"];
    }
    if(imageData)
    {
        [bodyDict setObject:imageData forKey:@"data"];
        [bodyDict setObject:fileType forKey:@"photo_type"];
        [bodyDict setObject:[imageData base64Encoding] forKey:@"photo_content"];
    }
    
    if (fileData) {
        [bodyDict setObject:fileData forKey:@"data"];
        [bodyDict setObject:fileType forKey:@"photo_type"];
        [bodyDict setObject:[fileData base64Encoding] forKey:@"photo_content"];
    }
    
    NSArray * fileArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"RX_fileserver"];
    NSString * sigStr = [@"yuntongxunytx123" MD5EncodingString];
    NSString * fileUrl = [NSString stringWithFormat:@"http://%@/2015-03-26/Corp/yuntongxun/Upload/VTM?appId=%@&userName=%@&fileName=%@&sig=%@",fileArr[0],[Common sharedInstance].getAppid,[Common sharedInstance].getAccount,fileName,sigStr];
    
    if ([fileName hasSuffix:@"mp4"]) {
        fileUrl = [NSString stringWithFormat:@"http://%@/2015-03-26/Corp/yuntongxun/Upload/VTM?appId=%@&userName=%@&fileName=%@&rotate=%ld&sig=%@",fileArr[0],[Common sharedInstance].getAppid,[Common sharedInstance].getAccount,fileName,(long)imageType,sigStr];
    }
    
    //wang ming add
    if ([fileName hasSuffix:@"zip"]) {
        fileUrl = [NSString stringWithFormat:@"http://%@/2015-03-26/Corp/yuntongxun/Upload/VTM?appId=%@&userName=%@&fileName=%@&rotate=%ld&sig=%@",fileArr[0],[Common sharedInstance].getAppid,[Common sharedInstance].getAccount,fileName,(long)imageType,sigStr];
        //wangming modify 2017-10-09
        //获取当前连接的服务器ip
        NSString *callBackIP = nil;
        NSString *currentUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"kitAppIP"];
        BOOL IPChanged =  [[[NSUserDefaults standardUserDefaults]objectForKey:@"HaveChangedIPWithRonglian"]boolValue];
        if (IPChanged && !KCNSSTRING_ISEMPTY(currentUrl)) {
            NSArray* arr = [currentUrl componentsSeparatedByString:@":"];
            if ([arr count]>=2) {
                callBackIP = [arr objectAtIndex:1];
                if ([callBackIP hasPrefix:@"//"]) {
                    callBackIP = [callBackIP stringByReplacingOccurrencesOfString:@"//" withString:@""];
                }
            }
        }
        if ([callBackIP length]<=0) {
            callBackIP = kHOST;
        }
        //wangming modify 2017-10-09 end
        NSString* callBackUrl = [NSString stringWithFormat:@"http://%@:%d/bm/admin/sys/syslogadd?appid=%@&account=%@&appinfo=%@",callBackIP,9092,[Common sharedInstance].getAppid,[Common sharedInstance].getAccount,[self userAgent]];
        fileUrl = [NSString stringWithFormat:@"%@&callbackurl=%@",fileUrl,[callBackUrl base64EncodingString]];
    }
    //wangming end
    DDLogInfo(@"fileUrl:%@",fileUrl);

    [HYTApiClient requestUploadWithPathAtAuthorization:fileUrl body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

//上传服务器地址
+ (void)requestUploadWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    
    NSDate* date = [NSDate date];
    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
//    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    NSDictionary *headers =[NSDictionary dictionaryWithObjectsAndKeys:@"application/octet-stream;charset=utf-8",@"Content-Type",@"application/json",@"accept",@"YmRiMjc4ZjU1MWIzYTViYjAxNTFjMzhmYTBkMDAwMDA6MjAxNjAzMTAxMDEzMDU＝",@"Authorization",requestTime,@"Date", nil];
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
    [requestDict setObject:headDict forKey:@"head"];
    
    NSData *data =[body objectForKey:@"data"];
    if (body) {
        [requestDict setObject:data forKey:@"body"];
    }
    
    RX_MKNetworkOperation *operation = [HYTApiClient requestUploadWithPath:path headers:headers postBody:data];
    [operation addCompletionHandler:^(RX_MKNetworkOperation *completedOperation) {
         DDLogInfo(@"path is %@,responseString=%@", path,completedOperation.responseString);
        NSData *jsonData = [completedOperation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                       
                                                              error:&err];
//        [result printJson];
        NSDictionary* response;
        if ([dic hasValueForKey:@"Response"]) {
            response = [dic objectForKey:@"Response"];
        }else{
            
            if([dic hasValueForKey:@"response"])
            {
                response = [dic objectForKey:@"response"];
            }else
            {
                response =dic;
            }
            
        }
        NSDictionary *head = [response objectForKey:@"head"];
        if ([[head objectForKey:@"statusCode"] integerValue]== 0) { 
            if (finish) {
                finish(dic, path);
            }
        }else{
            if (fail) {
                NSError *error = nil;
                
                if ([head hasValueForKey:@"statusMsg"]&&[head hasValueForKey:@"statusCode"] ) {
                    error = [NSError errorWithDomain:[head objectForKey:@"statusMsg"]
                                                         code:[head objectForKey:@"statusCode"] userInfo:nil];
                }
                fail(error, path);
            }
        }
    } errorHandler:^(RX_MKNetworkOperation *completedOperation, NSError *error) {
        if (fail) {
            fail(error, path);
        }
    }];
    [[HYTApiClient engine] enqueueOperation:operation];
}

//文件服务器上传专属
+ (RX_MKNetworkOperation *)requestUploadWithPath:(NSString *)path headers:(NSDictionary *)headers postBody:(NSData *)data
{
    NSAssert(path!=nil, @"the url path can't be null");
    
    // [self operationWithURLString:urlString params:body httpMethod:method];
    
    RX_MKNetworkOperation *operation = [[HYTApiClient engine] operationWithURLString:path params:nil httpMethod:@"POST"];
    [operation setStringEncoding:NSUTF8StringEncoding];
    [operation setShouldContinueWithInvalidCertificate:YES];
    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    if (headers) {
        [operation addHeaders:headers];
    }
    if (data) {
        [operation addHeaders:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu", (unsigned long)data.length], @"Content-Length", nil]];
        [operation setHttpPostData:data];
    }
#ifdef DEBUG
//    HYTDLog(@"http headers=%@", [headers description]);
//    HYTDLog(@"http postdata=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
    return operation;
}
//
///**
// *  运动会 恒信 消息发布
// *  @sig MD5(account+passWord)
// *  @mobile 账号
// *  @content 内容
// *  @imgUrl 图片地址
// *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
// *  @subject 主题
// */
//+ (void)sendSportMeetMessageSig:(NSString *)sig
//                    withAccount:(NSString *)mobile
//                    withContent:(NSString *)content
//                    withFileUrl:(NSArray *)imgUrl
//                      withDomin:(NSDictionary *)domain
//                    withSubject:(NSString *)subject
//                didFinishLoadedMK:(didFinishLoadedMK)finish
//                  didFailLoadedMK:(didFailLoadedMK)fail
//{
//    
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    if(sig)
//    {
//        [bodyDict setObject:sig forKey:@"sig"];
//    }
//    if(mobile)
//    {
//        [bodyDict setObject:mobile forKey:@"account"];
//    }
//    if(content)
//    {
//        [bodyDict setObject:content forKey:@"content"];
//    }
//    if(imgUrl.count>0)
//    {
//        [bodyDict setObject:imgUrl forKey:@"fileUrl"];
//    }
//    if(domain)
//    {
//        [bodyDict setObject:domain forKey:@"domain"];
//    }
//    if(subject)
//    {
//        [bodyDict setObject:subject forKey:@"subject"];
//    }
//    
//    DDLogInfo(@"body:%@",bodyDict);
//    
//    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_sendSportMeet,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *  运动会 恒信 获取消息
// *  @sig MD5(account+passWord)
// *  @mobile 账号
// *  @content 内容
// *  @limit 获取个数 默认是5条
// *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
// *  @version 开始的版本号，默认为空，从第一条开始
// */

+ (void)getSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version withLimit:(int)limit withDomain:(NSDictionary *)domain didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
 
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(version)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
    }
    if(domain)
    {
        [bodyDict setObject:domain forKey:@"domain"];
    }
    if(limit)
    {
        //[bodyDict setIntValue:limit forKey:@"limit"];
        [bodyDict setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    }
    
    NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];
    
    if (dict[Table_User_OrgId]) {
        [bodyDict setObject:dict[Table_User_OrgId] forKey:@"orgId"];
    }
    
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_GETSportMeet,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
///**
// *  运动会 恒信 获取单条消息
// *  @sig MD5(account+passWord)
// *  @account 账号
// *  @version 开始的版本号，默认为空，从第一条开始
// */
+ (void)getSingleSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(version)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
    }
    
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_GETFC,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
///**
// *  获取某个人的所有同事圈
// *  @sig MD5(account+passWord)
// *  @account 自己账号
// *  @friendAccount 朋友的账号
// *  @limit 获取个数 默认是10条
// *  @domain 自定义json字段
// *  @msgId 开始的版本号，默认为空，从第一条开始
// */
//
+ (void)getFCMyListMessageSig:(NSString *)sig withAccout:(NSString*)account withMsgId:(NSString *)msgId withLimit:(int)limit withDomain:(NSDictionary *)domain didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account){
        [bodyDict setObject:account forKey:@"account"];
    }
    if(msgId){
        [bodyDict setObject:[NSNumber numberWithInt:[msgId intValue]] forKey:@"msgId"];
    }
    if(domain){
        [bodyDict setObject:domain forKey:@"domain"];
    }
    if(limit){
        [bodyDict setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    }
    
    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_getFCMyList,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
///**
// *  删除同事圈
// *  @sig MD5(account+passWord)
// *  @account 账号
// *  @version 同事圈消息版本号
// */
//+ (void)deleteFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
//    
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    if(sig)
//    {
//        [bodyDict setObject:sig forKey:@"sig"];
//    }
//    if(account)
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    if(version)
//    {
//        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
//    }
//    
//    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_deleteFCMsg,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
///**
// *  获取所有评论和点赞
// *  @sig MD5(account+passWord)
// *  @account 账号
// *  @version 同事圈消息版本号
// *  @flag    0 全部， 1 赞，2评论   默认值0
// */
+ (void)getRepliesAndFavorsWithFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version withFlag:(int)flag didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(version)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
    }
    [bodyDict setObject:[NSNumber numberWithInt:flag] forKey:@"flag"];
    
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_getRepliesAndFavors,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
///**
// *  同事圈评论
// *  @sig MD5(account+passWord)
// *  @account 自己账号
// *  @rAccount 回复对方的帐号
// *  @version 同事圈版本号
// *  @content 评论内容
// */
+ (void)replyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyAccount:(NSString *)rAccount withVersion:(NSString *)version withContent:(NSString *)content  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if (rAccount) {
        [bodyDict setObject:rAccount forKey:@"accepter"];
    }
    if(version)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
    }
    if (content) {
        [bodyDict setObject:content forKey:@"content"];
    }
    
    NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];
    
    if (dict[Table_User_OrgId]) {
        [bodyDict setObject:dict[Table_User_OrgId] forKey:@"orgId"];
    }
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_Reply,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
///**
// *  同事圈点赞
// *  @sig MD5(account+passWord)
// *  @account 账号
// *  @version 同事圈版本号
// */
+ (void)favourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(version)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
    }
    
    NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];
    
    if (dict[Table_User_OrgId]) {
        [bodyDict setObject:dict[Table_User_OrgId] forKey:@"orgId"];
    }
    
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_Favour,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
///**
// *  取消同事圈评论
// *  @sig MD5(account+passWord)
// *  @account 账号
// *  @replyId 评论ID
// */
+ (void)cancelReplyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyId:(NSString *)replyId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(replyId)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[replyId intValue]] forKey:@"id"];
    }
    
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_CancelReply,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
///**
// *  取消同事圈点赞
// *  @sig MD5(account+passWord)
// *  @account 账号
// *  @version 同事圈版本号
// */
+ (void)cancelFavourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(version)
    {
        [bodyDict setObject:[NSNumber numberWithInt:[version intValue]] forKey:@"msgId"];
    }
    
    [HYTApiClient requestSportMeetWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@",kAPI_CancelFavour,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
//包括给header签名
+ (void)requestSportMeetWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    //这个是不需要拼body和request的接口
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
    NSString *FCStr = [[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"];
    if (!KCNSSTRING_ISEMPTY(FCStr)) {
            path =[FCStr stringByAppendingString:path];
        RX_MKNetworkOperation *operation = [HYTApiClient requestSportMeetWithPath:path headers:nil postBody:data];
        [operation addCompletionHandler:^(RX_MKNetworkOperation *completedOperation) {
            DDLogInfo(@"path is %@, responseString=%@", path,completedOperation.responseString);
            
            NSData *jsonData = [completedOperation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                 
                                                                  error:&err];
            //        [result printJson];
            NSDictionary* response;
            if ([dic hasValueForKey:@"Response"]) {
                response = [dic objectForKey:@"Response"];
            }else{
                
                if([dic hasValueForKey:@"response"])
                {
                    response = [dic objectForKey:@"response"];
                }else
                {
                    response =dic;
                }
                
            }
            //        NSDictionary *head = [NSDictionary dictionary];
            //
            //        if ([response hasValueForKey:@"head"]) {
            //            head = [response objectForKey:@"head"];
            //        }
            
            
            if ([response[@"status"] intValue] >= 0) { // 未知错误
                if (finish) {
                    finish(dic, path);
                }
            }else{
                if (fail) {
                    NSError *error = [NSError errorWithDomain:[dic objectForKey:@"statusMsg"]
                                                         code:[dic objectForKey:@"statusCode"] userInfo:nil];
                    fail(error, path);
                }
            }
        } errorHandler:^(RX_MKNetworkOperation *completedOperation, NSError *error) {
            if (fail) {
                fail(error, path);
            }
        }];
        [[HYTApiClient engine] enqueueOperation:operation];
    }
}

//
///**
// *  获取文件服务器地址
// *
// */
//+ (void)getFileServiceUrldidFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
//    
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[RXUser sharedInstance].appid forKey:@"appId"];
//    
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_GetFileServiceUrl body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
///**
// *  特别关注
// *  取消或者添加特别关注
// *   type 0.增加 1.删除
// *  attectionAccounts 关注的账号
// */
//+ (void)selectSpecialAccount:(NSArray *)attectionAccounts type:(int)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//     NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    [bodyDict setObject:[RXUser sharedInstance].mobile forKey:@"account"];
//    
//   
//    
//    if(attectionAccounts)
//    {
//        [bodyDict setObject:attectionAccounts forKey:@"attentionAccounts"];
//    }
//    
//    [bodyDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
//    
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_SpecialServiceUrl body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *  特别关注
// *  获取自己关注的账号
// *  addRequest 是否是增量更新
// *  account 自己账号
// */
//+ (void)getAllSpecialAtt:(NSString *)account withAddRequest:(BOOL)addRequest didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    if(account)
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    NSString *lastreqtime =@"" ;
//    
//    if(addRequest)
//    {
//       lastreqtime = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAPI_GetSpecialServiceUrl,[RXUser sharedInstance].mobile]];
//    }
//    
//    [bodyDict setObject:KCNSSTRING_ISEMPTY(lastreqtime)?@"":lastreqtime forKey:@"synctime"];
//
//    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetSpecialServiceUrl] body:bodyDict didFinishLoadedMK:^(KXJson *json, NSString *path) {
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[[json  getJsonForKey:@"body"] getStringForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",kAPI_GetSpecialServiceUrl,[RXUser sharedInstance].mobile]];
//        if (finish) {
//            finish(json, path);
//        }
//    } didFailLoadedMK:fail];
//   
//}
//
//
//
//
/**
 *  增加收藏
 *  account 账号
 *  content 收藏内容
 *  type  1,文本 ；2，图片；3，网页；4，语音；5，视频；6，图文
 */

+ (void)addCollectDataWithAccount:(NSString *)account fromAccount:(NSString *)fromAccount TxtContent:(NSString *)txtContent Url:(NSString *)url DataType:(NSString *)type didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (account) {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if (fromAccount) {
        [bodyDict setObject:fromAccount forKey:@"fromAccount"];
    }
    
    if (txtContent) {
        [bodyDict setObject:txtContent forKey:@"txtContent"];
    }
    
    if(url){
        [bodyDict setObject:url forKey:@"url"];
    }
    
    [bodyDict setObject:type forKey:@"type"];
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_AddCollect body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

/**
 *  删除收藏
 *  account 账号
 *  collectIds 收藏id数组
 */

+ (void)deleteCollectDataWithAccount:(NSString *)account CollectIds:(NSArray *)collectIds didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:account forKey:@"account"];
    
    if (collectIds.count > 0) {
        [bodyDict setObject:collectIds forKey:@"collectIds"];
    }
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_DelCollect body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

/**
 *  获取收藏
 *  account 账号
 *  synctime 上次同步时间，为空则为全量
 *  collectId 收藏id
 */

+ (void)getCollectDataWithAccount:(NSString *)account Synctime:(NSString *)synctime CollectId:(NSString *)collectId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{

    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:account forKey:@"account"];
    
    if (synctime) {
        [bodyDict setObject:synctime forKey:@"synctime"];
    }
    if (collectId) {
        [bodyDict setObject:collectId forKey:@"collectId"];
    }
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_GetCollects body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

//// 自定义url
//+ (void)requestWithCustomPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSAssert(path!=nil, @"the url path can't be null");
//    NSDate* date = [NSDate date];
//    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
//    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
//    if (!KCNSSTRING_ISEMPTY([[RXUser sharedInstance] mobile])) {
//        [authorization appendString:[[RXUser sharedInstance] mobile]];
//    }
//    if (!KCNSSTRING_ISEMPTY([[RXUser sharedInstance]clientpwd])) {
//        [authorization appendString:[[RXUser sharedInstance]clientpwd]];
//    }
//    //@"application/json;charset=utf-8;", @"Content-Type",@"application/json",@"Accept",
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
//   // NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
////    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
////    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
//    
//   // NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//   // [requestDict setObject:headDict forKey:@"head"];
//    
////    if (body) {
////        [requestDict setObject:body forKey:@"body"];
////        //[requestDict setObject:@"0" forKey:@"flag"];
////    }
//    KXJson *json = [KXJson jsonWithObject:body];
//    //KXJson *json = [KXJson jsonWithObject:[NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil]];
//    //[json printJson];
//    MKNetworkOperation *operation = [HYTApiClient requestCustomPath:path headers:headers postBody:[[json toJsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        // DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        [result printJson];
//        KXJson *response = nil;
//        if ([result haveJsonValueForKey:@"Response"]) {
//            response = [result getJsonForKey:@"Response"];
//        }else{
//            response = [result getJsonForKey:@"response"];
//        }
//        KXJson *head = [response getJsonForKey:@"head"];
//        NSInteger strCode =[result getIntForKey:@"status"];
//        
//        if ([head getIntForKey:@"statusCode"] == 0 || strCode ==0) { // 未知错误
//            if (finish) {
//                
//                if(strCode==0)
//                {
//                    finish(result, path);
//                }else{
//                    finish(result, path);
//                }
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, path);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, path);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}
////----公众号操作
//
//
///**
// * 公众号置顶功能
// * sig鉴权字段 account+client
// * account 获取账号
// * pnId 获取的公众号信息
// *
// *
// ***/
//
//+ (void)settingPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    if(account)
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    if(pnId)
//    {
//        [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
//    }
//    [HYTApiClient requestWithCustomPathSearchAtAuthorization:[NSString stringWithFormat:@"%@%@%@",KHostURL == 2?[RXUser sharedInstance].friendGroupUrl:PublicUrl,KAPI_PUBLICTOTOPAPI,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// * 公众号取消置顶功能
// * sig鉴权字段 account+client
// * account 获取账号
// * pnId 获取的公众号信息
// *
// *
// ***/
//+ (void)cancelPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    if(account)
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    if(pnId)
//    {
//        [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
//    }
//    [HYTApiClient requestWithCustomPathSearchAtAuthorization:[NSString stringWithFormat:@"%@%@%@",KHostURL == 2?[RXUser sharedInstance].friendGroupUrl:PublicUrl,KAPI_PUBLICCANCELTOP,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// * 获取公众号历史记录
// * sig鉴权字段 account+clientpwd
// * account 获取账号
// * pnId 获取的公众号信息
// * msgSendId 可选 发送消息记录Id 默认为0 此值从缓存中取，取最小值，无缓存置0；
//   值为0时，取最新消息
// * limit 可选 默认10 获取消息条数
// **/
+(void)getPublicHistroyDataSig:(NSString *)sig account:(NSString *)account publicId:(int )pnId msgSendId:(int)msgSendId limit:(int)limit didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];

    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
     
    }
    
    if(pnId)
    {
        [bodyDict setObject:[NSNumber numberWithInt:pnId]forKey:@"pn_id"];
    }
    [bodyDict setObject:[NSNumber numberWithInt:msgSendId] forKey:@"msg_send_id"];
    if(limit>0)
    {
        [bodyDict setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    }
    
    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_GETHISTORYMESSAGELIST,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
//
///**
// * 获取公众号信息
// * sig Md5(account + clientpwd)
// * account 账号
// * pnid 公众号
// * utime 公众号更新时间
// */
+(void)getPublicInfoDataSig:(NSString *)sig account:(NSString*)account publicId:(NSString *)pnId utime:(long long)utime didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
//    sig =@"2361B7F1605F327331F99D8D6EF494AB";
//    account =@"18049261713";
//    utime =@"1481272109787";
//    pnId =@"1";
    
    //@"http://192.168.6.6:8080/ECFC"

    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(pnId)
    {
        [bodyDict setObject:[NSNumber numberWithInteger:[pnId integerValue]]  forKey:@"pn_id"];
    }
    
    if(utime)
    {
        //[bodyDict setObject:utime forKey:@"utime"];
        [bodyDict setObject:[NSNumber numberWithLong:utime] forKey:@"utime"];
    }
    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_GetPublicUrl,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
    
}
//
///**
// *
// *  公众号搜索
// *  account 账号
// *  lPnId 本轮查询中的上次返回数据中最大pn_id
// *  limit 一次获取多少条公众号信息，默认20
// **/
+(void)getPublicSearchDataSig:(NSString *)sig account:(NSString*)account searchStr:(NSString *)searchString publicId:(NSInteger )ipnId limit:(NSInteger)limit didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(!KCNSSTRING_ISEMPTY(searchString))
    {
        [bodyDict setObject:searchString forKey:@"pn_name"];
    }
    [bodyDict setObject:[NSNumber numberWithInteger:ipnId] forKey:@"lPnId"];
    [bodyDict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];

    NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];

    if (dict[Table_User_OrgId]) {
        [bodyDict setObject:dict[Table_User_OrgId] forKey:@"orgId"];
    }
    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_GetSearchPublicUrl,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
    
}
//
///**
// *
// *  关注公众号
// *  account 账号
// *  pnid 公众号Id
// **/
+(void)attentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];

    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
    
    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_ATttPublicNum,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
    
}
///**
// *
// *  取消公众号
// *  account 账号
// *  pnid 公众号Id
// **/
//+(void)cancelAttentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    if(account)
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    
//    [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
//    
//    [HYTApiClient requestWithCustomPathSearchAtAuthorization:[NSString stringWithFormat:@"%@%@%@",KHostURL == 2?[RXUser sharedInstance].friendGroupUrl:PublicUrl,KAPI_DeleteMyAttPublicNum,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//
///**
// *
// *  获取已关注的公众号
// *  account 账号
// **/
+(void)getMyAttentionPublicSig:(NSString *)sig account:(NSString*)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }

    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_GetMyAttPublicNum,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
///**
// *
// *  获取菜单中的消息
// *  account 账号
// *  pnId  公众号ID
// *  msg_id 消息id
// *  sig 鉴权
// **/
//
+(void)getPublicMenuMessage:(NSString *)sig account:(NSString*)account msg_id:(NSString *)msgId publicId:(NSInteger )pnId didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [bodyDict setObject:msgId forKey:@"msglist"];
    
    [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
    
    //PublicUrl http://192.168.178.48.8080/ECFC/pn/getPNmsg/
    [HYTApiClient requestWithCustomPathWithAuthorization:[NSString stringWithFormat:@"%@%@",KAPI_PUBLICMENUMESSAGE,sig] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}


//包括给header签名 自定义搜索url
//+ (void)requestWithCustomPathSearchAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSAssert(path!=nil, @"the url path can't be null");
//    NSDate* date = [NSDate date];
//    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
//    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
//
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
//     NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
//        [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
//        [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
//    
//     NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
//     [requestDict setObject:headDict forKey:@"head"];
//    
//        if (body) {
//            [requestDict setObject:body forKey:@"body"];
//        }
//   // KXJson *json = [KXJson jsonWithObject:requestDict];
//    KXJson *json = [KXJson jsonWithObject:[NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil]];
//    //[json printJson];
//    MKNetworkOperation *operation = [HYTApiClient requestCustomPath:path headers:headers postBody:[[json toJsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        // DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        [result printJson];
//        KXJson *response = nil;
//        if ([result haveJsonValueForKey:@"Response"]) {
//            response = [result getJsonForKey:@"Response"];
//        }else{
//            response = [result getJsonForKey:@"response"];
//        }
//        KXJson *head = [response getJsonForKey:@"head"];
//        NSInteger strCode =[result getIntForKey:@"status"];
//        
//        if ([head getIntForKey:@"statusCode"] == 0 || strCode ==0) { // 未知错误
//            if (finish) {
//                
//                if(strCode==0)
//                {
//                    finish(result, path);
//                }else{
//                    finish(result, path);
//                }
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, path);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, path);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}


//-------好友操作-------
/**
 *
 *  添加好友
 *  type 0/1/2 邀请/接受/拒绝
 *  account 好友account 唯一标示
 *  0/1/2 邀请/接受/拒绝 邀请描述内容
 *
 **/
+(void)addNewFriendAccount:(NSString *)userAccount inviteType:(NSInteger)inviteType descrContent:(NSString *)descrContent didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:[[Common sharedInstance] getAccount] forKey:@"account"];
    
    if(userAccount)
    {
        [bodyDict setObject:userAccount forKey:@"friendAccount"];
    }
    //暂时不需要TYPE 此接口就代表接受邀请操作
    //[bodyDict setObject:[NSNumber numberWithInteger:inviteType] forKey:@"type"];
    
    //[bodyDict setObject:descrContent?descrContent:@"" forKey:@"validMsg"];
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_ADDNewFrien body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
/**
 *
 *  获取邀请历史记录记录接口
 *  account my账号
 *
 **/
+(void)getMyFriendHistorytWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_GetFriendInviteRecord body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

/**
 *
 *  获取自己的好友列表
 *  addRequest 是否增量更新
 *  synctime 同步时间  有值为增量 nil时为全量
 **/
+(void)getMyFriendWithAccount:(NSString *)account synctime:(NSString *)synctime  addRequest:(BOOL)addRequest didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(addRequest)
    {
        synctime = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",KAPI_GetMyFriend,[[Common sharedInstance] getMobile]]];
    }
    
    [bodyDict setObject:KCNSSTRING_ISEMPTY(synctime)?@"":synctime forKey:@"synctime"];
    
    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:KAPI_GetMyFriend] body:bodyDict didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
        [[NSUserDefaults standardUserDefaults] setObject:[[json  objectForKey:@"body"] objectForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",KAPI_GetMyFriend,[[Common sharedInstance] getMobile]]];
        if (finish) {
            finish(json, path);
        }
    } didFailLoadedMK:^(NSError *error, NSString *path) {
        DDLogError(@"失败+++++++++%@",error);
    }];
    
    //    [HYTApiClient requestWithPathAtAuthorization:[NSString stringWithFormat:KAPI_GetMyFriend] body:bodyDict didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
    //
    //        [[NSUserDefaults standardUserDefaults] setObject:[[json  objectForKey:@"body"] objectForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",KAPI_GetMyFriend,[[Common sharedInstance] getMobile]]];
    //        if (finish) {
    //            finish(json, path);
    //        }
    //    } didFailLoadedMK:fail];
}

/**
 *
 *  删除好友
 *  account 删除账号
 *
 **/
+(void)deleteMyFriendWithAccount:(NSString *)account friendAccounts:(NSArray *)friendAccounts  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [bodyDict setObject:friendAccounts forKey:@"friendAccounts"];
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_DeleteMyFriend body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}
//
///**
// *
// *  搜索用户
// *  account 账号
// *  keyword 关键词
// *  pageSize 每页显示多少条，默认10条
// *  currentPage 当前页数
// **/
//+(void)searchUserInfoWithAccount:(NSString *)account KeyWord:(NSString *)keyword PageSize:(NSInteger)pageSize CurrentPage:(NSInteger)currentPage didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
//
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    [bodyDict setObject:account forKey:@"account"];
//    [bodyDict setObject:keyword forKey:@"keyword"];
//    
//    if([[DeviceDelegateHelper sharedInstance] isPureNumandCharacters:keyword]) {
//        [bodyDict setObject:@"2" forKey:@"searchType"];//手机号
//    }else{
//        [bodyDict setObject:@"1" forKey:@"searchType"];//用户姓名
//    }
//    
//    if (pageSize) {
//        [bodyDict setObject:[NSString stringWithFormat:@"%ld",(long)pageSize] forKey:@"pageSize"];
//    }
//    if (currentPage) {
//        [bodyDict setObject:[NSString stringWithFormat:@"%ld",(long)currentPage] forKey:@"currentPage"];
//    }
//    
//    
//    [HYTApiClient requestWithPathAtAuthorization:KAPI_SearchUser body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// * 获取历史消息记录   个人聊天
// * appId           应用Id  必选
// * userName        登录帐号 必选
// * version         消息版本号 可选
// * msgId           消息Id version和msgId两个参数二选一，都传则以version为准 可选
// * pageSize        获取消息条数，最多100条。默认10条 可选
// * talker          交互者账号 必选
// * order           1.升序 2.降序 默认1  可选
// **/
//
//+(void)getHistoryMyChatMessageWithAccount:(NSString *)userName withAppid:(NSString *)appid version:(long long)version msgId:(NSString *)msgId pageSize:(NSInteger)pageSize talker:(NSString *)talker order:(NSInteger)order  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail {
//
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    if(appid)
//    {
//        [bodyDict setObject:appid forKey:@"appId"];
//    }
//        
//    if(!KCNSSTRING_ISEMPTY(msgId))
//    {
//        [bodyDict setObject:msgId forKey:@"msgId"];
//    }
//    
//    if(pageSize>0)
//    {
//        [bodyDict setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
//    }
//    
//    if(version>0)
//    {
//    
//        [bodyDict setObject:[NSNumber numberWithLongLong:version] forKey:@"version"];
//        
////        [bodyDict setObject:userName forKey:@"talker"];
////        if(userName)
////        {
////            [bodyDict setObject:talker forKey:@"userName"];
////        }
//        
//    }
//    
//    if(talker)
//    {
//       
//        [bodyDict setObject:talker forKey:@"talker"];
//    }
//    
//    if(userName)
//    {
//        [bodyDict setObject:userName forKey:@"userName"];
//    }
//    
//   
//    [bodyDict setObject:[NSNumber numberWithInteger:order] forKey:@"order"];
//    
//
//    NSString *httpStr = @"http";
//    
//    if([RXUser sharedInstance].restHost && [[RXUser sharedInstance].restHost hasSuffix:@"8883"])
//    {
//        httpStr = @"https";
//    }
//    //@"http://10.3.143.19:8881/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig="
//    //[NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[RXUser sharedInstance].restHost,[RXUser sharedInstance].appid]  [NSString stringWithFormat:KApi_GetHistroyMessage,[RXUser sharedInstance].appid]
//    
//    
//    [HYTApiClient requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[RXUser sharedInstance].restHost,[RXUser sharedInstance].appid]  body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//    
//}
//
///**
// * 获取消息记录        群组操作
// * appid             应用ID
// * groupId           群组ID
// * startTime         开始时间
// * endTime           结束时间
// * pageNo            页码 缺省第一页
// * pageSize          每页条数，最多100条 缺省100条
// * msgDecompression  返回的消息内容是否解压。0、不解压 1、解压 缺省0
// **/
//
//+ (void)getHistoryGroupListMessageGroupId:(NSString *)groupId startTime:(NSString *)startTime endTime:(NSString *)endTime pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize msgDecompression:(NSString *)msgDecompression didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//   if([RXUser sharedInstance].appid)
//   {
//       [bodyDict setObject:[RXUser sharedInstance].appid forKey:@"appId"];
//   }
//    if(groupId)
//    {
//        [bodyDict setObject:groupId forKey:@"groupId"];
//    }
//    
//    if(startTime)
//    {
//        [bodyDict setObject:startTime forKey:@"startTime"];
//
//    }
//    
//    if(endTime)
//    {
//        [bodyDict setObject:endTime forKey:@"endTime"];
//    }
//    
//    if(pageNo)
//    {
//        [bodyDict setObject:pageNo forKey:@"pageNo"];
//
//    }
//    
//    if(pageSize)
//    {
//        [bodyDict setObject:pageSize forKey:@"pageSize"];
//
//    }
//    
//    if(msgDecompression)
//    {
//        [bodyDict setObject:msgDecompression forKey:@"msgDecompression"];
//
//    }
//    
//    NSString *httpStr = @"http";
//    
//    if([RXUser sharedInstance].restHost && [[RXUser sharedInstance].restHost hasSuffix:@"8883"])
//    {
//       httpStr = @"https";
//    }
//    //@"http://10.3.143.19:8881/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig="
//    //[NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[RXUser sharedInstance].restHost,[RXUser sharedInstance].appid];[NSString stringWithFormat:KApi_GetHistroyMessage,[RXUser sharedInstance].appid]
//    
//    
//    
//     [HYTApiClient requestGetHistoryMessagePathAtAuthorization:[NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[RXUser sharedInstance].restHost,[RXUser sharedInstance].appid] body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
//
//
////获取历史消息head签名
//+ (void)requestGetHistoryMessagePathAtAuthorization:(NSString *)path body:(NSDictionary *)body didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSAssert(path!=nil, @"the url path can't be null");
//    
//    NSDate* date = [NSDate date];
//    
//    NSString *authorization =[NSString stringWithFormat:@"%@:%@",[RXUser sharedInstance].appid,[HYTApiClient requestTime:date]];
//    
//     NSString * sigStr = [[NSString stringWithFormat:@"%@%@%@",[RXUser sharedInstance].appid,[RXUser sharedInstance].apptoken,[HYTApiClient requestTime:date]] MD5EncodingString];
//    
//    NSString *urlPath =[NSString stringWithFormat:@"%@%@",path,sigStr];
//    
//    [DemoGlobalClass sharedInstance].historyMessageUrl =urlPath;
//    
//    NSDictionary *headers =[NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8",@"Content-Type",@"application/json",@"accept",[authorization base64EncodingString],@"Authorization", nil];
//    
////    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
////    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
////    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
////    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
////    [requestDict setObject:headDict forKey:@"head"];
////    
////    if (body) {
////        [requestDict setObject:body forKey:@"body"];
////    }
//    
//    NSData *bodyData =[NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
//    
//   // KXJson *json = [KXJson jsonWithObject:[NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil]];
//    
//    MKNetworkOperation *operation = [HYTApiClient requestCustomPath:urlPath headers:headers postBody:bodyData];
//    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
//        // DDLogInfo(@"responseString=%@", completedOperation.responseString);
//        KXJson *result = [KXJson jsonWithJsonString:completedOperation.responseString];
//        [result printJson];
//        KXJson *response = nil;
//        if ([result haveJsonValueForKey:@"Response"]) {
//            response = [result getJsonForKey:@"Response"];
//        }else{
//            
//            if([result haveJsonValueForKey:@"response"])
//            {
//                response = [result getJsonForKey:@"response"];
//            }else
//            {
//                response =result;
//            }
//            
//        }
//        KXJson *head = [response getJsonForKey:@"head"];
//        if ([head getIntForKey:@"statusCode"] == 0) { // 未知错误
//            if (finish) {
//                finish(response, path);
//            }
//        }else{
//            if (fail) {
//                NSError *error = [NSError errorWithDomain:[head getStringForKey:@"statusMsg"]
//                                                     code:[head getIntForKey:@"statusCode"] userInfo:nil];
//                fail(error, path);
//            }
//        }
//    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
//        if (fail) {
//            fail(error, path);
//        }
//    }];
//    [[HYTApiClient engine] enqueueOperation:operation];
//}
//
//
///**
// *  获取红包签名
// *  account 账号
// */
//+ (void)getRedpacketSignWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail {
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    [bodyDict setObject:account forKey:@"account"];
//    
//    [HYTApiClient requestWithPathAtAuthorization:kAPI_GetRedpacketSign body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *
// * 获取图片验证码
// * account 账号
// * 900363 开始获取验证码
// *
// **/
//+ (void)getLoginImageCodeWithUuid:(NSString *)uuid didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//
//    [bodyDict setObject:uuid forKey:@"codeKey"];
//    
//    [HYTApiClient requestWithPathAtAuthorization:KAPI_GetImageCode body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *
// * 获取线下终端会议室
// * account 唯一标识
// *
// **/
//+ (void)getOfflineRoomsWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    [bodyDict setObject:account forKey:@"account"];
//    
//    [HYTApiClient requestWithPathAtAuthorization:KAPI_GetOfflineRooms body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}
//
///**
// *
// * 检查鉴权
// * account 唯一标识
// *
// **/
//+ (void)checkAuthWithAccount:(NSString *)account didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    
//    [bodyDict setObject:account forKey:@"account"];
//    
//    [HYTApiClient requestWithPathAtAuthorization:KAPI_CheckAuth body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
//}


//#pragma mark 包括给head body 自定义url 1.获取关注的公众账号2.公共号消息;3.获取历史消息;4.搜索公众号
+ (void)requestWithCustomPathWithAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    NSDate* date = [NSDate date];
    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:headDict forKey:@"head"];
    
    if (body) {
        [requestDict setObject:body forKey:@"body"];
    }
    
    NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil];
    //    NSString *postJsonString = [postDic coverString];
    NSData *data = [NSJSONSerialization dataWithJSONObject:postDic options:NSJSONWritingPrettyPrinted error:nil];;
    //    NSData *data = [postJsonString dataUsingEncoding:NSUTF8StringEncoding];
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"]) {
        NSString *requestURL = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"]];
        if (!KCNSSTRING_ISEMPTY(requestURL)) {
            path = [requestURL stringByAppendingString:path];
            RX_MKNetworkOperation *operation = [HYTApiClient requestCustomPath:path headers:headers postBody:data];
            [operation addCompletionHandler:^(RX_MKNetworkOperation *completedOperation) {
                DDLogInfo(@"path is %@,     req postDic is %@,    responseString=%@", path,postDic,completedOperation.responseString);
                NSData *jsonData = [completedOperation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                NSDictionary* response;
                if ([dic hasValueForKey:@"Response"]) {
                    response = [dic objectForKey:@"Response"];
                }else{
                    
                    if([dic hasValueForKey:@"response"])
                    {
                        response = [dic objectForKey:@"response"];
                    }else
                    {
                        response =dic;
                    }
                    
                }
                NSDictionary *head = [NSDictionary dictionary];
                
                if ([response hasValueForKey:@"head"]) {
                    head = [response objectForKey:@"head"];
                }
                
                
                if ([response[@"status"] intValue] >= 0) { // 未
                    if (finish) {
                        finish(dic, path);
                    }
                }else{
                    if (fail) {
                        NSError *error = nil;
                        
                        if ([head hasValueForKey:@"statusMsg"]&&[head hasValueForKey:@"statusCode"] ) {
                            error = [NSError errorWithDomain:[head objectForKey:@"statusMsg"]
                                                        code:[head objectForKey:@"statusCode"] userInfo:nil];
                        }
                        fail(error, path);
                    }
                }
            } errorHandler:^(RX_MKNetworkOperation *completedOperation, NSError *error) {
                if (fail) {
                    fail(error, path);
                }
            }];
            [[HYTApiClient engine] enqueueOperation:operation];
        }
    }

}
//自定义url  不需要拼接如何端口 http
+ (void)requestCustomUrlPathWithAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    NSDate* date = [NSDate date];
    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
   
    RX_MKNetworkOperation *operation = [HYTApiClient requestCustomPath:path headers:headers postBody: [[body convertToString] dataUsingEncoding:NSUTF8StringEncoding]];
    [operation addCompletionHandler:^(RX_MKNetworkOperation *completedOperation) {
        DDLogInfo(@"path is %@,responseString=%@", path,completedOperation.responseString);
        NSData *jsonData = [completedOperation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                             
                                                              error:&err];
        //        [result printJson];
        NSDictionary* response;
        if ([dic hasValueForKey:@"Response"]) {
            response = [dic objectForKey:@"Response"];
        }else{
            
            if([dic hasValueForKey:@"response"])
            {
                response = [dic objectForKey:@"response"];
            }else
            {
                response =dic;
            }
            
        }
        NSDictionary *head = [NSDictionary dictionary];
        
        if ([response hasValueForKey:@"head"]) {
            head = [response objectForKey:@"head"];
        }
        
        
        if ([response[@"status"] intValue] >= 0) { // 未
            if (finish) {
                finish(dic, path);
            }
        }else{
            if (fail) {
                NSError *error = nil;
                
                if ([head hasValueForKey:@"statusMsg"]&&[head hasValueForKey:@"statusCode"] ) {
                    error = [NSError errorWithDomain:[head objectForKey:@"statusMsg"]
                                                code:[head objectForKey:@"statusCode"] userInfo:nil];
                }
                fail(error, path);
            }
        }
    } errorHandler:^(RX_MKNetworkOperation *completedOperation, NSError *error) {
        if (fail) {
            fail(error, path);
        }
    }];
    [[HYTApiClient engine] enqueueOperation:operation];
}

//包括给header签名
+ (void)requestWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    NSDate* date = [NSDate date];
    NSString* requestTime =  [HYTApiClient requestGMTTime:date];
    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    if (!KCNSSTRING_ISEMPTY([[Common sharedInstance] getAccount])) {
        [authorization appendString:[[Common sharedInstance] getAccount]];
    }
    if (!KCNSSTRING_ISEMPTY([[Common sharedInstance] getAppClientpwd])) {
        [authorization appendString:[[Common sharedInstance] getOneClientPassWord]];
    }
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8;", @"Content-Type", requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[HYTApiClient userAgent] forKey:@"useragent"];
    [headDict setObject:[HYTApiClient requestTime:date] forKey:@"reqtime"];
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:headDict forKey:@"head"];
    
    if (body) {
        [requestDict setObject:body forKey:@"body"];
        //[requestDict setObject:@"0" forKey:@"flag"];
    }
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil];
    NSString *currentURL = [self getCurrentUrlString];
    if (!KCNSSTRING_ISEMPTY(currentURL)) {
        path = [currentURL stringByAppendingString:path];
    }
    RX_MKNetworkOperation *operation = [HYTApiClient requestCustomPath:path headers:headers postBody:[[postDict convertToString] dataUsingEncoding:NSUTF8StringEncoding]];
    [operation addCompletionHandler:^(RX_MKNetworkOperation *completedOperation) {
        // DDLogInfo(@"responseString=%@", completedOperation.responseString);
        //        NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:completedOperation.responseString, nil];
        DDLogInfo(@"path is %@, req postDic is %@,responseString=%@", path,postDict,completedOperation.responseString);
        NSData *jsonData = [completedOperation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                               options:NSJSONReadingMutableContainers
                                
                                                                 error:&err];
        //        [result printJson];
        NSDictionary *response = nil;
        
        if ([result hasValueForKey:@"Response"]) {
            response = [result objectForKey:@"Response"];
        }else{
            response = [result objectForKey:@"response"];
        }
        NSDictionary *head = [response objectForKey:@"head"];
        if ([response[@"status"] intValue] >= 0) { // 未
            if (finish) {
                finish(response, path);
            }
        }else{
            if (fail) {
                NSError *error = [NSError errorWithDomain:[head objectForKey:@"statusMsg"]
                                                     code:[head objectForKey:@"statusCode"] userInfo:nil];
                fail(error, path);
            }
        }
    } errorHandler:^(RX_MKNetworkOperation *completedOperation, NSError *error) {
        if (fail) {
            fail(error, path);
        }
    }];
    [[HYTApiClient engine] enqueueOperation:operation];
}

+(NSString *)getCurrentUrlString{
    NSString *requestURL = nil;
    NSString *currentUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"kitAppIP"];
    
    BOOL IPChanged =  [[[NSUserDefaults standardUserDefaults]objectForKey:@"HaveChangedIPWithRonglian"]boolValue];
    if (IPChanged && !KCNSSTRING_ISEMPTY(currentUrl) && !kSwitchPBSURL) {
        requestURL = currentUrl;
    }else{
        requestURL = [NSString stringWithFormat:@"%@://%@:%d",kRequestHttp,kHOST,kPORT];

    }
    return requestURL;
}



#pragma mark 恒丰新增 wjy
//文件加密处理接口

//获取加密文件uuid和key请求
/*应答
 * "fileNodeId": "43cf185192ea4082a624f4a1ec78bbcc",*
 " fileKey": "5192ea4082a624f4a1ec78bbcc"*
 */

+ (void)getFileNodelIdAndKeyWithAccount:(NSString *)account didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_File_getNodelIdAndKey body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

//获取加密文件的key请求
+(void)getKeyByFileNodeIdWithAccount:(NSString *)account withNodeId:(NSString *)fileNodeId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(fileNodeId)
    {
        [bodyDict setObject:fileNodeId forKey:@"fileNodeId"];
        
    }
    
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_File_getKeyByNodeId body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}


+ (void)speedPunchWithAccount:(NSString *)account withAddressName:(NSString *)addrename withLongitude:(double)longitude withFdimension:(double)fdimension altitude:(double)altitude orgId:(NSInteger)orgId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(addrename)
    {
        [bodyDict setObject:addrename forKey:@"addrename"];
    }
    
    [bodyDict setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [bodyDict setObject:[NSNumber numberWithDouble:fdimension] forKey:@"fdimension"];
    [bodyDict setObject:[NSNumber numberWithDouble:altitude] forKey:@"altitude"];
    [bodyDict setObject:[NSNumber numberWithInteger:orgId] forKey:@"orgId"];
    [bodyDict setObject:[NSNumber numberWithInteger:2] forKey:@"device_type"];
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if(uuid)
    {
        [bodyDict setObject:uuid forKey:@"deviceuuid"];
    }
    
    NSString *MacWifi = [HYTApiClient getWiFiMac];
    
    if(MacWifi)
    {
        [bodyDict setObject:MacWifi forKey:@"wifimac"];
    }
    
    NSString *wifissid  = [HYTApiClient getMacSsid];
    if(wifissid)
    {
        [bodyDict setObject:wifissid forKey:@"wifissid"];
    }    
    
    if (IsHengFengTarget) {
        [HYTApiClient requestCustomUrlPathWithAuthorization:KAPI_SpeedPunchUrl body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
    }
    else
    {
        NSString* strUrl = [NSString stringWithFormat:@"%@/asi/jsdkadd", [RxAppStoreData getAppUrl:5]];
        [HYTApiClient requestCustomUrlPathWithAuthorization:strUrl body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
    }
    
}


+ (NSString *)getWiFiMac
{
    CFArrayRef myArray =CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict =CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray,0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            return [dict valueForKey:@"BSSID"];     //Mac地址
        }
    }
    
    return nil;
}

+ (NSString *)getMacSsid
{
    CFArrayRef myArray =CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict =CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray,0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            return [dict valueForKey:@"SSID"];     //Mac地址
        }
    }
    
    return nil;
}


//获取banner图的请求
/**
 * account 用户标识
 * time 更新时间
 */
+(void)getBannersWithAccount:(NSString *)account withUpdateTime:(NSString *)time didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(time)
    {
        [bodyDict setObject:time forKey:@"update_time"];
        
    }else
    {
        [bodyDict setObject:@"0" forKey:@"update_time"];
    }
    
    
    [HYTApiClient requestWithPathAtAuthorization:KAPI_GetBanners body:bodyDict didFinishLoadedMK:finish didFailLoadedMK:fail];
}

#pragma mark --------- 直播相关接口

//#define kLiveStreamUrl(url) [NSString stringWithFormat:@"http://%@:8094/v1/application/%@/livestream/%@",kHOST,[Common sharedInstance].getAppid,url]
//#define kLiveStreamUrl(url) [NSString stringWithFormat:@"http://%@:8088/v1/application/%@/livestream/%@",@"47.93.125.35",@"test",url]
#define kLiveStreamUrl(url) [NSString stringWithFormat:@"http://%@:8088/v1/application/%@/livestream/%@",@"47.93.125.35",@"ytxdemo",url]

+ (void)createChannelWithUid:(NSString *)uid Name:(NSString *)name didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail {
    
    NSMutableDictionary * body = [NSMutableDictionary dictionaryWithCapacity:0];
    if (uid) {
        [body setValue:uid forKey:@"uid"];
    }
    if (name) {
        [body setValue:name forKey:@"name"];
    }
    
    [HYTApiClient requestCustomUrlPathWithAuthorization:kLiveStreamUrl(@"createChannel") body:body didFinishLoadedMK:finish didFailLoadedMK:fail];
}

+ (void)createChannelWithUid:(NSString *)uid Name:(NSString *)name  description:(NSString *)description channelCover:(NSString *)channelCover  didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail {
    NSMutableDictionary * body = [NSMutableDictionary dictionaryWithCapacity:0];
    if (uid) {
        [body setValue:uid forKey:@"uid"];
    }
    if (name) {
        [body setValue:name forKey:@"name"];
    }
    
    if (description) {
        [body setValue:description forKey:@"description"];
    }
    
    if (channelCover) {
        [body setValue:channelCover forKey:@"channelCover"];
    }
    
    [HYTApiClient requestCustomUrlPathWithAuthorization:kLiveStreamUrl(@"createChannel") body:body didFinishLoadedMK:finish didFailLoadedMK:fail];
}

+ (void)getPushUrlsWithUid:(NSString *)uid ChannelId:(NSString *)channelId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail {
    
    NSMutableDictionary * body = [NSMutableDictionary dictionaryWithCapacity:0];
    if (uid) {
        [body setValue:uid forKey:@"uid"];
    }
    if (channelId) {
        [body setValue:channelId forKey:@"channelId"];
    }
    
    [HYTApiClient requestCustomUrlPathWithAuthorization:kLiveStreamUrl(@"getPushUrls") body:body didFinishLoadedMK:finish didFailLoadedMK:fail];
}

+ (void)getChannelListWithStatus:(NSString *)status Uid:(NSString *)uid PageNo:(NSInteger)pageNo PageSize:(NSInteger)pageSize didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail{

    NSMutableDictionary * body = [NSMutableDictionary dictionaryWithCapacity:0];
    if (status) {
        [body setValue:status forKey:@"status"];
    }
    if (uid) {
        [body setValue:uid forKey:@"uid"];
    }
    if (pageNo) {
        [body setValue:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    }
    if (pageSize) {
        [body setValue:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    }
    
    [HYTApiClient requestCustomUrlPathWithAuthorization:kLiveStreamUrl(@"channelList") body:body didFinishLoadedMK:finish didFailLoadedMK:fail];
}

+ (void)getPlayUrlsWithUid:(NSString *)uid ChannelId:(NSString *)channelId didFinishLoaded:(didFinishLoadedMK)finish didFailLoaded:(didFailLoadedMK)fail {
    
    NSMutableDictionary * body = [NSMutableDictionary dictionaryWithCapacity:0];
    if (uid) {
        [body setValue:uid forKey:@"uid"];
    }
    if (channelId) {
        [body setValue:channelId forKey:@"channelId"];
    }
    
    [HYTApiClient requestCustomUrlPathWithAuthorization:kLiveStreamUrl(@"getPlayUrls") body:body didFinishLoadedMK:finish didFailLoadedMK:fail];
}

#pragma mark  - gy
//上传应用商店的文件
+ (void)upLoadStoreAppFile:(NSArray <NSData *>*)datas withUploadUrl:(NSString *)uploadUrl withHead:(NSDictionary *)headDic didFinishLoadedMK:(didFinishLoadedMK)finish didFailLoadedMK:(didFailLoadedMK)fail
{
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    AFHTTPSessionManager *manager = [Common sharedInstance].sharedHTTPSession;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    if (headDic.count>0) {
        [headDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //2.上传文件
    [manager POST:uploadUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSData *data in datas) {
            NSString *imgName = [NSString stringWithFormat:@"%@.jpg",[[NSString uuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            //上传文件参数
            [formData appendPartWithFileData:data
                                        name:@"file"
                                    fileName:imgName
                                    mimeType:@"image/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //打印上传进度
        //        CGFloat progress = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        //        DLog(@"%.2lf%%", progress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功
        //        DLog(@"请求成功：%@",responseObject);
        !finish?:finish(responseObject,uploadUrl);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        NSDictionary *userInfo = error.userInfo;
        //        NSData *data = userInfo[@"com.alamofire.serialization.response.error.data"];
        //        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //请求失败
        //        DLog(@"请求失败：%@",error);
        !fail?:fail(error,uploadUrl);
    }];
    
    
}

@end
