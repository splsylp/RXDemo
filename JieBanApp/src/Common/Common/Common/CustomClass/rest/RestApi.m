//
//  Created by wangming on 16/7/18.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RestApi.h"
#import "RXThirdPart.h"
#import "KCConstants_API.h"
#import "KCConstants_string.h"
#import "NSString+Ext.h"
#import "RX_MKNetworkOperation.h"
#import "HYTApiClient.h"
#import "UIAlertView+Ext.h"
#import "RXCollectData.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "UIImage+deal.h"

#define  SettingAFRequestTimeOUT  15

@interface RestApi()

@property(nonatomic,strong) AFHTTPSessionManager* manager;

@property(nonatomic,copy) NSString* account;
@property(nonatomic,copy) NSString* clientpwd;
@property(nonatomic,copy) NSString* appkey;
@property(nonatomic,copy) NSString* apptoken;
@property(nonatomic,copy) NSString* mobile;
@end


@implementation RestApi

+ (RestApi *)sharedInstance
{
    static dispatch_once_t onceToken;
    static RestApi *shareEngine;
    dispatch_once(&onceToken, ^ {
        shareEngine = [[RestApi alloc] init];
        shareEngine.manager = [AFHTTPSessionManager manager];
        shareEngine.manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        shareEngine.manager.securityPolicy.allowInvalidCertificates = YES;
        shareEngine.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        shareEngine.manager.responseSerializer = [AFJSONResponseSerializer serializer];
        shareEngine.manager.securityPolicy.validatesDomainName = NO; // 关键语句1
        shareEngine.manager.securityPolicy.allowInvalidCertificates = YES; // 关键语句2

        if ([Common sharedInstance].componentDelegate && [[Common sharedInstance].componentDelegate respondsToSelector:NSSelectorFromString(@"onGetUserInfo")]) {
            NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];
            if (dict) {
                shareEngine.account = [dict objectForKey:Table_User_account];
                shareEngine.clientpwd = [dict objectForKey:App_Clientpwd];
                shareEngine.appkey = [dict objectForKey:App_AppKey];
                shareEngine.apptoken = [dict objectForKey:App_Token];
                shareEngine.mobile = [dict objectForKey:Table_User_mobile];
            }
        }
        [shareEngine.manager.responseSerializer.acceptableContentTypes intersectsSet:[NSSet setWithObject:@"text/html"]];
    });
    return shareEngine;
}


+(void)showErrorDomain:(NSError *)errorDomain
{
    
    
    if(errorDomain.code==900005)
    {
        [SVProgressHUD dismiss];
        
        //鉴权失败
        
        [UIAlertView showAlertView:languageStringWithKey(@"提示") message:languageStringWithKey(@"该账号身份已过期，请重新登录") click:nil okText:languageStringWithKey(@"确定")];
        
        return;
    }
#if DEBUG
    [SVProgressHUD showErrorWithStatus:[RestApi errorDomain:[NSString stringWithFormat:@"%@%ld",errorDomain.domain,(long)errorDomain.code] withErrorPrompt:languageStringWithKey([errorDomain localizedDescription])]];//[errorDomain localizedDescription]
#else
    [SVProgressHUD showErrorWithStatus:[RestApi errorDomain:errorDomain.domain withErrorPrompt:languageStringWithKey([errorDomain localizedDescription])]];
    
#endif
    
    //[ATMHud showMessage:[HYTApiClient errorDomain:errorDomain.domain withErrorPrompt:[errorDomain localizedDescription]]];
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

+(NSString *)errorDomain:(NSString *)errDomain withErrorPrompt:(NSString *)prompt
{
    if([errDomain rangeOfString:@"NSURLErrorDomain"].location!=NSNotFound)
    {
        return prompt;
    }
    
    return errDomain;
}
+ (void)handlerErrorCode:(int)errorcode
{
    [SVProgressHUD showErrorWithStatus:[RestApi errorMessage:errorcode]];
}

+ (NSString *)errorMessage:(int)errorcode
{
    switch (errorcode) {
        case 111003:
            return languageStringWithKey(@"没有权限");
        case 111010:
            return languageStringWithKey(@"没有授权");
        case 111200:
            return languageStringWithKey(@"备份个人联系人失败");
        case 111201:
            return languageStringWithKey(@"备份个人通讯录，写文件失败");
        case 111300:
            return languageStringWithKey(@"下载联系人失败");
        case 111301:
            return languageStringWithKey(@"下载联系人读文件失败");
        case 111400:
            return languageStringWithKey(@"下载企业通讯录，存储执行失败");
        case 111401:
            return languageStringWithKey(@"下载企业通讯录，读通讯录文件失败");
        case 111402:
            return languageStringWithKey(@"下载企业通讯录，无更新，不需要下载");
        case 111403:
            return languageStringWithKey(@"下载企业通讯录，用户不属于任何企业");
        case 111500:
            return languageStringWithKey(@"确认加入企业，存储执行失败");
        case 111501:
            return languageStringWithKey(@"已确认加入企业");
        case 111600:
            return languageStringWithKey(@"设置个人用户信息，存储执行失败");
        case 111601:
            return languageStringWithKey(@"设置个人用户信息，写文件失败");
        case 111700:
            return languageStringWithKey(@"存储执行失败");
        case 111701:
            return languageStringWithKey(@"账号或密码错误");
        case 111702:
            return languageStringWithKey(@"注册失败，创建子账号失败");
        case 111703:
            return languageStringWithKey(@"登录失败");
        case 111704:
            return languageStringWithKey(@"不存在此账号");
        case 111800:
            return languageStringWithKey(@"获取短信验证码，存储执行失败");
        case 111801:
            return languageStringWithKey(@"获取短信验证码，次数超限，每个号码每天只允许三次");
        case 111802:
            return languageStringWithKey(@"获取短信验证码，用户状态异常");
        case 111900:
            return languageStringWithKey(@"获取企业审核状态，存储执行失败");
        default:
            return languageStringWithKey(@"网络异常");
    }
}

-(void)setAccountDict:(NSDictionary*)dict{
    self.account = [dict objectForKey:Table_User_account];
    self.clientpwd = [dict objectForKey:App_Clientpwd];
    self.appkey = [dict objectForKey:App_AppKey];
    self.apptoken = [dict objectForKey:App_Token];
    self.mobile = [dict objectForKey:Table_User_mobile];
}

+ (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (void)requestGet:(NSString *)path params:(NSDictionary *)params didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    [self requestGet:path params:params progress:nil didFinishLoaded:finish didFailLoaded:fail];
}

- (void)requestGet:(NSString *)path  params:(NSDictionary *)params progress:(void (^)(NSProgress * _Nonnull))progress didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    [[RestApi sharedInstance].manager GET:path parameters:params progress:^(NSProgress * _Nonnull progress) {
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* dict = [NSDictionary dictionaryWithDictionary:responseObject];
        DDLogInfo(@"path=%@,Response=%@",path,dict);
        finish(dict,path);
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        DDLogInfo(@"path=%@,errorCode=%d,des=%@",path,(int)error.code,error.description);
        fail(error,path);
    }];
}


- (void)requestPost:(NSString *)path  params:(NSDictionary *)params didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSLog(@"网络请求 path = %@ , params = %@",path,params);
    [self requestPost:path params:params progress:nil didFinishLoaded:finish didFailLoaded:fail];
}

- (void)requestPost:(NSString *)path params:(NSDictionary *)params progress:(void (^)(NSProgress * _Nonnull))progress didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    [[RestApi sharedInstance].manager POST:path parameters:params progress:^(NSProgress * _Nonnull progress) {
    
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
        DDLogInfo(@"path=%@,Response=%@",path,dict);
        if (finish) {
            finish(dict,path);
        }
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        DDLogInfo(@"path=%@,errorCode=%d,des=%@",path,(int)error.code,error.description);
        fail(error,path);
    }];
}

//包括给header签名
+ (void)requestWithPathAtAuthorization:(NSString *)path body:(NSDictionary *)body  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    NSDate* date = [NSDate date];
    NSString* requestTime =  [RestApi requestGMTTime:date];
    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    if (!KCNSSTRING_ISEMPTY([Common sharedInstance].getAccount)) {
        [authorization appendString:[Common sharedInstance].getAccount];
    }
//    if (!KCNSSTRING_ISEMPTY([[RestApi sharedInstance] mobile])) {
//        [authorization appendString:[[RestApi sharedInstance] mobile]];
//    }
    if (!KCNSSTRING_ISEMPTY([Common sharedInstance].getOneClientPassWord)) {
        [authorization appendString:[Common sharedInstance].getOneClientPassWord];
    }
    
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8;", @"Content-Type", requestTime,@"Date",[[authorization MD5EncodingString]lowercaseString],@"Authorization",nil];
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[RestApi userAgent] forKey:@"useragent"];
    [headDict setObject:[RestApi requestTime:date] forKey:@"reqtime"];

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:headDict forKey:@"head"];
    
    if (body) {
        [requestDict setObject:body forKey:@"body"];
    }
    
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:[[authorization MD5EncodingString]lowercaseString] forHTTPHeaderField:@"Authorization"];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;
    NSMutableDictionary *parmsDict = [NSMutableDictionary dictionary];
    [parmsDict setObject:requestDict forKey:@"Request"];
    
    NSString *currentURL = [self getCurrentUrlString];
    if (!KCNSSTRING_ISEMPTY(currentURL)) {
          NSLog(@"准备网络请求 path = %@ , parmsDict = %@",path,parmsDict);
        [[RestApi sharedInstance] requestPost:[NSString stringWithFormat:@"%@%@",currentURL,path] params:parmsDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            if (finish) {
                if ([dict hasValueForKey:@"Response"]) {
                    finish([dict objectForKey:@"Response"], path);
                }else {
                    finish(dict, path);
                }
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (fail) {
                fail(error, path);
            }
        }];
    }
}

+ (void)requestWithPath:(NSString *)path body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSDate* date = [NSDate date];
    NSString* requestTime =  [RestApi requestGMTTime:date];
    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    if (!KCNSSTRING_ISEMPTY([Common sharedInstance].getAccount)) {
        [authorization appendString:[Common sharedInstance].getAccount];
    }
    if (!KCNSSTRING_ISEMPTY([Common sharedInstance].getOneClientPassWord)) {
        [authorization appendString:[Common sharedInstance].getOneClientPassWord];
    }
    
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[RestApi userAgent] forKey:@"useragent"];
    [headDict setObject:[RestApi requestTime:date] forKey:@"reqtime"];
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:headDict forKey:@"head"];
    
    if (body) {
        [requestDict setObject:body forKey:@"body"];
    }
    
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:[[authorization MD5EncodingString]lowercaseString] forHTTPHeaderField:@"Authorization"];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;

    NSMutableDictionary *parmsDict = [NSMutableDictionary dictionary];
    [parmsDict setObject:requestDict forKey:@"Request"];

    NSString *currentURL = [RestApi  getCurrentUrlString];
    if (!KCNSSTRING_ISEMPTY(currentURL)) {
        [[RestApi sharedInstance] requestPost:[NSString stringWithFormat:@"%@%@",currentURL,path] params:parmsDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            if (finish) {
                finish([dict objectForKey:@"Response"], path);
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (fail) {
                fail(error, path);
            }
        }];
    }
}

