//
//  ECMessage+Ext.m
//  ECSDKDemo_OC
//
//  Created by wangming on 16/5/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ECMessage+Ext.h"
#import <objc/runtime.h>

@implementation ECMessage(Ext)

static char heightKey;
static char messageVersion;
static char messagePrimaryKey;

static char imageHeightKey;
static char imageWightKey;
static char speedKey;
static char unreadCountKey;

- (void)setHeight:(int)height{
    if (height > 0) {
        objc_setAssociatedObject(self, &heightKey, [NSNumber numberWithInt:height], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else{
        objc_setAssociatedObject(self, &heightKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (int)getHeight{
    NSString* str = objc_getAssociatedObject(self, &heightKey);
    if (str) {
        return [str intValue];
    }else{
        return -1;
    }
}

- (void)setVersion:(NSInteger)version {
    objc_setAssociatedObject(self, &messageVersion, [NSNumber numberWithInteger:version], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)getVersion {
    NSString* str = objc_getAssociatedObject(self, &messageVersion);
    if (str) {
        return [str integerValue];
    }else{
        return 0;
    }
}

- (void)setMsgPrimaryKey:(NSInteger)msgPrimaryKey{
    objc_setAssociatedObject(self, &messagePrimaryKey, [NSNumber numberWithLongLong:msgPrimaryKey], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)getMsgPrimaryKey{
    NSString *str = objc_getAssociatedObject(self, &messageVersion);
    if (str) {
        return [str integerValue];
    }else{
        return 0;
    }
}

- (void)setSpeed:(unsigned long long)speed{
    objc_setAssociatedObject(self, &heightKey, [NSNumber numberWithUnsignedLongLong:speed], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (unsigned long long)getSpeed{
    NSNumber *str = objc_getAssociatedObject(self, &heightKey);
    if (str) {
        return [str unsignedLongLongValue];
    }else{
        return 0;
    }
}
///是否是图文消息
- (BOOL)isRichTextMessage{
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    }
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_RICH_TXT]) {
        return YES;
    }
    if ([userData hasValueForKey:@"Rich_text"]) {
        return YES;
    }
    return NO;
}
///是否是阅后即焚消息
- (BOOL)isBurnWithMessage{
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    }
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_SHNAP_BURN]) {
        return YES;
    }
    if(![userData hasValueForKey:kRonxinBURN_MODE]){
        return NO;
    }
    NSString *meetType = [userData objectForKey:kRonxinBURN_MODE];
    if (![meetType isEqualToString:kRONGXINBURN_ON]) {
        return NO;
    }
    return YES;
}
///是否是名片消息
- (BOOL)isCardWithMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_CARD]) {
        return YES;
    }
    if ([userData hasValueForKey:ShareCardMode]) {
        return YES;
    }
    return NO;
}
///是否是合并消息
- (BOOL)isMergeMessage{
    if(!self){
        return NO;
    }
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_COMBINE_MSG]) {
        return YES;
    }

    if([self.userData containsString:kMergeMessage_CustomType]){
        return YES;
    }else if([self.userData containsString:kFileTransferMsgNotice_CustomType]){
        NSString *base64littleUserData = [self analysisMessage];
        NSString *decode64Base = [base64littleUserData base64DecodingString];
        if([decode64Base containsString:kMergeMessage_CustomType]){
            return  YES;
        }else{
            return  NO;
        }
    }
    return NO;
}

//给合并收藏用的
+ (BOOL)isMergeMessage:(NSString *)userdata {
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:userdata];
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_COMBINE_MSG]) {
        return YES;
    }
    if([userdata containsString:kMergeMessage_CustomType]){
        return YES;
    }
    return NO;
}

///是否是白板消息
- (BOOL)isBoardMessage{
    if(!self){
        return NO;
    }
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_WBSS]) {
        return YES;
    }
    NSString *boardValue = [userData objectForKey:@"com.yuntongxun.rongxin.message_type"];
    //进白板
    if ([boardValue isEqualToString:@"WBSS_SENDMSG"] ||
        [boardValue isEqualToString:@"WBSS_SHOWMSG"]||
        [boardValue isEqualToString:@"WBSS_HIDE"] ||
        [boardValue isEqualToString:@"WBSS_VOICE"]) {
        return YES;
    }
    return NO;
}

