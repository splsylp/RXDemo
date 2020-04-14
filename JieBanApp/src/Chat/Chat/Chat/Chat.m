//
//  Chat.m
//  Chat
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "Chat.h"
#import "SessionViewController.h"
#import "ChatViewController.h"
#import "GroupListSeessionViewController.h"
#import "CustomEmojiView.h"
//#import "RXWorkingWebViewController.h"
#import "RXJoinGroupViewController.h"
#import "HXMessageMergeManager.h"
@implementation Chat

SYNTHESIZE_SINGLETON_FOR_CLASS(Chat);

- (id)init {
    if (self = [super init]) {
        self.componentInfo = [NSDictionary dictionaryWithObjectsAndKeys:languageStringWithKey(@"消息"),@"caption",@"tab_icon_message_normal",@"componentIconName",nil];
    }
    self.componentDelegate = [AppModel sharedInstance];
       [CustomEmojiView shardInstance];
   

    return self;
}

//返回会话列表
- (UIViewController *)mainView{
    if (![self respondsToSelector:@selector(getSessionViewController)]){
        return [super mainView];
    }
    return [self getSessionViewController];
}

//获取会话列表
- (UIViewController *)getSessionViewController {
    return [[SessionViewController alloc] init];
}
- (UIViewController *)getGroupListViewController {
    return [[GroupListSeessionViewController alloc] init];
}

- (UIViewController *)getGroupListViewControllerWithMembers:(NSMutableArray *) members withType:(NSNumber *)type{
    KitGroupSelectViewController *GroupMembersVC = [[KitGroupSelectViewController alloc] init];
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:GroupMembersVC];
    GroupMembersVC.allMembersArray = members;
    GroupMembersVC.isFromVideoMeeting = [type intValue];
    GroupMembersVC.isFromVoiceConfMeeting = 0;
    GroupMembersVC.view.frame = [UIScreen mainScreen].bounds;
    self.groupListForMeeting = nav;
    if (self.owner) {
        [self.owner addSubview:nav.view];
    }
    return GroupMembersVC;
}

- (UIViewController *)getGroupListViewControllerWithParam:(NSDictionary *)param {
    KitGroupSelectViewController *GroupMembersVC = [[KitGroupSelectViewController alloc] init];
    GroupMembersVC.isFromVideoMeeting = [param[@"isMeeting"] intValue];
    GroupMembersVC.groupId = param[@"groupId"];
    GroupMembersVC.selectMembers = [NSMutableArray arrayWithArray:param[@"selectMembers"]];
    GroupMembersVC.conferenceType = [param[@"conferenceType"] integerValue];
    if (GroupMembersVC.conferenceType == 4) {
        GroupMembersVC.chatVC = (UIViewController *)param[@"chatVC"];
        GroupMembersVC.allMembersArray = param[@"allMembers"];
    }
    return GroupMembersVC;
}

- (UIViewController *)getVoiceConfGroupControllerMembers:(NSMutableArray *)members withType:(NSNumber *)type {
    
    KitGroupSelectViewController *GroupMembersVC = [[KitGroupSelectViewController alloc] init];
    RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:GroupMembersVC];
    GroupMembersVC.allMembersArray = members;
    GroupMembersVC.isFromVoiceConfMeeting = 1;
    GroupMembersVC.isAppConf = [type intValue];
    GroupMembersVC.view.frame = [UIScreen mainScreen].bounds;
    self.groupListForMeeting = nav;
    if (self.owner) {
        [self.owner addSubview:nav.view];
    }
    return GroupMembersVC;
    
}

- (id)owner{
    if ([super owner]) {
        return [super owner];
    }else{
        self.owner = [AppModel sharedInstance].owner;
        return [super owner];
    }
}

//根据sessionId获取聊天界面
- (UIViewController *)getChatViewControllerWithSessionId:(NSString *)sessionId {
    ChatViewController *chatVC = [[ChatViewController alloc] initWithSessionId:sessionId];
    return chatVC;
}


