//
//  HXMessageMergeManager.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/29.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMessageMergeManager.h"
#import "BaseViewController.h"
//#import "ChatViewController.h"
#import "HXFileCacheManager.h"
#import "HXMergeMessageModel.h"
#import "YXPAlertView.h"
#import "HYTApiClient+Ext.h"

static NSString *const huiChe = @"[rx_str_merge_des]"; //PC端回车转换有问题,用这个字符串替换


@interface HXMessageMergeManager ()
//
//@property (nonatomic,weak) ChatViewController *mChatVC;
///合并前的新消息数组
@property (nonatomic,strong) NSArray *beforeMergeMessageArray;
///合并后的新消息数组，上传成文件内容
@property (nonatomic,strong) NSArray *mergeMessageArray;
///用于cell 显示的简介信息放在UserData里
@property (nonatomic,strong) NSMutableArray *mCellSimleInformationArray;
///获取合并消息的title
@property (nonatomic,strong) NSString       *mMergeMessageTitle;
///获取合并消息的描述
@property (nonatomic,strong) NSString *mMergeMessageDes;
///转发方式 合并或者逐条
@property (nonatomic,assign) ForwardMode mForwardMode;
///聊天mSessoinId
@property (nonatomic,strong) NSString *mSessoinId;

@end


@implementation HXMessageMergeManager

#pragma mark 关于init
static HXMessageMergeManager *shareHXMessageMergeManager = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t threadOnceToken;
    dispatch_once(&threadOnceToken, ^{
        if(!shareHXMessageMergeManager){
            shareHXMessageMergeManager = [[HXMessageMergeManager alloc] init];
        }
    });
    return shareHXMessageMergeManager;
}

- (ForwardMode)getForwardMode{
    return _mForwardMode;
}

//- (void)setVC:(UIViewController *)vc{
//
//    if([vc isKindOfClass:[ChatViewController class]]){
//        self.mChatVC =(ChatViewController*) vc;
//    }else{
//        self.mChatVC = nil;
//    }
//}



