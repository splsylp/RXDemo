//
//  RXCollectManager.m
//  Chat
//
//  Created by lxj on 2018/12/20.
//  Copyright © 2018 ronglian. All rights reserved.
//

#import "RXCollectManager.h"
#import "RXCollectData.h"
#import "HXMessageMergeManager.h"
#import "NSData+Ext.h"

@implementation RXCollectManager

#pragma mark - 收藏相关
//解析im消息，获取收藏要准备的数据
+ (NSArray<RXCollectData *> *)getCollectionsWithMessageData:(NSArray *)messageData {
    NSMutableArray *collects = [NSMutableArray arrayWithCapacity:0];
    
    /**
     
     if (messageData.count == 1){收藏单个聊天记录
     ECMessage *message = messageData.firstObject;
     if (message.isMergeMessage) {
     判断文件本地是否存在
     ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
     NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
     if(fileDic.count > 0){
     NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
     
     NSString *filePaht = [HXFileCacheManager DocumentAppDataPath:[fileDic objectForKey:cachefileIdentifer] CacheDirectory:[fileDic objectForKey:cachefileDirectory] dispathName:[fileDic objectForKey:cachefileDisparhName] sessionId:[fileDic objectForKey:cacheimSissionId]];
         NSString *filePaht = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:mediaBody.remotePath.lastPathComponent];
     NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePaht];
     NSString *base64 = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
     if (!base64) {Android 发的需要先解压，才能读取到里面的内容
     NSData *dataUncompressed = [fileData uncompressZippedData];
     base64 = [[NSString alloc] initWithData:dataUncompressed encoding:NSUTF8StringEncoding];
     }
     if (!base64) {
     return nil;
     }
     NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
     NSArray *tempDataArray = [NSData toArrayOrNSDictionary:decodedData];
     
     1,文本 ；2，图片；3，网页；4，语音；5，视频；6，图文 7，文件
     for (NSDictionary *dictionary in tempDataArray) {
     RXCollectData *data = [[RXCollectData alloc] init];
     NSInteger merge_type = [dictionary[@"merge_type"] integerValue];
                         NSString *favoriteMsgId = @"";
     switch (merge_type) {
     case 1:
     data.type = @"1";
                                 favoriteMsgId = [message.messageId MD5EncodingString].lowercaseString;
     break;
     case 2:
     data.type = @"4";
     break;
     case 3:
     data.type = @"5";
     break;
     case 4:{
     NSDictionary *userData =  [MessageTypeManager getCusDicWithUserData:dictionary[@"merge_userData"]];
     if([userData hasValueForKey:@"Rich_text"]){
     data.type = @"6";
     }else {
     data.type = @"2";
     }
     }
     break;
     case 6:
     data.type = @"7";
     break;
     default:
     break;
     }
     data.sessionId = message.from;
     data.txtContent = dictionary.yy_modelToJSONString;
     data.url = @"";
     data.favoriteMsgId = [message.messageId MD5EncodingString].lowercaseString;
     [collects addObject:data];
     }
     }else {
     [SVProgressHUD showInfoWithStatus:@"未下载不能收藏"];
     }
     return collects;
     }
     }
     */
    
    for (ECMessage * message in messageData) {
        if ([Common sharedInstance].isIMMsgMoreSelect) {
            if ([self checkMessageMoreActionBarClickWithType:ChatMoreActionBarType_collection messageArr:@[message]] != ChatMoreActionFuncType_None) {
                continue;
            }
        }
        NSDictionary *dic = [self getRXCollectDataProperty:message];
        RXCollectData *data = [[RXCollectData alloc] init];
        data.type = dic[@"type"];
        data.sessionId = message.from;
        if (message.isMergeMessage) {
            data.sessionId = message.sessionId;
        }
        data.txtContent = dic[@"txtContect"];
        data.url = @"";
        data.favoriteMsgId = dic[@"favoriteMsgId"];
        [collects addObject:data];
    }
    return collects;
}

