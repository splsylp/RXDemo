//
//  ChatMessageManager.m
//  Chat
//
//  Created by zhangmingfei on 2016/10/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatMessageManager.h"
#import "EmojiConvertor.h"

@interface ChatMessageManager()<ECProgressDelegate>
///记录传输key 为messageId value @{@"date":@"",@"uploadLenth":@"",@"speed":@""}
@property(nonatomic ,strong) NSMutableDictionary *mDic;

@end

@implementation ChatMessageManager{
    SystemSoundID sendSound;
}
//懒加载
- (NSMutableDictionary *)mDic{
    if (_mDic == nil) {
        _mDic = [NSMutableDictionary new];
    }
    return _mDic;
}

- (instancetype)init{
    if (self = [super init]) {
        self.AtPersonArray = [NSMutableArray array];
        //提前下载消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shoulDownloadMediaMessage:) name:@"shoulDownloadMediaMessage" object:nil];
    }
    return self;
}

//单例模式创建
+ (ChatMessageManager *)sharedInstance {
    static dispatch_once_t ChatMessageManagerOnce;
    static ChatMessageManager *chatMessageManager;
    dispatch_once(&ChatMessageManagerOnce, ^{
        chatMessageManager = [[ChatMessageManager alloc] init];
    });
    return chatMessageManager;
}
///播放声音
- (void)playSendMsgSound{
    if ([KitGlobalClass sharedInstance].isMessageSound){
        //播放声音
        AudioServicesPlaySystemSound(sendSound);
    }
}
#pragma mark - 发送消息相关
//发送用户状态
- (void)sendUserState:(int)state to:(NSString *)to{
    if ([to hasPrefix:@"g"]) {
        return;
    };
    [[ECDevice sharedInstance].messageManager sendMessage:[[ECMessage alloc] initWithReceiver:to body:[[ECUserStateMessageBody alloc] initWithUserState:[NSString stringWithFormat:@"%d", state]]] progress:nil completion:nil];
}
#pragma mark - 重发消息 入库
- (ECMessage *)resendMessage:(ECMessage *)message{
    BOOL isFile = [message.messageBody isKindOfClass:[ECFileMessageBody class]];
    ///是否是转发文件
    BOOL isForwardMessage = message.isForwardMessage;
    ECFileMessageBody *fileBody;
    if (isForwardMessage) {
       fileBody = (ECFileMessageBody *)message.messageBody;
        message.messageBody = [[ECTextMessageBody alloc] initWithText:@"发来一个文件"];
    }
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        ECTextMessageBody *messageBody = (ECTextMessageBody *)message.messageBody;
        messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
    }
    if (isFile) {//文件重发走断点续传
        ECFileMessageBody *messageBody = (ECFileMessageBody *)message.messageBody;
        messageBody.uploadLength = 1;
        messageBody.isCompress = NO;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];

    NSString *oldMsgId = message.messageId;
    NSString *newMsgId = [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode != ECErrorType_NoError) {
            [self errorAbout:error];
        }else{
            [self playSendMsgSound];
        }
        //文件消息加锚点
        if (amessage.messageBody.messageBodyType == MessageBodyType_File) {
            ECFileMessageBody *fileBody = (ECFileMessageBody *)amessage.messageBody;
            if (![fileBody.remotePath containsString:@"#iszip"]) {
//                fileBody.remotePath = [NSString stringWithFormat:@"%@#iszip=%d",fileBody.remotePath,fileBody.isCompress?1:0];
//                [[KitMsgData sharedInstance] updateLocationMessageLocalPath:amessage.messageId withPath:fileBody.remotePath];
            }
        }
        [[KitMsgData sharedInstance] updateState:message.messageState ofMessageId:message.messageId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];
    if (!isFile) {//文件类的消息为断点续传 无需更新id
        message.messageId = newMsgId;
    }
    if (isForwardMessage) {//转发消息入库
        message.messageBody = fileBody;
        message.messageId = newMsgId;
    }
    //更新消息id
    [[KitMsgData sharedInstance] deleteMessage:oldMsgId andSession:message.sessionId];
    [[KitMsgData sharedInstance] addNewMessage:message andSessionId:oldMsgId];
    return message;
}
#pragma mark - 发送转发消息 入库
- (ECMessage *)sendForwardMessageByMessage:(ECMessage *)message{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    ///大通讯录下userdata的处理
    [self updateBasicInfo:message];

    if ([message.messageBody isKindOfClass:[ECFileMessageBody class]]) {
        ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
        body.uploadLength = 0;
//        if (message.isMergeMessage) {
            body.isCompress = NO;
//        }
        message.messageBody = body;
    }
    message.messageId = [[ECDevice sharedInstance].messageManager sendMessage:message progress:nil completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode != ECErrorType_NoError) {
            [self errorAbout:error];
        }else{
            [self playSendMsgSound];
        }
        
        //连messageBody一起更新
        if ([amessage.messageBody isKindOfClass:[ECFileMessageBody class]]) {
            ECFileMessageBody *fileBody = (ECFileMessageBody*)amessage.messageBody;
            [[KitMsgData sharedInstance] updateMessageRemotePathByMessageId:amessage.messageId remotePath:fileBody.remotePath];
        }
        [[KitMsgData sharedInstance] updateState:amessage.messageState ofMessageId:amessage.messageId];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];
    [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
    return message;
}
#pragma mark - 发送cmd消息方法 不入库
- (void)sendCmdMessageByDic:(NSDictionary *)dic{
    [self sendCmdMessageByDic:dic callBack:nil];
}
- (void)sendCmdMessageByDic:(NSDictionary *)dic callBack:(void(^)(ECError *error, ECMessage *amessage))callBack{
    ECCmdMessageBody *messageBody = [[ECCmdMessageBody alloc] init];
    messageBody.offlinePush = ECOfflinePush_Off;
    messageBody.isSyncMsg = NO;
    messageBody.isHint = NO;
    messageBody.isSave = YES;

    ECMessage *message = [[ECMessage alloc] init];
    message.messageBody = messageBody;
    message.isRead = YES;
    message.from = [[Chat sharedInstance] getAccount];

    ChatMessageType type = (ChatMessageType)[dic[@"type"] integerValue];
    ///这里写针对message的单独处理 主要是userdata
    if (type == ChatMessageTypeTopterminal) {
        BOOL isTop = [dic[@"isTop"] boolValue];
        NSString *sessionId = dic[@"sessionId"];

        NSString *isTopStr = isTop?@"true":@"false";
        NSDictionary *bodyDic = @{@"com.yuntongxun.rongxin.message_type":StickyOnTopChanged,@"account":sessionId,@"isTop":isTopStr};
        if (ISSwithToNewMESSAGE) {
            bodyDic = @{SMSGTYPE:TYPE_STICKY_ON_TOP,@"sid":sessionId,@"isTop":isTop?@"1":@"0"};
        }
        ///赋值
        message.userData = bodyDic.jsonEncodedKeyValueString;
        message.to =[Chat sharedInstance].getAccount;
        messageBody.text = languageStringWithKey(@"置顶消息");
    }else if (type == ChatMessageTypeReadterminal) {
        NSString *sessionId = dic[@"sessionId"];
        NSDictionary *bodyDic = @{SMSGTYPE:TYPE_READ_SYNC,@"sid":sessionId};
        NSString *userdataStr = bodyDic.jsonEncodedKeyValueString;
        ///赋值
        message.userData = userdataStr;
        message.to = FileTransferAssistant;
        messageBody.text = languageStringWithKey(@"消息已读");
    }else if (type == ChatMessageTypeProfileChanged) {
        NSString *text = dic[@"text"];
        NSDictionary *bodyDic = @{kRonxinMessageType:@"ProfileChanged"};
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[bodyDic coverString]];
        if (ISSwithToNewMESSAGE) {
            bodyDic = @{SMSGTYPE:TYPE_PROFILE_SYNC};
            userdataStr = bodyDic.jsonEncodedKeyValueString;
        }
        ///赋值
        message.userData = userdataStr;
        message.to = FileTransferAssistant;
        messageBody.text = text;
    }else if (type == ChatMessageTypePCLoginout) {
//        NSDictionary *bodyDic = @{@"type":@"0",@"syncDeviceName":@"iOS"};
//        NSString *userdataStr=[NSString stringWithFormat:@"customtype=1000,%@",[bodyDic convertToString]];
        NSDictionary *bodyDic = @{SMSGTYPE:TYPE_ONLINE,@"syncDeviceName":@"iOS",@"online":@"0"};
        NSString *userdataStr=[NSString stringWithFormat:@"%@",[bodyDic convertToString]];
        ECCmdMessageBody * cmdBody = [[ECCmdMessageBody alloc] initWithText:languageStringWithKey(@"Log out")];
        cmdBody.offlinePush = YES;
        cmdBody.isSyncMsg = NO;
        cmdBody.isHint =YES;
        cmdBody.isSave = NO;
        ECMessage *cmdMsg = [[ECMessage alloc] initWithReceiver:[Common sharedInstance].getAccount body:cmdBody];
        cmdMsg.apsAlert = nil;
        cmdMsg.userData = userdataStr;
        cmdMsg.isRead = NO;
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        cmdMsg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
        message = cmdMsg;
    }else if (type == ChatMessageTypeMessageNoticeterminal) {
        BOOL isMute = [dic[@"isMute"] boolValue];
        NSString *sessionId = dic[@"sessionId"];
        
        NSString *isMuteStr = isMute?@"true":@"false";
        NSDictionary *bodyDic = @{@"com.yuntongxun.rongxin.message_type":NewMsgNotiSetMute,@"account":sessionId,@"isMute":isMuteStr};
        if (ISSwithToNewMESSAGE) {
            bodyDic = @{SMSGTYPE:TYPE_NO_DISTURB,@"sid":sessionId,@"isMute":isMute?@"1":@"0"};
        }
        ///赋值
        message.userData = bodyDic.jsonEncodedKeyValueString;
        message.to = [[Common sharedInstance] getAccount];
        messageBody.text = languageStringWithKey(@"消息免打扰通知");
    }
    
    [[ECDevice sharedInstance].messageManager sendMessage:message progress:nil completion:^(ECError *error, ECMessage *amessage){
        if (callBack) {
            callBack(error,amessage);
        }
    }];
}