- (NSString *)changeToStringWithArray:(NSArray *)array{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

//消息按照时间戳，从小到大排序
- (NSArray *)sortByTimeArrayWithMessageArray:(NSArray *)messageArr{
    NSMutableArray *newMessage = [[NSMutableArray alloc]initWithArray:messageArr];
    for (int i=0;i<newMessage.count-1;i++) {
        for (int j = i+1;j<newMessage.count;j++) {
            ECMessage *message1 = [newMessage objectAtIndex:i];
            ECMessage *message2 = [newMessage objectAtIndex:j];
            if(message1.timestamp.longLongValue > message2.timestamp.longLongValue){
                [newMessage exchangeObjectAtIndex:j withObjectAtIndex:i];
            }
        }
    }
    return newMessage;
}
- (void)setMergeMessageTitleWithSessonId:(NSString *)sessionId{
    NSString *resultString ;
    if([sessionId hasPrefix:@"g"]){//群组，
        NSString *groName = sessionId;
        NSArray *groupArray = [[KitMsgData sharedInstance] getGroupInformation:sessionId];
        if(groupArray.count > 0){
            NSDictionary *groupInfoDic = groupArray[0];
            groName = [groupInfoDic objectForKey:@"groupname"];
        }
        resultString = [NSString stringWithFormat:@"%@%@",groName,languageStringWithKey(@"的聊天记录")] ;
    }else{//单聊
        resultString = [NSString stringWithFormat:@"%@%@",[Common sharedInstance].getUserName,languageStringWithKey(@"的聊天记录")];
    }
    self.mMergeMessageTitle = resultString;
}

- (void)sendMergeMessageAndSelectResultArray:(NSArray *)selectResultArray andCompletion:(Completion)completion andView:(UIView *)currentView{
    //逐条转发
    NSArray *msgArr = [Common sharedInstance].moreSelectMsgData;
    int count = self.mForwardMode == ForwardMode_EachMessage?(int)msgArr.count :(int)self.mergeMessageArray.count;
    NSString *content = [NSString stringWithFormat:@"%@%d%@",languageStringWithKey(@"共"),count,languageStringWithKey(@"消息")];
    YXPAlertView *alertView =[[YXPAlertView alloc] initWithBlock:^(BOOL isConfirm, NSString *customParameter) {
        if(isConfirm){
            if (self.mForwardMode == ForwardMode_EachMessage) {
               
                [self eachForwardChatMessage:msgArr andCompletion:completion];
            }else if (self.mForwardMode == ForwardMode_MergeMessage){
                //合并转发
              
                [self sendMergeMessageAndSelectResultArray:selectResultArray andCompletion:completion];
            }
        }
    } alertType:YXP_relay title:@"" groupCount:@"" content:content description:@""  sessiongArray:selectResultArray relayType:(self.mForwardMode == ForwardMode_MergeMessage ? RelayMessage_mergeMessage:RelayMessage_eachMessage) localPath:@"" remoteUrl:@""];
    [currentView addSubview:alertView];
}


/**
 逐条转发
 
 @param selectResultArray 消息数组
 @param completion 完成回调
 */
- (void)eachForwardChatMessage:(NSArray *)selectResultArray andCompletion:(Completion)completion{
    //eachForwardChatMessage
//    - (void)sureClickisConfirm:(BOOL)isConfirm customParameter:(NSString *)customParameter message:(ECMessage *)message{
    for (ECMessage *msg in selectResultArray) {
        [[AppModel sharedInstance]runModuleFunc:@"KitSelectManager" :@"sureClickisConfirmStr:message:" :@[@"1",msg] hasReturn:NO];
    }
    [[Common sharedInstance].moreSelectMsgData removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancleMoreSelectActionInfo" object:nil];
    
    DDLogInfo(@"aa");
}

/**
 合并转发

 @param selectResultArray 消息数组
 @param completion 完成回调
 */
- (void)sendMergeMessageAndSelectResultArray:(NSArray *)selectResultArray andCompletion:(Completion)completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSInteger i = 0; i < selectResultArray.count; i ++) {
            id data = selectResultArray[i];
            NSString *sessionId = nil;
            if ([data isKindOfClass:[NSDictionary class]]){
                NSDictionary *book = (NSDictionary *)data;
                sessionId = book[Table_User_account];
            }else if ([data isKindOfClass:[ECSession class]]) {
                ECSession *session = (ECSession *)data;
                sessionId = session.sessionId;
            }else if ([data isKindOfClass:[ECGroup class]]) {
                ECGroup *group = (ECGroup *)data;
                sessionId = group.groupId;
            }
            if (!sessionId) {
                return ;
            }

            NSString *timePath = [HXFileCacheManager createRandomFileName];
            NSData *fileData = [[self getMergeFileData] dataUsingEncoding:NSUTF8StringEncoding];
            NSString *displayName = [NSString stringWithFormat:@"%@.mergeMessage",timePath];
            NSString *filePath = [HXFileCacheManager saveData:fileData toCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument fileIdentifer:timePath displayName:displayName ImSessionId:sessionId aExtension:[displayName pathExtension]?[displayName pathExtension]:@"mergeMessage"];
            NSTimeInterval fileSize = [HXFileCacheManager fileSizeAtPath:filePath];

            NSString *remotePath = [NSString stringWithFormat:@"YXPLocationSendFile%@",timePath];
            [[SendFileData sharedInstance] insertFileinfoData:@{cachefileUrl:remotePath,cacheimSissionId:sessionId,cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,cachefileIdentifer:timePath,cachefileDisparhName:displayName?displayName:timePath,cachefileExtension:[displayName pathExtension]?[displayName pathExtension]:@"mergeMessage",cachefileSize:[NSString stringWithFormat:@"%f",fileSize]}];

            dispatch_async(dispatch_get_main_queue(), ^{
                ECFileMessageBody *fileBody = [[ECFileMessageBody alloc] initWithFile:filePath displayName:displayName];
                fileBody.remotePath = remotePath;
                fileBody.localPath = filePath;
                fileBody.displayName = displayName;
                fileBody.fileLength = fileSize;
                fileBody.originFileLength = fileSize;

                NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
                mDic[@"sessionId"] = sessionId;
                mDic[@"type"] = @(ChatMessageTypeMergeFile);
                mDic[@"userData"] = [self getMergerMessageFileUserDataAndTo:sessionId];
                [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"sendMessageWithMessageBody:dic:" :@[fileBody, mDic]];
//                [[ChatMessageManager sharedInstance] sendMessageWithMessageBody:fileBody dic:mDic];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([Common sharedInstance].isIMMsgMoreSelect) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"cancleMoreSelectActionInfo" object:nil];
//            }
            if(completion){
                completion();
            }
        });
    });
}



/**
 合并转发
 
 @param selectResultArray 消息数组
 @param completion 完成回调
 */
