/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "KitMsgData.h"
#import <UIKit/UIDevice.h>
#import "ECSession+Ext.h"
#import "KCConstants_API.h"
#import "ECMessage_Son.h"

#import "KitGroupInfoData.h"
@interface KitMsgData()

@end

@implementation KitMsgData

+ (KitMsgData *)sharedInstance{
    static KitMsgData *imdbmanager;
    static dispatch_once_t imdbmanageronce;
    dispatch_once(&imdbmanageronce, ^{
        imdbmanager = [[KitMsgData alloc] init];
    });
    return imdbmanager;
}
#pragma mark - session表相关

///使用事务来入库
-(void)updateSessionArr:(NSArray<ECSession *> *)resourse useTransaction:(BOOL)useTransaction{
    NSMutableArray *newArr = [NSMutableArray new];
    for (ECSession *session in resourse) {
        NSString *groupNotice = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount],session.sessionId];
        NSString *isNotice = [[NSUserDefaults standardUserDefaults] objectForKey:groupNotice];
        if([isNotice isEqualToString:@"1"]){//isnotice字段设置1
            session.isNotice = YES;
        }else{
            session.isNotice = NO;
        }
        
        [newArr addObject:session];
    }
    [ECSession insertSessionArr:newArr useTransaction:useTransaction];
    
}

///新增或修改session
- (void)updateSession:(ECSession *)session{
    NSString *groupNotice = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount],session.sessionId];
    NSString *isNotice = [[NSUserDefaults standardUserDefaults] objectForKey:groupNotice];
    if (!session.isNotice) {    
        if([isNotice isEqualToString:@"1"]){//isnotice字段设置1
            session.isNotice = YES;
        }else{
            session.isNotice = NO;
        }
    }
    ///新增或修改session
    [ECSession addNewSession:session];
}
///新增草稿
- (void)addNewDraftText:(ECSession *)message{
    ECSession *session = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:message.sessionId];
    if(session){
        session.draft = message.draft;
        session.dateTime = message.dateTime + 1;
    }else{
        session = message;
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
    }
    [self updateSession:session];
}
///更新草稿
- (void)updateDraft:(NSString *)draft withSessionID:(NSString *)sessionID{
    if (KCNSSTRING_ISEMPTY(draft)) {
        //首先得判断沟通列表是否存在
        ECSession *session = [ECSession getSessionBySessionId:sessionID];
        if(session == nil){
            return;
        }
        //存在更新沟通列表显示 有二种情况 一种是含有聊天消息 另外是没有聊天消息
        NSArray<ECMessage *> *messageArray = [self getLatestHundredMessageOfSessionId:sessionID andSize:1 andASC:YES];

        if(messageArray.count > 0){
            ECMessage *message = messageArray.firstObject;
            session = [ECSession messageConvertToSession:message useNewTime:NO];
            if (!KCNSSTRING_ISEMPTY(message.sessionId)) {
                [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
            }
            session.unreadCount = 0;
            session.draft = @"";
            [self addNewDraftText:session];
        }else{
            //没有聊天消息 更新列表
            session.text = @"";
            session.draft = @"";
            [self addNewDraftText:session];
        }
    }else{
        //草稿的时间应该不变，因为是未发出的消息
//        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
//        NSTimeInterval time = [date timeIntervalSince1970] * 1000;

        ECSession *session = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:sessionID];
        if (!session) {
            session = [[ECSession alloc] init];
            session.type = MessageBodyType_Text;
            session.text = @"";
        }
        session.sessionId = sessionID;
//        session.dateTime = time;
        session.draft = draft;
        [self addNewDraftText:session];
    }
}