//根据sessionId获取集中监控平台聊天界面
- (UIViewController *)getOAShowDetailVCSessionId:(NSString *)sessionId{
    return [[AppModel sharedInstance] runModuleFunc:@"Work" :@"getOAShowDetailVCSessionId:" :@[sessionId?:@"rx2"]];
}

//根据传过来的数据开始聊天

- (void)getChatViewControllerWithData:(NSDictionary *)data completion:(void (^)(UIViewController *))completion failed:(void (^)(void))failed {
    NSArray *selectedList = data[@"selectedList"];
    
    if (selectedList.count == 0) {
        return;
    }
    
    //转发
    if (data[@"msg"]) {
        ECMessage *message = data[@"msg"];
        [self transmitMsg:message withSelectedList:selectedList completion:completion];
        return;
    }
    
    //群聊选人 不用创建新的群组
    if (data[@"groupId"]) {
        NSString *groupId = [data objectForKey:@"groupId"];
        [self inviteJoinGroupWithGroupId:groupId andSelectedList:selectedList andIsGroupChat:YES completion:^(UIViewController *controller) {
            completion(nil);
        } failed:nil];
    }else {
        
        //要创建新的群组
        ECGroup * newgroup = [[ECGroup alloc] init];
        NSString *tepStr = languageStringWithKey(@"发起的会话");
        newgroup.name = [NSString stringWithFormat:@"%@%@",[[Chat sharedInstance] getUserName].length>0?[[Chat sharedInstance] getUserName]:languageStringWithKey(@"自己"),tepStr];//默认群组名称：××发起的会话
        newgroup.declared = @"";
        newgroup.mode = 0;
        newgroup.owner = [[Chat sharedInstance] getAccount];
        newgroup.scope = ECGroupType_VIP;//默认1000人群
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        newgroup.createdTime = [NSString stringWithFormat:@"%lld", (long long)tmp];
        if (!isRealGroup) {
            newgroup.isDiscuss = YES;
        }
        [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
            
            if (error.errorCode == ECErrorType_NoError) {
                
                [[KitMsgData sharedInstance] addGroupIDs:@[group]];
                KitGroupInfoData *groupData =[[KitGroupInfoData alloc]init];
                groupData.groupName=group.name;
                groupData.groupId=group.groupId;
                groupData.declared=group.declared;;
                groupData.owner=group.owner;
                //                        groupData.isAnonymity = group.isAnonymity;
                groupData.createTime=group.createdTime;
                groupData.type=group.type;
                groupData.memberCount=group.memberCount;
                groupData.isDiscuss = group.isDiscuss;
                [KitGroupInfoData insertGroupInfoData:groupData];
                
                [self inviteJoinGroupWithGroupId:group.groupId andSelectedList:selectedList andIsGroupChat:NO completion:^(UIViewController *controller) {
                    completion(controller);
                } failed:nil];
            }
            else{
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"发起群聊失败")];
            }
        }];
    }
}

//根据不同的groupId 去邀请选中的人
- (void)inviteJoinGroupWithGroupId:(NSString *)groupId andSelectedList:(NSArray *)selectedList andIsGroupChat:(BOOL)isGroupChat completion:(void(^)(UIViewController *controller))completion failed:(void(^)(NSString *errorDesc))failed{
    NSMutableArray *inviteArray = [[NSMutableArray alloc] init];
    NSString *userAccount = [[Chat sharedInstance] getAccount];
    for (NSString *account in selectedList) {
        if ([account isEqualToString:userAccount]) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"不能邀请自己")];
            failed(languageStringWithKey(@"不能邀请自己"));
            return;
        }
        if (account.length > 0) {
            [inviteArray addObject:account];
        }
    }
    
    [[ECDevice sharedInstance].messageManager inviteJoinGroup:groupId reason:@"" members:inviteArray confirm:1 completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if(error.errorCode == ECErrorType_NoError){
            if (isGroupChat) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_memberChange_Group object:nil];
                completion(nil);
            } else {
                //聊天控制器
                UIViewController *chatVC = [self getChatViewControllerWithSessionId:groupId];
                completion(chatVC);
            }
        }else{
            if(error.errorCode==171139){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"网络不给力")];
                failed(languageStringWithKey(@"网络不给力"));
            }else{
                if(!KCNSSTRING_ISEMPTY(error.errorDescription)){
                    [SVProgressHUD showErrorWithStatus:error.errorDescription];
                    failed(languageStringWithKey(error.errorDescription));
                }else{
                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"邀请失败")];
                    failed(languageStringWithKey(@"邀请失败"));
                }
            }
        }
    }];
}

