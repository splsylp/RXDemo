//
//  ECMessage_Son.mm
//  Common
//
//  Created by lxj on 2018/8/22.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "ECMessage_Son+WCTTableCoding.h"
#import "ECMessage_Son.h"
#import <WCDB/WCDB.h>

#import "DataBaseManager.h"
@implementation ECMessage_Son

WCDB_IMPLEMENTATION(ECMessage_Son)
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, tid, "id")
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, sessionId, "SID")
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, messageId, "msgid")
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, from, "sender")
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, to, "receiver")
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, timestamp, "createdTime")
WCDB_SYNTHESIZE(ECMessage_Son, userData)
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, messageState, "state")
WCDB_SYNTHESIZE(ECMessage_Son, msgType)
WCDB_SYNTHESIZE(ECMessage_Son, text)
WCDB_SYNTHESIZE(ECMessage_Son, localPath)
WCDB_SYNTHESIZE_COLUMN(ECMessage_Son, remotePath, "URL")
WCDB_SYNTHESIZE(ECMessage_Son, serverTime)
WCDB_SYNTHESIZE(ECMessage_Son, dstate)
WCDB_SYNTHESIZE(ECMessage_Son, remark)
WCDB_SYNTHESIZE(ECMessage_Son, displayName)
WCDB_SYNTHESIZE(ECMessage_Son, uuid)
WCDB_SYNTHESIZE_DEFAULT(ECMessage_Son, isRead,0)
WCDB_SYNTHESIZE_DEFAULT(ECMessage_Son, height,-1)
WCDB_SYNTHESIZE_DEFAULT(ECMessage_Son, imageHeight,0)
WCDB_SYNTHESIZE_DEFAULT(ECMessage_Son, imageWight,0)
WCDB_SYNTHESIZE_DEFAULT(ECMessage_Son, unreadCount,0)

WCDB_PRIMARY_AUTO_INCREMENT(ECMessage_Son, tid)

WCDB_INDEX(ECMessage_Son, "idx1", sessionId)
WCDB_INDEX(ECMessage_Son, "idx2", messageId)
WCDB_INDEX(ECMessage_Son, "idx3", sessionId)
WCDB_INDEX(ECMessage_Son, "idx3", messageId)
WCDB_INDEX(ECMessage_Son, "idx4", sessionId)
WCDB_INDEX(ECMessage_Son, "idx4", timestamp)
WCDB_INDEX(ECMessage_Son, "idx5", sessionId)
WCDB_INDEX(ECMessage_Son, "idx5", msgType)
WCDB_INDEX(ECMessage_Son, "idx6", sessionId)
WCDB_INDEX(ECMessage_Son, "idx6", msgType)
WCDB_INDEX(ECMessage_Son, "idx6", timestamp)
WCDB_INDEX(ECMessage_Son, "idx7", sessionId)
WCDB_INDEX(ECMessage_Son, "idx7", messageId)
WCDB_INDEX(ECMessage_Son, "idx7", timestamp)
WCDB_INDEX(ECMessage_Son, "idx8", sessionId)
WCDB_INDEX(ECMessage_Son, "idx8", msgType)
WCDB_INDEX(ECMessage_Son, "idx8", messageId)
WCDB_INDEX(ECMessage_Son, "idx8", timestamp)

///使用事务来入库
+ (BOOL)insertData:(NSArray<ECMessage *> *)resourse useTransaction:(BOOL)useTransaction{
    NSLog(@"消息批量入库 resourse.count = %lu",(unsigned long)resourse.count);
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }
        NSMutableArray<ECMessage_Son *> *newArr = [NSMutableArray new];
        for (ECMessage *message in resourse) {
            ECMessage_Son *son = [ECMessage_Son sonWithMesaage:message];
            son.isAutoIncrement = YES;
            [newArr addObject:son];
        }
        BOOL res =  [dataBase insertObjects:newArr into:DATA_CHAT_DBTABLE];
        
        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
        return res;
    }else{//普通插入
        NSMutableArray<ECMessage_Son *> *newArr = [NSMutableArray new];
        for (ECMessage *message in resourse) {
            ECMessage_Son *son = [ECMessage_Son sonWithMesaage:message];
            son.isAutoIncrement = YES;
            [newArr addObject:son];
        }
       return [dataBase insertObjects:newArr into:DATA_CHAT_DBTABLE];
    }
}

