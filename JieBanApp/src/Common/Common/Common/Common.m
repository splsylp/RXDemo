//
//  Common.m
//  Common
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "Common.h"
#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"
#import "NSData+Ext.h"
#import "KitMsgData.h"
#import "KitCompanyAddress.h"
#import "KitAddressBook.h"
#import "AppModel.h"
#import "KitGlobalClass.h"
#import "KitGroupInfoData.h"
#import "RestApi.h"
#import <AVFoundation/AVFoundation.h>
#import "HXMyFriendList.h"
#import "RXMyFriendList.h"
#import "HXFileCacheManager.h"
#import "KCConstants_API.h"

#import "HXFileCacheManager.h"
#import "UIViewController+Extend.h"

#import "UIImage+deal.h"
#import "UIImage+Addtions.h"

@interface Common ()

@property(strong, nonatomic) AVAudioPlayer *player;//呼叫铃声
@property(nonatomic, strong) NSTimer *vibrationTimer;//呼叫震动
@property(nonatomic, assign) NSInteger callTimeOut;
@property(strong, nonatomic) NSMutableArray *sessionRequestArray;//请求的标示
@end

@implementation Common
SYNTHESIZE_SINGLETON_FOR_CLASS(Common);

- (id)init {
    if (self = [super init]) {
        self.owner = [AppModel sharedInstance].owner;
        self.componentDelegate = [AppModel sharedInstance];
        self.FCDynamicDic = [NSMutableDictionary dictionaryWithCapacity:0];
        self.cacheGroupMemberRequestArray = [NSMutableArray array];
        self.sessionRequestArray = [NSMutableArray array];
        
        if (kHttpSAndHttp) {
            self.httpType = @"https";
            self.port = kRX_PORT;
        }else {
            self.httpType = @"http";
            self.port = kRX_PORT;
        }
        NSString *krxhost = [[NSUserDefaults standardUserDefaults] objectForKey:@"kHOST"];
        
        self.host = krxhost?krxhost:kRX_HOST;
        
    }
    return self;
}

//开始及振动
- (void)startVibrate:(BOOL)isPush {
    if (!_vibrationTimer) {
        [self stopShakeSoundVibrate];
        DDLogInfo(@"=============== startVibrate isPush %d", isPush);
        _callTimeOut = isPush ? 30 : 60;

        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

void systemAudioCallback(SystemSoundID sound, void *clientData) {
    [[Common sharedInstance] performSelector:@selector(playkSystemVibrate) withObject:nil afterDelay:1];
}

//振动
- (void)playkSystemVibrate {
    _callTimeOut--;
    if (_callTimeOut > 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    } else {
        DDLogInfo(@"================= 30s timeout stopVibrate");
        [self stopShakeSoundVibrate];
    }
}


//停止振动
- (void)stopShakeSoundVibrate {
    DDLogInfo(@"=============== stopVibrate");
    [NSObject cancelPreviousPerformRequestsWithTarget:[Common sharedInstance]
                                             selector:@selector(playkSystemVibrate)
                                               object:nil];
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);

}

- (void)playAVAudioIncomingCall {

    [self setSpeakerOfIncomingCall];
    [self setSoundPayerMode];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CCPSDKBundle.bundle/ring" ofType:@"wav"]] error:nil];
    self.player.numberOfLoops = MAXFLOAT;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

/**
 *播放急速打卡声音
 */
- (void)speedPunchSuccessAudio {
    [self setSpeakerOfIncomingCall];
    [self setSoundPayerMode];
    [self stopAVAudio];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"speedPunchSuccessAudio" ofType:@"mp3"]] error:nil];
    self.player.numberOfLoops = 0;//默认只播放一次 不循环
    [self.player play];
    // NSTimeInterval duration = self.player.duration;//获取持续时间
}

- (void)stopAVAudio {

    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
}

/**
 @brief 静音模式不让播放音乐
 @discussion
 */
- (void)setSoundPayerMode; {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}

//设置扬声器播放
- (void)setSpeakerOfIncomingCall {

    AVAudioSession *session = [AVAudioSession sharedInstance];

    NSError *sessionError;

    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
            sizeof(audioRouteOverride),
            &audioRouteOverride);
    if (session == nil) {
        DDLogInfo(@"Error creating session: %@", [sessionError description]);
    } else {
        [session setActive:YES error:nil];
    }
}

//检查权限
- (BOOL)checkUserAuth:(NSString *)auth {

    NSArray *authArr = [[Common sharedInstance].getAuthtag componentsSeparatedByString:@","];
    NSInteger exitAuth = [authArr indexOfObject:auth];
    if (exitAuth != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

//搜索判断首字母
+ (BOOL)isAccordWithSearchConditionName:(NSString *)name withkeyWords:(NSString *)keyWords withFirstLetter:(NSString *)firstLet {
    if (name.length > 0) {
        if (KCNSSTRING_ISEMPTY(firstLet)) {
            firstLet = [RX_KCPinyinHelper quickConvert:name];
        }
        NSString *firstWords = [keyWords substringWithRange:NSMakeRange(0, 1)];
        if ([firstLet rangeOfString:firstWords options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}


- (NSString *)networkingStatesFromStatebar {
//    UIApplication *app =[UIApplication sharedApplication];
//    NSArray *children =[[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    int netWorkType = 0;
//    for (id child in children) {
//        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
//            netWorkType = [[child valueForKeyPath:@"dataNetworkType"] intValue];
//        }
//    }

    netWorkType = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;

    NSString *stateString = languageStringWithKey(@"未知");
    switch (netWorkType) {
        case 0:
            stateString = languageStringWithKey(@"无");
            break;

        case 1:
            stateString = languageStringWithKey(@"一般");
            break;

        case 2:
            stateString = languageStringWithKey(@"强");
            break;

        default:

            break;
    }
    return stateString;
}


//删除会话的数据
- (void)deleteAllMessageOfSession:(NSString *)sessionId {
    [[KitMsgData sharedInstance] deleteSession:sessionId];

    if (![sessionId isEqualToString:@"rx2"]) {
        [[KitMsgData sharedInstance] deleteMessageOfSession:sessionId];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_DeleteLocalSessionMessage object:sessionId];
    });
}

/// eagle 隐藏chatvc右上角按钮
- (void)hideChatVCRightItemBarWithsessionId:(NSString *)sessionId {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_HiddenChatVCRightButtonSessionMessage object:sessionId];
    });
}