//修改本地消息
- (BOOL)updateMessageWithMessageBody:(ECMessageBody *)msgBody inMessage:(ECMessage *)message {
    
    return YES;
}

#pragma mark - 发送消息方法 入库
///准备整理成统一的发送消息messagebody消息体 dic包含参数(type定义类型,sessionId)最后会把所有发消息统一成这个
- (ECMessage *)sendMessageWithMessageBody:(ECMessageBody *)messageBody dic:(NSDictionary *)dic{
    ECMessage *message = [[ECMessage alloc] init];
    ///传来的参数
    message.messageBody = messageBody;
    NSString *sessionId = dic[@"sessionId"];
    ChatMessageType type = (ChatMessageType)[dic[@"type"] integerValue];
    
    if (dic[@"messageId"]) {
        message.messageId = dic[@"messageId"];
    }
    ///收消息的人
    message.sessionId = sessionId;
    message.to = sessionId;
    //时间戳
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
    message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    ///这里写针对message的单独处理 主要是userdata
    [self setMessageWithType:type dic:dic message:message];

    NSString *remoteLocalUrl;
    NSString *filePath;
    if ([message.messageBody isKindOfClass:[ECFileMessageBody class]]) {
        ECFileMessageBody *messageBody = (ECFileMessageBody *)message.messageBody;
        remoteLocalUrl = messageBody.remotePath;
        filePath = messageBody.localPath;
        messageBody.isCompress = NO;
    }

    [[ECDevice sharedInstance].messageManager sendMessage:message progress:self completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode != ECErrorType_NoError) {//发送消息失败
            [self errorAbout:error];
        }else{
            [self playSendMsgSound];
            if([messageBody isKindOfClass:[ECFileMessageBody class]]){//文件类型的消息 根据回调修改remotepath
                [[KitMsgData sharedInstance] updateLocationMessageLocalPath:amessage.messageId withPath:((ECFileMessageBody *)amessage.messageBody).remotePath];
                [self clearLocalCache:filePath withRemopath:((ECFileMessageBody *)amessage.messageBody).remotePath withOldPath:remoteLocalUrl];
            }else if(type == ChatMessageTypeCall){
                [self updateTextByMessage:message];
            }else if(type == ChatMessageTypeBoard){//白板消息最后入文本库
                NSString *keyValue = dic[@"keyValue"];
                if ([keyValue isEqualToString:@"WBSS_SHOWMSG"]) {
                    ECCmdMessageBody *cmdBody = (ECCmdMessageBody *)amessage.messageBody;
                    ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:cmdBody.text];
                    amessage.messageBody = textBody;
                    [[KitMsgData sharedInstance] addNewMessage:amessage andSessionId:amessage.sessionId];
                }
                return ;
            }
        }
        [[KitMsgData sharedInstance] updateState:message.messageState ofMessageId:message.messageId];
        //文件消息加锚点
        if (amessage.messageBody.messageBodyType == MessageBodyType_File) {
            ECFileMessageBody *fileBody = (ECFileMessageBody *)amessage.messageBody;
            if (![fileBody.remotePath containsString:@"#iszip"]) {
//                fileBody.remotePath = [NSString stringWithFormat:@"%@#iszip=%d",fileBody.remotePath,fileBody.isCompress?1:0];
//                [[KitMsgData sharedInstance] updateLocationMessageLocalPath:amessage.messageId withPath:fileBody.remotePath];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
    }];

    if (type == ChatMessageTypeBoard) {
        return message;
    }
    if (type == ChatMessageTypeForwardFile) {//文件转发走文本消息
        message.messageBody = messageBody;
    }
    if (type == ChatMessageTypeSendUrl) { //保存在本地数据库
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
        userData[SMSGTYPE] = TYPE_WEBURL;
        userData[@"sendState"] = dic[@"sendState"];
        userData[@"title"] = dic[@"title"];
        userData[@"desc"] = dic[@"desc"];
        userData[@"img"] = dic[@"img"];
        userData[@"url"] = dic[@"url"];
        message.userData = userData.jsonEncodedKeyValueString;
    }
    
    if (message.messageBody.messageBodyType == MessageBodyType_Video) {
        ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
        
        //占位消息
        ECMessage *msg = [[KitMsgData sharedInstance] getMessagesWithMessageId:videoBody.localPath OfSession:message.sessionId];
        if (msg) {
            [[KitMsgData sharedInstance] updateMessageId:message.messageId andTime:message.timestamp.longLongValue ofMessageId:msg.messageId];
            [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:videoBody.localPath withDownloadState:ECMediaDownloadSuccessed];
            [[KitMsgData sharedInstance] updateUuid:videoBody.uuid ofMessageId:message.messageId];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SendMessageCompletion object:nil userInfo:@{KErrorKey:@"", KMessageKey:message}];
        }
    }else {
        [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
    }
    return message;
}
///为特定的消息设置userData
- (void)setMessageWithType:(ChatMessageType)type dic:(NSDictionary *)dic message:(ECMessage *)message{
    if (type == ChatMessageTypeWebsite) {//网址链接消息
        ECPreviewMessageBody *msgBody = (ECPreviewMessageBody *)message.messageBody;
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {//发送给自己 即文件传输助手
            NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
            userParas[kVidyoSyncDeviceName] = kClientType_iPhone;
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            NSString *userdataStr = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
            message.userData = userdataStr;
        } else {
            //web端要从userdata里取值
            NSMutableDictionary *userData = [NSMutableDictionary dictionary];
            userData[@"title"] = msgBody.title?:@"";
            userData[@"desc"] = msgBody.desc?:@"";
            userData[@"url"] = msgBody.url?:@"";
            ///大通讯录里添加基本信息
            [self setBasicInfo:userData];
            message.userData = userData.jsonEncodedKeyValueString;
        }
    }
    else if (type == ChatMessageTypeLocation) {//坐标消息
        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        message.userData = userParas.jsonEncodedKeyValueString;
    }else if (type == ChatMessageTypeMedia) {//语音图片小视频
        BOOL isBurn = [dic[@"isBurn"] boolValue];
        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        if ([message.messageBody isKindOfClass:[ECVoiceMessageBody class]]) {
            ECVoiceMessageBody *messageBody = (ECVoiceMessageBody *)message.messageBody;
            userParas[@"duration"] = @(messageBody.duration);
        }
        if ([message.messageBody isKindOfClass:[ECVideoMessageBody class]]) {
            ECVideoMessageBody *messageBody = (ECVideoMessageBody *)message.messageBody;
            ///接收人+时间戳生成唯一uuid 断点续传标志
            messageBody.uuid = [NSString stringWithFormat:@"%@%@",message.to,message.timestamp];
        }
        
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {//发送给自己 即文件传输助手
            userParas[kVidyoSyncDeviceName] = kClientType_iPhone;
            userdataStr = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
        }
        if (isBurn && ISSwithToNewMESSAGE) {
            userParas[SMSGTYPE] = TYPE_SHNAP_BURN;
            userParas[@"status"] = @"1";
            message.apsAlert = languageStringWithKey(@"你收到了一条悄悄话");
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userdataStr = userParas.jsonEncodedKeyValueString;
        }
        message.userData = userParas.jsonEncodedKeyValueString;
    }else if (type == ChatMessageTypeText) {//文本消息
        BOOL isBurn = [dic[@"isBurn"] boolValue];
        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        if (isBurn) {
            userParas[kRonxinBURN_MODE] = kRONGXINBURN_ON;
            message.apsAlert = languageStringWithKey(@"你收到了一条悄悄话");
        }else{
            userParas[kRonxinBURN_MODE] = kRONGXINBURN_OFF;
        }
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {
            userParas[kVidyoSyncDeviceName] = kClientType_iPhone;
            userdataStr = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
        }
        if (isBurn && ISSwithToNewMESSAGE) {
            userParas = [[NSMutableDictionary alloc] init];
            userParas[SMSGTYPE] = TYPE_SHNAP_BURN;
            userParas[@"status"] = @"1";
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userdataStr = userParas.jsonEncodedKeyValueString;
        }
        if (!isBurn) {//H5需要这样
            userdataStr = @"";
        }
        message.userData = userdataStr;
    }else if (type == ChatMessageTypeImageText) {//图文模式
        NSString *text = dic[@"text"];
        //安卓希望我们加密文本
        text = text.base64EncodingString;

        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        userParas[@"Rich_text"] = text;
        userParas[kRonxinBURN_MODE] = kRONGXINBURN_OFF;
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {
            userParas[kVidyoSyncDeviceName] = kClientType_iPhone;
            userdataStr = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
        }
        if (ISSwithToNewMESSAGE) {
            userParas = [[NSMutableDictionary alloc] init];
            userParas[SMSGTYPE] = TYPE_RICH_TXT;
            userParas[@"content"] = text;
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userdataStr = userParas.jsonEncodedKeyValueString;
        }
        message.userData = userdataStr;
    }else if (type == ChatMessageTypeFile) {
        ECFileMessageBody *messageBody = (ECFileMessageBody *)message.messageBody;
        NSString *filePath = messageBody.localPath;
        NSString *fileName = filePath.lastPathComponent;
        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        userParas[@"fileName"] = fileName?:@"";
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {
            userParas[kVidyoSyncDeviceName] = kClientType_iPhone;
        }
        
        //H5要的
        [userParas setObject:@(messageBody.fileLength) forKey:@"length"];
        [userParas setObject:@(messageBody.originFileLength) forKey:@"originFileLen"];
        
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        message.userData = [NSString stringWithFormat:@"%@",userParas.jsonEncodedKeyValueString.base64EncodingString];
        ///接收人+时间戳生成唯一uuid 断点续传标志
        messageBody.uuid = [NSString stringWithFormat:@"%@%@",message.to,message.timestamp];
    }else if (type == ChatMessageTypeMergeFile) {
        NSString *userData = dic[@"userData"];
        message.userData = userData;

        NSDictionary *wbBook = [[Common sharedInstance].componentDelegate getDicWithId:[Common sharedInstance].getAccount withType:0];
        if(wbBook[Table_User_member_name]){
            message.apsAlert = [NSString stringWithFormat:@"%@:[%@]",wbBook[Table_User_member_name],languageStringWithKey(@"聊天记录")];
        }else{
            message.apsAlert = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"聊天记录")];
        }
    }else if (type == ChatMessageTypeCall) {
        NSDictionary *userData = dic[@"userData"];
        message.userData = userData.jsonEncodedKeyValueString;
    }else if (type == ChatMessageTypeBigEmoji) {
        BOOL isBurn = [dic[@"isBurn"] boolValue];
        NSString *emojiCode = dic[@"emojiCode"];
        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        if (isBurn) {
            userParas[kRonxinBURN_MODE] = kRONGXINBURN_ON;
        }else{
            userParas[kRonxinBURN_MODE] = kRONGXINBURN_OFF;
        }
        userParas[@"SmileyEmoji"] = emojiCode;
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        message.userData = userdataStr;
    }else if (type == ChatMessageTypeBoard) {
        NSString *roomID = dic[@"roomID"];
        NSString *psd = dic[@"psd"];
        NSString *keyValue = dic[@"keyValue"];
        NSString *alertString = dic[@"alertString"];

        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        userParas[ROOMID] = roomID;
        userParas[PASSWORD] = psd;
        userParas[@"com.yuntongxun.rongxin.message_type"] = keyValue;
        userParas[BOARDURL] = [Common sharedInstance].getBoardUrl;
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",userParas.coverString];
        if (ISSwithToNewMESSAGE) {
            //wbssType 显示白板邀请消息，0.可以点击加入 1.不显示消息直接弹出加入房间模式 2.隐藏白板房间模式
            NSString *type;
            if ([keyValue isEqualToString:@"WBSS_SHOWMSG"]) {
                type = @"0";
            }else if ([keyValue isEqualToString:@"WBSS_SENDMSG"]) {
                type = @"1";
            }else if ([keyValue isEqualToString:@"WBSS_HIDE"]) {
                type = @"2";
            }else if ([keyValue isEqualToString:@"WBSS_VOICE"]) {
                type = @"3";
            }
            userParas = [[NSMutableDictionary alloc] init];
            userParas[SMSGTYPE] = TYPE_WBSS;
            userParas[@"roomId"] = roomID;
            userParas[@"pwd"] = psd;
            userParas[@"server"] = [[Chat sharedInstance] getBoardUrl];
            userParas[@"wbssType"] = type;
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userdataStr = userParas.jsonEncodedKeyValueString;
        }
        ///赋值
        message.apsAlert = alertString?:nil;
        message.userData = userdataStr;
    }else if (type == ChatMessageTypeCard) {
        NSString *card_type = dic[@"card_type"];
        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *userDataDic = [[NSMutableDictionary alloc] init];
        if ([card_type isEqualToString:@"1"]) {
            NSString *account = dic[@"account"];
            userParas[@"account"] = account;
            userParas[@"type"] = @"1";
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userDataDic[ShareCardMode] = userParas;
            if (ISSwithToNewMESSAGE) {
                userParas = [[NSMutableDictionary alloc] init];
                userParas[SMSGTYPE] = TYPE_CARD;
                userParas[@"account"] = dic[@"account"];
                userParas[@"type"] = @"1";
                ///大通讯录里添加基本信息
                [self setBasicInfo:userParas];
                userDataDic = userParas;
            }
        }else if ([card_type isEqualToString:@"2"]) {//服务号名片
            NSString *pn_id = dic[@"pn_id"];
            NSString *pn_name = dic[@"pn_name"];
            NSString *pn_photourl = dic[@"pn_photourl"];
            userParas[@"pn_id"] = pn_id;
            userParas[@"pn_name"] = pn_name;
            userParas[@"pn_photourl"] = pn_photourl;
            userParas[@"type"] = card_type;
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userDataDic[ShareCardMode] = userParas;
            if (ISSwithToNewMESSAGE) {
                userParas = [[NSMutableDictionary alloc] init];
                userParas[SMSGTYPE] = TYPE_CARD;
                userParas[@"pn_id"] = pn_id;
                userParas[@"pn_name"] = pn_name;
                userParas[@"type"] = card_type;
                userParas[@"pn_photourl"] = pn_photourl;
                ///大通讯录里添加基本信息
                [self setBasicInfo:userParas];
                userDataDic = userParas;
            }
        }
        ///赋值
        message.userData = userDataDic.jsonEncodedKeyValueString;
    }else if (type == ChatMessageTypeForwardFile) {
        ECFileMessageBody *messageBody = (ECFileMessageBody *)message.messageBody;

        NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
        userParas[@"com.yuntongxun.rongxin.message_type"] = @"Forward_filese";
        userParas[@"originFileLen"] = [NSString stringWithFormat:@"%lld",messageBody.originFileLength];
        if (ISSwithToNewMESSAGE) {
            userParas = [[NSMutableDictionary alloc] init];
            userParas[SMSGTYPE] = TYPE_FORWARD;
            userParas[@"originLen"] = [NSString stringWithFormat:@"%lld",messageBody.originFileLength];
        }
        userParas[@"fileUrl"] = messageBody.remotePath;
        userParas[@"length"] = [NSString stringWithFormat:@"%lld",messageBody.fileLength];
        userParas[@"fileName"] = messageBody.displayName?:messageBody.localPath.lastPathComponent;
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        NSString *userdataStr;
        if (ISSwithToNewMESSAGE) {
            userdataStr = userParas.jsonEncodedKeyValueString;
        }else{
            userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        }
        ///body用文本形式发送
        message.messageBody = [[ECTextMessageBody alloc] initWithText:@"发来一个文件"];
        ///赋值
        message.userData = userdataStr;
    }
    else if (type == ChatMessageTypeUnsendUrl) {
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
        userData[SMSGTYPE] = TYPE_SMILEY;
        message.userData = userData.jsonEncodedKeyValueString;
    }
}
///回调错误处理
- (void)errorAbout:(ECError *)error {
    if (error.errorCode == ECErrorType_Have_Forbid || error.errorCode == ECErrorType_File_Have_Forbid) {
        RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
        [dialog showTitle:languageStringWithKey(@"您已被禁言") subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:nil selected:^(NSInteger index) {
        }];
    } else if (error.errorCode == ECErrorType_ContentTooLong) {
        RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
        [dialog showTitle:error.errorDescription subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:nil selected:^(NSInteger index) {
        }];
    } else {
        //测试不让弹框 我注释了代码 换成了日志输入
        //[SVProgressHUD showInfoWithStatus:error.errorDescription];
        DDLogInfo(@"%@",error.errorDescription);
    }
}
///更新语音的text文字
- (void)updateTextByMessage:(ECMessage *)message{
    //文本消息
    ECTextMessageBody *textmsg = (ECTextMessageBody *)message.messageBody;
    textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
    NSDictionary *dict = [message userDataToDictionary];
    if (message.isVoipRecordsMessage && [message.from isEqualToString:[[Common sharedInstance] getAccount]]) {//音视频消息,被叫方处理
        NSInteger status = [dict[@"status"] integerValue];
        switch (status) {
            case 106://呼叫失败 被叫端不处理
                break;
            case 105://呼叫超时
                textmsg.text = languageStringWithKey(@"呼叫超时");
                break;
            case 104://对方无应答
                textmsg.text = languageStringWithKey(@"对方无应答");
                break;
            case 103://对方已拒绝
                textmsg.text = languageStringWithKey(@"对方已拒绝");
                break;
            case 102://对方忙线中
                textmsg.text = languageStringWithKey(@"对方忙线中");
                break;
            case 101://对方不在线
                textmsg.text = languageStringWithKey(@"对方不在线");
                break;
            case 100://已取消
                textmsg.text = languageStringWithKey(@"已取消");
                break;
            case 200://通话时长
                break;
            default:
                break;
        }
    }
}
///清除文件缓存
- (void)clearLocalCache:(NSString *)filePath withRemopath:(NSString *)newRemotePath withOldPath:(NSString *)oldPath{
    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:oldPath];
    if(fileDic.count > 0){
        [[SendFileData sharedInstance] deleteAllFileUrl:oldPath];
        NSString *idifterPath = [fileDic objectForKey:cachefileIdentifer];
        NSString *fileSize =[fileDic objectForKey:cachefileSize];
        NSString *dispatchName =[fileDic objectForKey:cachefileDisparhName];
        NSString *disExents =[fileDic objectForKey:cachefileExtension];
        NSString *locationPath =[fileDic objectForKey:cachefileDirectory];
        NSString *sessionId =[fileDic objectForKey:cacheimSissionId];
        NSString *fileUuid = fileDic[cachefileUuid];
        NSString *fileKey = fileDic[cachefileKey];
        NSDictionary *dic = @{cachefileUrl:newRemotePath,cacheimSissionId:sessionId,cachefileDirectory:locationPath,cachefileIdentifer:idifterPath,cachefileDisparhName:dispatchName,cachefileExtension:disExents,cachefileSize:fileSize,cachefileUuid:fileUuid,cachefileKey:fileKey};
        [[SendFileData sharedInstance] insertFileinfoData:dic];
    }
}