#pragma mark - 增
+ (BOOL)addNewChat:(ECMessage *)message{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [ECMessage_Son sonWithMesaage:message];
    son.isAutoIncrement = YES;
    return [dataBase insertObject:son into:DATA_CHAT_DBTABLE];
}

#pragma mark - 删
///删除方法
+ (BOOL)deleteMessageByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_CHAT_DBTABLE where:condition];
}
///根据sessionid删除
+ (BOOL)deleteMessageBySessionId:(NSString *)sessionId{
    return [self deleteMessageByCondition:ECMessage_Son.sessionId == sessionId];
}
///根据messageId和sessionid删除
+ (BOOL)deleteMessageId:(NSString *)messageId andSession:(NSString *)sessionId{
    return [self deleteMessageByCondition:ECMessage_Son.messageId == messageId && ECMessage_Son.sessionId == sessionId];
}
///删除所有聊天
+ (BOOL)deleteAllMessage{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_CHAT_DBTABLE];
}
#pragma mark - 改
///将发送中的消息改为发送失败
+ (BOOL)updateMessageSendFileBySessionId:(NSString *)sessionId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.messageState = (ECMessageState)ECMessageState_SendFail;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.messageState withObject:son where:ECMessage_Son.sessionId == sessionId && ECMessage_Son.messageState == ECMessageState_Sending];
}
///撤回消息
+ (BOOL)updateMessage:(NSString *)sessionId msgid:(NSString *)msgId withMessage:(ECMessage *)message{
    if (![message.messageBody isKindOfClass:[RXRevokeMessageBody class]]) {
        return NO;
    }
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    RXRevokeMessageBody *revokeBody = (RXRevokeMessageBody *)message.messageBody;
    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.messageState = message.messageState;
    son.msgType = message.messageBody.messageBodyType;
    son.text = revokeBody.text;
    son.remark = @"RXRevokeMessageBody";
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:{ECMessage_Son.messageState,ECMessage_Son.msgType,ECMessage_Son.text,ECMessage_Son.remark} withObject:son where:ECMessage_Son.messageId == msgId];
}
///根据msgId设置下载状态和路径
+ (BOOL)updateMessageLocalPathByMsgId:(NSString *)msgId withPath:(NSString *)path withDownloadState:(NSInteger)state{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.localPath = path;
    son.dstate = state;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:{ECMessage_Son.localPath,ECMessage_Son.dstate} withObject:son where:ECMessage_Son.messageId == msgId];
}
///根据msgId设置下载路径
+ (BOOL)updateLocationMessageLocalPathByMsgId:(NSString *)msgId withPath:(NSString *)path{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.remotePath = path;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.remotePath withObject:son where:ECMessage_Son.messageId == msgId];
}
//更新某消息的状态
+ (BOOL)updateState:(NSInteger)state messageId:(NSString *)msgId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.messageState = (ECMessageState) state;

    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.messageState withObject:son where:ECMessage_Son.messageId == msgId];
}

//更新某消息uuid
+ (BOOL)updateUuid:(NSString *)uuid messageId:(NSString *)msgId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.uuid = uuid;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.uuid withObject:son where:ECMessage_Son.messageId == msgId];
}

//更新某消息计算好的高度
+ (BOOL)updateHeight:(int)height ofMessageId:(NSString *)msgId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.height = height;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.height withObject:son where:ECMessage_Son.messageId == msgId];
}

//更新某消息的未读数
+ (BOOL)updateUnreadCount:(NSInteger)unreadCount ofMessageId:(NSString *)msgId {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.unreadCount = unreadCount;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.unreadCount withObject:son where:ECMessage_Son.messageId == msgId];
}

+ (NSInteger)getUnreadCountByMessageId:(NSString *)msgId {
    ECMessage_Son *son = [self getMessageByCondition:ECMessage_Son.messageId == msgId];
    return son.unreadCount;
}