- (NSString *)getOtherUserStatusWithAccount:(NSString *)account {
    if (!KCNSSTRING_ISEMPTY(account)) {
        NSDictionary *dict = [self.componentDelegate getDicWithId:account withType:0];
        return [dict objectForKey:Table_User_status];
    }
    return nil;
}

- (NSDictionary *)getOtherInfoWithSessionId:(NSString *)sessionId {
    NSDictionary *info;
    if ([sessionId hasPrefix:@"g"]) {
        ECGroup * group = [[KitMsgData sharedInstance] getGroupByGroupId:sessionId];
        NSArray *members = [KitGroupMemberInfoData getSequenceMembersforGroupId:sessionId memberCount:9];
        NSArray *imageArray = [self getImageArrayWithmemberArray:members HeaderViewH:60 withImageWH:60];
        UIImage *image = [UIImage groupIconWith:imageArray bgColor:[UIColor groupTableViewBackgroundColor]];
        info = @{@"name":group.name, @"avatar":image};
    }
    else {
        NSDictionary *tempInfo = [self.componentDelegate getDicWithId:sessionId withType:0];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:tempInfo[@"avatar"]] placeholderImage:ThemeDefaultHead(imgView.size, tempInfo[@"member_name"], tempInfo[@"account"])];
        info = @{@"name":tempInfo[@"member_name"], @"avatar":imgView.image};
    }
    return info;
}

- (NSArray*)getImageArrayWithmemberArray:(NSArray*)memberArray HeaderViewH:(CGFloat)headerWH withImageWH:(CGFloat)imageWH{
    
    CGFloat diameter = headerWH;//直径
    CGFloat r = diameter / 2;//半径
    CGFloat scale = diameter / imageWH;//比例
    
    NSMutableArray *ImageArray = [[NSMutableArray alloc] init];
    for (KitGroupMemberInfoData *memberData in memberArray) {
        
#if isOpen
        NSDictionary *info = [[Common sharedInstance].componentDelegate getDicWithId:memberData.memberId withType:0];
        memberData.memberName = info[Table_User_member_name];
        memberData.headUrl = info[Table_User_avatar];
#else
#endif
        UIImage *pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
//#if isOpenCache
        pathImage =[[SDImageCache sharedImageCache]imageFromCacheForKey:memberData.headUrl];
        if (pathImage) {
            pathImage = [pathImage imageWithCornerRadius:5];
        }else {
            NSString *filePath  =[NSCacheDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@groupHeader",[Common sharedInstance].getAccount]];
            pathImage = [[UIImage alloc]initWithContentsOfFile:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"group%@.png",memberData.memberId]]];
        }
//#else
        
//#endif
        
        UIImage *oldimage = pathImage?pathImage:ThemeDefaultHead(CGSizeMake(imageWH, imageWH), memberData.memberName?memberData.memberName:memberData.memberId,memberData.memberId);
        
        [ImageArray addObject:oldimage];
    }
    
    
    return ImageArray;
}

- (NSString *)getOtherNameWithPhone:(NSString *)phone {
    __block NSString *nameChat = nil;
    if (phone.length <= 0) {
        return @"";
    }
    if ([phone hasPrefix:@"g"]) {
        NSString *name = [[KitMsgData sharedInstance] getGroupNameOfId:phone];
        if (KCNSSTRING_ISEMPTY(name)) {
            //请求群组信息
            if ([self currentExistPhone:[NSString stringWithFormat:@"groupHead%@", phone]]) {
                return phone;
            }
            [self.sessionRequestArray addObject:[NSString stringWithFormat:@"groupHead%@", phone]];
            __weak typeof(self) weak_self = self;
            [[ECDevice sharedInstance].messageManager getGroupDetail:phone completion:^(ECError *error, ECGroup *group) {
                if (error.errorCode == ECErrorType_NoError && group.name.length > 0) {
                    [[KitMsgData sharedInstance] addGroupIDs:@[group]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_reloadSessionGroupName object:group.groupId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:group.groupId];

                    //自己不在群组里需要修改群组状态
                    [[ECDevice sharedInstance].messageManager queryGroupMembers:phone completion:^(ECError *error, NSString *groupId, NSArray *members) {
                        BOOL result = YES;
                        for (ECGroupMember *member in members) {
                            if ([member.memberId isEqualToString:[Common sharedInstance].getAccount]) {
                                result = NO;
                                break;
                            }
                        }
                        if (result) {
                            [[KitMsgData sharedInstance] updateMemberStateInGroupId:group.groupId memberState:1];
                        }
                    }];
                } else if (error.errorCode == 590010) {
                    //群组不存在
                    [self deleteAllMessageOfSession:phone];
                    [KitGroupInfoData deleteGroupInfoDataDB:phone];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:group.groupId];
                }
                if ([weak_self currentExistPhone:[NSString stringWithFormat:@"groupHead%@", phone]]) {
                    [weak_self.sessionRequestArray removeObject:[NSString stringWithFormat:@"groupHead%@", phone]];
                }
            }];
            return phone;
        } else {
            return name;
        }
    } else {
        nameChat = [[self.componentDelegate getDicWithId:phone withType:0] objectForKey:Table_User_member_name];
    
        /// eagle 这里可能为手机通讯录
        if (KCNSSTRING_ISEMPTY(nameChat) && isOpenPhoneContact) {
            id addBook = [[AppModel sharedInstance] runModuleFunc:@"KitAddressBookManager" :@"checkAddressBook:" :@[phone] hasReturn:YES];
            NSDictionary *dic = [addBook yy_modelToJSONObject];
            if ([dic hasValueForKey:@"name"]) {
                nameChat = [dic objectForKey:@"name"];
            }
        }
        if (KCNSSTRING_ISEMPTY(nameChat)) {
//            WS(weakSelf)
            id success = ^(NSDictionary *dic){
//                weakSelf.nickNameLabel.text = dic[@"username"];
//                weakSelf.headImageUrl = dic[@"photourl"];
//                [weakSelf.headPortraitImgView setImageWithURLString:weakSelf.headImageUrl urlmd5:[dic objectForKey:Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(weakSelf.headPortraitImgView.size, dic[@"username"], dic[Table_User_account]) withRefreshCached:NO];
                nameChat = dic[@"username"];
            };
            id fail = ^(NSError *error){
                NSLog(@"%@",error);
            };
            [[AppModel sharedInstance] runModuleFunc:@"KitAddressBookManager" :@"updateOneAddressWithAccount:callBacks:" :@[phone,@{@"success":success,@"fail":fail}] hasReturn:NO];
        }
        if (KCNSSTRING_ISEMPTY(nameChat)) {
//            nameChat = @"无名称";
            nameChat = phone;
        }
    }
    return nameChat ? nameChat : phone;
}