- (void)userLoginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[RestApi  countryCode] forKey:@"countrycode"];
    [bodyDict setObject:mobile forKey:@"mobilenum"];
    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
    }
    if (!KCNSSTRING_ISEMPTY(pwd)) {
        [bodyDict setObject:pwd forKey:@"userpasswd"];
    }
    [bodyDict setObject:@"1" forKey:@"type"];
    
    [RestApi requestWithPath:kAPI_Auth body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


- (void)userLoginWithMobile:(NSString *)mobile
                 verifyCode:(NSString *)verifyCode
                     passwd:(NSString *)pwd
                   userType:(int)type
                withCodeKey:(NSString *)codeKey
                    imgCode:(NSString *)imgCode
                     compId:(NSString *)compId
            didFinishLoaded:(didFinishLoaded)finish
              didFailLoaded:(didFailLoaded)fail
{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[RestApi countryCode] forKey:@"countrycode"];
    [bodyDict setObject:mobile forKey:@"loginName"];
    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
    }
    
//    if (!KCNSSTRING_ISEMPTY(pwd)) {
//        [bodyDict setObject:[self md5PassWord:pwd] forKey:@"userpasswd"];
//    }
    if (!KCNSSTRING_ISEMPTY(pwd)) {//恒丰项目需要aes 加密
        if (HX_Password_3DES_Encrypt) {
            [bodyDict setObject:[NSString encoded_ase:pwd withkey:TRIPLEDESKEY] forKey:@"userpasswd"];
            
        } else {
             [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:@"originalPwd"];
            if (isCOSMO) {
               NSData *data = [pwd dataUsingEncoding:NSUTF8StringEncoding];
               // 进行加密
               NSString *passwordBase64 = [data base64EncodedStringWithOptions:0];
                [bodyDict setObject:passwordBase64 forKey:@"userpasswd"];
            }else{
               
                [bodyDict setObject:[self md5PassWord:pwd] forKey:@"userpasswd"];
            }
           
        }
    }
    [bodyDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    if(!KCNSSTRING_ISEMPTY(codeKey))
    {
        [bodyDict setObject:codeKey forKey:@"codeKey"];
    }
    
    if(!KCNSSTRING_ISEMPTY(imgCode))
    {
        [bodyDict setObject:imgCode forKey:@"imgCode"];
    }
    
    if (!KCNSSTRING_ISEMPTY(compId)) {
        [bodyDict setObject:compId forKey:@"compId"];
    }
    NSString* strTmp = @"im";
    //拼接避免扫瞄代码
    NSString *currentURL = [RestApi  getCurrentUrlString];
    if ([currentURL hasPrefix:[NSString stringWithFormat:@"%@://192.168.96.202",kRequestHttp]]) {
        [bodyDict setObject:[NSArray arrayWithObject:[[UIDevice currentDevice].identifierForVendor UUIDString]] forKey:[NSString stringWithFormat:@"%@ei",strTmp]];
    }
    
#if kHttpSAndHttp
    
    //客户端完整性校验
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *app_Identifier = [infoDictionary objectForKey:(__bridge_transfer NSString *)kCFBundleIdentifierKey];
#if DEBUG
    app_Identifier = @"com.hfbank.im";//开发
#endif
    NSString *md5Identifier = [app_Identifier MD5EncodingString];
    [bodyDict setObject:app_Version forKey:@"version"];
    [bodyDict setObject:md5Identifier forKey:@"completeCode"];
    [bodyDict setObject:@"1" forKey:@"appType"]; //0/1/2 andorid/ios/pc
#endif
    [RestApi requestWithPath:kAPI_Auth body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

-(NSString *)md5PassWord:(NSString *)passWord
{
    if(KCNSSTRING_ISEMPTY(passWord) || passWord.length>31)
    {
        return passWord;
    }
    const char *cStr = [[NSString stringWithFormat:@"%@",passWord] UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString* MD5 =  [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    
    return MD5;
}

/**
 *
 * 获取图片验证码
 * account 账号
 * 900363 开始获取验证码
 *
 **/
- (void)getLoginImageCodeWithUuid:(NSString *)uuid didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:uuid forKey:@"codeKey"];
    
    [RestApi requestWithPathAtAuthorization:KAPI_GetImageCode body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


- (void)userOutloginWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[RestApi countryCode] forKey:@"countrycode"];
    [bodyDict setObject:mobile forKey:@"mobilenum"];
    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
    }
    [bodyDict setObject:pwd forKey:@"userpasswd"];
    [bodyDict setObject:@"1" forKey:@"type"];
    
    [RestApi requestWithPath:kAPI_Auth body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)userRegisterWithMobile:(NSString *)mobile verifyCode:(NSString *)verifyCode passwd:(NSString *)pwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[RestApi countryCode] forKey:@"countrycode"];
    [bodyDict setObject:ISSTRING_ISSTRING(mobile) forKey:@"mobilenum"];
    if (!KCNSSTRING_ISEMPTY(verifyCode)) {
        [bodyDict setObject:verifyCode forKey:@"smsverifycode"];
    }else{
        [bodyDict setObject:@"" forKey:@"smsverifycode"];
    }
    if(pwd)
    {
        [bodyDict setObject:pwd forKey:@"userpasswd"];
    }
    [bodyDict setObject:@"0" forKey:@"type"];
    
    [RestApi requestWithPath:kAPI_Auth body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
- (void)sendSMSVerifyCodeWithMobile:(NSString *)mobile
                           withFlag:(NSString *)flag
                            codeKey:(NSString *)codeKey
                            imgCode:(NSString *)imgCode
                             compId:(NSString *)compId
                    didFinishLoaded:(didFinishLoaded)finish
                      didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[RestApi countryCode] forKey:@"countrycode"];
    [bodyDict setObject:(NSString*)mobile forKey:@"mobilenum"];
    //zmf add 恒信使用邮箱验证 容信使用短信验证
    if (IsHengFengTarget != 1) {
        [bodyDict setObject:@"0" forKey:@"type"];
    } else {
        [bodyDict setObject:@"2" forKey:@"type"];
    }
    //zmf end
    
    [bodyDict setObject:[NSString imei] forKey:@"imei"];
    [bodyDict setObject:[NSString macAddress] forKey:@"mac"];
    [bodyDict setObject:flag forKey:@"flag"];
    if (codeKey) {
        [bodyDict setObject:codeKey forKey:@"codeKey"];
    }
    if (imgCode) {
        [bodyDict setObject:imgCode forKey:@"imgCode"];
    }
    if (compId) {
        [bodyDict setObject:compId forKey:@"compId"];
    }
    
    [RestApi requestWithPath:KAPI_GETSMS body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
- (void)sendTelVerifyCodeWithMobile:(NSString *)mobile withFlag:(NSString *)flag didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[RestApi countryCode] forKey:@"countrycode"];
    [bodyDict setObject:mobile forKey:@"mobilenum"];
    [bodyDict setObject:@"1" forKey:@"type"];
    [bodyDict setObject:[NSString imei] forKey:@"imei"];
    [bodyDict setObject:[NSString macAddress] forKey:@"mac"];
    [bodyDict setObject:flag forKey:@"flag"];
    [RestApi requestWithPath:KAPI_GETSMS body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)findPasswordWithMobile:(NSString *)mobile
                        newpwd:(NSString *)newpwd
                    verifyCode:(NSString *)verifyCode
                        compId:(NSString *)compId
               didFinishLoaded:(didFinishLoaded)finish
                 didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:@"0" forKey:@"type"];
    [bodyDict setObject:verifyCode forKey:@"auth"];
    [bodyDict setObject:newpwd forKey:@"new_pwd"];
    
    if (!KCNSSTRING_ISEMPTY(compId)) {
        [bodyDict setObject:compId forKey:@"compId"];
    }
    
    if(!KCNSSTRING_ISEMPTY(mobile))
    {
        [bodyDict setObject:mobile forKey:@"mobilenum"];
    }
    [RestApi requestWithPathAtAuthorization:kAPI_ModifiPassword body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)updatePasswordWithMobile:(NSString *)mobile auth:(NSString *)auth newpwd:(NSString *)newpwd type:(NSString*)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail;
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:type forKey:@"type"];
    [bodyDict setObject:auth forKey:@"auth"];
    [bodyDict setObject:newpwd forKey:@"new_pwd"];
    if(!KCNSSTRING_ISEMPTY(mobile))
    {
        [bodyDict setObject:mobile forKey:@"mobilenum"];
    }
    [RestApi requestWithPathAtAuthorization:kAPI_ModifiPassword body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)updateNewPasswordWithAccount:(NSString *)account auth:(NSString *)auth newPass:(NSString *)newPwd type:(int )type oldPwd:(NSString *)oldPwd didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(account))
    {
        [bodyDict setObject:account forKey:@"mobilenum"];
    }
    if(!KCNSSTRING_ISEMPTY(auth)){
        
        [bodyDict setObject:auth forKey:@"auth"];
    }
    [bodyDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    if(!KCNSSTRING_ISEMPTY(newPwd))
    {
        [bodyDict setObject:[NSString encoded_ase:newPwd withkey:TRIPLEDESKEY] forKey:@"new_pwd"];
    }
    
    if(!KCNSSTRING_ISEMPTY(oldPwd))
    {
        [bodyDict setObject:[NSString encoded_ase:oldPwd withkey:TRIPLEDESKEY] forKey:@"oldPwd"];
    }

    [RestApi requestWithPathAtAuthorization:kAPI_ModifiPassword body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}

- (void)feedBackWithDict:(NSDictionary *)feedbackDict didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    [RestApi requestWithPathAtAuthorization:kAPI_Feedback body:feedbackDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)checkVersionWithMobile:(NSString *)mobile didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    [bodyDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey] forKey:@"version"];//CFBundleShortVersionString
    
      NSString *app_Version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [bodyDict setObject:app_Version forKey:@"version"];
    
    [bodyDict setObject:@"1" forKey:@"type"];
    if(!KCNSSTRING_ISEMPTY(mobile))
    {
        [bodyDict setObject:mobile forKey:@"account"];
    }
    [RestApi requestWithPath:[NSString stringWithFormat:kAPI_CheckVersion] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)updateUserInfo:(NSString *)mobile nickName:(NSString *)nickName photo:(UIImage *)photo signature:(NSString *)signature didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (!KCNSSTRING_ISEMPTY([RestApi sharedInstance].account)) {
        [dict setObject:[RestApi sharedInstance].account forKey:@"account"];
    }
    if (!KCNSSTRING_ISEMPTY(nickName)) {
        [dict setObject:nickName forKey:@"nickname"];
    }
    
    if (!KCNSSTRING_ISEMPTY(mobile)) {
        [dict setObject:mobile forKey:@"mobilenum"];
    }
    if (photo) {
        NSData *imgData = UIImageJPEGRepresentation(photo, 0.5);
        [dict setObject:@"jpeg" forKey:@"photo_type"];
        [dict setObject:[imgData base64Encoding] forKey:@"photo_content"];
    } else {
//        NSData *imgData = UIImageJPEGRepresentation(photo, 0.5);
//        [dict setObject:@"no" forKey:@"photo_type"];
//        [dict setObject:@"" forKey:@"photo_content"];
    }
    if (KCNSSTRING_ISEMPTY(signature)) {
        [dict setObject:@"" forKey:@"signature"];
    }else {
        [dict setObject:signature forKey:@"signature"];
    }
    [RestApi requestWithPathAtAuthorization:kAPI_SetUserInfo body:dict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)getVOIPUserInfoWithMobile:(NSString *)mobile type:(NSString*)type  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSArray* array = [NSArray arrayWithObjects:mobile, nil];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:array forKey:@"userAccounts"];
    [bodyDict setObject:type forKey:@"type"];
    if([[[Common sharedInstance]getAccount] length]){
        [bodyDict setObject:[[Common sharedInstance]getAccount] forKey:@"account"];
    }
    
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetVOIPUserInfo] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
- (void)getVOIPUserInfoWithMobile:(NSString *)mobile number:(NSArray*)number type:(NSString*)type  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:number forKey:@"mobilenum"];
    [bodyDict setObject:type forKey:@"type"];
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetVOIPUserInfo, mobile] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/// 获取权限控制匹配规则
/// @param compId 企业id
/// @param finish 成功回调
/// @param fail 失败回调
- (void)getPrivilegeRuleWithCompId:(NSString *)compId  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(compId){
        [bodyDict setObject:compId forKey:@"compId"];
    }
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetPrivilegeRule] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/// 获取企业下所有部门
/// @param compId 企业id
/// @param finish 成功回调
/// @param fail 失败回调
- (void)getAllDepartInfo:(NSString *)compId  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(compId){
        //    synctime 可选
        [bodyDict setObject:compId forKey:@"companyid"];
    }
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetAllDepartInfo] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