#pragma mark  - 阅后即焚后台倒计时
- (NSMutableArray *)delMsgArr{
    if (!_delMsgArr) {
        _delMsgArr = [NSMutableArray array];
    }
    return _delMsgArr;
}
///添加数据进阅后即焚倒计时
- (void)addDelMsgWithDelMsgArr:(NSMutableArray *)arr {
    [self.delMsgArr addObjectsFromArray:arr];
    if ((!self.delMsgTimer) || ![self.delMsgTimer isValid]){
        self.delMsgTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerShouldDeleteMessge) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.delMsgTimer forMode:NSRunLoopCommonModes];
        [self.delMsgTimer fire];
    }
}
///倒计时 事件
- (void)timerShouldDeleteMessge{
    NSMutableArray *deleteSession = [NSMutableArray array];
    for (int i = 0; i < self.delMsgArr.count; ) {
        id someMessage = [self.delMsgArr objectAtIndex:i];
        if (![someMessage isKindOfClass:[ECMessage class]]) {
            [self.delMsgArr removeObject:someMessage];
            continue;
        }
        ECMessage * Message = [self.delMsgArr objectAtIndex:i];
        
        if (self.sessionIdNow && [self.sessionIdNow isEqualToString:Message.sessionId]) {
            [self.delMsgArr removeObject:someMessage];
            continue;
        }
        
        NSString * timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:Message.messageId];
        
        if (KCNSSTRING_ISEMPTY(timeStr)) {
            [self.delMsgArr removeObject:Message];
        }else{
            int times = [timeStr intValue];
            times = times - 1;
            if (times < 1) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:Message.messageId];
                
                [self.delMsgArr removeObject:Message];
                
                [[KitMsgData sharedInstance] deleteMessage:Message.messageId andSession:Message.sessionId];
                
                if (![deleteSession containsObject:Message.sessionId]) {
                    [deleteSession addObject:Message.sessionId];
                }
            }else{
                NSString *timeStr = [NSString stringWithFormat:@"%d",times];
                [[NSUserDefaults standardUserDefaults] setValue:timeStr forKey:Message.messageId];
                i ++;
            }
        }
    }
    for (NSString *sessionID in deleteSession) {
        NSArray* messageArr = [[KitMsgData sharedInstance] getLatestHundredMessageOfSessionId:sessionID andSize:1 andASC:YES];
        if (messageArr.count > 0) {
            ECMessage *premessage = messageArr.lastObject;
            long long int time = [premessage.timestamp longLongValue];
            ECSession * session = [ECSession messageConvertToSession:premessage useNewTime:NO];
            session.dateTime = time;
            [[KitMsgData sharedInstance] updateSession:session];
        }
    }
    if (self.delMsgArr.count == 0) {
        if ([self.delMsgTimer isValid]){
            [self.delMsgTimer invalidate];
            self.delMsgTimer = nil;
        }
    }
}