- (void)getUserInfoByAccount:(NSString *)account completion:(void (^)(NSDictionary *userInfo,NSString *userName))completion {
    NSDictionary *dic = [self.componentDelegate getDicWithId:account withType:0];
    if (dic.count>0) {
        !completion?:completion(dic,dic[Table_User_member_name]);
    }else {
        
        id success = ^(NSDictionary *dic){
            !completion?:completion(dic,dic[@"username"]);
        };
        
        id fail = ^(NSError *error){
            NSLog(@"%@",error);
        };
        [[AppModel sharedInstance] runModuleFunc:@"KitAddressBookManager" :@"updateOneAddressWithAccount:callBacks:" :@[account,@{@"success":success,@"fail":fail}] hasReturn:NO];
    }
}

- (NSString *)getOtherNameAndCountWithPhone:(NSString *)phone {
    __block NSString *nameChat = nil;
    if (phone.length <= 0) {
        return @"";
    }
    if ([phone hasPrefix:@"g"]) {//群组才有count
        ECGroup *group = [[KitMsgData sharedInstance] getGroupByGroupId:phone];
        NSString *name = group.name;
        if (KCNSSTRING_ISEMPTY(name)) {
            //请求群组信息
            if ([self currentExistPhone:[NSString stringWithFormat:@"groupHead%@", phone]]) {
                return phone;
            }
            [self.sessionRequestArray addObject:[NSString stringWithFormat:@"groupHead%@", phone]];
            __weak typeof(self) weak_self = self;
            [[ECDevice sharedInstance].messageManager getGroupDetail:phone completion:^(ECError *error, ECGroup *group) {
                if (error.errorCode == ECErrorType_NoError && group.name.length > 0) {
                    [[KitMsgData sharedInstance] addGroupIDs:@[group]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_reloadSessionGroupName object:group.groupId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:group.groupId];

                    //自己不在群组里需要修改群组状态
                    [[ECDevice sharedInstance].messageManager queryGroupMembers:phone completion:^(ECError *error, NSString *groupId, NSArray *members) {
                        BOOL result = YES;
                        for (ECGroupMember *member in members) {
                            if ([member.memberId isEqualToString:[Common sharedInstance].getAccount]) {
                                result = NO;
                                break;
                            }
                        }
                        if (result) {
                            [[KitMsgData sharedInstance] updateMemberStateInGroupId:group.groupId memberState:1];
                        }
                    }];
                } else if (error.errorCode == 590010) {
                    //群组不存在
                    [self deleteAllMessageOfSession:phone];
                    [KitGroupInfoData deleteGroupInfoDataDB:phone];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:group.groupId];
                }
                if ([weak_self currentExistPhone:[NSString stringWithFormat:@"groupHead%@", phone]]) {
                    [weak_self.sessionRequestArray removeObject:[NSString stringWithFormat:@"groupHead%@", phone]];
                }
            }];
            return phone;
        } else {
            return [NSString stringWithFormat:@"%@(%ld)", name, group.memberCount];
        }
    } else {
        nameChat = [[self.componentDelegate getDicWithId:phone withType:0] objectForKey:Table_User_member_name];
        /// eagle 这里可能为手机通讯录
        if (KCNSSTRING_ISEMPTY(nameChat) && isOpenPhoneContact) {
            id addBook = [[AppModel sharedInstance] runModuleFunc:@"KitAddressBookManager" :@"checkAddressBook:" :@[phone] hasReturn:YES];
            NSDictionary *dic = [addBook yy_modelToJSONObject];
            if ([dic hasValueForKey:@"name"]) {
                nameChat = [dic objectForKey:@"name"];
            }
        }
        if (KCNSSTRING_ISEMPTY(nameChat)) {
            nameChat = @"无名称";
        }
    }
    return nameChat ? nameChat : phone;
}