- (void)downloadCOMAddressBookWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    return;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //lastreqtime 为@""的时候为全量下载 不为空的适合为增量下载[userDefaults objectForKey:KNotification_ADDCOUNTQUESTTime]
    NSString *lastreqtime =@"" ;
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:KCNSSTRING_ISEMPTY(account)?@"":account forKey:@"phone"];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:KNotification_ADDCOUNTQUEST])
    {
        lastreqtime = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",KNotification_ADDCOUNTQUESTTime,[RestApi sharedInstance].account]];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SettingViewController"]) {
        lastreqtime = @"";
    }
    
    #if isZipBaseFile
        [bodyDict setObject:[NSNumber numberWithInt:1] forKey:@"isZip"];
    #else
        [bodyDict setObject:[NSNumber numberWithInt:0] forKey:@"isZip"];
    #endif

    [bodyDict setObject:KCNSSTRING_ISEMPTY(lastreqtime)?@"":lastreqtime forKey:@"synctime"];
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GETCOMAddBook] body:bodyDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        [userDefaults setObject:[[dict objectForKey:@"body"] objectForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",KNotification_ADDCOUNTQUESTTime,[RestApi sharedInstance].account]];
        if (finish) {
            finish(dict,path);
        }
    } didFailLoaded:fail];

}

/**
 *  加入企业通讯录
 *
 *  @param mobile
 */+ (void)confirmInvitWithMobile:(NSString *)mobile companyid:(NSString *)companyid didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:companyid forKey:@"companyid"];
    [bodyDict setObject:@"1" forKey:@"type"];
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_ConfirmInvit, mobile] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 *  获取企业审核状态
 *
 *  @param mobile
 */
+ (void)confirmInvitStatusWithMobile:(NSString *)mobile  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetComStatus, mobile] body:nil didFinishLoaded:finish didFailLoaded:fail];
}

#pragma mark --- 朋友圈部分 --- 服务器替换
/**
 *  运动会 恒信 消息发布
 *  @sig MD5(account+passWord)
 *  @mobile 账号
 *  @content 内容
 *  @imgUrl 图片地址
 *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
 *  @subject 主题
 */
+ (void)sendSportMeetMessageSig:(NSString *)sig
                    withAccount:(NSString *)mobile
                    withContent:(NSString *)content
                    withFileUrl:(NSArray *)imgUrl
                      withDomin:(NSDictionary *)domain
                    withSubject:(NSString *)subject
                didFinishLoaded:(didFinishLoaded)finish
                  didFailLoaded:(didFailLoaded)fail
{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(sig)
    {
        [bodyDict setObject:sig forKey:@"sig"];
    }
    if(mobile)
    {
        [bodyDict setObject:mobile forKey:@"account"];
    }
    if(content)
    {
        [bodyDict setObject:content forKey:@"content"];
    }
    if(imgUrl.count>0)
    {
        [bodyDict setObject:imgUrl forKey:@"fileUrl"];
    }
    if(domain)
    {
        [bodyDict setObject:domain forKey:@"domain"];
    }
    if(subject)
    {
        [bodyDict setObject:subject forKey:@"subject"];
    }
    NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];

    if (dict[Table_User_OrgId]) {
        [bodyDict setObject:dict[Table_User_OrgId] forKey:@"orgId"];
    }
    
    DDLogInfo(@"body:%@",bodyDict);
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_sendSportMeet,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 *  运动会 恒信 获取消息
 *  @sig MD5(account+passWord)
 *  @mobile 账号
 *  @content 内容
 *  @limit 获取个数 默认是5条
 *  @domain 运动会期间{“msgType”:””, “item”:””,“status”:”” }，1你我看点，2场外之声，3精彩回放，4战绩快报
 *  @version 开始的版本号，默认为空，从第一条开始
 */

+ (void)getSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version withLimit:(int)limit withDomain:(NSDictionary *)domain didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
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
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_GETSportMeet,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 *  运动会 恒信 获取单条消息
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 开始的版本号，默认为空，从第一条开始
 */
+ (void)getSingleSportMeetMessageSig:(NSString *)sig withAccout:(NSString*)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_GETFC,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 *  获取某个人的所有同事圈
 *  @sig MD5(account+passWord)
 *  @account 自己账号
 *  @friendAccount 朋友的账号
 *  @limit 获取个数 默认是10条
 *  @domain 自定义json字段
 *  @msgId 开始的版本号，默认为空，从第一条开始
 */

+ (void)getFCMyListMessageSig:(NSString *)sig withAccout:(NSString*)account withMsgId:(NSString *)msgId withLimit:(int)limit withDomain:(NSDictionary *)domain didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_getFCMyList,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 *  删除同事圈
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 */
+ (void)deleteFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_deleteFCMsg,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 *  获取所有评论和点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈消息版本号
 *  @flag    0 全部， 1 赞，2评论   默认值0
 */
+ (void)getRepliesAndFavorsWithFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version withFlag:(int)flag didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_getRepliesAndFavors,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 *  同事圈评论
 *  @sig MD5(account+passWord)
 *  @account 自己账号
 *  @rAccount 回复对方的帐号
 *  @version 同事圈版本号
 *  @content 评论内容
 */
+ (void)replyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyAccount:(NSString *)rAccount withVersion:(NSString *)version withContent:(NSString *)content  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_Reply,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 *  同事圈点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈版本号
 */
+ (void)favourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_Favour,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 *  取消同事圈评论
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @replyId 评论ID
 */
+ (void)cancelReplyFCMessageSig:(NSString *)sig withAccout:(NSString *)account withReplyId:(NSString *)replyId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_CancelReply,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 *  取消同事圈点赞
 *  @sig MD5(account+passWord)
 *  @account 账号
 *  @version 同事圈版本号
 */
+ (void)cancelFavourFCMessageSig:(NSString *)sig withAccout:(NSString *)account withVersion:(NSString *)version didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    
    [RestApi requestWithPathAtAuthorizationNew:[NSString stringWithFormat:@"%@%@",kAPI_CancelFavour,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}



+ (void)requestCollectionWithPath:(NSString *)path body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSDate* date = [NSDate date];
    NSString* requestTime =  [RestApi requestGMTTime:date];
    NSMutableString * authorization = [NSMutableString stringWithString:requestTime] ;
    if (!KCNSSTRING_ISEMPTY([RestApi sharedInstance].account)) {
        [authorization appendString:[RestApi sharedInstance].account];
    }
    if (!KCNSSTRING_ISEMPTY([RestApi sharedInstance].clientpwd)) {
        [authorization appendString:[RestApi sharedInstance].clientpwd];
    }
    
    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[RestApi userAgent] forKey:@"useragent"];
    [headDict setObject:[RestApi requestTime:date] forKey:@"reqtime"];
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:headDict forKey:@"head"];
    
    if (body) {
        [requestDict setObject:body forKey:@"body"];
    }
    
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:[[authorization MD5EncodingString]lowercaseString] forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *parmsDict = [NSMutableDictionary dictionary];
    [parmsDict setObject:requestDict forKey:@"Request"];
    NSString *currentURL = [RestApi getCurrentUrlString];
    if (!KCNSSTRING_ISEMPTY(currentURL)) {
        [[RestApi sharedInstance] requestPost:[NSString stringWithFormat:@"%@%@",currentURL,path] params:parmsDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            if (finish) {
                finish([dict objectForKey:@"Response"], path);
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (fail) {
                fail(error, path);
            }
        }];
    }
  
}
/**
 *  删除收藏
 *  account 账号
 *  collectIds 收藏id数组
 */

+ (void)deleteCollectDataWithAccount:(NSString *)account CollectIds:(NSArray *)collectIds didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:account forKey:@"account"];
    
    if (collectIds.count > 0) {
        [bodyDict setObject:collectIds forKey:@"collectIds"];
    }
    [RestApi requestCollectionWithPath:KAPI_DelCollect body:bodyDict didFinishLoaded:finish didFailLoaded:fail];

}

/**
 *  获取收藏
 *  account 账号
 *  synctime 上次同步时间，为空则为全量
 *  collectId 收藏id
 */