///是否是多终端上下线消息
- (BOOL)isMoreLoginMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if (![userData isKindOfClass:[NSDictionary class]]){return NO;};
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_ONLINE]) {//多终端上下线消息
        return YES;
    }
    if ([userData hasValueForKey:kRonxinMessageType]) {
        NSString *type = userData[kRonxinMessageType];
        //先判断是否多端登陆
        if ([type isEqualToString:PC_online]) {//PC登陆
            return YES;
        }
        if ([type isEqualToString:PC_offline]) {//PC登陆
            return YES;
        }
    }
    return NO;
}


/// 是否是修改密码消息
- (BOOL)isModifyPasswordMessage {
    if(!KCNSSTRING_ISEMPTY(self.userData) && [self.userData rangeOfString:kUpdatePwdNotice_CustomType].location != NSNotFound){
        return YES;
    }
    return NO;
}

///是否是置顶消息
- (BOOL)isTopMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] && [userData[SMSGTYPE] isEqualToString:TYPE_STICKY_ON_TOP]) {//多终端置顶同步
        return YES;
    }else if ([userData hasValueForKey:StickyOnTopChanged]) {
        return YES;
    }else if ([userData hasValueForKey:kRonxinMessageType]){
        NSString *str = userData[kRonxinMessageType];
        if ([str isEqualToString:StickyOnTopChanged]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSetMuteMessage {
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] && [userData[SMSGTYPE] isEqualToString:TYPE_NO_DISTURB]) {//多终端设置免打扰
        return YES;
    }
    return NO;
}

///是否是人员删除消息
- (BOOL)isDeleteAccountMessage{
    if (!self.userData) {return NO;}
    if ([self.userData rangeOfString:KAccountDel_CustomType].location != NSNotFound) {
        return YES;
    }
    NSDictionary *userData =  self.userDataToDictionary;
    if (![userData isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    if ([userData hasValueForKey:@"msg_type"] && [userData[@"msg_type"]integerValue] == 102) {//人员删除消息
        return YES;
    }
    return NO;
}

///是否是多终端消息通知
- (BOOL)isNotiMuteMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:NewMsgNotiSetMute]) {
        return YES;
    }else if ([userData hasValueForKey:kRonxinMessageType]){
        NSString *str = userData[kRonxinMessageType];
        if ([str isEqualToString:NewMsgNotiSetMute]) {
            return YES;
        }
    }
    return NO;
}
///是否是多终端个人信息（头像）同步
- (BOOL)isProfileChangedMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_PROFILE_SYNC]) {//多终端个人信息（头像）同步
        return YES;
    }
    ///含有透传消息 李晓杰
    if ([userData hasValueForKey:kRonxinMessageType] &&
        [userData[kRonxinMessageType] isEqualToString:@"ProfileChanged"]) {
        return YES;
    }
    return NO;
}
///是否是文件转发消息
- (BOOL)isForwardMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        ([userData[SMSGTYPE] isEqualToString:TYPE_FORWARD] || [userData[SMSGTYPE] isEqualToString:@"4"])) {
        return YES;
    }
    NSString *fileTranValue = [userData objectForKey:@"com.yuntongxun.rongxin.message_type"];
    if ([fileTranValue isEqualToString:@"Forward_filese"]){
        return YES;
    }
    return NO;
}
///是否是消息已读消息
- (BOOL)isHaveReadMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_READ_SYNC]) {
        return YES;
    }
    return NO;
}
///是否是添加好友相关消息
- (BOOL)isAddFriendMessage{
    NSDictionary *userData =  self.userDataToDictionary;
    if ([userData hasValueForKey:SMSGTYPE] &&
        [userData[SMSGTYPE] isEqualToString:TYPE_FRIEND]) {//好友验证消息
        return YES;
    }
    if([self.userData rangeOfString:@"friendPBSIM"].location == NSNotFound) {
        return NO;
    }
    NSDictionary *dic = userData[@"friendPBSIM"];
    if([dic hasValueForKey:@"addFriend"] ||
       [dic hasValueForKey:@"delFriends"]){
        return YES;
    }
    return NO;
}
///是否是群组 包含g判断
- (BOOL)isGroupFlag{
    if ([self.sessionId hasPrefix:@"g"]) {
        return YES;
    } else {
        return NO;
    }
}
///VoIP 通话记录消息
- (BOOL)isVoipRecordsMessage{
    NSDictionary *im_modeDic = self.userDataToDictionary;
    BOOL flag = [im_modeDic[SMSGTYPE] intValue] == 18;
    return flag;
}