//群组删除一些缓存
- (void)deleteOneGroupInfoGroupId:(NSString *)groupId {
    [[Common sharedInstance] deleteAllMessageOfSession:groupId];
    //群组解散  删除缓存
    [KitGroupInfoData deleteGroupInfoDataDB:groupId];
    //删除成员缓存
    [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
    //删除本地文件缓存
    [HXFileCacheManager deleteAllSessionFile:groupId];
    [[SendFileData sharedInstance] deleteAllFileSessionId:groupId];
}

- (NSString *)getIMageUrlWithPhone:(NSString *)phone {

    NSString *imageUrl = nil;
    NSString *sex = nil;

    if ([phone hasPrefix:@"g"]) {

        imageUrl = @"icon_groupdefaultavatar";
        return imageUrl;
    }

    NSDictionary *dict = [self.componentDelegate getDicWithId:phone withType:0];
    if (dict) {
        NSString *path = [dict objectForKey:Table_User_avatar];
        if ([path length] > 0) {
            imageUrl = path;
            return imageUrl;
        }
    }

    if (![imageUrl hasPrefix:@"http"]) {
        return nil;
    }
    return imageUrl;
}


- (void)recordAllLoginMobile:(NSString *)loginMobile {
    [[NSUserDefaults standardUserDefaults] setObject:loginMobile forKey:[NSString stringWithFormat:@"%@%@", loginMobile, @"RX_AllLoginMobile"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CGSize)widthForContent:(NSString *)text withSize:(CGSize)size withLableFont:(CGFloat)fontSize {
    NSDictionary *attributs = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize newSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributs context:nil].size;
    return newSize;
}

+ (NSString *)imageFullURLString:(NSString *)url {
    if (KCNSSTRING_ISEMPTY(url)) {
        return @"";
    }
    //如果是完整的URL链接，则不需要拼接http头
    NSString *lowString = [url lowercaseString];
    if ([lowString hasPrefix:@"http"]) {
        return url;
    }
    NSString *returnString = nil;
    NSString *head = @"http://";

    NSString *lastPathComponent = [[url lastPathComponent] lowercaseString];
    if ([lastPathComponent hasSuffix:@"gif"]) {
        NSString *tail = [url stringByReplacingOccurrencesOfString:[url lastPathComponent] withString:@""];
        if ([head hasSuffix:@"/"] && [tail hasPrefix:@"/"]) {
            tail = [tail substringFromIndex:1];
        } else if (![head hasSuffix:@"/"] && ![tail hasPrefix:@"/"]) {
            head = [head stringByAppendingString:@"/"];
        }
        returnString = [NSString stringWithFormat:@"%@%@", head, tail];
        returnString = [returnString stringByAppendingString:[url lastPathComponent]];
    } else {
        NSString *tail = url;
        if ([head hasSuffix:@"/"] && [tail hasPrefix:@"/"]) {
            tail = [tail substringFromIndex:1];
        } else if (![head hasSuffix:@"/"] && ![tail hasPrefix:@"/"]) {
            head = [head stringByAppendingString:@"/"];
        }
        returnString = [NSString stringWithFormat:@"%@%@", head, tail];
    }
    return returnString;
}


- (NSString *)md5AccountPassWord {
    //username md5
    NSString *mobile = [[AppModel sharedInstance].appData.userInfo objectForKey:Table_User_account];
    NSString *passwd = [[AppModel sharedInstance].appData.userInfo objectForKey:App_Clientpwd];

    if (KCNSSTRING_ISEMPTY(mobile) || KCNSSTRING_ISEMPTY(passwd)) {
        return @"";
    }
    const char *cStr = [[NSString stringWithFormat:@"%@%@", mobile, passwd] UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG) strlen(cStr), result);
    NSString *MD5 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];

    return MD5;
}

- (NSString *)myFCNewMsgIdWithKeyValue:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"myFCNewMsgId_%@", key]];
}

- (void)setMyFCNewMsgId:(NSString *)myFCNewMsgId KeyValue:(NSString *)key {

    [[NSUserDefaults standardUserDefaults] setObject:myFCNewMsgId forKey:[NSString stringWithFormat:@"myFCNewMsgId_%@", key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setNewMsgId:(NSString *)newMsgId {

    [[NSUserDefaults standardUserDefaults] setObject:newMsgId forKey:[NSString stringWithFormat:@"newMsgIdOf%@", [Common sharedInstance].getMobile]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)newMsgId {

    return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"newMsgIdOf%@", [Common sharedInstance].getMobile]];

}

- (void)setNewlCId:(NSString *)newlCId {
    [[NSUserDefaults standardUserDefaults] setObject:newlCId forKey:[NSString stringWithFormat:@"newlCIdOf%@", [Common sharedInstance].getMobile]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)newlCId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"newlCIdOf%@", [Common sharedInstance].getMobile]];
}


- (void)setNewlPId:(NSString *)newlPId {
    [[NSUserDefaults standardUserDefaults] setObject:newlPId forKey:[NSString stringWithFormat:@"newlPIdOf%@", [Common sharedInstance].getMobile]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)newlPId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"newlPIdOf%@", [Common sharedInstance].getMobile]];
}

#pragma mark - 收藏时间

- (void)setCollectSynctime:(NSString *)collectSynctime {
    NSString *mobile = [[AppModel sharedInstance].appData.userInfo objectForKey:Table_User_account];
    [[NSUserDefaults standardUserDefaults] setObject:collectSynctime forKey:[NSString stringWithFormat:@"collectSynctimeOf%@", mobile]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)collectSynctime {
    NSString *mobile = [[AppModel sharedInstance].appData.userInfo objectForKey:Table_User_account];
    return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"collectSynctimeOf%@", mobile]];
}


#pragma mark 检查账号是否被冻结

- (BOOL)checkPointToPiontChatWithAccount:(NSString *)account {
    NSString *userStatus = [self getOtherUserStatusWithAccount:account];
    if ([userStatus integerValue] == 4) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前账号已被冻结")];
        return YES;
    } else if ([userStatus integerValue] == 3) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前用户已离职")];
        return YES;
    }
    return NO;
}

//检查是否离职
- (BOOL)isDimissionWithAccount:(NSString *)account {
    NSString *userStatus = [self getOtherUserStatusWithAccount:account];
    if ([userStatus integerValue] == 3) {
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"当前用户已离职")];
        return YES;
    }
    return NO;
}



//检查是否是符合权限控制