+ (void)getCollectDataWithAccount:(NSString *)account Synctime:(NSString *)synctime CollectId:(NSString *)collectId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if (synctime) {
        [bodyDict setObject:synctime forKey:@"synctime"];
    }
    if (collectId) {
        [bodyDict setObject:collectId forKey:@"collectId"];
    }
    [RestApi requestCollectionWithPath:KAPI_GetCollects body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 *  增加收藏
 *  account 账号
 *  content 收藏内容
 *  type  1,文本 ；2，图片；3，网页；4，语音；5，视频；6，图文
 */
+ (void)addCollectDataWithAccount:(NSString *)account fromAccount:(NSString *)fromAccount TxtContent:(NSString *)txtContent Url:(NSString *)url  DataType:(NSString *)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
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
    [RestApi requestCollectionWithPath:KAPI_AddCollect body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}

/**
 *  增加收藏
 *  account 账号
 *  collectContents 收藏的数据
 */
+ (void)addMultiCollectDataWithAccount:(NSString *)account
                       collectContents:(NSArray *)collectContents
                       didFinishLoaded:(didFinishLoaded)finish
                         didFailLoaded:(didFailLoaded)fail {
    [self addMultiCollectDataWithAccount:account sessionId:nil collectContents:collectContents didFinishLoaded:finish didFailLoaded:fail];
    
}


/**
 收藏

 @param account 自己的 account
 @param sessionId 会话 id（合并收藏的时候必选）
 @param collectContents 收藏内容
 @param finish 成功回调
 @param fail 失败回调
 */
+ (void)addMultiCollectDataWithAccount:(NSString *)account
                             sessionId:(NSString *)sessionId
                       collectContents:(NSArray *)collectContents
                       didFinishLoaded:(didFinishLoaded)finish
                         didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if (account) {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if (collectContents) {
        NSMutableArray * collectArr = [NSMutableArray arrayWithCapacity:0];
        for (RXCollectData * data in collectContents) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
            if (data.type) {
                [dic setObject:data.type forKey:@"type"];
            }
            
            if (data.sessionId) {
                [dic setObject:data.sessionId forKey:@"fromAccount"];
            }
            if (data.url) {
                [dic setObject:data.url forKey:@"url"];
            }
            //增加字段 favoriteMsgId防重复判断
            if (data.favoriteMsgId) {
                [dic setObject:data.favoriteMsgId forKey:@"favoriteMsgId"];
            }
            
            if (data.txtContent) {
                [dic setObject:data.txtContent forKey:@"txtContent"];
            }else{
                [dic setObject:@"" forKey:@"txtContent"];
            }
            [collectArr addObject:dic];
        }
        [bodyDict setObject:collectArr forKey:@"collectContents"];
        if (collectContents.count>1) {
            [bodyDict setObject:@"8" forKey:@"merge"];
            if (sessionId) {
                [bodyDict setObject:sessionId forKey:@"mergeId"];
            }
        }
    }
    
    [RestApi requestCollectionWithPath:KAPI_AddCollect body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}

//上传附件 将文件名字和图片传进来
+ (void)uploadPhoWithFileName:(NSString *)fileName photo:(UIImage *)photo fileData:(NSData *)fileData fileType:(NSString *)fileType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[[AppModel sharedInstance].appData.userInfo objectForKey:App_AppKey] forKey:@"appId"];
    [bodyDict setObject:fileName forKey:@"filename"];
    
    if (photo) {
        //UIImageJPEGRepresentation(photo, 0.1);
        NSData *imgData = [photo fixCurrentImage];
        [bodyDict setObject:imgData forKey:@"data"];
        [bodyDict setObject:@"jpeg" forKey:@"photo_type"];
        [bodyDict setObject:[imgData base64Encoding] forKey:@"photo_content"];
    }
    
    if (fileData) {
        [bodyDict setObject:fileData forKey:@"data"];
        [bodyDict setObject:fileType forKey:@"photo_type"];
        [bodyDict setObject:[fileData base64Encoding] forKey:@"photo_content"];
    }
    
    NSArray * fileArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"RX_fileserver"];
    NSString * sigStr = [@"yuntongxunytx123" MD5EncodingString];
    NSString * fileUrl = [NSString stringWithFormat:@"http://%@/2015-03-26/Corp/yuntongxun/Upload/VTM?appId=%@&userName=%@&fileName=%@&sig=%@",fileArr[0],[Common sharedInstance].getAppid,[Common sharedInstance].getAccount,fileName,sigStr];

    [RestApi requestWithPathAtAuthorization:fileUrl body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+(void)getMyAttentionPublicSig:(NSString *)sig account:(NSString*)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_GetMyAttPublicNum,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


/**
 * 获取公众号信息
 * sig Md5(account + clientpwd)
 * account 账号
 * pnid 公众号
 */
+(void)getPublicInfoDataSig:(NSString *)sig account:(NSString*)account publicId:(NSString *)pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(pnId)
    {
        [bodyDict setObject:[NSNumber numberWithInteger:[pnId integerValue]]  forKey:@"pn_id"];
    }
    
    
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:FRIENDGROUPURL],KAPI_GetPublicUrl,sig] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}

///**
// *
// *  公众号搜索
// *  account 账号
// *  lPnId 本轮查询中的上次返回数据中最大pn_id
// *  limit 一次获取多少条公众号信息，默认20
// **/
//+(void)getPublicSearchDataSig:(NSString *)sig account:(NSString*)account searchStr:(NSString *)searchString publicId:(NSInteger )ipnId limit:(NSInteger)limit didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
//{
//    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
//    if(account)
//    {
//        [bodyDict setObject:account forKey:@"account"];
//    }
//    if(!KCNSSTRING_ISEMPTY(searchString))
//    {
//        [bodyDict setObject:searchString forKey:@"pn_name"];
//    }
//    [bodyDict setObject:[NSNumber numberWithInteger:ipnId] forKey:@"lPnId"];
//    [bodyDict setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
//    
//    NSDictionary* dict = [[Common sharedInstance].componentDelegate onGetUserInfo];
//    
//    if (dict[Table_User_OrgId]) {
//        [bodyDict setObject:dict[Table_User_OrgId] forKey:@"orgId"];
//    }
//    
//    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_GetSearchPublicUrl,sig]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
//}

/**
 * 公众号置顶功能
 * sig鉴权字段 account+client
 * account 获取账号
 * pnId 获取的公众号信息
 *
 *
 ***/

+ (void)settingPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(pnId)
    {
        [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
    }
    
    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_PUBLICTOTOPAPI,sig]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 * 公众号取消置顶功能
 * sig鉴权字段 account+client
 * account 获取账号
 * pnId 获取的公众号信息
 *
 *
 ***/
+ (void)cancelPublicMessageTopShowSig:(NSString *)sig account:(NSString *)account public:(int)pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    if(pnId)
    {
        [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
    }
    
    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_PUBLICCANCELTOP,sig]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


/**
 *
 *  关注公众号
 *  account 账号
 *  pnid 公众号Id
 **/
+(void)attentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
    
    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_ATttPublicNum,sig]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}
/**
 *
 *  取消公众号
 *  account 账号
 *  pnid 公众号Id
 **/
+(void)cancelAttentionPublicSig:(NSString *)sig account:(NSString*)account publicId:(NSInteger )pnId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [bodyDict setObject:[NSNumber numberWithInteger:pnId] forKey:@"pn_id"];
    
    [RestApi requestWithPathWithRequest:[NSString stringWithFormat:@"%@%@",KAPI_DeleteMyAttPublicNum,sig]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 * 获取公众号历史记录
 * sig鉴权字段 account+clientpwd
 * account 获取账号
 * pnId 获取的公众号信息
 * msgSendId 可选 发送消息记录Id 默认为0 此值从缓存中取，取最小值，无缓存置0；
 值为0时，取最新消息
 * limit 可选 默认10 获取消息条数
 **/
+(void)getPublicHistroyDataSig:(NSString *)sig account:(NSString *)account publicId:(int )pnId msgSendId:(int)msgSendId limit:(int)limit didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
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
    
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:@"%@%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:FRIENDGROUPURL],KAPI_GETHISTORYMESSAGELIST,sig]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+ (NSString *)userAgent
{
    int width = [[UIScreen mainScreen] bounds].size.width*[[UIScreen mainScreen] scale];
    int hight = [[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] scale];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@;%@;%@;%d*%d;%@", [[UIDevice currentDevice] name], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], width, hight, version];
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


#pragma mark 朋友圈上传文件
//上传附件 将文件名字和图片传进来
+ (void)uploadPhoWithFileName1:(NSString *)fileName photo:(UIImage *)photo fileData:(NSData *)fileData fileType:(NSString *)fileType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    [RestApi uploadPhoWithFileName1:fileName photo:photo fileData:fileData fileType:fileType withImageType:-1 didFinishLoaded:finish didFailLoaded:fail];
}
+ (void)uploadPhoWithFileName1:(NSString *)fileName photo:(UIImage *)photo fileData:(NSData *)fileData fileType:(NSString *)fileType withImageType:(NSInteger)imageType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:[[AppModel sharedInstance].appData.userInfo objectForKey:App_AppKey] forKey:@"appId"];
    [bodyDict setObject:fileName forKey:@"filename"];
    
    if (photo) {
        //UIImageJPEGRepresentation(photo, 0.1);
        NSData *imgData = [photo fixCurrentImage];
        [bodyDict setObject:imgData forKey:@"data"];
        [bodyDict setObject:@"jpeg" forKey:@"photo_type"];
        [bodyDict setObject:[imgData base64Encoding] forKey:@"photo_content"];
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
        fileUrl = [NSString stringWithFormat:@"http://%@/2015-03-26/Corp/yuntongxun/Upload/VTM?appId=%@&userName=%@&fileName=%@&rotate=%ld&sig=%@",fileArr[0],[Common sharedInstance].getAppid,[Common sharedInstance].getAccount,fileName,imageType,sigStr];
    }
    DDLogInfo(@"fileUrl:%@",fileUrl);
    
    [RestApi requestWithPathAtAuthorization2:fileUrl body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


+ (void)requestWithPathAtAuthorization2:(NSString *)path body:(NSDictionary *)body  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    [request setHTTPMethod:@"POST"];
    
    //Add the header info
    NSString *boundary = @"---------------------------------0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [[NSMutableData alloc] init];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Disposition:form-data; name=\"iosImage\"; filename=\"applyRepair.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type:image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[body objectForKey:@"data"]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add the body to the post
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        DDLogInfo(@"data:%@&&&&&&&&",responseString);

        DDLogInfo(@"response:%@&&&&&&&&",response);
        DDLogInfo(@"&&&&&&&&&&&&&&&&&&&&&");
    }];
    
    [[RestApi sharedInstance].manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
     [[RestApi sharedInstance].manager.requestSerializer setValue:@"YmRiMjc4ZjU1MWIzYTViYjAxNTFjMzhmYTBkMDAwMDA6MjAxNjAzMTAxMDEzMDU" forHTTPHeaderField:@"Authorization"];
    
   [RestApi sharedInstance].manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;

    
    NSDictionary *paramDic = [NSDictionary dictionary];
    [[RestApi sharedInstance].manager POST:path parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
        NSData *imageData = [body objectForKey:@"data"];
        NSString *a = [body objectForKey:@"filename"];
        NSString *name = [a hasSuffix:@"jpeg"]?[a substringToIndex:a.length-5]:@"";
        //上传的参数(上传图片，以文件流的格式)
//        [formData appendPartWithFileData:imageData
//                                    name:name
//                                fileName:[body objectForKey:@"filename"]
//                                mimeType:[body objectForKey:@"photo_type"]];

        NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithData:imageData encoding:NSASCIIStringEncoding]];
        [formData appendPartWithFileURL:url name:name error:nil];

    } progress:^(NSProgress *_Nonnull uploadProgress) {
        //打印下上传进度
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        //上传成功
        DDLogInfo(@"111111***************");
        if (finish) {
            finish(responseObject,nil);
        }

    } failure:^(NSURLSessionDataTask *_Nullable task, NSError * _Nonnull error) {
        //上传失败
        DDLogInfo(@"2222222***************");
        if (fail) {
            fail(error, nil);
        }
    }];
}