#pragma mark - 通知相关
- (void)shoulDownloadMediaMessage:(NSNotification *)notifi {
    ECMessage *mediaMessage = notifi.userInfo[@"mediaMessage"];
    [self downloadMediaMessage:mediaMessage andCompletion:nil];
}
//下载消息附件
- (void)downloadMediaMessage:(ECMessage*)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion{
    ECFileMessageBody *mediaBody = (ECFileMessageBody *)message.messageBody;
    if (!mediaBody.displayName) {
        mediaBody.displayName = mediaBody.remotePath.lastPathComponent;
    }
    mediaBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.remotePath.lastPathComponent];//mediaBody.displayName
//    mediaBody.isCompress = NO;
    NSLog(@"下载文件 mediaBody.remotePath = %@  mediaBody.localPath = %@",mediaBody.remotePath,mediaBody.localPath);
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:message progress:nil completion:^(ECError *error, ECMessage *amessage) {
        if (error.errorCode == ECErrorType_NoError) {
            [[KitMsgData sharedInstance] updateMessageLocalPath:amessage.messageId withPath:mediaBody.localPath withDownloadState:((ECFileMessageBody *)amessage.messageBody).mediaDownloadStatus];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        } else {
            mediaBody.localPath = nil;
            [[KitMsgData sharedInstance] updateMessageLocalPath:amessage.messageId withPath:@"" withDownloadState:((ECFileMessageBody*)amessage.messageBody).mediaDownloadStatus];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_DownloadMessageCompletion object:nil userInfo:@{KErrorKey:error, KMessageKey:amessage}];
        }
        if (completion != nil) {
            completion(error, amessage);
        }
        if (message.isBurnWithMessage) {
            NSString *timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:amessage.messageId];
            if ((!timeStr) && amessage.messageBody.messageBodyType != MessageBodyType_Voice) {
                [[NSUserDefaults standardUserDefaults] setValue:@"30" forKey:message.messageId];
            }
        }
    }];
}