+ (NSDictionary *)getRXCollectDataProperty:(ECMessage *)message {
    
    NSString *type = nil;
    NSString *txtContect = nil;
    NSString *favoriteMsgId = nil;
    
    if (message.messageBody.messageBodyType == MessageBodyType_Text && !message.isWebUrlMessageSendSuccess) {
        type = @"1";
        ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
        NSDictionary *dic = @{@"content":textBody.text};
        txtContect = [dic translateToJSONString];
        favoriteMsgId = [message.messageId MD5EncodingString].lowercaseString;
    }else if (message.messageBody.messageBodyType == MessageBodyType_Image) {
        NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
        if (message.isRichTextMessage) {//图文
            type = @"6";
            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
            if (imageBody.remotePath.length <= 0) {
                imageBody.remotePath = @"";
                NSLog(@"error error");
            }
            NSString *text = [userData hasValueForKey:@"content"] ? [userData[@"content"] base64DecodingString]:[userData[@"Rich_text"] base64DecodingString];
            NSDictionary *dic = @{@"url":imageBody.remotePath,@"content":text};
            txtContect = [dic convertToString];
            favoriteMsgId = [message.messageId MD5EncodingString].lowercaseString;
        }else{// 图片
            type = @"2";
            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
            if (imageBody.remotePath.length > 0) {
                NSDictionary * dic = @{@"url":imageBody.remotePath};
                txtContect = [dic convertToString];
                favoriteMsgId = [imageBody.remotePath MD5EncodingString].lowercaseString;
            }
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Preview || message.isWebUrlMessageSendSuccess) {
        type = @"3";
        if (message.isWebUrlMessageSendSuccess) {
            NSDictionary *dic = message.userDataToDictionary;
            dic = @{@"url":dic[@"url"],
                    @"urlTitle":dic[@"title"],
                    @"urlDescription":dic[@"desc"],
                    @"urlThum":dic[@"img"]
            };
            txtContect = [dic translateToJSONString];
            favoriteMsgId = [dic[@"url"] MD5EncodingString].lowercaseString;
        } else {
            ECPreviewMessageBody *previewBody = (ECPreviewMessageBody *)message.messageBody;
            NSDictionary * urlDic = @{@"url":previewBody.url,@"urlTitle":previewBody.title?previewBody.title:@"",@"urlDescription":previewBody.desc?previewBody.desc:@"",@"urlThum":previewBody.thumbnailRemotePath?previewBody.thumbnailRemotePath:@""};
            txtContect = [urlDic translateToJSONString];
            favoriteMsgId = [previewBody.url MD5EncodingString].lowercaseString;
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Voice) {
        type = @"4";
        ECVoiceMessageBody * voiceBody = (ECVoiceMessageBody *)message.messageBody;
        if (voiceBody.remotePath) {
            NSDictionary *dic = @{@"url":voiceBody.remotePath,@"length":[NSString stringWithFormat:@"%ld",(long)voiceBody.duration]};
            txtContect = [dic translateToJSONString];
            favoriteMsgId = [voiceBody.remotePath MD5EncodingString].lowercaseString;
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Video) {
        type = @"5";
        ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
        if (videoBody.remotePath) {
            NSDictionary *dic = @{@"url":videoBody.remotePath,@"videoThum":videoBody.thumbnailRemotePath?videoBody.thumbnailRemotePath:[NSString stringWithFormat:@"%@_thum",videoBody.remotePath]};
            txtContect = [dic translateToJSONString];
            favoriteMsgId = [videoBody.remotePath MD5EncodingString].lowercaseString;
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_File){
        type = @"7";
        ECFileMessageBody * fileBody = (ECFileMessageBody *)message.messageBody;
        NSArray * displayNameArr = [fileBody.displayName componentsSeparatedByString:@"."];
        NSString * fileType = displayNameArr[displayNameArr.count - 1];
        if (fileBody.remotePath &&
            ![fileBody.remotePath hasPrefix:@"YXPLocationSendFile"]) {
            NSDictionary *dic = @{@"url":fileBody.remotePath,@"fileName":fileBody.displayName,@"fileSize":[NSString stringWithFormat:@"%lld",(fileBody.originFileLength>0)?fileBody.originFileLength:fileBody.fileLength],@"fileExt":fileType,@"userData":!KCNSSTRING_ISEMPTY(message.userData)?message.userData:@""};
            txtContect = [dic translateToJSONString];
            favoriteMsgId = [fileBody.remotePath MD5EncodingString].lowercaseString;
        }
    }else if (message.messageBody.messageBodyType == MessageBodyType_Location){
        type = @"8";
        ECLocationMessageBody *locationBody = (ECLocationMessageBody *)message.messageBody;
        NSDictionary *dic = @{@"content":locationBody.title,
                              @"latitude":[NSString stringWithFormat:@"%f",locationBody.coordinate.latitude],
                              @"longitude":[NSString stringWithFormat:@"%f",locationBody.coordinate.longitude],
                              };
        txtContect = [dic translateToJSONString];
        favoriteMsgId = [message.messageId MD5EncodingString].lowercaseString;
    }
    
    return @{
             @"type":type,
             @"txtContect":txtContect,
             @"favoriteMsgId":favoriteMsgId
             };
}


//收藏多条消息
+ (void)collectionRequestWithCollections:(NSArray *)collections sessionId:(NSString *)sessionId {
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在收藏")];
    [RestApi addMultiCollectDataWithAccount:[Common sharedInstance].getAccount sessionId:sessionId  collectContents:collections didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        NSDictionary* head = [dict objectForKey:@"head"];
        NSInteger statusCode = [[head objectForKey:@"statusCode"] integerValue];
        if(statusCode == 0){
            [SVProgressHUD showSuccessWithStatus:languageStringWithKey(@"收藏成功")];
            NSDictionary* body = [dict objectForKey:@"body"];
            NSArray * collectIds = [body objectForKey:@"collectIds"];
            for (NSInteger i = 0; i < collections.count; i ++) {
//                RXCollectData * data = collections[i];
//                data.collectId = collectIds[i];
//                data.time = [body getStringForKey:@"createTime"];
//                [RXCollectData insertCollectionInfoData:data];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:statusCode == 901551 ? languageStringWithKey(@"请不要重复收藏"): languageStringWithKey(@"收藏失败")];
        }
    } didFailLoaded:^(NSError *error, NSString *path) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"收藏失败")];
        DDLogInfo(@"收藏失败%@",error);
    }];
}

#pragma mark - 消息检查
//检查im消息的职能
+ (ChatMoreActionFuncType)checkMessageMoreActionBarClickWithType:(ChatMoreActionBarType)type messageArr:(NSArray <ECMessage *> *)messageArr{
    // fixbug by liyijun 2017/08/08 添加消息是否收藏判断
    //多选的合并转发
    if(type == ChatMoreActionBarType_forword_Multiple_Merge){
        return [self checkforword_Multiple_MergMessageMoreActionMessageArr:messageArr];
    } else if(!IsHengFengTarget && type == ChatMoreActionBarType_collection){ // 消息是否可收藏判断
        return [self checkForwordMultipleMergMessageCollectionActionMessageArr:messageArr];
    }
    ChatMoreActionFuncType isCheck = ChatMoreActionFuncType_None;
    for (ECMessage * message in messageArr) {
        MessageBodyType messageType = message.messageBody.messageBodyType;
        NSDictionary *im_modeDic =  [MessageTypeManager getCusDicWithUserData:message.userData];

        if ([[im_modeDic objectForKey:kRonxinBURN_MODE] isEqualToString:kRONGXINBURN_ON]) {
            if ([im_modeDic hasValueForKey:@"isRead"]||[message.from isEqualToString:[Common sharedInstance].getAccount]) {
                if (type != ChatMoreActionBarType_delete) {
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }
            }else{
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            }
        }else{
            if (messageType == MessageBodyType_Text) {
                NSDictionary *useDataDic = [MessageTypeManager getCusDicWithUserData:message.userData];
                NSDictionary *cardData = [useDataDic hasValueForKey:SMSGTYPE] ? useDataDic:useDataDic[ShareCardMode];
                NSInteger type = [[cardData objectForKey:@"type"] integerValue];//名片类型
                if (message.userData
                    && message.isVoipRecordsMessage) {//音视频通话记录
                        if (type != ChatMoreActionBarType_delete){
                            isCheck = ChatMoreActionFuncType_NotSupport;
                            break;
                        }
                    }else if (type == 1 || type == 2) { //个人名片、公众号名片
                        if (type == ChatMoreActionBarType_collection) {
                            isCheck = ChatMoreActionFuncType_NotSupport;
                            break;
                        }
                    }else if(!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:@"WBSS_SHOWMSG"].location != NSNotFound){ //白板协同邀请消息
                        if (type != ChatMoreActionBarType_delete) {
                            isCheck = ChatMoreActionFuncType_NotSupport;
                            break;
                        }
                    }else if (!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:@"IM_Mode"].location != NSNotFound) { //请假审批消息
                        if (type != ChatMoreActionBarType_delete) {
                            isCheck = ChatMoreActionFuncType_NotSupport;
                            break;
                        }
                    }else if (useDataDic && [useDataDic hasValueForKey:@"is_money_msg"]) {//红包
                        if (type != ChatMoreActionBarType_delete) {
                            isCheck = ChatMoreActionFuncType_NotSupport;
                            break;
                        }
                    }
            }else if (messageType==MessageBodyType_Voice){
                if (type == ChatMoreActionBarType_forword) {
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }
            }else if (messageType == MessageBodyType_Image) {
                //转发前，判断文件的有没有本地路径
                if (type == ChatMoreActionBarType_forword) {
                    ECFileMessageBody * body = (ECFileMessageBody *)message.messageBody;
                    if (KCNSSTRING_ISEMPTY(body.localPath)) {
                        isCheck = ChatMoreActionFuncType_NotDownload;
                        break;
                    }
                }
            }else if (messageType == MessageBodyType_Preview){
                //转发前，判断文件的有没有本地路径
                if (type == ChatMoreActionBarType_forword) {
                    ECFileMessageBody * body = (ECFileMessageBody *)message.messageBody;
                    if (KCNSSTRING_ISEMPTY(body.localPath)) {
                        isCheck = ChatMoreActionFuncType_NotDownload;
                        break;
                    }
                }
            }else if (messageType == MessageBodyType_Video) {
                //转发前，判断文件的有没有本地路径
                if (type == ChatMoreActionBarType_forword) {
                    ECFileMessageBody * body = (ECFileMessageBody *)message.messageBody;
                    if (KCNSSTRING_ISEMPTY(body.localPath)) {
                        isCheck = ChatMoreActionFuncType_NotDownload;
                        break;
                    }
                }
            }else if (messageType==MessageBodyType_File) {
                //转发前，判断文件的有没有本地路径
                if (type == ChatMoreActionBarType_forword) {
                    ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
                    NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
                    //合并的消息不能转发 yxp2017
                    if(message.isMergeMessage){
                        isCheck = ChatMoreActionFuncType_NotSupport;
                        break;
                    }
                    if(fileDic.count == 0){
                        isCheck = ChatMoreActionFuncType_NotDownload;
                        break;
                    }
                }
            }
        }
    }
    return isCheck;
}