- (BOOL)checkPointToPiontIsMyFriendWithAccount:(NSString *)account needPrompt:(BOOL)isPrompt {
    return YES; // 现在没有非好友不能聊天的需求
    BOOL isMyFriend = [HXMyFriendList isMyFriend:account];
    NSDictionary *addressBook = [[Common sharedInstance].componentDelegate getDicWithId:account withType:0];
    if ([account hasPrefix:@"g"] || [account isEqualToString:FileTransferAssistant]) {
        return YES;
    }

    if (isPrompt && isMyFriend == NO) {
//        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"您们不是好友关系,部分功能将无法使用")];
    }

    return NO;
}

//检查比自己高两个级别的用户
- (id)isHighLevelOfTwoWithAccount:(NSString *)account {
    NSInteger level = [[Common sharedInstance].getUserLevel integerValue];
    if (level == 1 || level == 2) {
        return [NSNumber numberWithBool:NO];
    }
    NSDictionary *dic = [[Common sharedInstance].componentDelegate getDicWithId:account withType:0];
    if (dic && level - [dic[Table_User_Level] integerValue] >= 2) {
        return [NSNumber numberWithBool:YES];
    }

    return [NSNumber numberWithBool:NO];
}

/**
 * 数据迁移
 **/
- (NSArray *)appInProgressDataMigration {
    return nil;
//  return [HXOriginalData changeHxOriginTable];
}

- (UIViewController *)getProgressView:(NSArray *)tableArray {
    return nil;
}


//判断当前数组中是否含有请求过的参数
- (BOOL)currentExistPhone:(NSString *)account {
    if (self.sessionRequestArray.count > 0) {
        if ([self.sessionRequestArray containsObject:account]) {
            return YES;
        }
    }
    return NO;
}


#pragma mark otherAppFile

//2017yxp8.16  第三方应用文件分享
- (id)shareOtherAppFile:(NSString *)filePath {
    UIViewController *curViewController = [UIViewController windowCurrentViewController];
    UIViewController *groupSelectVC = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getChooseMembersVCWithExceptData:WithType:" :@[@{@"otherAppFileDataList": @{@"otherAppFilePath": filePath}}, [NSNumber numberWithInteger:4001]]];

    if (curViewController.navigationController) {
        groupSelectVC.hidesBottomBarWhenPushed = YES;
        [curViewController.navigationController pushViewController:groupSelectVC animated:YES];

    } else {
        RXBaseNavgationController *selecNav = [[RXBaseNavgationController alloc] initWithRootViewController:groupSelectVC];
        [curViewController presentViewController:selecNav animated:YES completion:nil];
        DDLogInfo(@"此不是导航栏...其他应用App....");
    }
    return nil;
}

#pragma mark getMYAPPStoreCount

//2017yxp8.17 第三方应用消息未读数
- (id)getMyAppStoreUnreadCountStatus:(NSNumber *)statusNum {
    return 0;
//    BOOL result = [KitAppStoreUnreadData getAPPUnreadStatus:[statusNum intValue]];
//    return [NSNumber numberWithBool:result];
}

- (id)getMyAppStoreUnreadCountStatusWithAppId:(NSString *)appId withStatus:(NSNumber *)statusNum {
    return 0;
//    BOOL result = [KitAppStoreUnreadData getAPPUnreadStatus:[statusNum intValue] withAppId:appId];
//
//    return [NSNumber numberWithBool:result];
}

- (BOOL)deleteAppStoreUnreadCountRecordWithAppId:(NSString *)appId appType:(NSInteger)appType {
    return 0;
//    return [KitAppStoreUnreadData deleteAppUnreadAppId:appId appType:appType];
}

//2017yxp8.22
- (id)appDeleteFileAtPath:(NSString *)filePath {
    [HXFileCacheManager deleteFileAtPath:filePath];
    return nil;
}