- (void)gy_sendMergeMessageAndSelectResultArray:(NSString *)sessionId andCompletion:(void (^)(ECMessage *message))completion{
    
        NSString *timePath = [HXFileCacheManager createRandomFileName];
        NSData *fileData = [[self getMergeFileData] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *displayName = [NSString stringWithFormat:@"%@.mergeMessage",timePath];
        NSString *filePath = [HXFileCacheManager saveData:fileData toCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument fileIdentifer:timePath displayName:displayName ImSessionId:sessionId aExtension:[displayName pathExtension]?[displayName pathExtension]:@"mergeMessage"];
        NSTimeInterval fileSize = [HXFileCacheManager fileSizeAtPath:filePath];
    
        NSData *data = [NSData dataWithContentsOfFile:filePath];
    //先调文件服务器 上传文件获取 url
        [HYTApiClient uploadPhoWithFileName:displayName photo:nil withImageData:nil fileData:data fileType:@"jpeg" didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
            if ([[json objectForKey:@"statusCode"] isEqualToString:@"000000"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *url = [json[@"downloadUrl"] stringByReplacingOccurrencesOfString:@"_thum" withString:@""];
                    ECFileMessageBody *fileBody = [[ECFileMessageBody alloc] initWithFile:filePath displayName:displayName];
                    fileBody.remotePath = url;
                    fileBody.localPath = filePath;
                    fileBody.displayName = displayName;
                    fileBody.fileLength = fileSize;
                    fileBody.originFileLength = fileSize;
                    
                    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
                    mDic[@"sessionId"] = sessionId;
                    ECMessage *message = [[ECMessage alloc]initWithReceiver:sessionId body:fileBody];
                    message.userData = [self getMergerMessageFileUserDataAndTo:sessionId isMerge:YES];
                    completion(message);
                    
                    
                    //写到本地，收藏列表就不需要重新下载了
                    NSString *fileUUid = [NSString fileMessageUUid:message.userData];
                    long long llSize = fileBody.originFileLength;
                    if (llSize<=0) {
                        llSize = fileBody.fileLength;
                    }
                    NSString *fileIdentiferTime = [HXFileCacheManager createRandomFileName];
                    NSDictionary *fileDic =@{cachefileUrl:fileBody.remotePath,
                                             cacheimSissionId:message.sessionId,
                                             cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,
                                             cachefileIdentifer:fileIdentiferTime,
                                             cachefileDisparhName:displayName,
                                             cachefileExtension:[displayName pathExtension]?[displayName pathExtension]:@"",
                                             cachefileSize:[NSString stringWithFormat:@"%lld",llSize],
                                             cachefileUuid:!KCNSSTRING_ISEMPTY(fileUUid)?fileUUid:@""};
                    [[SendFileData sharedInstance] insertFileinfoData:fileDic];
                    [HXFileCacheManager saveData:data toCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument fileIdentifer:fileIdentiferTime displayName:displayName ImSessionId:message.sessionId aExtension:[displayName pathExtension]?[displayName pathExtension]:@""];
                });
            } else {
                completion(nil);
            }
        } didFailLoadedMK:^(NSError *error, NSString *path) {
            if(error.code ==171139 || error.code==-1004){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"网络不给力")];
                return ;
            }
            if([error.localizedDescription isEqualToString:languageStringWithKey(@"请求超时")]){
                [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"请求超时")];
                return;
            }
        }];
}


/**
 @brief 多条消息的合并转发
 @discussion
 */
- (void)forwardChatMultipleMessageMerge:(NSArray<ECMessage *> *)messageArr withVC:(UIViewController *)vc{
    self.mergeMessageArray = nil;
    self.mForwardMode = ForwardMode_MergeMessage;
    self.beforeMergeMessageArray = messageArr;
    self.mCellSimleInformationArray = [[NSMutableArray alloc] init];
//    [self setVC:vc];
    
    if (messageArr.count <= 0) {
        return;
    }
    //按时间排序
    NSArray *newMessageArray = [self sortByTimeArrayWithMessageArray:messageArr];
    //合并后的数组
    NSMutableArray *messageMergeArray = [[NSMutableArray alloc] init];
    for (ECMessage *message in newMessageArray) {
        NSDictionary *dict = [self mergeMessageWithMessage:message];
        if(dict){
            [messageMergeArray addObject:dict];
        }
    }
    self.mergeMessageArray = messageMergeArray;//合并后的数据,要转化为二进制
    self.mMergeMessageDes = [self.mCellSimleInformationArray componentsJoinedByString:huiChe];//描述
    
    UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{} WithType:SelectObjectType_OnlyMergeMultiSelectContactMode];
    RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:groupVC];
    [vc presentViewController:nav animated:YES completion:nil];
}