//转发消息
- (void)transmitMsg:(ECMessage *)message withSelectedList:(NSArray *)selectedList completion:(void(^)(UIViewController *controller))completion{
    ECMessage *msg = (ECMessage *)message;
    for (NSString* account in selectedList) {
        ECMessage *transmitMsg = [[ECMessage alloc] initWithReceiver:account body:msg.messageBody];
        transmitMsg.userData = msg.userData;
        [[ChatMessageManager sharedInstance] sendForwardMessageByMessage:transmitMsg];
    }
    completion(nil);
}
//消息转发
- (void)transmitMsg:(NSDictionary *)data{
    ECMessage *messageList;
    if ([[data objectForKey:@"msg"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *messageDic = [data objectForKey:@"msg"];
        ECMessage *message = [[ECMessage alloc] init];
        ECPreviewMessageBody *msgBody = [[ECPreviewMessageBody alloc] initWithFile:[messageDic objectForKey:@"imgLocalPath"]?:@"" displayName:[[messageDic objectForKey:@"imgLocalPath"] lastPathComponent]];
        msgBody.url =  [messageDic objectForKey:@"URL"]?:@"";
        msgBody.title = [messageDic objectForKey:@"articleTitle"]?:@"链接";
        msgBody.remotePath = [messageDic objectForKey:@"imageStr"];
        msgBody.desc = [messageDic objectForKey:@"content"]?:msgBody.url;
        msgBody.thumbnailLocalPath = [messageDic objectForKey:@"imgThumbPath"];
        message.messageBody = msgBody;
        if ([messageDic objectForKey:@"imgLocalPath"]) {
            NSDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:[messageDic objectForKey:@"imgLocalPath"],@"fileName", nil];
            NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
            message.userData = userdataStr;
        }else{
            message.userData = @"";
        }
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
        messageList = message;
    }else{
        messageList = [data objectForKey:@"msg"];
    }
    if (messageList) {
        for (NSString *account in data[@"selectedList"]) {
            if ([[data objectForKey:@"collectionPage_IM_forwardMenu"] isEqualToString:@"collectionPage_IM_forwardMenu"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"collectionPage_IM" object:@{@"sessionId":account}];
            }else {
                if ([messageList.messageBody isKindOfClass:[ECFileMessageBody class]]) {
                    ECFileMessageBody *msgBody = (ECFileMessageBody *)messageList.messageBody;
                    NSString *oldPath = msgBody.remotePath;
                    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:oldPath];
                    if(fileDic.count > 0){
                        [[SendFileData sharedInstance] deleteAllFileUrl:oldPath];
                        NSString *filePath = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
                        ECFileMessageBody *mediaBody = [[ECFileMessageBody alloc] initWithFile:filePath displayName:[fileDic objectForKey:cachefileDisparhName]];
                        mediaBody.remotePath = msgBody.remotePath;
                        messageList.messageBody = mediaBody;
                    }
                }
                ECMessage *message = [[ECMessage alloc] initWithReceiver:account body:messageList.messageBody];
                message.userData = messageList.userData;
                [[ChatMessageManager sharedInstance] sendForwardMessageByMessage:message];
            }
        }
    }
}