//朋友圈专属  包括给header签名
+ (void)requestWithPathAtAuthorizationNew:(NSString *)path body:(NSDictionary *)body  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    //获取朋友圈不加嵌套
    NSAssert(path!=nil, @"the url path can't be null");
    [[RestApi sharedInstance].manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;

    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"]) {
        NSString *requestURL = [[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"];
        NSString *requsetString = [NSString stringWithFormat:@"%@%@",requestURL,path];
        [[RestApi sharedInstance] requestPost:requsetString params:body didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            if (finish) {
                finish(dict, path);
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (fail) {
                fail(error, path);
            }
        }];
    }
    
}
//请求需拼接@"Request"字段 ：1.获取某人朋友圈接口;2.获取某人关注公众号接口；3.公众号置顶；4.关注公众号；5.取消关注公众号
+ (void)requestWithPathWithRequest:(NSString *)path body:(NSDictionary *)body  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSAssert(path!=nil, @"the url path can't be null");
    //获取单人的朋友圈 加前套
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    
    if (body) {
        [requestDict setObject:body forKey:@"body"];
    }
    NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:requestDict, @"Request", nil];
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"]) {
        NSString *requestURL = [[NSUserDefaults standardUserDefaults]stringForKey:@"HX_ClientAuthResp_friendGroup_Url"];
        NSString *requsetString = [NSString stringWithFormat:@"%@%@",requestURL,path];
        [[RestApi sharedInstance] requestPost:requsetString params:postDic didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            if (finish) {
                finish(dict, path);
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (fail) {
                fail(error, path);
            }
        }];
    }
}

//获取聊天记录
 +(void)getHistoryMyChatMessageWithAccount:(NSString *)userName withAppid:(NSString *)appid version:(long long)version time:(NSString *)time pageSize:(NSInteger)pageSize talker:(NSString *)talker order:(NSInteger)order  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
     NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
     if(appid)
     {
         [bodyDict setObject:appid forKey:@"appId"];
     }
     if(!KCNSSTRING_ISEMPTY(time))
     {
         [bodyDict setObject:time forKey:@"time"];
     }
     if(pageSize>0)
     {
         [bodyDict setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
     }
     if(version>0)
     {
         [bodyDict setObject:[NSNumber numberWithLongLong:version] forKey:@"version"];
     }
     if(talker)
     {
         [bodyDict setObject:talker forKey:@"talker"];
     }
     if(userName)
     {
         [bodyDict setObject:userName forKey:@"userName"];
     }
     
     [bodyDict setObject:@"1" forKey:@"msgDecompression"];
     [bodyDict setObject:[NSNumber numberWithInteger:order] forKey:@"order"];
     NSString *httpStr = @"http";
     if([[Common sharedInstance]getRestHost] && [[[Common sharedInstance]getRestHost] hasSuffix:@"8883"])
     {
         httpStr = @"https";
     }
     
     [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/GetIMHistoryMsg?sig=",httpStr,[[Common sharedInstance]getRestHost],[[Common sharedInstance]getAppid]]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
 }
//获取群组消息记录

+ (void)getHistoryGroupListMessageGroupId:(NSString *)groupId startTime:(NSString *)startTime endTime:(NSString *)endTime pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize msgDecompression:(NSString *)msgDecompression didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if([[Common sharedInstance]getAppid])
    {
    [bodyDict setObject:[[Common sharedInstance]getAppid] forKey:@"appId"];
    }
    if(groupId)
    {
    [bodyDict setObject:groupId forKey:@"groupId"];
    }
    if(startTime)
    {
    [bodyDict setObject:startTime forKey:@"startTime"];
    
    }
    
    if(endTime)
    {
    [bodyDict setObject:endTime forKey:@"endTime"];
    }
    
    if(pageNo)
    {
    [bodyDict setObject:pageNo forKey:@"pageNo"];
    
    }
    if(pageSize)
    {
    [bodyDict setObject:pageSize forKey:@"pageSize"];
    }
    if(msgDecompression)
    {
    [bodyDict setObject:msgDecompression forKey:@"msgDecompression"];
    
    }
    NSString *httpStr = @"http";
    if([[Common sharedInstance]getRestHost] && [[[Common sharedInstance]getRestHost] hasSuffix:@"8883"])
    {
        httpStr = @"https";
    }
    NSString *requestStr = [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[[Common sharedInstance]getRestHost],[[Common sharedInstance]getAppid]] ;
    [RestApi requestGetHistoryMessagePathAtAuthorization:requestStr body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

 //获取历史消息head签名
//+ (void)requestGetHistoryMessagePathAtAuthorization:(NSString *)path body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
//{
//    NSDate* date = [NSDate date];
//     NSString *authorization =[NSString stringWithFormat:@"%@:%@",[[Common sharedInstance]getAppid],[RestApi requestTime:date]];
//     NSDictionary *headers =[NSDictionary dictionaryWithObjectsAndKeys:@"application/json;charset=utf-8",@"Content-Type",@"application/json",@"accept",[authorization base64EncodingString],@"Authorization", nil];
//    
//    NSString * sigStr = [[NSString stringWithFormat:@"%@%@%@",[[Common sharedInstance]getAppid],[[Common sharedInstance]getApptoken],[RestApi requestTime:date]] MD5EncodingString];
//    NSString *urlPath =[NSString stringWithFormat:@"%@%@",path,sigStr];
//    [Common sharedInstance].historyMessageUrl =urlPath;
//    [[RestApi sharedInstance]requestPost:urlPath params:body didFinishLoaded:^(NSDictionary *dict, NSString *path) {
//        if (finish) {
//            finish(dict,path);
//        }
//    } didFailLoaded:^(NSError *error, NSString *path) {
//        if (fail) {
//            fail(error,path);
//        }
//    }];    
//}
+ (void)requestGetHistoryMessagePathAtAuthorization:(NSString *)path body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    
    NSDate* date = [NSDate date];
     NSString* requestTime =  [RestApi requestTime:date];
    
    NSString *authorization =[NSString stringWithFormat:@"%@:%@",[[Common sharedInstance]getAppid],requestTime];
    NSString * sigStr = [[NSString stringWithFormat:@"%@%@%@",[[Common sharedInstance]getAppid],[[Common sharedInstance]getApptoken],requestTime] MD5EncodingString];
    
    NSString *urlPath =[NSString stringWithFormat:@"%@%@",path,sigStr];
    
     [Common sharedInstance].historyMessageUrl =urlPath;
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:[authorization base64EncodingString] forHTTPHeaderField:@"Authorization"];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;

    [[RestApi sharedInstance]requestPost:urlPath params:body didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        if (finish) {
            finish(dict,path);
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        if (fail) {
            fail(error,path);
        }
    }];

}

// 自定义url
+ (void)requestWithCustomPathAtAuthorization:(NSString *)path body:(NSDictionary *)body isNeedAuthor:(BOOL)isNeed didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSDate* date = [NSDate date];
    NSString* requestTime =  [RestApi requestTime:date];
    NSString *authorization = nil;
    NSString * sigStr = nil;
    NSString *urlPath =[NSString stringWithFormat:@"%@",path];

    if(isNeed)
    {
         authorization =[NSString stringWithFormat:@"%@:%@",[[Common sharedInstance]getAppid],requestTime];
         sigStr = [[NSString stringWithFormat:@"%@%@%@",[[Common sharedInstance]getAppid],[[Common sharedInstance]getApptoken],requestTime] MD5EncodingString];
        urlPath = [NSString stringWithFormat:@"%@%@",path,sigStr];
    }
    
    
    [Common sharedInstance].historyMessageUrl =urlPath;
    //[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [RestApi sharedInstance].manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    [RestApi sharedInstance].manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
    if(authorization)
    {
        [[RestApi sharedInstance].manager.requestSerializer setValue:[authorization base64EncodingString] forHTTPHeaderField:@"Authorization"];
    }
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;

    [[RestApi sharedInstance]requestPost:urlPath params:body didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        if (finish) {
            finish(dict,path);
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        if (fail) {
            fail(error,path);
        }
    }];
}

/**
 *  特别关注
 *  取消或者添加特别关注
 *   type 0.增加 1.删除
 *  attectionAccounts 关注的账号
 */
+ (void)selectSpecialAccount:(NSArray *)attectionAccounts type:(int)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:[RestApi sharedInstance].account forKey:@"account"];
    
    if(attectionAccounts)
    {
        [bodyDict setObject:attectionAccounts forKey:@"attentionAccounts"];
    }
    
    [bodyDict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    [RestApi requestWithPathAtAuthorization:kAPI_SpecialServiceUrl body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+ (void)getAllSpecialAtt:(NSString *)account withAddRequest:(BOOL)addRequest didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    NSString *lastreqtime =@"" ;
    
    if(addRequest)
    {
        lastreqtime = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kAPI_GetSpecialServiceUrl,[RestApi sharedInstance].account]];
    }
    
    [bodyDict setObject:KCNSSTRING_ISEMPTY(lastreqtime)?@"":lastreqtime forKey:@"synctime"];
    
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetSpecialServiceUrl] body:bodyDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[[dict objectForKey:@"body"] objectForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",kAPI_GetSpecialServiceUrl,[RestApi sharedInstance].account]];
        if (finish) {
            finish(dict, path);
        }
    } didFailLoaded:fail];
    
}

//-------好友操作-------
/**
 *
 *  添加好友
 *  type 0/1/2 邀请/接受/拒绝
 *  account 好友account 唯一标示
 *  0/1/2 邀请/接受/拒绝 邀请描述内容
 *
 **/
+(void)addNewFriendAccount:(NSString *)userAccount inviteType:(NSInteger)inviteType descrContent:(NSString *)descrContent didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:[[Common sharedInstance] getAccount] forKey:@"account"];
    
    if(userAccount)
    {
        [bodyDict setObject:userAccount forKey:@"friendAccount"];
    }
    
    [RestApi requestWithPathAtAuthorization:KAPI_ADDNewFrien body:bodyDict didFinishLoaded:finish didFailLoaded:fail];

}