/*
 * 检查消息是否支持收藏
 * 支持收藏的消息类型：图片、小视频、语音、文件、链接分享
 * 不支持收藏消息类型：阅后即焚，位置，图文、名片【个人名片、服务号名片】、白板邀请、通话记录、审批消息、红包
 */
+ (ChatMoreActionFuncType)checkForwordMultipleMergMessageCollectionActionMessageArr:(NSArray <ECMessage *> *)messageArr{
    ChatMoreActionFuncType isCheck = ChatMoreActionFuncType_None;
    if (messageArr.count == 1) {//单条合并消息可以收藏
        ECMessage *message = messageArr.firstObject;
        if (message.isMergeMessage) {
            return isCheck;
        }
    }
    for (ECMessage * message in messageArr) {
        NSDictionary *imJsonDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:message.userData];
        MessageBodyType messageBodyType = message.messageBody.messageBodyType;
        //特别参数
        if (messageBodyType == MessageBodyType_Text) {  //1.文本类型
            if (message.isCardWithMessage){
                //名片、服务号不支持收
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            } else {
                if(message.userData
                   && message.isVoipRecordsMessage) {//音视频通话记录
                       isCheck = ChatMoreActionFuncType_NotSupport;
                       break;
                   } else if([message.userData rangeOfString:@"WBSS_SHOWMSG"].location != NSNotFound&&[message.userData containsString:@"WBSS_SHOWMSG"]){ //白板协同邀请消息
                       isCheck = ChatMoreActionFuncType_NotSupport;
                       break;
                   } else if([message.userData rangeOfString:@"IM_Mode"].location != NSNotFound&&[message.userData containsString:@"IM_Mode"]) { //请假审批消息
                       isCheck = ChatMoreActionFuncType_NotSupport;
                       break;
                   } else if(imJsonDic && [imJsonDic hasValueForKey:@"is_money_msg"]) {//红包
                       isCheck = ChatMoreActionFuncType_NotSupport;
                       break;
                   } else if(message.isBurnWithMessage){//阅后焚毁的消息
                       isCheck = ChatMoreActionFuncType_NotSupport;
                       break;
                   }
            }
        } else if(messageBodyType == MessageBodyType_File){       //5.文件
            //合并的消息不能收藏，收藏合并的消息有问题
            if(message.isMergeMessage){
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            }
        } else if(messageBodyType == MessageBodyType_Location){
//            isCheck = ChatMoreActionFuncType_NotSupport;
            break;
        } else if(messageBodyType == MessageBodyType_Image){
            NSDictionary* userData =[MessageTypeManager getCusDicWithUserData:message.userData];
            if ([userData hasValueForKey:@"Rich_text"]) { // 图文消息
                isCheck = ChatMoreActionFuncType_None;
                break;
            }
        }else if (messageBodyType == MessageBodyType_Voice){ //先把合并收藏的语音消息屏蔽，因为老版本的安卓会崩溃。
            isCheck = ChatMoreActionFuncType_NotSupport;
            break;
        }
        
        if ([message.messageBody isKindOfClass:[ECFileMessageBody class]]) {
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            if (![body.remotePath hasPrefix:@"http"]) {
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            }
        }
    }
    
    return isCheck;
}
+(ChatMoreActionFuncType)checkforword_Multiple_MergMessageMoreActionMessageArr:(NSArray<ECMessage *> *)messageArr{
    ChatMoreActionFuncType isCheck = ChatMoreActionFuncType_None;
    for (ECMessage *message in messageArr) {
        
        if ([message.messageBody isKindOfClass:[ECFileMessageBody class]]) {
            ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
            if (![body.remotePath hasPrefix:@"http"]) {
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            }
        }
        
        NSDictionary *im_jsonDic = [HXMessageMergeManager jsonDicWithNOBase64UserData:message.userData];
        MessageBodyType messageBodyType     =  message.messageBody.messageBodyType;
        //特别参数
        if(messageBodyType == MessageBodyType_Text){//1.文字
            if(message.isCardWithMessage){
                //名片可以
            }else{
                if (message.userData && message.isVoipRecordsMessage){//音视频通话记录
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }else if([message.userData rangeOfString:@"WBSS_SHOWMSG"].location != NSNotFound&&[message.userData containsString:@"WBSS_SHOWMSG"]){ //白板协同邀请消息
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }else if ([message.userData rangeOfString:@"IM_Mode"].location != NSNotFound&&[message.userData containsString:@"IM_Mode"]) { //请假审批消息
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }else if (im_jsonDic && [im_jsonDic hasValueForKey:@"is_money_msg"]) {//红包
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }else if(message.isBurnWithMessage){//阅后焚毁的消息
                    isCheck = ChatMoreActionFuncType_NotSupport;
                    break;
                }
            }
        }else if(messageBodyType == MessageBodyType_Image){     //2.图片
            //            ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
        }else if(messageBodyType == MessageBodyType_Video){     //3.视频
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
            //下载以后可以
            if (KCNSSTRING_ISEMPTY(videoBody.localPath)) {
                isCheck = ChatMoreActionFuncType_NotDownload;
                break;
            }
        }else if(messageBodyType == MessageBodyType_Preview){    //4.链接 ，//6.服务号
            if(!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:fromWorkFileShare].location != NSNotFound){
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            }else{
                if(!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:kFileTransferMsgNotice_CustomType].location != NSNotFound){
                    NSString *keyStr = [NSString stringWithFormat:@"%@,",kFileTransferMsgNotice_CustomType];
                    NSString *userDataCove = [[message.userData substringFromIndex:keyStr.length] base64DecodingString];
                    if([userDataCove rangeOfString:fromWorkFileShare].location != NSNotFound){
                        isCheck = ChatMoreActionFuncType_NotSupport;
                        break;
                    }
                }
            }
        }else if(messageBodyType == MessageBodyType_File){       //5.文件
            ECFileMessageBody *fileBody =(ECFileMessageBody *)message.messageBody;
            //合并的消息不能转发 2017yxp
            if(message.isMergeMessage){
                isCheck = ChatMoreActionFuncType_NotSupport;
                break;
            }
            NSDictionary *fileDic = [[SendFileData sharedInstance] getCacheFileData:fileBody.remotePath];
            //下载以后可以
            if (KCNSSTRING_ISEMPTY(fileBody.localPath) && fileDic.count == 0) {
                isCheck = ChatMoreActionFuncType_NotDownload;
                break;
            }
        }else if(messageBodyType == MessageBodyType_Location){ //位置
            //            isCheck = ChatMoreActionFuncType_NotSupport;
            break;
        }else{
            isCheck = ChatMoreActionFuncType_NotSupport;
            break;
        }
    }
    return isCheck;
}


@end