//合并转发
- (id)sendMergeMessageAndSelectResultArray:(NSArray *)selectContectData andView:(UIView *)view {
    [[HXMessageMergeManager sharedInstance] sendMergeMessageAndSelectResultArray:selectContectData andCompletion:^{
        
    } andView:view];
    return nil;
}

- (UIViewController *)getRXWorkingWebViewController{
//    RXWorkingWebViewController *vc = [[RXWorkingWebViewController alloc]init];
    //    vc.isPop = YES;
//    return vc;
    return nil;
}


- (void)sendRedMessageWithText:(NSString *)text userData:(NSString *)userData sessionId:(NSString *)sessionId {
    
    ECCmdMessageBody * cmdBody = [[ECCmdMessageBody alloc] initWithText:text];
    cmdBody.offlinePush = ECOfflinePush_Off;
    cmdBody.isSyncMsg = NO;
    cmdBody.isHint = NO;
    cmdBody.isSave = YES;
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:sessionId body:cmdBody];
    //msg.apsAlert = text;
    msg.userData = userData;
    msg.isRead = YES;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    msg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
    [[ECDevice sharedInstance].messageManager sendMessage:msg progress:nil completion:^(ECError *error, ECMessage *message){
        if (error.errorCode == ECErrorType_NoError) {
            
        }
        [[KitMsgData sharedInstance] updateState:message.messageState ofMessageId:message.messageId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:message}];
    }];
    
    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:msg.sessionId];
}

- (ECMessage *)sendMessageWithMessageBody:(ECMessageBody *)messageBody dic:(NSDictionary *)dic{
    return [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:dic];
}
#pragma mark - im插件相关的方法
//设置个人信息
- (void)setPersonInfoWithUserName:(NSString *)userName withUserAcc:(NSString *)userAcc{
    ECPersonInfo *UserInfo =[[ECPersonInfo alloc]init];
    if(userName.length>0)
    {
        UserInfo.nickName=userName;
    }
    if (userAcc.length > 0) {
        UserInfo.userAcc = userAcc;
    }
    [[ECDevice sharedInstance]setPersonInfo:UserInfo completion:^(ECError *error, ECPersonInfo *person) {
        if(error.errorCode==ECErrorType_NoError && !KCNSSTRING_ISEMPTY(person.nickName))
        {
            //存入昵称成功
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[NSString stringWithFormat:@"%@%@",userAcc,@"isLoginSetPersonInfo",nil]];
        }
    }];
}

/*
 @brief 根据选择联系人界面所选择的数据开始聊天
 @param exceptData 传进聊天界面的数据
 @param addData 要添加的群组成员的数组
 @param completion 成功的回调
 @param failed 失败回调
 */