/**
 *
 *  获取邀请历史记录记录接口
 *  account my账号
 *
 **/
+(void)getMyFriendHistorytWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    [RestApi requestWithPathAtAuthorization:KAPI_GetFriendInviteRecord body:bodyDict didFinishLoaded:finish didFailLoaded:fail];

}
/**
 *
 *  获取自己的好友列表
 *  addRequest 是否增量更新
 *  synctime 同步时间  有值为增量 nil时为全量
 **/
+(void)getMyFriendWithAccount:(NSString *)account synctime:(NSString *)synctime addRequest:(BOOL)addRequest didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(addRequest)
    {
        synctime = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",KAPI_GetMyFriend,[[Common sharedInstance] getAccount]]];
    }
    
    [bodyDict setObject:KCNSSTRING_ISEMPTY(synctime)?@"":synctime forKey:@"synctime"];
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:KAPI_GetMyFriend] body:bodyDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[[dict objectForKey:@"body"] objectForKey:@"synctime"] forKey:[NSString stringWithFormat:@"%@%@",KAPI_GetMyFriend,[RestApi sharedInstance].account]];
        if (finish) {
            finish(dict, path);
        }
    } didFailLoaded:fail];
}
/**
 *
 *  删除好友
 *  account 删除账号
 *
 **/
+(void)deleteMyFriendWithAccount:(NSString *)account friendAccounts:(NSArray *)friendAccounts didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(account)
    {
        
        [bodyDict setObject:account forKey:@"account"];
    }
    
    [bodyDict setObject:friendAccounts forKey:@"friendAccounts"];
    [RestApi requestWithPathAtAuthorization:KAPI_DeleteMyFriend body:bodyDict didFinishLoaded:finish didFailLoaded:fail];

}

/**
变更---讨论组转群组  添加允许设置某人为群组创建者

 @param groupID 必选 群组ID
 @param groupName 必选 群组名字最长为50个字符
 @param declared 可选 群组公告最长为200个字符
 @param permission 可选 申请加入模式 0：默认直接加入1：需要身份验证 2：私人群组缺省0
 @param groupDomain 可选 用户扩展字段
 @param userName 可选 自定义账号（自定义登录方式需传此参数并且应用ID不能为空），当 subAccountSid参数为空时生效
 @param uesracc 可选 群员唯一标识，如果传入则设置该群员为群组创建者
 @param finish 回调
 @param fail 失败
 */
-(void)ModifyGroupAndMemberRoleWithGroupId:(NSString *)groupID withGroupName:(NSString *)groupName withDeclared:(NSString *)declared withPermission:(NSString *)permission withGroupDomain:(NSString *)groupDomain withUserName:(NSString *)userName withUseracc:(NSString *)useracc didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(groupID))
    {
        [bodyDict setObject:groupID forKey:@"groupId"];
    }
    if(!KCNSSTRING_ISEMPTY(groupName))
    {
        [bodyDict setObject:groupName forKey:@"name"];
    }
    if(!KCNSSTRING_ISEMPTY(declared))
    {
        [bodyDict setObject:declared forKey:@"declared"];
    }
    if(!KCNSSTRING_ISEMPTY(permission))
    {
        [bodyDict setObject:permission forKey:@"permission"];
    }
    if(!KCNSSTRING_ISEMPTY(groupDomain))
    {
        [bodyDict setObject:groupDomain forKey:@"groupDomain"];
    }
    if(!KCNSSTRING_ISEMPTY(userName))
    {
        [bodyDict setObject:userName forKey:@"userName"];
    }
    if(!KCNSSTRING_ISEMPTY(useracc))
    {
        NSString *u =[NSString stringWithFormat:@"%@#%@",[[Common sharedInstance] getAppid],useracc];
        [bodyDict setObject:u forKey:@"useracc"];
    }
    
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@%@?sig=",httpStr,[[Common sharedInstance] getRestHost],[[Common sharedInstance] getAppid], KAPI_ModifyGroupAndMemberRole] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
//    NSString *requestStr = [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@%@?sig=",httpStr,[[Common sharedInstance]getRestHost],[[Common sharedInstance]getAppid],kAPI_Join_group] ;
//    [RestApi requestGetHistoryMessagePathAtAuthorization:requestStr body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
//       [RestApi requestWithPathAtAuthorization:KAPI_ModifyGroupAndMemberRole body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}

/**
 查询消息已读状态
 
 @param type       0 未读 1已读
 @param msgId      消息id
 @param pageSize   每页数量
 @param pageNo     页数
 @param completion block返回值
 */
- (void)queryMessageReadStatus:(NSInteger)type
                         msgId:(NSString*)msgId
                      pageSize:(NSInteger)pageSize
                        pageNo:(NSInteger)pageNo
                    completion:(void (^)(NSString *err,NSArray *array,NSInteger totalSize))completion{
    
    AFHTTPSessionManager *mgr = [RestApi sharedInstance].manager;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *timerStr =  [dateFormatter stringFromDate:[NSDate date]];
    NSString *authorBase64 = [NSString stringWithFormat:@"%@:%@",[[Common sharedInstance] getAppid],timerStr];
    authorBase64 = [[authorBase64 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [mgr.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [mgr.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [mgr.requestSerializer setValue:authorBase64 forHTTPHeaderField:@"Authorization"];
    [mgr.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return parameters;
    }];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setValue:msgId forKey:@"msgId"];
    [bodyDict setValue:@(pageSize) forKey:@"pageSize"];
    [bodyDict setValue:@(pageNo) forKey:@"pageNo"];
    [bodyDict setValue:@(type) forKey:@"type"];
    [bodyDict setValue:[[Common sharedInstance] getAccount] forKey:@"userName"];
    
    NSString *paramter = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *sig = [[NSString stringWithFormat:@"%@%@%@",[[Common sharedInstance] getAppid],[[Common sharedInstance] getApptoken],timerStr] MD5EncodingString];
    NSString *url = nil;
    NSString *currentURL = [RestApi getCurrentUrlString];
    if (!KCNSSTRING_ISEMPTY(currentURL)) {
         url = [NSString stringWithFormat:@"%@/2016-08-15/Application/%@/IMPlus/MessageReceipt?sig=%@",currentURL,[[Common sharedInstance] getAppid],sig];
    }else{
        url = @"";
    }
 
    if ([url hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 是否允许,NO-- 不允许无效的证书
        [securityPolicy setAllowInvalidCertificates:YES];
        securityPolicy.validatesDomainName = NO;
        mgr.securityPolicy = securityPolicy;
    }
    
    [mgr POST:url parameters:paramter progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *statusCode = [responseObject objectForKey:@"statusCode"];
        NSArray *result = [responseObject objectForKey:@"result"];
        NSInteger totalSize = [[responseObject objectForKey:@"totalSize"] integerValue];
        NSMutableArray *readStatusArray = [NSMutableArray array];
        for (NSDictionary *dict in result) {
            ECReadMessageMember *member = [[ECReadMessageMember alloc] init];
            member.userName = dict[@"useracc"];
            member.timetmp = dict[@"time"];
            [readStatusArray addObject:member];
        }
        DDLogInfo(@"queryMessageReadStatus-statusCode:%@,readStatusArray:%@,totalSize:%ld",statusCode,readStatusArray,(long)totalSize);
        completion(statusCode,readStatusArray,totalSize);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion([NSString stringWithFormat:@"%ld",(long)error.code],nil,0);
    }];
}

+ (NSString *)getCurrentUrlString{
    NSString *requestURL = nil;
    NSString *currentUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"kitAppIP"];
    BOOL IPChanged =  [[[NSUserDefaults standardUserDefaults]objectForKey:@"HaveChangedIPWithRonglian"]boolValue];
    
    //配置IP
    NSString *configIP = [[NSUserDefaults standardUserDefaults]stringForKey:@"_tf_connector_ip"];
//    NSInteger configPort = [[[NSUserDefaults standardUserDefaults]stringForKey:@"_tf_connector_port"]integerValue];
    
    if (IPChanged && !KCNSSTRING_ISEMPTY(currentUrl) && !kSwitchPBSURL) {
        requestURL = currentUrl;
    }else{
//        if (!KCNSSTRING_ISEMPTY(configIP)) {
//            requestURL =[NSString stringWithFormat:@"%@://%@:%d",kRequestHttp,configIP,kPORT];
//        }else{
        requestURL = [NSString stringWithFormat:@"%@://%@:%d",kRequestHttp,kHOST,kPORT];
//        }
      
    }
    return requestURL;
}

/**
 *
 * 获取线下终端会议室
 * account 唯一标识
 *
 **/
+ (void)getOfflineRoomsWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:account forKey:@"account"];
    [RestApi requestWithPath:KAPI_GetOfflineRooms body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+ (void)getKeyByFileNodeIdWithAccount:(NSString *)account withNodeId:(NSString *)fileNodeId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(account)
    {
        [bodyDict setObject:account forKey:@"account"];
    }
    
    if(fileNodeId)
    {
        [bodyDict setObject:fileNodeId forKey:@"fileNodeId"];
        
    }
    
    [RestApi requestWithPath:KAPI_File_getKeyByNodeId body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+(void)getRedpacketSignWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    [bodyDict setObject:account forKey:@"account"];
    [RestApi requestWithPath:kAPI_GetRedpacketSign body:bodyDict didFinishLoaded:finish didFailLoaded:fail];

}
/**
 * 获取历史消息记录   个人聊天
 * appId           应用Id  必选
 * userName        登录帐号 必选
 * version         消息版本号 可选
 * msgId           消息Id version和msgId两个参数二选一，都传则以version为准 可选
 * pageSize        获取消息条数，最多100条。默认10条 可选
 * talker          交互者账号 必选
 * order           1.升序 2.降序 默认1  可选
 默认拉取消息类型msgType
 **/

+(void)getHistoryMyChatMessageWithAccount:(NSString *)userName withAppid:(NSString *)appid version:(long long)version msgId:(NSString *)msgId pageSize:(NSInteger)pageSize talker:(NSString *)talker order:(NSInteger)order andMsgType:(NSInteger)msgType didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    if(appid)
    {
        [bodyDict setObject:appid forKey:@"appId"];
    }
    
    if(!KCNSSTRING_ISEMPTY(msgId))
    {
        [bodyDict setObject:msgId forKey:@"msgId"];
    }
    
    if(pageSize>0)
    {
        [bodyDict setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    }
    
    if(version>0)
    {
        
        [bodyDict setObject:[NSNumber numberWithLongLong:version] forKey:@"version"];
        
        //        [bodyDict setObject:userName forKey:@"talker"];
        //        if(userName)
        //        {
        //            [bodyDict setObject:talker forKey:@"userName"];
        //        }
        
    }
    
    if(talker)
    {
        
        [bodyDict setObject:talker forKey:@"talker"];
    }
    
    if(userName)
    {
        [bodyDict setObject:userName forKey:@"userName"];
    }
    
    
    [bodyDict setObject:@"1" forKey:@"msgDecompression"];
    
    
    [bodyDict setObject:[NSNumber numberWithInteger:order] forKey:@"order"];
    
    [bodyDict setObject:[NSNumber numberWithInteger:msgType] forKey:@"msgType"];
    
    
    NSString *httpStr = @"http";
    if([[Common sharedInstance]getRestHost] && [[[Common sharedInstance]getRestHost] hasSuffix:@"8883"])
    {
        httpStr = @"https";
    }
    //@"http://10.3.143.19:8881/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig="
    //[NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[RXUser sharedInstance].restHost,[RXUser sharedInstance].appid]  [NSString stringWithFormat:KApi_GetHistroyMessage,[RXUser sharedInstance].appid]
    
   
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/ClientHistroyMsg?sig=",httpStr,[[Common sharedInstance]getRestHost], [[Common sharedInstance]getAppid]]  body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
}



+ (void)getApps:(NSString *)account type:(NSString*)type compId:(NSString*)compId currentPage:(int) currentPage pagesize:(int) pagesize didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:account forKey:@"account"];
    [bodyDict setObject:compId forKey:@"compId"];
    [bodyDict setObject:type forKey:@"type"];
    [bodyDict setObject:[NSString stringWithFormat:@"%d",currentPage] forKey:@"currentPage"];
    [bodyDict setObject:[NSString stringWithFormat:@"%d",pagesize]  forKey:@"pageSize"];
    [RestApi requestWithPath:kAPI_GetApps body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+ (void)getMyApps:(NSString *)account compId:(NSString*)compId didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:account forKey:@"account"];
    [bodyDict setObject:compId forKey:@"compId"];
    [RestApi requestWithPath:kAPI_GetMyApps body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

+ (void)installApps:(NSString *)account compId:(NSString *)compId type:(NSString*)type appId:(NSString*)appId  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:account forKey:@"account"];
    [bodyDict setObject:compId forKey:@"compId"];
    [bodyDict setObject:type forKey:@"type"];
    [bodyDict setObject:appId forKey:@"appId"];
    [RestApi requestWithPath:kAPI_InstallApps body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
#pragma mark HCQ SSO
-(void)requestGetIdToken:(NSString *)path authStr:(NSString *)authStr body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    
    [[RestApi sharedInstance].manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [[RestApi sharedInstance].manager.requestSerializer setValue:authStr forHTTPHeaderField:@"Authorization"];
    
    [[RestApi sharedInstance]requestPost:path params:body didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        if (finish) {
            finish(dict,path);
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        if (fail) {
            fail(error,path);
        }
    }];
}
///add by李晓杰
///批量获取用户头像
- (void)getUserAvatarListByUseraccList:(NSArray *)useraccList type:(NSString *)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSArray* array = useraccList;
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:array forKey:@"userAccounts"];
    [bodyDict setObject:type forKey:@"type"];
    if([[[Common sharedInstance] getAccount] length]){
        [bodyDict setObject:[[Common sharedInstance] getAccount] forKey:@"account"];
    }
    [RestApi requestWithPathAtAuthorization:[NSString stringWithFormat:kAPI_GetVOIPUserInfo] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 @brief 扫一扫加入群 add by keven.
 @param confirm 1:不需要同意直接入群
 @param declared  传fromQRCode:这个字段会在 sdk的回调里返回  用作区分是通过二维码还是普通的邀请加群
 @param groupId  群id
 @param members  传被邀请人account数组
 @param userName  群主账号
 */
- (void)joinGroupChatWithConfirm:(NSInteger)confirm  Declared:(NSString *)declared GroupId:(NSString *)groupId Members:(NSArray*)members UserName :(NSString *)userName  didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:@(confirm) forKey:@"confirm"];
    if(!KCNSSTRING_ISEMPTY(declared))
    {
        [bodyDict setObject:declared forKey:@"declared"];
    }
    if(!KCNSSTRING_ISEMPTY(groupId))
    {
        [bodyDict setObject:groupId forKey:@"groupId"];
    }
    if (members!=nil&&members.count>0)
    {
        [bodyDict setObject:members forKey:@"members"];
    }
    
    if(!KCNSSTRING_ISEMPTY(userName))
    {
        [bodyDict setObject:userName forKey:@"userName"];
    }