//更新某消息 类型和userdata
+ (BOOL)updateMsgType:(ECMessageBody *)body UserData:(NSString *)userData ofMessageId:(NSString *)msgId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    [self setECMessage_Son:son mediaMsgBody:body];
    son.userData = userData;
    son.msgType = body.messageBodyType;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:{
        ECMessage_Son.userData,
        ECMessage_Son.msgType,
        ECMessage_Son.remark
    } withObject:son where:ECMessage_Son.messageId == msgId];
}
//重发，更新某消息的消息id
+ (BOOL)updateMessageId:(NSString *)msdNewId andTime:(long long)time ofMessageId:(NSString *)msgOldId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.messageId = msdNewId;
    son.timestamp = [NSString stringWithFormat:@"%lld",time];
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:{
        ECMessage_Son.messageId,
        ECMessage_Son.timestamp,
    } withObject:son where:ECMessage_Son.messageId == msgOldId];
}
//更新语音消息是否播放的状态
+ (BOOL)updateMessageState:(NSString *)messageId andUserData:(NSString *)userData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.userData = userData;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.userData withObject:son where:ECMessage_Son.messageId == messageId];
}
///更新是否已读状态
+ (BOOL)updateMessageReadStateByMessageId:(NSString *)messageId isRead:(BOOL)isRead{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.isRead = isRead;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.isRead withObject:son where:ECMessage_Son.messageId == messageId];
}

///更新文件消息体的服务器远程文件路径
+ (BOOL)updateMessageRemotePathByMessageId:(NSString *)messageId remotePath:(NSString *)remotePath{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.remotePath = remotePath;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:ECMessage_Son.remotePath withObject:son where:ECMessage_Son.messageId == messageId];
}

///更新图片计算好的大小
+ (BOOL)updateImageSize:(CGSize)size ofMessageId:(NSString *)msgId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.imageWight = size.width;
    son.imageHeight = size.height;
    return [dataBase updateRowsInTable:DATA_CHAT_DBTABLE onProperties:{
        ECMessage_Son.imageWight,
        ECMessage_Son.imageHeight,
    } withObject:son where:ECMessage_Son.messageId == msgId];
}
#pragma mark - 查
///单条查询
+ (ECMessage_Son *)getMessageByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_CHAT_DBTABLE where:condition];
}

///根据messageId和sessionId查询消息
+ (ECMessage *)getMessageByMessageId:(NSString *)messageId sessionId:(NSString *)sessionId{
    ECMessage_Son *son = sessionId.length >0 ?[self getMessageByCondition:ECMessage_Son.messageId == messageId && ECMessage_Son.sessionId == sessionId] :[self getMessageByCondition:ECMessage_Son.messageId == messageId];
    return [self getMessageWithSon:son];
}

///根据sessionId查询消息
+ (NSArray<ECMessage *> *)getMessageBySessionId:(NSString *)sessionId {
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.sessionId == sessionId];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in array) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}


///批量查询
+ (NSArray<ECMessage_Son *> *)getMessagesByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_CHAT_DBTABLE where:condition orderBy:ECMessage_Son.timestamp.order(WCTOrderedAscending)];
}
+ (NSArray<ECMessage_Son *> *)getMessagesByCondition:(const WCTCondition &)condition count:(NSInteger)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_CHAT_DBTABLE where:condition orderBy:ECMessage_Son.timestamp.order(WCTOrderedAscending) limit:count];
}

///根据sessionId 查n条 当前时间点前的数据 asc排序
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId beforeTime:(long long)time count:(NSInteger)count asc:(BOOL)asc{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSArray<ECMessage_Son *> *array =  [dataBase getObjectsOfClass:self fromTable:DATA_CHAT_DBTABLE where:ECMessage_Son.timestamp < time && ECMessage_Son.sessionId == sessionId && ECMessage_Son.msgType != 26 orderBy:ECMessage_Son.timestamp.order(WCTOrderedDescending) limit:count];
    //排序 asc
    NSArray<ECMessage_Son *> *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(ECMessage_Son *obj1, ECMessage_Son * obj2) {
        if(([obj1.timestamp integerValue] < [obj2.timestamp integerValue]) == asc) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in sortArray) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}
///根据sessionId 查n条 当前时间点前的数据
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId beforeTime:(long long)time count:(NSInteger)count{
    return [self getMessagesBySessionId:sessionId beforeTime:time count:count asc:YES];
}
///根据sessionId 查n条 某个时间点前的数据 区分已读未读
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId beforeTime:(long long)time count:(NSInteger)count isRead:(BOOL)isRead{
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.timestamp < time && ECMessage_Son.isRead = isRead count:count];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in array) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}