/**
 @brief 获取拼接后的data字符串，用于发送文件的data
 @discussion 合并消息以文件形式发送过去的数据的字段
 */
- (NSString *)getMergeFileData{
    NSString *fileData = [self changeToStringWithArray:self.mergeMessageArray];
    NSString *base64String = [fileData base64EncodingString];
    return base64String;
}

/**
 @brief 获取UserData用于显示Cell 的简介，最多三条
 @discussion
 */
- (NSString *)getMergerMessageFileUserDataAndTo:(NSString *)sessonId isMerge:(BOOL)isMerge{
    NSMutableDictionary *userParas = [[NSMutableDictionary alloc] init];
    if (ISSwithToNewMESSAGE) {
        userParas[SMSGTYPE] = TYPE_COMBINE_MSG;
        userParas[@"title"] = self.mMergeMessageTitle;
        userParas[@"msgDesc"] = self.mMergeMessageDes;
        ///大通讯录里添加基本信息
        [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"setBasicInfo:" :@[userParas]];
//        [[ChatMessageManager sharedInstance] setBasicInfo:userParas];
        return userParas.jsonEncodedKeyValueString;
    }
    if ([sessonId isEqualToString:[Common sharedInstance].getAccount] && !isMerge) {
        userParas[HXMergeMessageTitleKey] = self.mMergeMessageTitle;
        userParas[HXMergeMessageDesKey] = self.mMergeMessageDes;
        userParas[kVidyoSyncDeviceName] = kClientType_iPhone;
        
        NSString *userDataStr = [NSString stringWithFormat:@"%@,%@",kMergeMessage_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
        //拼接300标识
        NSString *base64UserData = [userDataStr base64EncodingString];
        NSString *mergeMessageUserDataString = [NSString stringWithFormat:@"%@,%@",kFileTransferMsgNotice_CustomType,base64UserData];
        return mergeMessageUserDataString;
    }else{
        userParas[HXMergeMessageTitleKey] = self.mMergeMessageTitle;
        userParas[HXMergeMessageDesKey] = self.mMergeMessageDes;
        
        //统一做base 64 处理
        NSString *userDataStr = [NSString stringWithFormat:@"%@,%@",kMergeMessage_CustomType,userParas.jsonEncodedKeyValueString.base64EncodingString];
        return userDataStr;
    }
}

/**
 @brief 获取UserData用于显示Cell 的简介，最多三条
 @discussion
 */
- (NSString *)getMergerMessageFileUserDataAndTo:(NSString *)sessonId{
    return [self getMergerMessageFileUserDataAndTo:sessonId isMerge:NO];
}


/**
 @brief
 @discussion 提取消息信息,提取规则
 */
- (NSDictionary *)mergeMessageWithMessage:(ECMessage *)message{
    NSString *str = nil;
    NSRange ran = [message.userData rangeOfString:@"UserData="];
    if (ran.location == NSNotFound) {
        NSRange ran1 = [message.userData rangeOfString:@"customtype="];
        if(ran1.location == NSNotFound){
            str = message.userData;
        }else{
            NSMutableArray *arrayData = [[NSMutableArray alloc]initWithArray:[message.userData componentsSeparatedByString:@","]];
            [arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tempString = obj;
                if([tempString rangeOfString:@"customtype="].location!=NSNotFound){
                    *stop = YES;
                    [arrayData removeObject:obj];
                }
            }];
            str = [arrayData componentsJoinedByString:@","];
        }
    }else{
        NSInteger index = ran.location + ran.length;
        str = [message.userData substringFromIndex:index];
    }
//    NSDictionary *im_modeDic =  [str coverDictionary];
//    NSDictionary *im_jsonDic = [str mutableObjectFromJSONString];
    NSDictionary *im_jsonDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:message.userData];
    if (!im_jsonDic) {
        im_jsonDic = [MessageTypeManager getCusDicWithUserData:message.userData];
    }
    NSString *HXMergeMessageType_Value = nil;//消息类型
    NSString *HXMergeMessageTitle_Value = nil;//消息title
    NSString *HXMergeMessageTime_Value = nil;//消息时间
    NSString *HXMergeMessageUrl_Value = nil;//消息url--图片地址，视频地址
    NSString *HXMergeMessageContent_Value = nil;//文字消息，
    NSString *HXMergeMessageAccount_Value = nil;//消息是谁发的
    NSString *HXMergeMessageUserData_Value = nil;//消息类型
    NSString *HXMergeMessagelinkThumUrl_Value = nil;//链接缩略图
    NSString *HXMergeMessageIdValue = nil;//消息Id
    NSString *HXMergeMessageFileSizeValue = nil;//文件大小
    NSString *HXMergeMessageSessonIdValue = nil;//合并消息的session
    NSString *HXMergeMessageDurationValue = @"";//语音消息的时长
    
    MessageBodyType messageBodyType =  message.messageBody.messageBodyType;
    //公共参数
    HXMergeMessageType_Value = [NSString stringWithFormat:@"%d",(int)messageBodyType];
    HXMergeMessageTime_Value = [NSString stringWithFormat:@"%@",message.timestamp];
    HXMergeMessageAccount_Value = message.from;
    HXMergeMessageUserData_Value = message.userData;
    HXMergeMessageIdValue = message.messageId;
    HXMergeMessageSessonIdValue = self.mSessoinId;
    //特别参数
    if(messageBodyType == MessageBodyType_Text){//1.文字||或者名片
        ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
        NSString *tempTile = nil;
        if(message.isCardWithMessage){
            tempTile = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"名片")];
        }else{
            if(textBody.text.length <= 8){
                tempTile = textBody.text;
            }else{
                NSRange ragne = NSMakeRange(0, 8);
                NSString *subString = [textBody.text substringWithRange:ragne];
                tempTile = [NSString stringWithFormat:@"%@...",subString];
                // hanwei 
                tempTile = [self subStringWith:textBody.text ToIndex:8];
            }
        }
        HXMergeMessageTitle_Value = tempTile;
        HXMergeMessageContent_Value = textBody.text;
        HXMergeMessageUrl_Value = @"";
    }else if(messageBodyType == MessageBodyType_Image){//2.图片
        ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
        HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"图片")];
        HXMergeMessageContent_Value = @"";
        HXMergeMessageUrl_Value = imageBody.remotePath;
        
        NSString *tempTile = [im_jsonDic hasValueForKey:@"content"] ? im_jsonDic[@"content"]:im_jsonDic[@"Rich_text"];
        if (tempTile) {
            HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[图片]%@",tempTile.base64DecodingString];
            HXMergeMessageContent_Value = @"";
            HXMergeMessageUrl_Value = imageBody.remotePath;
        }
    }else if(messageBodyType == MessageBodyType_Video){//3.视频
        ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
        HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"视频")];
        HXMergeMessageContent_Value = @"";
        HXMergeMessageUrl_Value = videoBody.remotePath;
    }else if(messageBodyType == MessageBodyType_Preview){//4.链接 //6.服务号
        ECPreviewMessageBody *previewBody = (ECPreviewMessageBody *)message.messageBody;
        HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"链接")];
        HXMergeMessageContent_Value = previewBody.desc;
        HXMergeMessageUrl_Value = previewBody.url;
        HXMergeMessagelinkThumUrl_Value = previewBody.remotePath;//链接缩略图
    }else if(messageBodyType == MessageBodyType_File){//5.文件
        ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
        if(fileBody.displayName.length != 0){
            HXMergeMessageTitle_Value = fileBody.displayName;
        }else{
            HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")];
        }
        HXMergeMessageContent_Value = @"";
        HXMergeMessageUrl_Value = fileBody.remotePath;
       // HXMergeMessageFileSizeValue     = [NSString stringWithFormat:@"%lld",fileBody.originFileLength];//文件大小
        
        HXMergeMessageFileSizeValue = [NSString stringWithFormat:@"%lld",fileBody.fileLength != 0?fileBody.fileLength :fileBody.originFileLength];//文件大小
    }
    else if(messageBodyType == MessageBodyType_Voice){//2.语音
        ECVoiceMessageBody *fileBody = (ECVoiceMessageBody *)message.messageBody;
        HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")];
        HXMergeMessageContent_Value = @"";
        HXMergeMessageUrl_Value = fileBody.remotePath;
        HXMergeMessageDurationValue = [NSString stringWithFormat:@"%ld",(long)fileBody.duration];//文件大小
    }else if(messageBodyType == MessageBodyType_Location){// 位置
        ECLocationMessageBody *locationBody = (ECLocationMessageBody *)message.messageBody;
        HXMergeMessageTitle_Value = [NSString stringWithFormat:@"[%@]%@",languageStringWithKey(@"位置"),locationBody.title];
        HXMergeMessageContent_Value = locationBody.title;
        HXMergeMessageUserData_Value = @{
                                         @"latitude":[NSString stringWithFormat:@"%f",locationBody.coordinate.latitude],
                                         @"longitude":[NSString stringWithFormat:@"%f",locationBody.coordinate.longitude]}.yy_modelToJSONString;
    }
    else{
        return nil;
    }
    if(self.mCellSimleInformationArray.count < 3){//提取简单描述
        if ([HXMergeMessageAccount_Value isEqualToString:@"~ytxfa"]) {
            HXMergeMessageAccount_Value = [[Common sharedInstance] getAccount];
        }
//        NSDictionary *address = [[Common sharedInstance].componentDelegate getDicWithId:HXMergeMessageAccount_Value withType:0];
//        NSString *tempString = [NSString stringWithFormat:@"%@:%@",address[Table_User_member_name],HXMergeMessageTitle_Value];
//        [self.mCellSimleInformationArray addObject:tempString];
        [[Common sharedInstance] getUserInfoByAccount:HXMergeMessageAccount_Value completion:^(NSDictionary *userInfo, NSString *userName) {
              NSString *tempString = [NSString stringWithFormat:@"%@:%@",userName,HXMergeMessageTitle_Value];
            [self.mCellSimleInformationArray addObject:tempString];
        }];
    }
    NSDictionary *dict = @{
                           HXMergeMessageType:HXMergeMessageType_Value?HXMergeMessageType_Value:@"",
                           HXMergeMessageTitle:HXMergeMessageTitle_Value?HXMergeMessageTitle_Value:@"",
                           HXMergeMessageTime:HXMergeMessageTime_Value?HXMergeMessageTime_Value:@"",
                           HXMergeMessageUrl:HXMergeMessageUrl_Value?HXMergeMessageUrl_Value:@"",
                           HXMergeMessageContent:HXMergeMessageContent_Value?HXMergeMessageContent_Value:@"",
                           HXMergeMessageAccount:HXMergeMessageAccount_Value?HXMergeMessageAccount_Value:@"",
                           HXMergeMessageUserData:HXMergeMessageUserData_Value?HXMergeMessageUserData_Value:@"",
                           HXMergeMessageLinkThumUrl:HXMergeMessagelinkThumUrl_Value?HXMergeMessagelinkThumUrl_Value:@"",
                           HXMergeMessageId:HXMergeMessageIdValue?HXMergeMessageIdValue:@"",
                           HXMergeMessageFileSize:HXMergeMessageFileSizeValue?HXMergeMessageFileSizeValue:@"",
                           HXMergeMessageSessonId:HXMergeMessageIdValue?HXMergeMessageSessonId:@"",
                           HXMergeMessageDuration:HXMergeMessageDurationValue
                           };
    return dict;
    
}