//    [RestApi requestWithPathAtAuthorization:kAPI_Join_group body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
    NSString *httpStr = @"http";
    if([[Common sharedInstance]getRestHost] && [[[Common sharedInstance]getRestHost] hasSuffix:@"8883"])
    {
        httpStr = @"https";
    }
    NSString *requestStr = [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@%@?sig=",httpStr,[[Common sharedInstance]getRestHost],[[Common sharedInstance]getAppid],kAPI_Join_group] ;
    [RestApi requestGetHistoryMessagePathAtAuthorization:requestStr body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
    /**
     获取已读未读数量
     
     @param msgId 消息id
     @param version 消息版本号msgId和version传一个即可 都传以version为准
     @param type 类型 1.已读 2.未读
     @param userName 用户账号
     @param isReturnList 是否获取人员列表 1-是；2-否
     @param
     */
- (void)getMessageReceiptByMsgId:(NSString *)msgId version:(NSString *)version type:(NSString *)type userName:(NSString *)userName isReturnList:(NSString *)isReturnList pageNo:(int)pageNo didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(version)){
        [bodyDict setObject:version forKey:@"version"];
    }
    if (![bodyDict hasValueForKey:@"version"] &&
        !KCNSSTRING_ISEMPTY(msgId)) {
        [bodyDict setObject:msgId forKey:@"msgId"];
    }
    
    if(type){
        [bodyDict setObject:type forKey:@"type"];
    }
    if(userName){
        [bodyDict setObject:userName forKey:@"userName"];
    }
    if(isReturnList){
        [bodyDict setObject:isReturnList forKey:@"isReturnList"];
    }
    if (pageNo) {
        [bodyDict setObject:@(pageNo) forKey:@"pageNo"];
    }
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/MessageReceipt?sig=",httpStr,[[Common sharedInstance] getRestHost], [[Common sharedInstance] getAppid]] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 获取已读未读数量
 

 */
- (void)setDisturb:(NSString *)msgId version:(NSString *)version type:(NSString *)type userName:(NSString *)userName isReturnList:(NSString *)isReturnList didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(version)){
        [bodyDict setObject:version forKey:@"version"];
    }
    if (![bodyDict hasValueForKey:@"version"] &&
        !KCNSSTRING_ISEMPTY(msgId)) {
        [bodyDict setObject:msgId forKey:@"msgId"];
    }
    
    if(type){
        [bodyDict setObject:type forKey:@"type"];
    }
    if(userName){
        [bodyDict setObject:userName forKey:@"userName"];
    }
    if(isReturnList){
        [bodyDict setObject:isReturnList forKey:@"isReturnList"];
    }
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/SetDisturb?sig=",httpStr,[[Common sharedInstance] getRestHost], [[Common sharedInstance] getAppid]] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 设置消息免打扰

 @param userAccount 用户账号
 @param state 状态 1开清静音，2，关闭静音
@param type 状态   1开启静音  2关闭静音
 */
-(void)setMsgRuleUserAccount:(NSString *)userAccount withState:(NSString *)state withType:(NSString *)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
      NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(userAccount){
        [bodyDict setObject:userAccount forKey:@"userName"];
    }
    if(state){
        [bodyDict setObject:state forKey:@"state"];
    }
    if(type){
        [bodyDict setObject:type forKey:@"type"];
    }
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
//    NSString *str = @"139.199.128.158:8881";
     [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@%@?sig=",httpStr,[[Common sharedInstance] getRestHost], [[Common sharedInstance] getAppid],KAPT_SetMsgMute] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


/**
 获取设置静音的装填

 @param account 用户账号
 @param finish 成功回调
 @param fail 失败回调
 */
-(void)getMsgMuteWithAccount:(NSString *)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];

    if(account){
        [bodyDict setObject:account forKey:@"userName"];
    }
   
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@%@?sig=",httpStr,[[Common sharedInstance] getRestHost], [[Common sharedInstance] getAppid],KAPT_GetMsgMute] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
    
    
}

/**
 获取已读未读数量

 @param msgId 消息id
 @param version 消息版本号msgId和version传一个即可 都传以version为准
 @param type 类型 1.已读 2.未读
 @param userName 用户账号
 @param isReturnList 是否获取人员列表 1-是；2-否
 */
- (void)getMessageReceiptByMsgId:(NSString *)msgId version:(NSString *)version type:(NSString *)type userName:(NSString *)userName isReturnList:(NSString *)isReturnList didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(version)){
        [bodyDict setObject:version forKey:@"version"];
    }
    if (![bodyDict hasValueForKey:@"version"] &&
        !KCNSSTRING_ISEMPTY(msgId)) {
        [bodyDict setObject:msgId forKey:@"msgId"];
    }

    if(type){
        [bodyDict setObject:type forKey:@"type"];
    }
    if(userName){
        [bodyDict setObject:userName forKey:@"userName"];
    }
    if(isReturnList){
        [bodyDict setObject:isReturnList forKey:@"isReturnList"];
    }
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@/IM/MessageReceipt?sig=",httpStr,[[Common sharedInstance] getRestHost], [[Common sharedInstance] getAppid]] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 获取通讯录

 @param deptId 部门ID,获取人员时部门ID为必选
 @param level 获取通讯录级别 ：0—企业、1—部门、2—人员
 @param isBig 是否是大通讯录 0—不是  1—是
 */
