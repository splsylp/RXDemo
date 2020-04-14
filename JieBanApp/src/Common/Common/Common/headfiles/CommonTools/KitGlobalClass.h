//
//  KitGlobalClass.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ECEnumDefs.h"
//#import "ECLoginInfo.h"


#define nameKey @"contact_nameKey"
#define phoneKey @"contact_phoneKey"
#define imageKey @"contact_imageKey"

#define KNotice_GetGroupName  @"KNotice_GetGroupName"

#define kSofeVer @"5.0.2r"


@class ECLoginInfo;

@interface KitGlobalClass : NSObject
/**
 *@brief 获取KitGlobalClass单例句柄
 */
+(KitGlobalClass*)sharedInstance;


/**
 *@brief 主账号信息
 */
@property (nonatomic, strong) NSMutableDictionary* mainAccontDictionary;

@property (nonatomic, strong) NSMutableDictionary* allSessions;

@property (nonatomic, readonly) NSString* appKey;

@property (nonatomic, readonly) NSString* appToken;

@property (nonatomic, copy) NSString* userName;

@property (nonatomic, copy) NSString* userPassword;

@property (nonatomic, assign) LoginAuthType loginAuthType;

@property (nonatomic, copy) NSString* nickName;

@property (nonatomic, assign) ECSexType sex;

@property (nonatomic, copy) NSString *birth;

@property (nonatomic, assign) unsigned long long dataVersion;

//是否已经登录
@property (nonatomic, assign) BOOL isAutoLogin;

@property (nonatomic, assign) BOOL isLogin;

@property (nonatomic, assign) BOOL isHiddenLoginError;//是否已经发起登录请求

@property (nonatomic, assign) ECNetworkType netType;

@property (nonatomic, assign) BOOL isNeedSetData;

@property (nonatomic, assign) BOOL isNeedUpdate;

@property (nonatomic, assign) BOOL isMessageSound;

@property (nonatomic, assign) BOOL isMessageShake;

@property (nonatomic, assign) BOOL isPlayEar;
  
@property (assign, nonatomic)BOOL isRecodeInsertSplite;

//webView页面字体大小
@property (nonatomic,strong) NSString * webViewFontSize;

/** 是否已开启来电识别**/
@property (nonatomic, assign) BOOL isCallIdentify;

@end
