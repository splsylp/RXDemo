//
//  BaseComponent.m
//  BaseComponent
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseComponent.h"
#import "KCConstants_string.h"
@implementation BaseComponent

-(UIViewController*)mainView{
    return [[UIViewController alloc] init];
}

-(NSString*)getUserName{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    if (dict) {
        NSAssert(dict.count, @"****** getUserName 没有返回数据! ******");
        return [dict objectForKey:Table_User_member_name];
    }
   return nil;
};

//-(NSArray*)getConfRooms{
//    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
//    NSAssert(dict.count, @"****** getUserName 没有返回数据! ******");
//    return [dict objectForKey:Table_User_confRooms];
//};

-(NSString*)getAccount{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    if (dict) {
        NSAssert(dict.count, @"****** getAccount 没有返回数据! ******");
        return [dict objectForKey:Table_User_account]?[dict objectForKey:Table_User_account]:@"";
    }
    return nil;
}

-(NSString*)getMobile{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    if (dict) {
        NSAssert(dict.count, @"****** getMobile 没有返回数据! ******");
        return [dict objectForKey:Table_User_mobile];
    }
    return nil;
}

- (NSString *)getStaffNo {
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    if (dict) {
        NSAssert(dict.count, @"****** getStaffNo 没有返回数据! ******");
        return [dict objectForKey:Table_User_staffNo];
    }
    return nil;
}

-(NSString*)getAvatar{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_avatar];
}

-(NSString*)getAppid{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:App_AppKey];
}

-(NSString*)getApptoken{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:App_Token];
}


-(NSString*)getAppClientpwd{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:App_Clientpwd];
}

-(NSString*)getCompanyId{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_company_id];
}


-(NSString*)getAPPCompanyName{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_company_name];
}

-(NSString*)getSex{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_sex];
}

-(NSString *)getRestHost{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:App_Resthost];
}
-(NSArray *)getLvsArray{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:App_LvsArray];
}
-(NSString *)getVidyoRoomUrl {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:APP_VidyoRoomUrl];
}
-(NSString *)getConfNum_regex {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Vidyo_ConfNum_regex];
}
-(NSString *)getVidyoRoomID {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Vidyo_VidyoRoomID];
}
-(NSString *)getVidyoFQDN {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Vidyo_VidyoFQDN];
}
-(NSString *)getVidyoConfExten {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Vidyo_VidyoConfExten];
}
-(NSString *)getVidyoEntityID {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Vidyo_VidyoEntityID];
}
-(NSString *)getAuthtag {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Table_User_access_control];
}
-(NSString *)getBoardUrl {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:App_boardUrl];
}
-(NSString *)getBoardAppId {
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:APP_CooAppId];
}
-(NSString *)getApproval{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    
    return [dict objectForKey:Table_User_Approval];
}

-(NSString*)getOutlookPwd{
    NSDictionary* dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_OutlookPwd];
}
;
-(NSString*)getUserLevel{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_Level];
}

-(NSString*)getPersonLevel{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:@"RX_user_personLevel"];
}

-(NSString *)getPassMd5{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_PassMd5];
}

-(NSString *)getDepartmentId{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_department_id];
}
-(NSString *)getOaAccount
{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_oaAccount];
}
-(NSString *)getLoginTokenMd5
{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_loginTokenMd5];
}
-(NSString *)getFriendgroupUrl
{
    NSDictionary *dict = [self.componentDelegate onGetUserInfo];
    return [dict objectForKey:Table_User_FriendGroupUrl];
}

- (NSString *)getOneAccount
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_account_key"];

}
- (NSString *)getOneClientPassWord
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_clientpwd_key"];
}

- (NSString *)getOneUserName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_user_username"];
}

- (NSString *)getOneUserPhotoUrl
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_user_head_url"];
}

- (NSString *)getOneUserMobile
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_mobile_key"];

}

-(NSString *)getOneCompanyId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_companyid_key"];

}

- (NSString *)getOneUserPhotoMd5
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RX_user_url_md5"];

}

@end