// hanwei
- (NSString *)subStringWith:(NSString *)string ToIndex:(NSInteger)index{
    NSString *result = string;
    if (result.length > index) {
        //Emoji占2个字符，如果是超出了半个Emoji，用15位置来截取会出现Emoji截为2半
        //超出最大长度的那个字符序列(Emoji算一个字符序列)的range
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:index];
        result = [result substringToIndex:(rangeIndex.location)];
    }
    return result;
}


- (void)eachForwardChatMessage:(NSArray<ECMessage *> *)messageArr withVC:(BaseViewController *)vc{
    self.mForwardMode = ForwardMode_EachMessage;
//    [self setVC:vc];
    
    if (messageArr.count <= 0) {
        return;
    }
    NSInteger type;
    ECMessage *message = messageArr[0];
    if (messageArr.count==1) {
        if(message.isMergeMessage){
            type = MessageBodyType_MessageMerge;
        }else{
            type = message.messageBody.messageBodyType;
        }
    }
    else {
        type = -1;
    }
    objc_setAssociatedObject(@"YXPMessageRealy", @"YXPMessageRealy", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSDictionary *allDic = [NSDictionary dictionary];
    //判断转发类型
    BOOL isRelay  =YES;//是否可转发
    switch (type) {
        case -1:{
            //多条消息
            allDic = @{@"RelayType":[NSNumber numberWithInt:RelayMessage_multi],@"data":@{@"msg_title":[NSString stringWithFormat:@"%@%@%lu%@",[NSString stringWithFormat:@"[%@]",languageStringWithKey(@"逐条转发")],languageStringWithKey(@"共"),(unsigned long)[Common sharedInstance].moreSelectMsgData.count,languageStringWithKey(@"消息")]}};
        }
            break;
        case MessageBodyType_Text:{
            //文本
            ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
            allDic = @{@"RelayType":[NSNumber numberWithInt:RelayMessage_text],@"data":@{@"msg_title":textBody.text}};
        }
            break;
        case MessageBodyType_Video:{
            //视频
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
            allDic =@{@"RelayType":[NSNumber numberWithInt:RelayMessage_video],@"data":@{@"msg_remoteUrl":videoBody.thumbnailRemotePath?videoBody.thumbnailRemotePath:@"",@"msg_localPath":videoBody.localPath?videoBody.localPath:@""}};
        }
            break;
        case MessageBodyType_Image:{
            //图片
            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
            allDic = @{@"RelayType":[NSNumber numberWithInt:RelayMessage_image],@"data":@{@"msg_localPath":imageBody.localPath?imageBody.localPath:@""}};
        }
            break;
        case MessageBodyType_MessageMerge:{
            //文件
            ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
            NSString *title = [[HXMessageMergeManager jsonDicWithBase64UserData:message.userData] objectForKey:HXMergeMessageTitleKey];
            allDic = @{@"RelayType":[NSNumber numberWithInt:RelayMessage_file],@"data":@{@"msg_title":title?title:([fileBody.remotePath lastPathComponent]?[fileBody.remotePath lastPathComponent]:languageStringWithKey(@"未知文件名"))}};
        }
            break;
        case MessageBodyType_File:{
            //文件
            ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
            allDic = @{@"RelayType":[NSNumber numberWithInt:RelayMessage_file],@"data":@{@"msg_title":fileBody.displayName?fileBody.displayName:([fileBody.remotePath lastPathComponent]?[fileBody.remotePath lastPathComponent]:languageStringWithKey(@"未知文件名"))}};
        }
            break;
        case MessageBodyType_Preview:{
            //连接预览
            ECPreviewMessageBody *previewBody = (ECPreviewMessageBody *)message.messageBody;
            allDic =@{@"RelayType":[NSNumber numberWithInt:RelayMessage_link],@"data":@{@"msg_title":previewBody.title?previewBody.title:previewBody.desc}};
        }
            break;
        case MessageBodyType_Location: {
            ECLocationMessageBody *locationBody = (ECLocationMessageBody *)message.messageBody;
            allDic =@{@"RelayType":[NSNumber numberWithInt:RelayMessage_location],@"data":@{@"msg_title":locationBody.title?:@"位置信息"}};
        } break;
        default:
            isRelay = NO;
            break;
    }
    
    if(!isRelay){
        [vc showCustomToast:languageStringWithKey(@"该内容不属于转发范畴")];
        return;
    }
    objc_setAssociatedObject(@"YXPMessageRealy", @"YXPMessageRealy", allDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIViewController *groupVC = [[Common sharedInstance].componentDelegate getChooseMembersVCWithExceptData:@{} WithType:SelectObjectType_OnlyMergeMultiSelectContactMode];
    RXBaseNavgationController * nav = [[RXBaseNavgationController alloc] initWithRootViewController:groupVC];
    [vc presentViewController:nav animated:YES completion:nil];
}

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;{
    // 格式化时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    double Time = [timeString doubleValue];
    int total_second =(int) (Time/1000.0);
    int yuSecond = total_second%(24*3600);
    NSString *dayZone = nil;
    if(yuSecond > 12*3600){
        dayZone = languageStringWithKey(@"下午");
    }else{
        dayZone = languageStringWithKey(@"上午");
    }
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (isEnLocalization) {
        [formatter setDateFormat:[NSString stringWithFormat:@"MM-dd HH:mm"]];
    }else{
         [formatter setDateFormat:[NSString stringWithFormat:@"MM月dd日 HH:mm"]];
    }
    // 毫秒值转化为秒
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)getUserBase64DataString:(NSString *)userData{
    NSString *str = nil;
    NSRange ran = [userData rangeOfString:@"UserData="];
    if (ran.location == NSNotFound) {
        NSRange ran1 = [userData rangeOfString:@"customtype="];
        if(ran1.location == NSNotFound){
            str = userData;
        }else{
            NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:[userData componentsSeparatedByString:@","]];
            [arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tempString = obj;
                if([tempString rangeOfString:@"customtype="].location!=NSNotFound){
                    *stop = YES;
                    [arrayData removeObject:obj];
                }
            }];
            str = [arrayData componentsJoinedByString:@","];
        }
    }else{
        NSInteger index = ran.location + ran.length;
        str = [userData substringFromIndex:index];
    }
    NSString *de64CodeStr = [str base64DecodingString];//解密，看看是不是嵌套
    return de64CodeStr;
}