///根据sessionId 查n条 某个时间点后的数据
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId afterTime:(long long)time count:(NSInteger)count{
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.timestamp > time && ECMessage_Son.sessionId == sessionId count:count];

    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in array) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}


///根据sessionId和msgType查询消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId msgType:(NSInteger)msgType{
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.sessionId == sessionId && ECMessage_Son.msgType == msgType];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in array) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}

///根据sessionId查询图片和视频消息
+ (NSArray<ECMessage *> *)getMediaMessagesBySessionId:(NSString *)sessionId {
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.sessionId == sessionId && (ECMessage_Son.msgType == MessageBodyType_Image ||ECMessage_Son.msgType == MessageBodyType_Video)];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in array) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}

///根据sessionId查询消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId {
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.sessionId == sessionId];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    for (ECMessage_Son *son in array) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}


///根据输入和sessionid查询文本消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId searchText:(NSString *)searchText{
    NSString *text = [NSString stringWithFormat:@"%%%@%%",searchText];
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.sessionId == sessionId && ECMessage_Son.text.like(text) && ECMessage_Son.msgType == 1];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    //倒序
    for (ECMessage_Son *son in array.reverseObjectEnumerator) {
        ECMessage *msg = [self getMessageWithSon:son];
        if (!msg.isAddFriendMessage && !msg.isGroupNoticeMessage) {
            [messageArr addObject:msg];
        }
    }
    return messageArr;
}
///查询时间段内的消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId startTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.timestamp > startTime && ECMessage_Son.timestamp < endTime && ECMessage_Son.sessionId == sessionId];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    //倒序
    for (ECMessage_Son *son in array.reverseObjectEnumerator) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}
///根据用户查消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId sender:(NSString *)sender{
    NSArray<ECMessage_Son *> *array = [self getMessagesByCondition:ECMessage_Son.from == sender &&ECMessage_Son.sessionId == sessionId];
    ///处理数据转ECMessage_Son换成ECMessage
    NSMutableArray<ECMessage *> *messageArr = [[NSMutableArray alloc] init];
    //倒序
    for (ECMessage_Son *son in array.reverseObjectEnumerator) {
        ECMessage *msg = [self getMessageWithSon:son];
        [messageArr addObject:msg];
    }
    return messageArr;
}