- (void)setConfRooms:(NSArray *)confRooms {
    [[NSUserDefaults standardUserDefaults] setObject:confRooms forKey:[NSString stringWithFormat:@"%@_%@", kKitConfRoomId, [self getAccount]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)confRooms {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_%@", kKitConfRoomId, [self getAccount]]];
}


// create by hw at 2018-12-25 Common fucntion for searchBar
#pragma mark - 搜索统一处理
- (void)searchWithType:(RXSearchType)searchType keyword:(NSString *)keyword otherData:(NSDictionary *)data completed:(SearchCompletionBlock)completion{
    switch (searchType) {
        case RXSearchTypeChat: {//聊天页面搜索功能
            if ([keyword isEqualToString:@""]) {
                completion(nil, nil);
                return;
            }
            [self getChatSearchBySearchText:keyword sessionArr:data[@"array"] completed:completion];
        }
            break;
        case RXSearchTypeChatDetail: {//聊天页面搜索详情
            if ([keyword isEqualToString:@""]) {
                completion(nil, nil);
                return;
            }
            NSMutableArray *home = [[NSMutableArray alloc] init];
            NSInteger selectCount = [data[@"selectIndex"] integerValue];
            if (selectCount == 0) {//联系人
                NSInteger page = [data[@"page"] integerValue]?:0;
                NSInteger pageSize = [data[@"pageSize"] integerValue]?:9999;
                if (isLargeAddressBookModel) {
                    [self getLargeSearchFriendBySearchValue:keyword page:page pageSize:pageSize completed:completion];
                    return;
                }
                NSArray *persons = [self filteredContactsDataSourceWithKey:keyword page:1 pageSize:9999];
                if (persons.count > 0) {
                    [home addObject:@{@"key": [NSNumber numberWithInt:SEARCH_CHAT_PERSON], @"title": languageStringWithKey(@"最常使用"), @"footerTitle": languageStringWithKey(@"更多联系人"), @"data": persons}];
                }
            } else if (selectCount == 5) {//群组
                [self setGroupInfoByKeyword:keyword m_home:home];
            } else if (selectCount == 2) {//聊天记录
                NSArray *sessionArray = data[@"array"];
                [self setChatRecordsByKeyword:keyword sessionArr:sessionArray m_home:home];
            }
            completion(home, nil);
        }
            break;
        case RXSearchTypeAddressbook: {
            NSInteger page = [data[@"page"] integerValue]?:0;
            NSInteger pageSize = [data[@"pageSize"] integerValue]?:9999;
            if (isLargeAddressBookModel) {
                [self getLargeSearchFriendBySearchValue:keyword page:page pageSize:pageSize completed:completion];
                return;
            } dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSArray<KitCompanyAddress *> *array = [self filteredContactsDataSourceWithKey:keyword page:page pageSize:pageSize];
                ///排序
                array = [array sortedArrayUsingComparator:^NSComparisonResult(KitCompanyAddress *obj1, KitCompanyAddress *obj2) {
                    return [obj1.pyname compare:obj2.pyname];
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(array, nil);
                });
            });
        }
            break;
        case RXSearchTypeLocalSearch:{
            NSString *sessionId = data[@"sessionId"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSArray<ECMessage *> *array = [[KitMsgData sharedInstance] getSomeMessagesWithSearhStr:keyword ofSession:sessionId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(array, nil);
                });
            });
        }
            break;
        case RXSearchTypeLocalSearchTime:{
            NSString *sessionId = data[@"sessionId"];
            NSDate *startDate = data[@"startDate"];
            NSDate *endDate = data[@"endDate"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSArray<ECMessage *> *array = [[KitMsgData sharedInstance] getMessagesBySessionId:sessionId startTime:startDate endTime:endDate];
                dispatch_async(dispatch_get_main_queue(), ^{
                completion(array, nil);
                });
            });
        }
            break;
        case RXSearchTypeLocalSearchPerson:{
            NSString *sessionId = data[@"sessionId"];
            NSString *sender = data[@"sender"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSArray<ECMessage *> *array = [[KitMsgData sharedInstance] getMessagesBySessionId:sessionId sender:sender];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(array, nil);
                });
            });
        }
            break;
        default:
            break;
    }
}
///聊天页面搜索功能相关
- (void)getChatSearchBySearchText:(NSString *)keyword sessionArr:(NSArray *)sessionArr completed:(SearchCompletionBlock)completion{
    NSMutableArray *m_home = [[NSMutableArray alloc] init];
    if (isLargeAddressBookModel) {//大通讯录模式下 联系人需要从接口查询
        ///查询不超过4人
        [[RestApi sharedInstance] getLargeSearchFriendBySearchValue:keyword page:0 pageSize:4 didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSDictionary *bodyDic = dict[@"body"];
            NSArray *dataArr = bodyDic[@"data"];
            NSArray<KitCompanyAddress *> *addressArr = [NSArray yy_modelArrayWithClass:KitCompanyAddress.class json:dataArr.yy_modelToJSONString];
            NSMutableArray *arr = [NSMutableArray array];
            for (KitCompanyAddress *address in addressArr) {//搜索接口没有把是否离职的字段返回，先这样处理
                if (!address.userStatus) {
                    KitCompanyAddress *obj = [KitCompanyAddress getCompanyAddressInfoDataWithAccount:address.account];
                    if (obj) {
                        address.userStatus = obj.userStatus;
                    }
                }
                [arr addObject:address];
            }
            
            NSArray *fileStringArr = @[@"文",@"件",@"传",@"输",@"助",@"手",@"File",@"Transfer"];
            BOOL flag = NO;
            for (NSString *obj in fileStringArr) {
                if ([keyword containsString:obj] ) {
                    flag = YES;
                    break;
                }
            }
            if (flag) {
                //增加文件助手的搜索
                KitCompanyAddress *fileAssistant = [KitCompanyAddress new];
                fileAssistant.account = FileTransferAssistant;
                fileAssistant.name = languageStringWithKey(@"文件传输助手");
                fileAssistant.pyname = @"wenjianzhushou";
                [arr addObject:fileAssistant];
            }
            
            if (arr.count > 0) {
                [m_home addObject:@{@"key": [NSNumber numberWithInt:SEARCH_CHAT_PERSON], @"title": languageStringWithKey(@"联系人"), @"footerTitle": languageStringWithKey(@"更多联系人"), @"data": arr}];
            }
            [self setGroupInfoByKeyword:keyword m_home:m_home];
            [self setChatRecordsByKeyword:keyword sessionArr:sessionArr m_home:m_home];
            completion(m_home,nil);
        } didFailLoaded:^(NSError *error, NSString *path) {
            [self setGroupInfoByKeyword:keyword m_home:m_home];
            [self setChatRecordsByKeyword:keyword sessionArr:sessionArr m_home:m_home];
            completion(m_home,nil);
        }];
        return;
    }
    //联系人
    NSArray *persons = [self filteredContactsDataSourceWithKey:keyword page:1 pageSize:9999];
    if (persons.count > 0) {
        [m_home addObject:@{@"key": [NSNumber numberWithInt:SEARCH_CHAT_PERSON], @"title": languageStringWithKey(@"联系人"), @"footerTitle": languageStringWithKey(@"更多联系人"), @"data": persons}];
    }
    [self setGroupInfoByKeyword:keyword m_home:m_home];
    [self setChatRecordsByKeyword:keyword sessionArr:sessionArr m_home:m_home];
    completion(m_home,nil);
}
- (void)setGroupInfoByKeyword:(NSString *)keyword m_home:(NSMutableArray *)m_home{
    //群组
    NSArray<ECGroup *> *groupArr = [self filteredGroupDataSourceWithKey:keyword];
    if (groupArr.count > 0) {
        [m_home addObject:@{@"key": [NSNumber numberWithInt:SEARCH_CHAT_GROUPS], @"title": languageStringWithKey(@"群组"), @"footerTitle": languageStringWithKey(@"更多群组"), @"data": groupArr}];
    }
}
- (void)setChatRecordsByKeyword:(NSString *)keyword sessionArr:(NSArray *)sessionArr m_home:(NSMutableArray *)m_home{
    //聊天记录
    NSArray *chaRecords = [self searchLoactionDataWithsearchString:keyword withSeesionArray:sessionArr];
    if (chaRecords.count > 0) {
        [m_home addObject:@{@"key": [NSNumber numberWithInt:SEARCH_CHAT_RECORD], @"title": languageStringWithKey(@"聊天记录"), @"footerTitle": languageStringWithKey(@"更多聊天记录"), @"data": chaRecords}];
    }
}
///大通讯录模式下 获取联系人
- (void)getLargeSearchFriendBySearchValue:(NSString *)searchValue page:(NSInteger)page pageSize:(NSInteger)pageSize completed:(SearchCompletionBlock)completion{
    [[RestApi sharedInstance] getLargeSearchFriendBySearchValue:searchValue page:page pageSize:pageSize didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSDictionary *bodyDic = dict[@"body"];
        NSArray *dataArr = bodyDic[@"data"];
        NSArray<KitCompanyAddress *> *addressArr = [NSArray yy_modelArrayWithClass:KitCompanyAddress.class json:dataArr.yy_modelToJSONString];
        completion(addressArr,nil);
    } didFailLoaded:^(NSError *error, NSString *path) {
        completion(nil,error);
    }];
}