- (void)getChatViewControllerWithexceptData:(NSDictionary *)exceptData withAddDatas:(NSArray *)addData completion:(void(^)(UIViewController *controller))completion failed:(void(^)(NSString *codeStr))failed {
    
    NSMutableArray *selectedList = [NSMutableArray array];
    selectedList = [NSMutableArray arrayWithArray:addData];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    //获取传过来的人 群聊再选人、单聊选人变群聊和转发选人会传过来members
    NSArray *personList = [exceptData objectForKey:@"members"];
    if (personList.count > 0){
        for (NSString *account in personList) {
            //判断是不是重复邀请
            for (NSString *addAccount in addData) {
                if([addAccount isEqualToString:account]) {
                    NSString *str = [NSString stringWithFormat:@"联系人%@已在会话中",account];
                    //                    [SVProgressHUD showErrorWithStatus:str];
                    //                    failed(str);
                    //                    return;
                }
            }
            //群聊再选人不能再把之前的人加进去 单聊选人变群聊要把自己加进去
            if (!exceptData[@"group_info"]) {
                [selectedList addObject:account];
            }
        }
    }
    
    //群聊添加成员会传过来groupId
    if (exceptData[@"group_info"]) {
        [data setObject:exceptData[@"group_info"] forKey:@"group_info"];
    }
    //转发
    if ([exceptData objectForKey:@"msg"]) {
        [data setObject:[exceptData objectForKey:@"msg"] forKey:@"msg"];
    }
    [data setObject:selectedList forKey:@"selectedList"];
    
    
    if (selectedList.count == 0) {
        
        //        failed(@"所传数据为空");
        //        return;
    }
    
    //转发
    if (data[@"msg"]) {
        [self transmitMsg:data];
        //        NSString *sessionid = [data[@"selectedList"] lastObject];
        //        UIViewController *chatVC = [self getChatViewControllerWithSessionId:sessionid];
        completion(nil);
        return;
    }
    
    //群聊选人 不用创建新的群组
    if (data[@"group_info"]) {
        NSString *groupId = [data objectForKey:@"group_info"];
        [self inviteJoinGroupWithGroupId:groupId andSelectedList:selectedList andIsGroupChat:YES completion:^(UIViewController *controller) {
            completion(nil);
        } failed:^(NSString *str) {
            failed(str);
        }];
    }else {
        
        //要创建新的群组
        ECGroup * newgroup = [[ECGroup alloc] init];
        newgroup.name = [NSString stringWithFormat:@"%@发起的会话",[[Chat sharedInstance] getUserName].length>0?[[Chat sharedInstance] getUserName]:@"自己"];//默认群组名称：××发起的会话
        newgroup.declared = @"";
        newgroup.mode = 0;
        newgroup.owner = [[Chat sharedInstance] getAccount];
        newgroup.scope = ECGroupType_VIP;//默认1000人群
        if (!isRealGroup) {
            newgroup.isDiscuss = YES;
        }
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        newgroup.createdTime = [NSString stringWithFormat:@"%lld", (long long)tmp];
        
        [[ECDevice sharedInstance].messageManager createGroup:newgroup completion:^(ECError *error, ECGroup *group) {
            
            if (error.errorCode == ECErrorType_NoError) {
                
                [[KitMsgData sharedInstance] addGroupIDs:@[group]];
                KitGroupInfoData *groupData =[[KitGroupInfoData alloc]init];
                groupData.groupName=group.name;
                groupData.groupId=group.groupId;
                groupData.declared=group.declared;;
                groupData.owner=group.owner;
                //                        groupData.isAnonymity = group.isAnonymity;
                groupData.createTime=group.createdTime;
                groupData.type=group.type;
                groupData.memberCount=group.memberCount;
                groupData.isDiscuss=group.isDiscuss;
                
                [KitGroupInfoData insertGroupInfoData:groupData];
                
                [self inviteJoinGroupWithGroupId:group.groupId andSelectedList:selectedList andIsGroupChat:NO completion:^(UIViewController *controller) {
                    completion(controller);
                } failed:^(NSString *str) {
                    if (failed != nil) {
                        failed(str);
                    }
                }];
            }
            else{
                NSString *codeStr = [NSString stringWithFormat:@"%ld", (long)error.errorCode];
                failed(codeStr);
            }
        }];
    }
    
}


//获取未读消息数
- (NSInteger)unreadMessageCount{
    NSInteger num =[[KitMsgData sharedInstance] getUnreadMessageCountFromSession];
    return num;
}

//创建message并发送
- (void)sendTextMessageWithText:(NSString *)text userData:(NSString *)userData receiver:(NSString *)receiver{
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    mDic[@"sessionId"] = receiver;
    mDic[@"type"] = @(ChatMessageTypeText);
    ///红包消息有自己的userData，看不到功能 先不处理吧
    mDic[@"userData"] = userData;
    [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:messageBody dic:mDic];
}

/**
 查询用户所在群组
 */