///ECMessage转ECMessage_Son
+ (ECMessage_Son *)sonWithMesaage:(ECMessage *)message{
    ECMessage_Son *son = [[ECMessage_Son alloc] init];
    son.sessionId = message.sessionId;
    son.messageId = message.messageId;
    son.from = message.from;
    son.to = message.to;
    son.timestamp = message.timestamp;
    son.userData = message.userData;
    son.messageState = message.messageState;
    [self setECMessage_Son:son mediaMsgBody:message.messageBody];
    son.isRead = message.isRead;
    son.unreadCount = [message getUnreadCount];
    if (message.messageBody.messageBodyType == MessageBodyType_Image) {//图片类型的预读图片高度
        if (!(son.imageHeight > 0 && son.imageWight > 0)) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ECImageMessageBody *body = (ECImageMessageBody *) message.messageBody;
                NSData *imageData;
                if (body.localPath != nil) {
                    imageData = [NSData dataWithContentsOfFile:body.localPath options:NSDataReadingMappedIfSafe error:nil];
                }
                if ((imageData == nil || imageData.bytes == 0) &&
                    body.remotePath != nil) {
                    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:body.remotePath]];
                }
                if ((imageData == nil || imageData.bytes == 0) &&
                    body.thumbnailRemotePath != nil) {
                    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:body.thumbnailRemotePath]];
                }
                CGSize size = [self caculateImageSize:imageData];
                [message setImageHeight:size.height];
                [message setImageWight:size.width];
                [self updateImageSize:size ofMessageId:son.messageId];
            });
        }
    }
    return son;
}
///将ECMessageBody赋予ECMessage_Son
+ (void)setECMessage_Son:(ECMessage_Son *)son mediaMsgBody:(ECMessageBody *)msgBody{
//    SID, msgid, sender, receiver, createdTime,
//    userData, state,msgType, text, localPath,
//    URL, serverTime, remark,displayName,isRead
//    8
    if ([msgBody isKindOfClass:[ECTextMessageBody class]]){
        son.msgType = MessageBodyType_Text;

        ECTextMessageBody *msg = (ECTextMessageBody *)msgBody;
        son.text = msg.text;
    } else if ([msgBody isKindOfClass:[ECFileMessageBody class]]) {
        son.msgType = msgBody.messageBodyType;

        ECFileMessageBody *msg = (ECFileMessageBody *)msgBody;
        NSString *file = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")];
        if (msg.localPath.length > 0) {
            file = [self getMessageMediaType:msg.localPath];
        } else if (msg.remotePath.length > 0) {
            file = [self getMessageMediaType:msg.remotePath];
        }
        son.text = file;
        son.localPath = msg.localPath;
        son.remotePath = msg.remotePath;
        son.serverTime = msg.serverTime;
        son.displayName = msg.displayName;
        son.uuid = msg.uuid?:@"";
        if ([msgBody isKindOfClass:[ECImageMessageBody class]]) {
            ECImageMessageBody *imagemsg = (ECImageMessageBody *) msgBody;
            son.remark = imagemsg.thumbnailRemotePath;
        } else if ([msgBody isKindOfClass:[ECVideoMessageBody class]]) {
            ECVideoMessageBody *videomsg = (ECVideoMessageBody *)msgBody;
            if (videomsg.thumbnailRemotePath) {
                son.remark = [NSString stringWithFormat:@"%@$$$%lld",videomsg.thumbnailRemotePath, videomsg.fileLength];
            }
        } else if ([msgBody isKindOfClass:[ECPreviewMessageBody class]]) {
            ECPreviewMessageBody *preBody = (ECPreviewMessageBody *)msgBody;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"url"] = preBody.url ? : @"";
            dict[@"title"] = preBody.title ? : @"";
            dict[@"descri"] = preBody.desc ? : @"";
            dict[@"thumbrp"] = preBody.thumbnailRemotePath ? : @"";
            dict[@"thumblp"] = preBody.thumbnailLocalPath ? : @"";
            dict[@"thumdownload"] = @(preBody.thumbnailDownloadStatus) ? : @(0);
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
            NSString *remark = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            son.remark = remark;
        }else{//恒丰新增 wjy
            son.remark = [NSString stringWithFormat:@"%lld",(msg.originFileLength != 0)?msg.originFileLength:msg.fileLength];
        }
    }else if ([msgBody isKindOfClass:[ECCallMessageBody class]]) {
        son.msgType = MessageBodyType_Call;

        ECCallMessageBody *msg = (ECCallMessageBody *) msgBody;
        son.text = msg.callText;
        son.serverTime = @"0";
        son.remark = [NSString stringWithFormat:@"%ld",(long)msg.calltype];
    }else if ([msgBody isKindOfClass:[ECLocationMessageBody class]]) {
        son.msgType = MessageBodyType_Location;

        ECLocationMessageBody *msg = (ECLocationMessageBody*) msgBody;
        NSDictionary *dict = @{locationLat:@(msg.coordinate.latitude),locationLon:@(msg.coordinate.longitude),locationTitle:msg.title};
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *strText = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        son.text = strText;
    } else if ([msgBody isKindOfClass:[RXRevokeMessageBody class]]) {
        son.msgType = MessageBodyType_None;

        RXRevokeMessageBody *msg = (RXRevokeMessageBody*) msgBody;
        son.text = msg.text;
        son.serverTime = @"0";
        son.remark = @"RXRevokeMessageBody";
    } else if([msgBody isKindOfClass:[ECCmdMessageBody class]]){
        son.msgType = msgBody.messageBodyType;

        ECCmdMessageBody *msg = (ECCmdMessageBody *)msgBody;
        son.text = msg.text;
        son.serverTime = @"0";
        son.remark = @"ECCmdMessageBody";
    }
}