#pragma mark - 根据搜索返回聊天记录 类型 [{@"searchSession":@"session",@"searchMessageArr":@[<ECMessage *>]}]
- (NSMutableArray *)searchLoactionDataWithsearchString:(NSString *)searchString withSeesionArray:(NSArray *)sessionArray {
    NSMutableArray *loactionSearchData = [[NSMutableArray alloc] init];
    for (ECSession *session in sessionArray) {
        NSMutableDictionary *searchDict = [NSMutableDictionary dictionary];
        NSArray<ECMessage *> *messageArr = [[KitMsgData sharedInstance] getSomeMessagesWithSearhStr:searchString ofSession:session.sessionId];
        if (messageArr.count > 0) {
            [searchDict setObject:messageArr forKey:@"searchMessageArr"];
            [searchDict setObject:session forKey:@"searchSession"];
            [loactionSearchData addObject:searchDict];
        }
    }
    return loactionSearchData;
}
#pragma mark - 根据搜索返回联系人数组
- (NSArray<KitCompanyAddress *> *)filteredContactsDataSourceWithKey:(NSString *)keyword page:(NSInteger)page pageSize:(NSInteger)pageSize {
    NSInteger _page = page?:0;
    NSInteger _pageSize = pageSize?:9999;
    NSArray<KitCompanyAddress *> *contacts = [KitCompanyAddress getCompanyAddressArrayBySearchText:keyword page:_page pageSize:_pageSize];
    contacts = [contacts sortedArrayUsingComparator:^NSComparisonResult(KitCompanyAddress *obj1, KitCompanyAddress *obj2) {
        return [obj1.pyname compare:obj2.pyname];
    }];
    return contacts;
}
#pragma mark - 根据搜索返回群组信息
- (NSArray<ECGroup *> *)filteredGroupDataSourceWithKey:(NSString *)keyword {
    //群组
    NSArray<ECGroup *> *nameGroups = [KitGroupInfoData getGroupWithSearchText:keyword];
    NSArray<ECGroup *> *peopleGroups = [KitGroupMemberInfoData getGroupInfoWithName:keyword];
    NSMutableArray<ECGroup *> *groupArr = [[NSMutableArray alloc] init];
    ///保证不添加了重复的群组
    [groupArr addObjectsFromArray:nameGroups];
    for (ECGroup *group in peopleGroups) {
        BOOL have = NO;
        for (ECGroup *temp in groupArr) {
            if ([group.groupId isEqualToString:temp.groupId]) {
                have = YES;
            }
        }
        if (!have) {
            [groupArr addObject:group];
        }
    }
    return groupArr.copy;
}

//根据account获取个人信息
- (void)getVOIPUserInfoWithAccount:(NSString *)account {
    [[RestApi sharedInstance] getVOIPUserInfoWithMobile:account type:@"2" didFinishLoaded:^(NSDictionary *json, NSString *path) {
        NSInteger statuscode = [[[json objectForKey:@"head"] objectForKey:@"statusCode"] integerValue];
        NSArray *voipinfos = [[json objectForKey:@"body"] objectForKey:@"voipinfo"];
        if (statuscode != 0) {
            return ;
        }
        if (voipinfos.count>0) {
            NSDictionary *voipinfo = voipinfos.firstObject;
            //入库
            [KitCompanyAddress insertCompanyAddressDic:voipinfo];
        }else {
            NSArray *errorAccount = [[json objectForKey:@"body"] objectForKey:@"errorAccount"];
            NSLog(@"这些账号有问题：%@",errorAccount);
        }
    } didFailLoaded:nil];
}