#pragma mark  - 发送消息代理回调
/**
 @brief 设置进度
 @discussion 用户需实现此接口用以支持进度显示
 @param progress 值域为0到1.0的浮点数
 @param message  某一条消息的progress
 @result
 */
- (void)setProgress:(float)progress forMessage:(ECMessage *)message {
    DDLogInfo(@"DeviceChatHelper setprogress %f,messageId=%@,from=%@,to=%@,session=%@",progress,message.messageId,message.from,message.to,message.sessionId);
    [message setSpeed:[self speedSize:message]];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_fileTranProgressChanged object:nil userInfo:@{@"progress":[NSNumber numberWithFloat:progress],KMessageKey:message}];
}
- (float)speedSize:(ECMessage *)message{
    ///先找到是否有这个字典
    NSDictionary *dataDic = [self.mDic valueForKey:message.messageId];

    ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
    ///现在的字节 和 时间
    unsigned long long uploadLength = body.uploadLength;
    NSDate *nowDate = [NSDate date];
    NSDictionary *newDic = @{@"uploadLength":@(body.uploadLength),@"date":nowDate,@"speed":@(0)};
    if (dataDic == nil) {
        //储存新时间
        [self.mDic setValue:newDic forKey:message.messageId];
        return 0;
    }
    ///之前的字节 和 时间
    unsigned long long oldUploadLength = [dataDic[@"uploadLength"] unsignedLongLongValue];
    NSDate *oldDate = dataDic[@"date"];
    float speed = [dataDic[@"speed"] floatValue];

    NSTimeInterval timeInterval = nowDate.timeIntervalSince1970 - oldDate.timeIntervalSince1970;
    if (timeInterval >= 1) {//1秒以上才更新 不然返回旧的
        ///单位时间上传速度
        speed = (uploadLength - oldUploadLength) / timeInterval;
        //储存新时间
        NSDictionary *newDic = @{@"uploadLength":@(body.uploadLength),@"date":nowDate,@"speed":@(speed)};
        [self.mDic setValue:newDic forKey:message.messageId];
    }
    return speed;
}