- (BOOL)isWebUrlMessage {
    NSDictionary *im_modeDic = self.userDataToDictionary;
    BOOL flag = [im_modeDic[SMSGTYPE] intValue] == 26;
    return flag;
}

- (BOOL)isAnalysisedMessage {
    NSDictionary *im_modeDic = self.userDataToDictionary;
    BOOL flag = [im_modeDic[SMSGTYPE] intValue] == 27;
    return flag;
}

- (BOOL)isWebUrlMessageSendSuccess {
    NSDictionary *im_modeDic = self.userDataToDictionary;
    BOOL flag = [im_modeDic[SMSGTYPE] intValue] == 27 && [im_modeDic[@"sendState"] intValue] == 1;
    return flag;
}

- (BOOL)isWebUrlMessageSendFail {
    NSDictionary *im_modeDic = self.userDataToDictionary;
    BOOL flag = [im_modeDic[SMSGTYPE] intValue] == 27 && [im_modeDic[@"sendState"] intValue] == 0;
    return flag;
}

///是否是群组通知消息
- (BOOL)isGroupNoticeMessage{
    NSDictionary *userData = self.userDataToDictionary;
    if ([userData hasValueForKey:kRonxinMessageType] &&
        [[userData objectForKey:kRonxinMessageType] isEqualToString:@"GROUP_NOTICE"]) {
        return YES;
    }
    return NO;
}

- (NSString *)analysisMessage{
    NSString *messageUserData = self.userData;
    NSString *str = nil;
    NSRange ran = [messageUserData rangeOfString:@"UserData="];
    if (ran.location == NSNotFound) {
        NSRange ran1 = [messageUserData rangeOfString:@"customtype="];
        if(ran1.location == NSNotFound){
            str = messageUserData;
        }else{
            NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:[messageUserData componentsSeparatedByString:@","]];
            [arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tempString = obj;
                if([tempString rangeOfString:@"customtype="].location != NSNotFound){
                    *stop = YES;
                    [arrayData removeObject:obj];
                }
            }];
            str = [arrayData componentsJoinedByString:@","];
        }
    }else{
        NSInteger index = ran.location + ran.length;
        str = [messageUserData substringFromIndex:index];
    }
    return str;
}


///add by李晓杰 保存图片cell的高度
- (void)setImageHeight:(CGFloat)height{
    if (height > 0) {
        objc_setAssociatedObject(self, &imageHeightKey, [NSNumber numberWithInt:height], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, &imageHeightKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (CGFloat)getImageHeight{
    NSString *str = objc_getAssociatedObject(self, &imageHeightKey);
    if (str) {
        return [str floatValue];
    }else{
        return 0;
    }
}
- (void)setImageWight:(CGFloat)wight{
    if (wight > 0) {
        objc_setAssociatedObject(self, &imageWightKey, [NSNumber numberWithInt:wight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, &imageWightKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (CGFloat)getImageWight{
    NSString *str = objc_getAssociatedObject(self, &imageWightKey);
    if (str) {
        return [str floatValue];
    }else{
        return 0;
    }
}

- (NSInteger)getUnreadCount {
    return [[KitMsgData sharedInstance] getUnreadCountByMessageId:self.messageId];
}


//userdata 转成 dic
- (NSDictionary *)userDataToDictionary {
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:self.userData];
    return userData;
}

@end