///根据名称判断消息类型
+ (NSString *)getMessageMediaType:(NSString *)displayName{
    NSString *http = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",http];
    BOOL isHttp = [predicate evaluateWithObject:displayName];
    if ([displayName hasSuffix:@".amr"]) {
        return [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")];
    } else if ([displayName hasSuffix:@".jpg"] || [displayName hasSuffix:@".png"]) {
        return [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"图片")];
    } else if ([displayName hasSuffix:@".mp4"]) {
        return [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"视频")];
    } else if (isHttp) {
        return [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"链接")];
    }else {
        return [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")];
    }
}

///将ECMessage_Son转ECMessage
+ (ECMessage *)getMessageWithSon:(ECMessage_Son *)son{
    if (son == nil) {
        return nil;
    }
    ECMessage *msg = [[ECMessage alloc] init];
    msg.messageId = son.messageId;
    msg.from = son.from;
    msg.to = son.to;
    msg.timestamp = son.timestamp;
    msg.userData = son.userData;
    msg.sessionId = son.sessionId;
    ///根据msgid 包含g为群组
    msg.isGroup = msg.isGroupFlag;
    msg.messageState = son.messageState;

    MessageBodyType msgType = (MessageBodyType)son.msgType;
    ///组装ECMessageBody
    msg.messageBody = (ECMessageBody *)[self getMessageBodyWithMsg:son andType:msgType];
    msg.isRead = son.isRead;
    [msg setHeight:msg.isRead];
    ///新增主键 不懂
    [msg setMsgPrimaryKey:son.tid];
    
    if (msg.messageBody.messageBodyType == MessageBodyType_Image){//图片类型的预读图片高度
        //先判断有没有高度
        if (son.imageHeight > 0 && son.imageWight > 0) {
            [msg setImageHeight:son.imageHeight];
            [msg setImageWight:son.imageWight];
            return msg;
        }
    }
    return msg;
}
///将ECMessage_Son转ECMessageBody
+ (id)getMessageBodyWithMsg:(ECMessage_Son *)msg andType:(MessageBodyType)type{
    msg.localPath = msg.localPath.xj_documentPath;
    switch (type) {
        case MessageBodyType_None: {
            NSString *remark = msg.remark;
            if (![remark isEqualToString:@"RXRevokeMessageBody"]) {
                return nil;
            }
            RXRevokeMessageBody *messageBody = [[RXRevokeMessageBody alloc] initWithText:msg.text];
            return messageBody;
        }
        case MessageBodyType_Text: {
            ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:msg.text];
            messageBody.serverTime = msg.serverTime;
            return messageBody;
        }
        case MessageBodyType_File: {
            ECFileMessageBody *messageBody = [[ECFileMessageBody alloc] initWithFile:msg.localPath displayName:@""];
            messageBody.remotePath = msg.remotePath;
            messageBody.serverTime = msg.serverTime;
            messageBody.mediaDownloadStatus = (ECMediaDownloadStatus) msg.dstate;
            messageBody.originFileLength = [msg.remark longLongValue];
            messageBody.displayName = msg.displayName;
            messageBody.remotePath =  msg.remotePath;
            messageBody.fileLength = [msg.remark longLongValue];
            messageBody.uuid = msg.uuid;
            return messageBody;
        }
        case MessageBodyType_Image: {
            ECImageMessageBody *messageBody = [[ECImageMessageBody alloc] initWithFile:msg.localPath displayName:@""];
            messageBody.remotePath = msg.remotePath;
            messageBody.serverTime = msg.serverTime;
            messageBody.uuid = msg.uuid;
            messageBody.mediaDownloadStatus = (ECMediaDownloadStatus) msg.dstate;
            messageBody.thumbnailRemotePath = msg.remark;
            return messageBody;
        }
        case MessageBodyType_Video: {
            ECVideoMessageBody * messageBody = [[ECVideoMessageBody alloc] initWithFile:msg.localPath displayName:@""];
            messageBody.remotePath = msg.remotePath;
            messageBody.serverTime = msg.serverTime;
            messageBody.uuid = msg.uuid;
            messageBody.mediaDownloadStatus = (ECMediaDownloadStatus) msg.dstate;
            NSString *remark = msg.remark;
            messageBody.displayName = msg.displayName;
            if (remark.length > 0) {
                NSArray *array = [remark componentsSeparatedByString:@"$$$"];
                if (array.count == 2) {
                    messageBody.thumbnailRemotePath = array[0];
                    messageBody.fileLength = [array[1] longLongValue];
                } else {
                    messageBody.thumbnailRemotePath = remark;
                }
            }
            return messageBody;
        }

        case MessageBodyType_Voice: {
            ECVoiceMessageBody *messageBody = [[ECVoiceMessageBody alloc] initWithFile:msg.localPath displayName:@""];
            messageBody.remotePath = msg.remotePath;
            messageBody.serverTime = msg.serverTime;
            messageBody.mediaDownloadStatus = (ECMediaDownloadStatus) msg.dstate;
            return messageBody;
        }
        case MessageBodyType_Call: {
            ECCallMessageBody *messageBody = [[ECCallMessageBody alloc] initWithCallText:msg.text];
            messageBody.calltype = (CallType)[msg.remark integerValue];
            return messageBody;
        }
        case MessageBodyType_Location: {
            ECLocationMessageBody *messageBody = [[ECLocationMessageBody alloc] init];
            NSString *text = msg.text;

            NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (jsonObject) {
                messageBody.title = [jsonObject objectForKey:locationTitle];
                double latitude = [[jsonObject objectForKey:locationLat] doubleValue];
                double longitude = [[jsonObject objectForKey:locationLon] doubleValue];
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = latitude;
                coordinate.longitude = longitude;
                messageBody.coordinate = coordinate;
                return messageBody;
            }
        }
        case MessageBodyType_Preview: {
            ECPreviewMessageBody *preBody = [[ECPreviewMessageBody alloc] init];
            preBody.localPath = msg.localPath;
            preBody.remotePath = msg.remotePath;
            preBody.serverTime = msg.serverTime;
            preBody.mediaDownloadStatus = (ECMediaDownloadStatus) msg.dstate;
            NSString *remark = msg.remark;
            if (remark) {
                NSData *data = [remark dataUsingEncoding:NSUTF8StringEncoding] ? :nil;
                NSError *error;
                NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if (!jsonObject) {
                    return preBody;
                }
                preBody.title = [jsonObject objectForKey:@"title"];
                preBody.desc = [jsonObject objectForKey:@"descri"];
                preBody.url = [jsonObject objectForKey:@"url"];
                preBody.thumbnailLocalPath = [jsonObject objectForKey:@"thumblp"];
                preBody.thumbnailRemotePath = [jsonObject objectForKey:@"thumbrp"];
                preBody.thumbnailDownloadStatus = (ECMediaDownloadStatus)[jsonObject[@"thumdownload"] unsignedIntegerValue];
                return preBody;
            }
            return preBody;
        }
        case MessageBodyType_Command: {
            ECCmdMessageBody *preBody = [[ECCmdMessageBody alloc] initWithText:msg.text];
            return preBody;
        }
        default:
            return nil;
    }
}