- (void)getLargeCompanyAddressByDeptId:(NSString *)deptId level:(NSString *)level isBig:(NSString *)isBig didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(deptId)){
        [bodyDict setObject:deptId forKey:@"deptId"];
    }
    if(level){
        [bodyDict setObject:level forKey:@"level"];
    }
    if(isBig){
        [bodyDict setObject:isBig forKey:@"isBig"];
    }
    [bodyDict setObject:[[Common sharedInstance] getAccount] forKey:@"account"];
    [RestApi requestWithPath:kAPI_GetLargeAddressBook body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 搜索联系人

 @param searchValue 搜索值
 @param page 页码 从0开始
 @param pageSize 页大小 默认20
 */
- (void)getLargeSearchFriendBySearchValue:(NSString *)searchValue page:(NSInteger)page pageSize:(NSInteger)pageSize didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(searchValue){
        [bodyDict setObject:searchValue forKey:@"searchValue"];
    }
    [bodyDict setObject:@(page) forKey:@"page"];
    [bodyDict setObject:@(pageSize) forKey:@"pageSize"];
    [bodyDict setObject:[[Common sharedInstance] getAccount] forKey:@"account"];
    [RestApi requestWithPath:kAPI_GetLargeSearchFriend body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
#pragma mark -  设备安全

+ (NSString *)getBaseUrlStringInDeviceSafe {
    return [NSString stringWithFormat:@"%@://%@:%d",kRequestHttpInDeviceSafe,kHOST,kPORTInDeviceSafe];
}

//设备安全如果isSigAuthority=YES,则url后面拼接{sig}/{date}
- (void)requestInEquipmentLockSafeWithPath:(NSString *)path isSigAuthority:(BOOL)isSigAuthority body:(NSDictionary *)body didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail
{
    NSAssert(path!=nil, @"the url path can't be null");
    NSString *currentURL = [RestApi  getBaseUrlStringInDeviceSafe];
    NSString *urlPath = [NSString stringWithFormat:@"%@%@",currentURL,path];
    if (isSigAuthority) {//设备安全
        NSDate* date = [NSDate date];
        NSString* requestTime =  [RestApi requestTime:date];
        
        NSString *authorization =[NSString stringWithFormat:@"%@:%@",[[Common sharedInstance]getAppid],requestTime];
        NSString * sigStr = [[NSString stringWithFormat:@"%@%@%@",[[Common sharedInstance]getAppid],[[Common sharedInstance]getApptoken],requestTime] MD5EncodingString];
        
        urlPath =[NSString stringWithFormat:@"%@%@%@/%@",currentURL,path,sigStr,requestTime];
        
        [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
        [[RestApi sharedInstance].manager.requestSerializer setValue:[authorization base64EncodingString] forHTTPHeaderField:@"Authorization"];
    }
    
    //AFN基本配置
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [RestApi sharedInstance].manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain", nil];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;
    [[RestApi sharedInstance].manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[RestApi sharedInstance]requestPost:urlPath params:body didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        if (finish) {
            finish(dict,path);
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        if (fail) {
            fail(error,path);
        }
    }];
    
}
/**
 @brief 安全登录接口 add by keven
 @param loginName 客户端登录账号
 @param cipherCode  用户密钥（MD5小写密码）
 @param macAddr  当前设备唯一标识
 */
- (void)safeLoginInEquipmentLockWithLoginName:(NSString*)loginName cipherCode:(NSString *)cipherCode macAddr:(NSString *)macAddr didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(loginName)){
        [bodyDict setObject:loginName forKey:@"loginName"];
    }
    if(!KCNSSTRING_ISEMPTY(macAddr)){
        [bodyDict setObject:macAddr forKey:@"macAddr"];
    }
    if(!KCNSSTRING_ISEMPTY(cipherCode)){
        [bodyDict setObject:cipherCode forKey:@"cipherCode"];
    }
    
    [self requestInEquipmentLockSafeWithPath:kSafeLoginInEquipment isSigAuthority:NO body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}
/**
 @brief 开启/取消设备锁账号 add by keven
 @param account 开启/取消设备锁账号
 @param status  设备锁状态 0：取消 1：开启
 */
- (void)setEquipmentLockWithAccount:(NSString*)account Status:(int)status didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(account)){
        [bodyDict setObject:account forKey:@"account"];
    }
    [bodyDict setObject:@(status) forKey:@"status"];
    
    [self requestInEquipmentLockSafeWithPath:kSetEquipmentLock isSigAuthority:YES body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 @brief 查询受信任设备列表 add by keven
 @param account account
 */
- (void)getTrustedEquipmentListWithAccount:(NSString*)account didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSString * baseURL = [NSString stringWithFormat:@"%@%@/",kGetTrustedEquipmentList,account];
     [self requestInEquipmentLockSafeWithPath:baseURL isSigAuthority:YES body:nil didFinishLoaded:finish didFailLoaded:fail];
}

/**
 @brief 获取短信验证码 add by keven
 @param phoneNum 手机号
 */
- (void)getSMSInEquipmentLockWithPhoneNum:(NSString*)phoneNum didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSString * baseURL = [NSString stringWithFormat:@"%@%@",kGetSMSInEquipmentLock,phoneNum];
    [self requestInEquipmentLockSafeWithPath:baseURL isSigAuthority:NO body:nil didFinishLoaded:finish didFailLoaded:fail];
}

/**
 @brief 移动端确认PC安全登陆接口
 @param uuid
 */
- (void)confirmLoginWithAccount:(NSString*)account uuid:(NSString *)uuid didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(account)){
        [bodyDict setObject:account forKey:@"account"];
    }
    if(!KCNSSTRING_ISEMPTY(uuid)){
        [bodyDict setObject:uuid forKey:@"uuid"];
    }
    
    [self requestInEquipmentLockSafeWithPath:kConfirmLoginForPCInEquipment isSigAuthority:YES body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 @brief 删除受信任设备
 */
- (void)delTrustedEquipmentWithAccount:(NSString*)account macAddr:(NSString *)macAddr didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(account)){
        [bodyDict setObject:account forKey:@"account"];
    }
    if(!KCNSSTRING_ISEMPTY(macAddr)){
        [bodyDict setObject:macAddr forKey:@"macAddr"];
    }
    
    [self requestInEquipmentLockSafeWithPath:kDelTrustedEquipment isSigAuthority:YES body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

/**
 @brief 通过短信验证码绑定手机号
 */
- (void)bindPhoneBySMSWithAccount:(NSString*)account phoneNum:(NSString *)phoneNum smsCode:(NSString *)smsCode didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    if(!KCNSSTRING_ISEMPTY(account)){
        [bodyDict setObject:account forKey:@"account"];
    }
    if(!KCNSSTRING_ISEMPTY(phoneNum)){
        [bodyDict setObject:phoneNum forKey:@"phoneNum"];
    }
    if(!KCNSSTRING_ISEMPTY(smsCode)){
        [bodyDict setObject:smsCode forKey:@"smsCode"];
    }
    [self requestInEquipmentLockSafeWithPath:kBindPhoneBySMS isSigAuthority:YES body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


/**
 @brief 短信绑定设备接口
 @param phoneNum 手机号
 @param smsCode 短信验证码
 @param macAddr 当前设备唯一标识
 @param name 设备名称（例如：Chan's iPhone）
 @param type 1:Android、2：iOS、3：H5、4：pc 5：mac
 */
- (void)bindEquipmentAndLoginInEquipmentWithphoneNum:(NSString *)phoneNum smsCode:(NSString *)smsCode macAddr:(NSString *)macAddr name:(NSString *)name type:(int)type didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail {
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
  
    if(!KCNSSTRING_ISEMPTY(phoneNum)){
        [bodyDict setObject:phoneNum forKey:@"phoneNum"];
    }
    if(!KCNSSTRING_ISEMPTY(smsCode)){
        [bodyDict setObject:smsCode forKey:@"smsCode"];
    }
    if(!KCNSSTRING_ISEMPTY(macAddr)){
        [bodyDict setObject:macAddr forKey:@"macAddr"];
    }
    if(!KCNSSTRING_ISEMPTY(name)){
        [bodyDict setObject:name forKey:@"name"];
    }
     [bodyDict setObject:@(type) forKey:@"type"];
    
    [self requestInEquipmentLockSafeWithPath:kbindEquipmentAndLoginInEquipment isSigAuthority:NO body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}


/**
 一键创群

 @param depart_id 部门id
 @param is_full 是否遍历子部门
 @param finish 成功回调
 @param fail 失败回调
 */
- (void)createGroupMethodByDepart_id:(NSString *)depart_id is_full:(NSString *)is_full didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];

    NSMutableDictionary *authDict = [NSMutableDictionary dictionary];
    authDict[@"appId"] = [[Common sharedInstance] getAppid];
    authDict[@"appToken"] = [[Common sharedInstance] getApptoken];
    bodyDict[@"auth"] = authDict;
    bodyDict[@"userName"] = [NSString stringWithFormat:@"%@#%@",[[Common sharedInstance] getAppid],[[Common sharedInstance] getAccount]];
    ;
    bodyDict[@"comp_id"] = [[Common sharedInstance] getCompanyId];
    if(!KCNSSTRING_ISEMPTY(depart_id)){
        [bodyDict setObject:depart_id forKey:@"depart_id"];
    }
    if(is_full){
        [bodyDict setObject:is_full forKey:@"is_full"];
    }
    bodyDict[@"sig"] = [@"yuntongxunytx123" MD5EncodingString];

    NSDate *date = [NSDate date];
    NSString* requestTime = [RestApi requestGMTTime:date];
    NSString *authorization = [NSString stringWithFormat:@"%@:%lld",[[Common sharedInstance] getAppid],(long long)[date timeIntervalSince1970] * 1000];

    NSMutableDictionary *headDict = [NSMutableDictionary dictionary];
    [headDict setObject:[RestApi userAgent] forKey:@"useragent"];
    [headDict setObject:[RestApi requestTime:date] forKey:@"reqtime"];

    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:headDict forKey:@"head"];


    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:requestTime forHTTPHeaderField:@"Date"];
    [[RestApi sharedInstance].manager.requestSerializer setValue:[authorization  base64EncodingString] forHTTPHeaderField:@"Authorization"];
    [RestApi sharedInstance].manager.requestSerializer.timeoutInterval = SettingAFRequestTimeOUT;

    NSString *currentURL = [RestApi  getCurrentUrlString];
    if (!KCNSSTRING_ISEMPTY(currentURL)) {
        [[RestApi sharedInstance] requestPost:[NSString stringWithFormat:@"%@%@",currentURL,@"/common/group/createGroupMethod"] params:bodyDict didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            if (finish) {
                finish(dict, path);
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (fail) {
                fail(error, path);
            }
        }];
    }
}

- (void)subscribeModifyByAccount:(NSString *)account type:(NSString *)type eventType:(NSString *)eventType publisherUserAccs:(NSArray *)publisherUserAccs didFinishLoaded:(didFinishLoaded)finish didFailLoaded:(didFailLoaded)fail{
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setObject:account?account:@"" forKey:@"useracc"];
    [bodyDict setObject:type forKey:@"type"];
    [bodyDict setObject:@"1" forKey:@"eventType"];
    [bodyDict setObject:publisherUserAccs forKey:@"publisherUserAccs"];
    
    
    NSString *httpStr = @"http";
    if([[Common sharedInstance] getRestHost] &&
       [[[Common sharedInstance] getRestHost] hasSuffix:@"8883"]){
        httpStr = @"https";
    }
    [RestApi requestGetHistoryMessagePathAtAuthorization: [NSString stringWithFormat:@"%@://%@/2013-12-26/Application/%@%@?sig=",httpStr,[[Common sharedInstance] getRestHost], [[Common sharedInstance] getAppid],KAPI_SubscribeState] body:bodyDict didFinishLoaded:finish didFailLoaded:fail];
}

@end