///根据sessionid获取Session
- (ECSession *)loadSessionWithID:(NSString *)sessionID {
    return [ECSession getSessionBySessionId:sessionID];
}
///根据sessionId删除
- (void)deleteSession:(NSString *)sessionId{
    if ([ECSession deleteSessionBySessionId:sessionId]) {
        //删除成功后移除
        if ([AppModel sharedInstance].appData.curSessionsDict) {
            [[AppModel sharedInstance].appData.curSessionsDict removeObjectForKey:sessionId];
        }
    }
}
///查询所有sessions key为sessionid  value为session对象
- (NSMutableDictionary *)loadAllSessions{
    NSMutableDictionary *sessionDict = [[NSMutableDictionary alloc] init];
    NSArray<ECSession *> *array = [ECSession getAllSession];

    for (ECSession *session in array) {
        if ([session.sessionId hasSuffix:@"@burn"]) {
            [self deleteMessageOfSession:session.sessionId];
            [self deleteSession:session.sessionId];
        }else if (![session.sessionId isEqualToString:@"rx1"]) {
            [sessionDict setObject:session forKey:session.sessionId];
            ///设置状态为发送失败
            [ECMessage_Son updateMessageSendFileBySessionId:session.sessionId];
        }
    }
    return sessionDict;
}
#pragma mark -根据ECMessage转成session插入消息 批量
- (void)addSessionArr:(NSArray <ECSession *>*)sessionArr andSessionId:(NSString *)sessionId{

//    [self addMessageArr:newSessionArr];
    [self updateSessionArr:sessionArr useTransaction:YES];
    //发通知ChatViewController刷新列表
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"callMessageClick" object:nil];
}
///根据ECMessage转成session插入消息 这里没有插入数据库
- (ECSession *)addNewMessage2:(ECMessage *)message andSessionId:(NSString *)sessionId {
    ECSession *session = [ECSession messageConvertToSession:message useNewTime:NO];
    if (!KCNSSTRING_ISEMPTY(message.sessionId)) {
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
    }
    ///读取ECMessage类型 在被邀请进群，被移出群，修改群名称，群公告，不需要unreadCount++ GROUP_NOTICE
    NSString *type = [[MessageTypeManager getCusDicWithUserData:message.userData] objectForKey:kRonxinMessageType];
    
    if ([message.from isEqualToString:[Common sharedInstance].getAccount]) {
        //自己发的消息未读数不加1，且未读数置为0
        session.unreadCount = 0;
    } else {
        if ([message.sessionId isEqualToString:sessionId] || message.messageState == ECMessageState_SendSuccess){
            if (![type isEqualToString:@"GROUP_NOTICE"]) {
                session.unreadCount++;
            }
        }else if (![session.sessionId isEqualToString:@"rx1"]){
            if (![type isEqualToString:@"GROUP_NOTICE"]) {
                session.unreadCount++;
            }
        }
    }
    return session;
}

//添加离线消息  入库的时间需要服务器时间
- (ECSession *)addOfflineMessage:(ECMessage *)message andSessionId:(NSString *)sessionId {
    ECSession *session = [ECSession messageConvertToSession:message useNewTime:NO];
    if (!KCNSSTRING_ISEMPTY(message.sessionId)) {
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
    }
    ///读取ECMessage类型 在被邀请进群，被移出群，修改群名称，群公告，不需要unreadCount++ GROUP_NOTICE
    NSString *type = [[MessageTypeManager getCusDicWithUserData:message.userData] objectForKey:kRonxinMessageType];
    
    if ([message.from isEqualToString:[Common sharedInstance].getAccount]) {
        //自己发的消息未读数不加1，且未读数置为0
        session.unreadCount = 0;
    } else {
        if ([message.sessionId isEqualToString:sessionId] || message.messageState == ECMessageState_SendSuccess){
            if (![type isEqualToString:@"GROUP_NOTICE"]) {
                session.unreadCount++;
            }
        }else if (![session.sessionId isEqualToString:@"rx1"]){
            if (![type isEqualToString:@"GROUP_NOTICE"]) {
                session.unreadCount++;
            }
        }
    }
    return session;
}

