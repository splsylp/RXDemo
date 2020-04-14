//
//  YHCManager.h
//  YHCManager
//
//  Created by wangjunping on 2018/7/11.
//  Copyright © 2018年 wangwenlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHCPlugDelegate.h"
#import "YHCConnectDelegate.h"
#import "YHCConference.h"
#import "YHCConferenceDelegate.h"
#import "YHCBoard.h"
#import "YHCBoardDelegate.h"


#define YHC_App_AppKey         @"YHC_App_AppKey"         //应用Id
#define YHC_App_Token          @"YHC_App_Token"          //应用令牌
#define YHC_App_Clientpwd      @"YHC_Clientpwd_key"
#define YHC_App_AccountSid     @"YHC_App_AccountSid"
#define YHC_App_AccountToken   @"YHC_App_AccountToken"

#define Table_User_account           @"account"           //'帐号',
#define Table_User_mobile            @"mobile"            //'手机号码',
#define Table_User_email             @"email"             //'邮箱（帐号）',
#define Table_User_member_name       @"member_name"       //'姓名',
#define Table_User_avatar            @"avatar"            //'头像',
#define Table_User_sex               @"sex"               //'性别 1:女 2男',

@interface YHCManager : NSObject
@property(nonatomic, assign) id<YHCPlugDelegate,YHCConnectDelegate,YHCBoardDelegate,YHCConferenceDelegate> delegate;//代理

@property (nonatomic, assign, readonly) ECNetworkType netType;
@property (nonatomic, assign, readonly) BOOL islogin;

+ (YHCManager *)sharedInstance;

-(void)login:(NSDictionary*) loginInfo :(void(^)(NSError* error)) LoginCompletion;
-(void)logout:(void(^)(NSError* error)) LogoutCompletion;
-(void)saveLoginInfoData:(NSDictionary *)loginInfoData;
@end