- (void)getQueryOwnGroupsWithBlock:(void(^)(NSArray *))callBack{
    [[ECDevice sharedInstance].messageManager queryOwnGroupsWith:ECGroupType_All completion:^(ECError *error, NSArray *groups) {
        if (error.errorCode == ECErrorType_NoError) {
            callBack(groups);
        } else {
            if(error&&error.errorDescription){
                NSLog(@"群组列表获取失败----reason:%@",error);
            }
        }
    }];
    
}

/*
 @brief  查询群组信息
 @param groupId 群组id
 @param callBack 用于接收返回数据
 */
- (void)getGroupDetailInfoWithId:(NSString *)groupId  WithBlock:(void(^)(NSDictionary *))callBack{
    
    [[ECDevice sharedInstance].messageManager getGroupDetail:[NSString stringWithFormat:@"%@",groupId] completion:^(ECError *error, ECGroup *group) {
        [SVProgressHUD dismiss];
        if (error.errorCode == ECErrorType_NoError)
        {
            NSDictionary *groupDict = @{@"groupId":group.groupId,@"owner":group.owner,@"createdTime":group.createdTime,@"name":group.name,@"declared":group.declared,@"isDiscuss":@(group.isDiscuss)};
            callBack(groupDict);
        }else
        {
            if(error.errorCode==171139)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请检查网络是否连接", nil)];
            }else if (error.errorCode==590010)
            {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"群组不存在", nil)];
            } else {
                
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"获取群组信息失败", nil)];
            }
            callBack(nil);
        }
    }];
}

/*
 @brief  查询群组成员
 @param groupId 群组id
 @param callBack 用于接收返回数据
 */
- (void)getQueryGroupMembersWithId:(NSString *)groupId  WithBlock:(void(^)(NSArray *))callBack{
    [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString* groupId, NSArray *members) {
        
        if(error.errorCode==ECErrorType_NoError)
        {
            callBack(members);
        }else
        {
            if(!KCNSSTRING_ISEMPTY(error.errorDescription))
            {
                [SVProgressHUD showErrorWithStatus:error.errorDescription];
                return;
            }
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"成员查询失败", nil)];
            
        }
    }];
}

- (void)jumpGroupWithGroupId:(NSString *)groupId withVC:(UIViewController *)vc {
    BaseViewController *chatVC = [[AppModel sharedInstance] runModuleFunc:@"Chat" :@"getChatViewControllerWithSessionId:" :@[groupId]];
    chatVC.data = groupId;
    if (chatVC) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([vc isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabBar = (UITabBarController *)vc;
                UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
                chatVC.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:chatVC animated:YES];
            }else {
                if (vc.navigationController) {
                    [vc.navigationController pushViewController:chatVC animated:YES];
                }
                else {
                    UITabBarController *tabBar = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                    UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
                    chatVC.hidesBottomBarWhenPushed = YES;
                    if (nav.childViewControllers.count > 0) {
                        //如果本身就在这个界面就不需要跳转了
                        id vc = nav.childViewControllers.lastObject;
                        if ([vc isKindOfClass:[chatVC class]]) {
                            ChatViewController *chat = vc;
                            if ([chat.sessionId isEqualToString:groupId])
                            return;
                        }
                    }
                    [nav pushViewController:chatVC animated:YES];
                }
            }
        });
    }
}

