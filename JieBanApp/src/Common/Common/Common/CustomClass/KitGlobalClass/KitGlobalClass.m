//
//  KitGlobalClass.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "KitGlobalClass.h"
#import "KCConstants_string.h"


#define UserDefault_UserName        @"UserDefault_Username"
#define UserDefault_UserPwd         @"UserDefault_UserPwd"
#define UserDefault_LoginAuthType   @"UserDefault_LoginAuthType"

#define UserDefault_NickName    [NSString stringWithFormat:@"%@_nickName",self.userName]
#define UserDefault_UserSex     [NSString stringWithFormat:@"%@_UserSex",self.userName]
#define UserDefault_UserBirth   [NSString stringWithFormat:@"%@_UserBirth",self.userName]
#define UserDefault_UserDataVer     [NSString stringWithFormat:@"%@_UserDataVer",self.userName]

//应用信息配置文件
#define AppConfigPlist @"AppConfig.plist"
#define AppConfig_AppKey @"AppKey"
#define AppConfig_AppToken @"AppToken"

//应用设置Key
#define messageSoundKey @"message_sound"
#define messageShakeKey @"message_shake"
#define playVoiceEar @"playvoice_ear"

@interface KitGlobalClass()
@property (nonatomic, strong) NSMutableDictionary *appinfoDic;
@end

@implementation KitGlobalClass

+(KitGlobalClass*)sharedInstance {
    
    static KitGlobalClass *kitGlobalClass;
    static dispatch_once_t kitGlobalClassonce;
    dispatch_once(&kitGlobalClassonce, ^{
        kitGlobalClass = [[KitGlobalClass alloc] init];
    });
    return kitGlobalClass;
}

-(id)init {
    
    if (self = [super init]) {
        self.mainAccontDictionary = [NSMutableDictionary dictionary];
        self.allSessions = [NSMutableDictionary dictionary];
        [self readAppConfig];
    }
    return self;
}

-(void)readAppConfig {
    self.appinfoDic=[NSMutableDictionary dictionary];
}

-(NSString*)appKey {
    NSString *value = [self.appinfoDic objectForKey:AppConfig_AppKey];
    DDLogInfo(@"appconfig appkey=%@",value);
    return value;
}

-(NSString*)appToken {
    NSString *value = [self.appinfoDic objectForKey:AppConfig_AppToken];
    DDLogInfo(@"appconfig apptoken=%@",value);
    return value;
}

-(void)setLoginAuthType:(LoginAuthType)loginAuthType {
    [[NSUserDefaults standardUserDefaults] setObject:@(loginAuthType) forKey:UserDefault_LoginAuthType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(LoginAuthType)loginAuthType {
    NSNumber *type = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_LoginAuthType];
    NSUInteger typeInt = type.unsignedIntegerValue;
    return typeInt==0?1:typeInt;
}

-(void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:UserDefault_UserName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)userName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserName];
}

- (void)setUserPassword:(NSString *)userPassword{
    [[NSUserDefaults standardUserDefaults] setObject:userPassword forKey:UserDefault_UserPwd];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)userPassword {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserPwd];
}

-(void)setNickName:(NSString *)nickName {
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:UserDefault_NickName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)nickName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_NickName];
}

-(void)setSex:(ECSexType)sex {
    [[NSUserDefaults standardUserDefaults] setObject:@(sex) forKey:UserDefault_UserSex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(ECSexType)sex {
    NSNumber* nssex = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserSex];
    return nssex.integerValue;
}

-(void)setDataVersion:(unsigned long long)dataVersion {
    [[NSUserDefaults standardUserDefaults] setObject:@(dataVersion) forKey:UserDefault_UserDataVer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(unsigned long long)dataVersion {
    NSNumber* nsdataver = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserDataVer];
    return nsdataver.unsignedLongLongValue;
}

-(void)setBirth:(NSString *)birth {
    [[NSUserDefaults standardUserDefaults] setObject:birth forKey:UserDefault_UserBirth];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)birth {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserBirth];
}

-(void)setIsMessageSound:(BOOL)isMessageSound {
    [[NSUserDefaults standardUserDefaults] setObject:@(isMessageSound) forKey:messageSoundKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isMessageSound {
    NSNumber* isPlay = [[NSUserDefaults standardUserDefaults] valueForKey:messageSoundKey];
    if (isPlay==nil || isPlay.boolValue){
        return YES;
    }
    return NO;
}

-(void)setIsMessageShake:(BOOL)isMessageShake {
    [[NSUserDefaults standardUserDefaults] setObject:@(isMessageShake) forKey:messageShakeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isMessageShake {
    NSNumber* isPlay = [[NSUserDefaults standardUserDefaults] valueForKey:messageShakeKey];
    if (isPlay==nil || isPlay.boolValue){
        return YES;
    }
    return NO;
}

-(void)setIsPlayEar:(BOOL)isPlayEar {
    [[NSUserDefaults standardUserDefaults] setObject:@(isPlayEar) forKey:playVoiceEar];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isPlayEar {
    NSNumber* isear = [[NSUserDefaults standardUserDefaults] valueForKey:playVoiceEar];
    return isear.boolValue;
}
//webView页面字体大小
- (void)setWebViewFontSize:(NSString *)webViewFontSize{
    
    [[NSUserDefaults standardUserDefaults] setObject:webViewFontSize forKey:@"webViewFontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)webViewFontSize{
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"webViewFontSize"];
}

- (void)setIsCallIdentify:(BOOL)isCallIdentify{
    [[NSUserDefaults standardUserDefaults] setObject:@(isCallIdentify) forKey:@"isCallIdentify"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isCallIdentify{
    NSNumber* isflag = [[NSUserDefaults standardUserDefaults] valueForKey:@"isCallIdentify"];
    if (isflag.boolValue){
        return YES;
    }
    return NO;
}
@end