///根据ECMessage转成session插入消息
- (void)addNewMessage:(ECMessage *)message andSessionId:(NSString *)sessionId{
//    [self addNewMessage2:message andSessionId:sessionId];
    ECSession *session = [ECSession messageConvertToSession:message useNewTime:YES];
    if (message.isGroupNoticeMessage) {
        session.isNotice = YES;
    }else {
        session.isNotice = NO;
    }
    if (!KCNSSTRING_ISEMPTY(message.sessionId)) {
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
    }
    ///读取ECMessage类型 在被邀请进群，被踢出群，修改群名称，群公告，不需要unreadCount++ GROUP_NOTICE
    NSString *type = [[MessageTypeManager getCusDicWithUserData:message.userData] objectForKey:kRonxinMessageType];
    
    if ([message.from isEqualToString:[Common sharedInstance].getAccount]) {
        //自己发的消息未读数不加1，且未读数置为0
        session.unreadCount = 0;
    } else {
        if (![message.sessionId isEqualToString:FileTransferAssistant]) { //文件助手 未读不加1
            if ([message.sessionId isEqualToString:sessionId] || message.messageState == ECMessageState_SendSuccess){
                if (![type isEqualToString:@"GROUP_NOTICE"]) {
                    session.unreadCount++;
                }
            } else if (![session.sessionId isEqualToString:@"rx1"]){
                if (![type isEqualToString:@"GROUP_NOTICE"]) {
                    session.unreadCount++;
                }
            }
        }
    }
    //更新session
    [self updateSession:session];
    
    //新增chat消息
    [self addMessage:message];
    
//    发通知ChatViewController刷新列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callMessageClick" object:message];
}
//删除单个聊天的所有消息，保留通道
- (void)deletemessageid:(NSString *)sessonid{
    ECSession *existSession = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:sessonid];
    if(existSession){
        existSession.text = @"";
        existSession.fromId = nil;
        existSession.unreadCount = 0;
        ///存在的话更新表
        [self updateSession:existSession];
    }else{
        [self deleteSession:sessonid];
    }
    ///删除某个会话的所有消息
    [self deleteMessageOfSession:sessonid];
}

- (void)deleteMessage:(ECMessage *)message andPre:(ECMessage *)premessage{
    if (premessage) {
        long long int time = [premessage.timestamp longLongValue];
        ECSession *session = [ECSession messageConvertToSession:premessage useNewTime:NO];
        if (!KCNSSTRING_ISEMPTY(message.sessionId)) {
            [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
        }
        session.dateTime = time;
        //删除沟通显示
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:message.sessionId];
        [self updateSession:session];
        ///删除某个会话的所有消息
        [self deleteMessage:message.messageId andSession:message.sessionId];
    } else {
        [[KitMsgData sharedInstance] deletemessageid:message.sessionId];
    }
}
///未读session数量
- (NSInteger)getUnreadMessageCountFromSession {
    return [ECSession getUnreadSessionCount];
}

///根据sessionid标记消息已读
- (void)setUnreadMessageCountZeroWithSessionId:(NSString *)sessionId{
    NSDictionary *sessionDic = [AppModel sharedInstance].appData.curSessionsDict;
    ECSession *session = [sessionDic objectForKey:sessionId];
    if (session == nil) {
        return;
    }
    session.unreadCount = 0;
    session.isAt = NO;
    [self updateSession:session];

    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:session.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
    //发通知ChatViewController刷新列表
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_Multi_TerminalRead object:nil];
}
/// eagle 设置所有消息未读为零
- (void)setAllUnreadMessageCountZero{
    //获取所有session
    NSArray<ECSession *> *array = [AppModel sharedInstance].appData.curSessionsDict.allValues;
    for (ECSession *session in array) {
        session.unreadCount = 0;
        session.isAt = NO;
        [self updateSession:session];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
    //发通知ChatViewController刷新列表
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_Multi_TerminalRead object:nil];
}
///更新是否是消息提醒的状态
- (BOOL)updateMessageNoticeid:(NSString *)sessionid withNoticeStatus:(BOOL)isNoticeStatus{
    ECSession *existSession = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:sessionid];
    if(existSession){
        [existSession setMessageNotice:isNoticeStatus];
    }
    return [ECSession updateSessionNoticeBySessionId:sessionid isNotice:isNoticeStatus];
}