///计算图片的高度
+ (CGSize)caculateImageSize:(NSData *)imageData{
    if (imageData == nil || imageData.bytes == 0) {
        return CGSizeMake(120 * fitScreenWidth, 150 * fitScreenWidth) ;
    }
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    //看是横向还是纵向图
    CGFloat newWidth;
    CGFloat newHeight;
    if (width / height > 1) {//横
        //按高度为120的5s比例算宽度
        newWidth = 120 * fitScreenWidth * (width / height);
        if (newWidth > 180 * fitScreenWidth) {//超过最大宽度
            newWidth = 180 * fitScreenWidth;
        }else if (newWidth < 96 * fitScreenWidth) {//小于最小宽度
            newWidth = 96 * fitScreenWidth;
        }
        newHeight = newWidth * (height / width);
        if (newHeight < 44 * fitScreenWidth) {
            newHeight = 44 * fitScreenWidth;
        }
    }else{//纵
        //按高度为120的5s比例算宽度
        newWidth = 120 * fitScreenWidth * (width / height);
        if (newWidth > 180 * fitScreenWidth) {//超过最大宽度
            newWidth = 180 * fitScreenWidth;
        }else if (newWidth < 80 * fitScreenWidth) {//小于最小宽度
            newWidth = 80 * fitScreenWidth;
        }
        newHeight = newWidth * (height / width);
        if (newHeight > 120 * fitScreenWidth) {
            newHeight = 120 * fitScreenWidth;
        }
    }
    return CGSizeMake(newWidth, newHeight);
}

@end