#pragma mark - 权限相关
//pbs登录完成后获取权限规则
- (void)getPrivilegeRuleFromPBS {
    [[RestApi sharedInstance] getPrivilegeRuleWithCompId:self.getCompanyId didFinishLoaded:^(NSDictionary *json, NSString *path) {
        NSInteger statuscode = [[json objectForKey:@"statusCode"] integerValue];
        NSArray *data = [json objectForKey:@"data"];
        if (statuscode != 0) {
            return;
        }
        NSString *key = [NSString stringWithFormat:@"RX_%@_PrivileRule",self.getAccount];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        
        NSMutableArray *chatPermissionArray = @[].mutableCopy;//不能聊天
        NSMutableArray *detailPermissionArray = @[].mutableCopy;//不能看资料
        NSMutableArray *whiteListArray = @[].mutableCopy;//白名单
        if (data.count>0) {
            for (NSDictionary *dic in data) {
                NSArray *whiteList = dic[@"whiteList"];
                NSArray *detailList = dic[@"viewDataPermission"];
                NSArray *chatList = dic[@"chatPermissions"];
                NSString *level =  [NSString stringWithFormat:@"%@",dic[@"level"]];
                //防止后台返回数据变化导致崩溃
                if (![whiteList isKindOfClass:[NSArray class]]) {continue;}
                if (![detailList isKindOfClass:[NSArray class]]) {continue;}
                if (![chatList isKindOfClass:[NSArray class]]) {continue;}
                if (KCNSSTRING_ISEMPTY(level)) {break;}
                
                if (detailList.count>0 || chatList.count>0) {//有规则限制的时候白名单才有意义
                    for (NSDictionary *whiteDic in whiteList) {//白名单
                        NSString *string = [NSString stringWithFormat:@"%@_&&_%@",level,whiteDic[@"account"]];
                        [whiteListArray addObject:string];
                    }
                    for (NSString *value in detailList) {//个人资料权限
                        NSString *string = [NSString stringWithFormat:@"%@_&&_%@",level,value];
                        [detailPermissionArray addObject:string];
                    }
                    for (NSString *value in chatList) {//沟通权限
                        NSString *string = [NSString stringWithFormat:@"%@_&&_%@",level,value];
                        [chatPermissionArray addObject:string];
                    }
                }
            }
            
            NSDictionary *ruleDic = @{
                @"white":whiteListArray,
                @"detail":detailPermissionArray,
                @"chat":chatPermissionArray,
            };
            NSLog(@"ruleDic =%@",ruleDic);
            [[NSUserDefaults standardUserDefaults] setObject:ruleDic forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:@{} forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        NSString *key = [NSString stringWithFormat:@"RX_%@_PrivileRule",self.getAccount];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }];
    
    [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getAllDepartInfo" :nil];
}


////是否能查看联系方式（邮箱电话）
/// @param level 对方的级别
/// @param account 对方account
- (BOOL)canLookContacts:(NSString *)level account:(NSString *)account {
    if ([self getCommonPrivilege:level account:account]) {
        return YES;
    }else {
        NSString *key = [NSString stringWithFormat:@"RX_%@_PrivileRule",self.getAccount];
        NSDictionary *rule = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSArray *detailPermissionArray = rule[@"detail"];
        NSString *obj = [NSString stringWithFormat:@"%@_&&_%@",level,self.getPersonLevel];
        return ![detailPermissionArray containsObject:obj];
    }
    return YES;
}


/// 能否聊天
/// @param level 对方的级别
/// @param account 对方account
- (BOOL)canChat:(NSString *)level account:(NSString *)account {
    if ([[self getRecentPerson] containsObject:account]) {//最近联系人
        return YES;
    }
    if ([self getCommonPrivilege:level account:account]) {
        return YES;
    }else {
        NSString *key = [NSString stringWithFormat:@"RX_%@_PrivileRule",self.getAccount];
        NSDictionary *rule = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSArray *chatPermissionArray = rule[@"chat"];
        NSString *obj = [NSString stringWithFormat:@"%@_&&_%@",level,self.getPersonLevel];
        return ![chatPermissionArray containsObject:obj];
    }
    return YES;
}


/// 下级是否可拉上级入群只根据PBS返回的规则来判断（不受好友关系和最近联系人影响）
/// @param level 对方的级别
/// @param account 对方account
- (BOOL)canCreatGroup:(NSString *)level account:(NSString *)account {
    if ([self getCommonPrivilege:level account:account]) {
        return YES;
    }else {
        NSString *key = [NSString stringWithFormat:@"RX_%@_PrivileRule",self.getAccount];
        NSDictionary *rule = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        NSArray *chatPermissionArray = rule[@"chat"];
        NSString *obj = [NSString stringWithFormat:@"%@_&&_%@",level,self.getPersonLevel];
        return ![chatPermissionArray containsObject:obj];
    }
}



/*
    1.自己或者对方的personLevel为空，不受限制
    2.服务端返回的规则为空，不受限制
    3.和被沟通或被查看的对象是好友关系，不受限制（好友相当于白名单）
    4.自己在被沟通或被查看的对象的白名单里，不受限制
    5.被沟通的对象存在最近联系人里面，可发起聊天
    6.按照规则匹配是否受限制
    7.下级是否可拉上级入群只根据PBS返回的规则和是否好友来判断（不受最近联系人影响）
*/
- (BOOL)getCommonPrivilege:(NSString *)level account:(NSString *)account {
    
    if (KCNSSTRING_ISEMPTY(level) || level.integerValue < 0) {//对方没有级别
        return YES;
    }
    if (KCNSSTRING_ISEMPTY(self.getPersonLevel) || self.getPersonLevel.integerValue < 0) {//自己没有级别
        return YES;
    }
    
    if ([HXMyFriendList isMyFriend:account]) {//是否好友
        return YES;
    }
    
    //企业规则
    NSString *key = [NSString stringWithFormat:@"RX_%@_PrivileRule",self.getAccount];
    NSDictionary *rule = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (rule.count<=0) {
        return YES;
    }
    NSArray *whiteListArray = rule[@"white"];//白名单
    NSString *string = [NSString stringWithFormat:@"%@_&&_%@",level,self.getAccount];
    return [whiteListArray containsObject:string];
}

- (NSMutableArray *)getRecentPerson {
    NSMutableArray *array = [NSMutableArray array];
    NSArray *recentArray = [[KitMsgData sharedInstance] getMyCustomSession];
    for (ECSession *session in recentArray) {
        if (![session.sessionId hasPrefix:@"g"] && !KCNSSTRING_ISEMPTY(session.sessionId)) {
            [array addObject:session.sessionId];
        }
    }
    return array;
}


@end