///按dateTime排序的sessionid
- (NSArray<NSString *> *)getMyCustomSession{
    if (![AppModel sharedInstance].appData.curSessionsDict){
        [AppModel sharedInstance].appData.curSessionsDict = [self loadAllSessions];
    }
    return  [[AppModel sharedInstance].appData.curSessionsDict.allValues sortedArrayUsingComparator:^(ECSession *obj1, ECSession* obj2){
        if(obj1.dateTime > obj2.dateTime) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
}
///按dateTime排序的sessionid
- (NSArray<NSString *> *)getMyNewCustomSession{
    [AppModel sharedInstance].appData.curSessionsDict = [self loadAllSessions];
    return  [[AppModel sharedInstance].appData.curSessionsDict.allValues sortedArrayUsingComparator:^(ECSession *obj1, ECSession* obj2){
        if(obj1.dateTime > obj2.dateTime) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
}
///更新会话和聊天表
- (void)updateSrcMessage:(NSString *)sessionId msgid:(NSString *)msgId withDstMessage:(ECMessage *)dstmessage{
    ECSession *session = [ECSession messageConvertToSession:dstmessage useNewTime:YES];
    if (!KCNSSTRING_ISEMPTY(dstmessage.sessionId)) {
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:dstmessage.sessionId];
    }
    //如果该消息正在聊天中 或 消息的状态是已发送则代码消息已经在其他设备上是已读过
    if ([dstmessage.messageBody isKindOfClass:[RXRevokeMessageBody class]]){
        session.unreadCount--;
        if (session.unreadCount < 0) {
            session.unreadCount = 0;
        }
    }else if ([sessionId isEqualToString:dstmessage.sessionId] ||
              dstmessage.messageState == ECMessageState_SendSuccess) {
        session.unreadCount = 0;
    } else {
        session.unreadCount++;
    }
    ///更新会话
    [self updateSession:session];
    ///更新聊天
    [self updateMessage:sessionId msgid:msgId withMessage:dstmessage];
}
///新增公众号消息
- (void)addNewPublicMessage:(id)message andSessionId:(NSString *)sessionId{
    ECSession *newSession = (ECSession *)message;
    ECSession *session = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:newSession.sessionId];

    long long int time = newSession.dateTime;
    if(session){
        if(session.dateTime < time){
            session.dateTime = time;
        }
        session.text = newSession.text;
        session.type = newSession.type;
        session.fromId = newSession.fromId;
    }else{
        session = message;
        [[AppModel sharedInstance].appData.curSessionsDict  setObject:session forKey:newSession.sessionId];
    }
    if([newSession.sessionId isEqualToString:sessionId]){
        session.unreadCount = 0;
    }else{
        session.unreadCount++;
    }
    [self updateSession:session];
}
///删除公众号会话
- (void)deletePublicMessage:(NSString *)sessionId{
    ECSession *session = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:sessionId];
    if(session){
        //获取最新的一条公众号消息
        NSDictionary *publicNum = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"getPublicMessageInformation" :nil];
        //当前未读数
        NSNumber *unreadCountNum = [[AppModel sharedInstance] runModuleFunc:@"PublicService" :@"getAppointPublicListCount:" :@[session.fromId ? :@""]];
        //总的未读数
        NSInteger resultCount = session.unreadCount - unreadCountNum.integerValue;
        if(resultCount <= 0){
            resultCount = 0;
        }
        if(publicNum.count > 0){
            session.fromId = publicNum[@"pnid"];
            session.dateTime = [publicNum[@"ptime"] longLongValue];
            session.unreadCount = resultCount;
            session.text = publicNum[@"msgTitle"];
        }else{
            session.fromId = @"";
            session.unreadCount = resultCount;
            session.text = @"";
        }
        [self updateSession:session];

        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:sessionId];
    }else{
        [self deleteSession:sessionId];
    }
}
//删除公众号消息 更新沟通列表的数据 publicDic:pnid(公众号) msgTitle(标题) ptime(时间)
- (void)deletePublicMessage:(NSString *)sessionId withPreNum:(NSDictionary *)publicDic{
    ECSession *session = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:sessionId];

    if(session){
        if(publicDic.count > 0){
            session.fromId = publicDic[@"pnid"];
            session.dateTime = [publicDic[@"ptime"] longLongValue];
            session.text = publicDic[@"msgTitle"];
            [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:sessionId];
        }else{
            session.text = @"";
            session.unreadCount = 0;
            session.fromId = @"";
        }
        //更新沟通列表
        [[AppModel sharedInstance].appData.curSessionsDict setObject:session forKey:sessionId];
        [self updateSession:session];
    }else{
        [self deleteSession:sessionId];
    }
}
//清空表
- (NSInteger)clearGroupMessageTable {
    return [ECSession deleteSessionType:@"100"];
}
#pragma mark - im_groupinfo表相关
///增加一条消息
- (BOOL)addGroupID:(ECGroup *)group {
    if ([group.name isEqualToString:@"ConfGroup"] && group.type == 0) {
        return YES;
    }
    return [KitGroupInfoData addGroup:group];
}
///增加多条消息
- (NSInteger)addGroupIDs:(NSArray*)messages {
    int i = 0;
    for (ECGroup *groupMsg in messages) {
        if ([self addGroupID:groupMsg]) {
            i++;
        }
    }
    return i;
}
///获取群组ID、名字
- (NSArray<ECGroup *> *)getGroupCountOfGroupInfo{
    return [KitGroupInfoData getAllGroup];
}
///根据name 倒序筛选查询群组
- (NSArray<ECGroup *> *)getGroupWithSearchText:(NSString *)searchText{
    return [KitGroupInfoData getGroupWithSearchText:searchText];
}
//获取群组个数
- (NSInteger)getGroupAllCount{
    return [KitGroupInfoData getGroupAllCount];
}