#pragma mark - addbylxj
- (void)setBasicInfo:(NSMutableDictionary *)mDic{
    if (!isLargeAddressBookModel) {
        return;
    }
    return;
    mDic[Table_User_account] = [[Chat sharedInstance] getAccount];
    mDic[Table_User_member_name] = [[Chat sharedInstance] getUserName];
    mDic[Table_User_avatar] = [[Chat sharedInstance] getOneUserPhotoUrl];
    mDic[Table_User_urlmd5] = [[Chat sharedInstance] getOneUserPhotoMd5];
}
- (void)updateBasicInfo:(ECMessage *)message{
  
    NSMutableDictionary *userParas = [MessageTypeManager getCusDicWithUserData:message.userData];
    if (isLargeAddressBookModel && [userParas hasValueForKey:@"ShareCard"]) {//服务号
        return;
    }
    if ([message.messageBody isKindOfClass:[ECPreviewMessageBody class]] || [message.messageBody isKindOfClass:[ECLocationMessageBody class]]) {
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {//发送给自己 即文件传输助手
            NSString *userdataStr = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
            message.userData = userdataStr;
        } else {
            message.userData = userParas.jsonEncodedKeyValueString;
        }
    }else if ([message.messageBody isMemberOfClass:[ECFileMessageBody class]]) {
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        if (message.isMergeMessage) {
            NSString *userDataString;
            if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {//发送给自己 即文件传输助手
                NSString *userDataStr = [NSString stringWithFormat:@"%@,%@",kMergeMessage_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
                userDataString = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userDataStr.base64EncodingString];
            }else{
                userDataString = [NSString stringWithFormat:@"%@,%@",kMergeMessage_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
            }
            if (ISSwithToNewMESSAGE) {
                [userParas setObject:TYPE_COMBINE_MSG forKey:SMSGTYPE];
                userDataString = userParas.jsonEncodedKeyValueString;
            }
            message.userData = userDataString;
            return;
        }
        message.userData = [NSString stringWithFormat:@"%@",userParas.jsonEncodedKeyValueString.base64EncodingString];
    }else if ([message.messageBody isKindOfClass:[ECFileMessageBody class]] || [message.messageBody isKindOfClass:[ECTextMessageBody class]]) {
        if (message.isCardWithMessage) {
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            NSMutableDictionary *userDataDic = [[NSMutableDictionary alloc] init];
            userDataDic[ShareCardMode] = userParas;
            if (ISSwithToNewMESSAGE) {
                userDataDic = userParas;
            }
            ///赋值
            message.userData = userDataDic.jsonEncodedKeyValueString;
            return;
        }
        ///大通讯录里添加基本信息
        [self setBasicInfo:userParas];
        
        NSString *userParsStr = [userParas coverString];
        NSString *userdataStr = @"";
        if (ISSwithToNewMESSAGE) {
            userdataStr = userParas.jsonEncodedKeyValueString;
        } else {
            if (userParsStr.length > 0) {
                userdataStr = [NSString stringWithFormat:@"UserData={%@}", userParsStr];
            }
        }
        if ([message.to isEqualToString:[Common sharedInstance].getAccount]) {//发送给自己 即文件传输助手
            userdataStr = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
        }
        //新版
        BOOL isBurn = [userParas[kRONGXINBURN_ON] boolValue];
        if (isBurn && ISSwithToNewMESSAGE) {
            userParas = [[NSMutableDictionary alloc] init];
            userParas[SMSGTYPE] = TYPE_SHNAP_BURN;
            userParas[@"status"] = @"1";
            ///大通讯录里添加基本信息
            [self setBasicInfo:userParas];
            userdataStr = userParas.jsonEncodedKeyValueString;
        }
        message.userData = userdataStr;
    }
}

- (void)updateUnreadMessageCountFromNetWorkByMessage:(ECMessage *)message version:(NSString *)version success:(void (^)(NSInteger unReadCount))success {
    [[RestApi sharedInstance] getMessageReceiptByMsgId:message.messageId version:version type:@"2" userName:[[Common sharedInstance] getAccount] isReturnList:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        if ([dict[@"statusCode"] isEqualToString:@"000000"]) {
            NSInteger unReadCount = [dict[@"unReadCount"] integerValue];
            DDLogInfo(@"已读未读数量是 -- %ld",(long)unReadCount);
            //将未读数保存在userdefault里  z
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            [userDefaults setValue:[NSString stringWithFormat:@"%ld",(long)unReadCount] forKey:[NSString stringWithFormat:@"%@_%@",messageId,@"CellMessageUnReadCount"]];
//            [userDefaults synchronize];
            NSInteger count = [message getUnreadCount];
            if (count != unReadCount) {            
                [[KitMsgData sharedInstance] updateUnreadCount:unReadCount ofMessageId:message.messageId];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageUnreadCount_Notification" object:message.messageId];
            }
            !success?:success(unReadCount);
        }else{
            DDLogInfo(@"已读未读数量错误");
        }
    } didFailLoaded:nil];
}
@end