- (NSDictionary *)jsonDicWithBase64UserData:(NSString *)userData{
    NSString *str = nil;
    str = [HXMessageMergeManager getUserBase64DataString:userData];
    while ([str containsString:@"customtype="]) {
        str = [HXMessageMergeManager getUserBase64DataString:str];
        if([str containsString:@"customtype="]==NO){
            break;
        }
    }
    NSDictionary *im_jsonDic = [MessageTypeManager getCusDicWithUserData:str];
    return im_jsonDic;
}


+ (NSDictionary *)jsonDicWithBase64UserData:(NSString *)userData{
    NSString *str = userData;
    while ([str containsString:@"customtype="]) {
        str = [HXMessageMergeManager getUserBase64DataString:str];
        if([str containsString:@"customtype="] == NO){
            break;
        }
    }
    NSDictionary *im_jsonDic = [MessageTypeManager getCusDicWithUserData:str];
    return im_jsonDic;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
        DDLogInfo(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSDictionary *)jsonDicWithNOBase64UserData:(NSString *)userData{
    if([userData isKindOfClass:[NSDictionary class]]){
        NSDictionary *tempdict = (NSDictionary *) userData;
        return tempdict;
    }
    NSString *str = nil;
    NSRange ran = [userData rangeOfString:@"UserData="];
    if (ran.location == NSNotFound) {
        NSRange ran1 = [userData rangeOfString:@"customtype="];
        if(ran1.location == NSNotFound){
            str = userData;
        }else{
            NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:[userData componentsSeparatedByString:@","]];
            [arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tempString = obj;
                if([tempString rangeOfString:@"customtype="].location!=NSNotFound){
                    *stop = YES;
                    [arrayData removeObject:obj];
                }
            }];
            str = [arrayData componentsJoinedByString:@","];
        }
    }else{
        NSInteger index = ran.location + ran.length;
        str = [userData substringFromIndex:index];
    }
    NSDictionary *im_jsonDic = [MessageTypeManager getCusDicWithUserData:str];
    return im_jsonDic;
}