- (void)qrcodeToJoinGroupChat:(NSDictionary *)QRcodeDic controller:(UIViewController *)controller {
    
    NSString * data = QRcodeDic[@"data"];
    NSString *dataJsonStr = data.base64DecodingString;
    NSDictionary * datajosnDic = [dataJsonStr dictionaryFromJSONString];
    
    KitGroupMemberInfoData *info = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:Common.sharedInstance.getAccount withGroupId:datajosnDic[@"groupid"]];
    if (info) { //直接进入群组
        [SVProgressHUD showSuccessWithStatus:@"你已经在此群中了"];
        [self jumpGroupWithGroupId:datajosnDic[@"groupid"] withVC:controller];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            RXJoinGroupViewController * joinGroupVC = [RXJoinGroupViewController new];
            joinGroupVC.dataSource = datajosnDic;
            if ([controller isKindOfClass:[UITabBarController class]]) {
                UITabBarController *tabBar = (UITabBarController *)controller;
                UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
                joinGroupVC.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:joinGroupVC animated:YES];
            }else {
                if (controller.navigationController) {
                    [controller.navigationController pushViewController:joinGroupVC animated:YES];
                }
                else {
                    UITabBarController *tabBar = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                    UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
                    joinGroupVC.hidesBottomBarWhenPushed = YES;
                    [nav pushViewController:joinGroupVC animated:YES];
                }
            }
            [joinGroupVC joinGroup:^(BOOL isfinish) {
                if (isfinish) {
                    [self jumpGroupWithGroupId:datajosnDic[@"groupid"] withVC:controller];
                }
            }];
        });
    }
    
//    KitGroupMemberInfoData *info = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:Common.sharedInstance.getAccount withGroupId:datajosnDic[@"groupid"]];
//    if (info) {
//        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"已在群组中")];
//    } else {
//
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:languageStringWithKey(@"是否加入群聊") preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:languageStringWithKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            //加入群
//            [[RestApi sharedInstance] joinGroupChatWithConfirm:1 Declared:@"fromQRCode" GroupId:datajosnDic[@"groupid"] Members:@[[[Common sharedInstance]getAccount]] UserName:datajosnDic[@"owner"] didFinishLoaded:^(NSDictionary *dict, NSString *path) {
//                NSInteger code = [dict[@"statusCode"] integerValue];
//                if (code == 000000) {
//                    //请求群组成员信息
//                    [[ECDevice sharedInstance].messageManager queryGroupMembers:datajosnDic[@"groupid"] completion:^(ECError *error, NSString *groupId, NSArray *members) {
//                        if (error.errorCode == ECErrorType_NoError &&
//                            members.count > 0) {
//                            [SVProgressHUD showSuccessWithStatus:nil];
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
//                                [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
//                                //聊天界面入口
//                                BaseViewController *chatVC = [[AppModel sharedInstance] runModuleFunc:@"Chat" :@"getChatViewControllerWithSessionId:" :@[datajosnDic[@"groupid"]]];
//                                chatVC.data = datajosnDic[@"groupid"];
//                                if (chatVC) {
//                                    UIViewController *sessionVC;
//                                    if (controller.navigationController.childViewControllers.count > 0) {
//                                        sessionVC = controller.navigationController.childViewControllers[0];
//                                    }
//                                    if (sessionVC) {
//                                        [controller.navigationController popToViewController:sessionVC animated:NO];
//                                        [(BaseViewController *)sessionVC pushViewController:chatVC];
//                                    }else{
//                                        controller.hidesBottomBarWhenPushed = YES;
//                                        [controller.navigationController pushViewController:chatVC animated:YES];
//                                    }
//                                }
//                            });
//                        }
//                    }];
//                }else if (code == 590038){
//                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"已在群组中")];
//                }else if (code == 590010){
//                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"该群组已解散")];
//                }else if (code == 113608){
//                    [SVProgressHUD showErrorWithStatus:dict[@"statusMsg"]];
//                }else{
//                    [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"扫码加群失败")];
//                }
//            } didFailLoaded:^(NSError *error, NSString *path) {
//                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"扫码加群失败")];
//            }];
//
//        }];
//
//        UIAlertAction *alertAction3 = [UIAlertAction actionWithTitle:languageStringWithKey(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [alertC dismissViewControllerAnimated:YES completion:nil];
//        }];
//        [alertC addAction:alertAction1];
//        [alertC addAction:alertAction3];
//        [controller presentViewController:alertC animated:YES completion:nil];
//    }
}

@end