///根据groupId查groupName
- (NSString *)getGroupName:(NSString *)groupId andGroupName:(NSString *)groupName {
    NSString *name = [self getGroupNameOfId:groupId];
    if (name.length > 0) {///查询到直接返回
        return name;
    }
    if (groupName.length > 0) {//有默认的话用默认
        return groupName;
    }
    ///没有数据用groupId替代
    return groupId;
}
///根据groupId查name
- (NSString *)getGroupNameOfId:(NSString *)groupId{
    return [KitGroupInfoData getGroupNameByGroupId:groupId];
}
///根据groupId查ECGroup对象
- (ECGroup *)getGroupByGroupId:(NSString *)groupId{
    return [KitGroupInfoData getGroupByGroupId:groupId];
}
///返回的是字典 ECGroup里没有isGroupMember字段 字典里有
- (NSArray *)getGroupInformation:(NSString *)groupId{
    return [KitGroupInfoData getGroupInformationByGroupId:groupId];
}
//刷新成员在群中的状态
- (BOOL)updateMemberStateInGroupId:(NSString *)groupId memberState:(int)memberState{
    return [KitGroupInfoData updateMemberStateByGroupId:groupId isGroupMember:memberState];
}
#pragma mark - chat表相关
///撤回消息
- (BOOL)updateMessage:(NSString *)sessionId msgid:(NSString *)msgId withMessage:(ECMessage *)message{
    return [ECMessage_Son updateMessage:sessionId msgid:msgId withMessage:message];
}
///根据sessionId查询某个时间前的n条聊天数据
- (NSArray<ECMessage *> *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp andASC:(BOOL)asc{
    return [ECMessage_Son getMessagesBySessionId:sessionId beforeTime:timesamp count:count asc:asc];
}
//按照文字去搜索消息
- (NSArray<ECMessage *> *)getSomeMessagesWithSearhStr:(NSString *)searchStr ofSession:(NSString *)sessionId{
    return [ECMessage_Son getMessagesBySessionId:sessionId searchText:searchStr];
}
///根据messageId 和 sessionId查询
- (ECMessage *)getMessagesWithMessageId:(NSString *)messageId  OfSession:(NSString *)sessionId{
    return [ECMessage_Son getMessageByMessageId:messageId sessionId:sessionId];
}

///查询所有的image消息
- (NSArray *)getAllImageMessageOfSessionId:(NSString *)sessionId{
    return [ECMessage_Son getMessagesBySessionId:sessionId msgType:(long)MessageBodyType_Image];
}

///查询所有的图片和视频消息
- (NSArray *)getAllMediaMessageOfSessionId:(NSString *)sessionId {
    return [ECMessage_Son getMediaMessagesBySessionId:sessionId];
}

///查询所有的文件消息
- (NSArray *)getAllFileMessageOfSessionId:(NSString *)sessionId {
    return [ECMessage_Son getMessagesBySessionId:sessionId msgType:(long)MessageBodyType_File];
}

///查询某个对话的所有消息
- (NSArray *)getAllMessageWithSessionId:(NSString *)sessionId {
    return [ECMessage_Son getMessageBySessionId:sessionId];
}
///使用事务来入库
//增加单条消息
- (BOOL)addMessage:(ECMessage *)message{
    return [ECMessage_Son addNewChat:message];
}
//增加多条消息
- (void)addMessageArr:(NSArray<ECMessage *> *)messageArr{
     [ECMessage_Son insertData:messageArr useTransaction:true];
}
//删除单条消息
- (BOOL)deleteMessage:(NSString *)msgId andSession:(NSString *)sessionId{
    return [ECMessage_Son deleteMessageId:msgId andSession:sessionId];
}
//删除某个会话的所有消息
- (NSInteger)deleteMessageOfSession:(NSString *)sessionId {
    return [ECMessage_Son deleteMessageBySessionId:sessionId];
}
//获取会话的某个时间点之前的count条消息
- (NSArray<ECMessage *> *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp {
    return [ECMessage_Son getMessagesBySessionId:sessionId beforeTime:timesamp count:count];
}
//获取会话的某个时间点之后的count条消息
- (NSArray<ECMessage *> *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId afterTime:(long long)timesamp {
    return [ECMessage_Son getMessagesBySessionId:sessionId afterTime:timesamp count:count];
}
///修改单条消息的下载路径
- (BOOL)updateMessageLocalPath:(NSString *)msgId withPath:(NSString *)path withDownloadState:(NSInteger)state{
    return [ECMessage_Son updateMessageLocalPathByMsgId:msgId withPath:path withDownloadState:state];
}

//修改单条本地消息的下载路径(明明改的是远程路径啊)
- (BOOL)updateLocationMessageLocalPath:(NSString*)msgId withPath:(NSString*)path{
    return [ECMessage_Son updateLocationMessageLocalPathByMsgId:msgId withPath:path];
}

///更新文件消息体的服务器远程文件路径
- (BOOL)updateMessageRemotePathByMessageId:(NSString *)messageId remotePath:(NSString *)remotePath {
    return [ECMessage_Son updateMessageRemotePathByMessageId:messageId remotePath:remotePath];
}

//更新某消息的状态
- (BOOL)updateState:(NSInteger)state ofMessageId:(NSString *)msgId{
    return [ECMessage_Son updateState:state messageId:msgId];
}

//更新某消息的uuid
- (BOOL)updateUuid:(NSString *)uuid ofMessageId:(NSString *)msgId{
    return [ECMessage_Son updateUuid:uuid messageId:msgId];
}

//更新某消息计算好的高度
- (BOOL)updateHeight:(int)height ofMessageId:(NSString *)msgId{
    return [ECMessage_Son updateHeight:height ofMessageId:msgId];
}

//更新某消息未读数
- (BOOL)updateUnreadCount:(NSInteger)unreadCount ofMessageId:(NSString *)msgId{
    return [ECMessage_Son updateUnreadCount:unreadCount ofMessageId:msgId];
}

//获取某消息未读数
- (NSInteger)getUnreadCountByMessageId:(NSString *)msgId {
    return [ECMessage_Son getUnreadCountByMessageId:msgId];
}

//更新某消息 类型和userdata
- (BOOL)updateMsgType:(ECMessageBody *)body UserData:(NSString *)userData ofMessageId:(NSString *)msgId{
    return [ECMessage_Son updateMsgType:body UserData:userData ofMessageId:msgId];
}
//重发，更新某消息的消息id
- (BOOL)updateMessageId:(NSString *)msdNewId andTime:(long long)time ofMessageId:(NSString *)msgOldId{
    return [ECMessage_Son updateMessageId:msdNewId andTime:time ofMessageId:msgOldId];
}

//更新语音消息是否播放的状态
-(BOOL)updateMessageState:(NSString *)messageId andUserData:(NSString *)userData{
    return [ECMessage_Son updateMessageState:messageId andUserData:userData];
}
///更新是否已读
- (BOOL)updateMessageReadStateByMessageId:(NSString *)messageId isRead:(BOOL)isRead {
    return [ECMessage_Son updateMessageReadStateByMessageId:messageId isRead:isRead];
}
///获取n条未读消息数，根据根据当前时间
- (NSArray<ECMessage *> *)getUnreadMessageDependCurrendTimeOfSessionId:(NSString *)sessionId andSize:(NSInteger)pageSize{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970] * 1000;
    return [ECMessage_Son getMessagesBySessionId:sessionId beforeTime:(long long)tmp count:pageSize isRead:NO];
}
///获取会话的某个时间点之前的 是否已读消息
- (NSArray<ECMessage *> *)getAllMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp andIsRead:(BOOL)isread{
    return [ECMessage_Son getMessagesBySessionId:sessionId beforeTime:timesamp count:count isRead:isread];
}
///根据sessionId 查n条 当前时间点前的数据 按时间排序
- (NSArray<ECMessage *> *)getLatestHundredMessageOfSessionId:(NSString *)sessionId andSize:(NSInteger)pageSize andASC:(BOOL)asc{
    //取消会议后立即查询消息，最新的消息查不出来，所以讲时间延后60s
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60];
    NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
    return [ECMessage_Son getMessagesBySessionId:sessionId beforeTime:(long long)tmp count:pageSize asc:asc];
}

///查询时间段内的消息
- (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId startTime:(NSDate *)startTime endTime:(NSDate *)endTime{
    long long startTimeSp = [startTime timeIntervalSince1970];
//    startTimeSp -= startTimeSp % 86400;
    startTimeSp *= 1000;

    long long endTimeTimeSp = [endTime timeIntervalSince1970];
//    endTimeTimeSp -= endTimeTimeSp % 86400;
//    endTimeTimeSp += 86399;
    endTimeTimeSp *= 1000;
    return [ECMessage_Son getMessagesBySessionId:sessionId startTime:[NSString stringWithFormat:@"%lld",startTimeSp] endTime:[NSString stringWithFormat:@"%lld",endTimeTimeSp]];
}

///根据用户查消息
- (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId sender:(NSString *)sender{
    return [ECMessage_Son getMessagesBySessionId:sessionId sender:sender];
}
#pragma mark - 李晓杰处理图片消息的宽高预读
//更新某消息计算好的高度
- (BOOL)updateImageSize:(CGSize)size ofMessageId:(NSString *)msgId{
    return [ECMessage_Son updateImageSize:size ofMessageId:msgId];
}
- (CGSize)caculateImageSize:(NSData *)imageData{
    return [ECMessage_Son caculateImageSize:imageData];
}







///删除所有消息
- (BOOL)deleteAllSessionAndGroupnoticeData {
    if ([self deleteAllChat] &&
        [self deleteAllSession]) {
        [self delleteMessageUpdateCache];
        return YES;
    }else{
        return NO;
    }
}
- (BOOL)deleteAllChat{
    return [ECMessage_Son deleteAllMessage];
}
- (BOOL)deleteAllSession{
    return [ECSession deleteAllSession];
}
- (BOOL)deleteAllGroupInfo{
    return [KitGroupInfoData deleteAllGroup];
}
///删除所有消息更新缓存
- (void)delleteMessageUpdateCache{
    [AppModel sharedInstance].appData.curSessionsDict = nil;
    [AppModel sharedInstance].appData.curSessionsDict = [NSMutableDictionary dictionary];
}

//gy add
- (ECMessage *)getMessageById:(NSString *)SID {
    NSArray *msgArr = [ECMessage_Son getMessagesBySessionId:SID];
    if (msgArr.count>0) {
        return msgArr.lastObject;
    }else {
        return nil;
    }
}

@end