#pragma mark ========================================
#pragma mark == 文件需要下载
#pragma mark ========================================
- (void)startDownload:(HXMergeMessageModel*)model andCompletion:(Completion)completion{
    NSString *fileName;
    if(model.merge_type.integerValue == MessageBodyType_File){
        fileName = model.merge_title;
        if (KCNSSTRING_ISEMPTY(fileName)) {
            fileName = [model.merge_url lastPathComponent];
        }
    }else if(model.merge_type.integerValue == MessageBodyType_Image){
        fileName = [model.merge_url lastPathComponent];
    }
    NSString *fileIdentiferTime = [HXFileCacheManager createRandomFileName];
    ECFileMessageBody *fileBody = [[ECFileMessageBody alloc] init];
    fileBody.remotePath = model.merge_url;

//    fileBody.localPath = [HXFileCacheManager createFilePathInCacheDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument dataExtension:fileIdentiferTime sessionId:model.merge_messageId fileName:fileName];
    
    fileBody.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    ECMessage *downLoadMessage = [[ECMessage alloc] initWithReceiver:model.merge_messageId body:fileBody];
    downLoadMessage.userData = model.merge_userData;
    [[ECDevice sharedInstance].messageManager downloadMediaMessage:downLoadMessage progress:nil completion:^(ECError *error, ECMessage *message) {
        if (error.errorCode == ECErrorType_NoError) {
            NSString *fileUUid = [NSString fileMessageUUid:message.userData];
            NSDictionary *fileDic = @{cachefileUrl:fileBody.remotePath,cacheimSissionId:message.sessionId,cachefileDirectory:YXP_FileCacheManager_CacheDirectoryOfDocument,cachefileIdentifer:fileIdentiferTime,cachefileDisparhName:fileName,cachefileExtension:[fileName pathExtension]?[fileName pathExtension]:@"",cachefileSize:[NSString stringWithFormat:@"%lld",fileBody.originFileLength],cachefileUuid:!KCNSSTRING_ISEMPTY(fileUUid)?fileUUid:@""};
            [[SendFileData sharedInstance] insertFileinfoData:fileDic];
            if(completion){
                completion();
            }
        } else {
            fileBody.localPath = nil;
            [[KitMsgData sharedInstance] updateMessageLocalPath:message.messageId withPath:@"" withDownloadState:((ECFileMessageBody*)message.messageBody).mediaDownloadStatus];
        }
    }];
}
- (UIImage *)getImageFromURL:(NSString *)fileURL{
    UIImage *result;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

/**
 @brief 是否是合并转发消息
 */

- (NSNumber *)checkIsMergeMessage:(ECMessage *)message{
    if(message.isMergeMessage){
        return [NSNumber numberWithInt:1];
    }else{
        return [NSNumber numberWithInt:0];
    }
}

@end
