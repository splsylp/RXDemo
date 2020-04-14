//
//  ECSession+Ext.m
//  Common
//
//  Created by 王文龙 on 2017/6/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECSession+Ext.h"
#import <objc/runtime.h>

@implementation ECSession (Ext)
- (void)setMessageNotice:(BOOL)messageNotice{
    if (messageNotice) {
        objc_setAssociatedObject(self, @"messageNotice", [NSNumber numberWithBool:messageNotice], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, &messageNotice, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
- (BOOL)getMessageNotice{
    NSString *str = objc_getAssociatedObject(self, @"messageNotice");
    return [str boolValue];
}

///ECMessage转ECSession
+ (ECSession *)messageConvertToSession:(ECMessage *)message useNewTime:(BOOL)useNewTime {
    
    //现在的时间 如果是接收（新）消息 则以本地时间为准 useNewTime为YES 其他则为NO
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
    
    //服务端时间比当前时间快，就用当前时间覆盖
    if (useNewTime && tmp<message.timestamp.longLongValue) {
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }

    //消息列表存在 此消息
    ECSession *session = [[AppModel sharedInstance].appData.curSessionsDict objectForKey:message.sessionId];
    if (!session) {
        session = [[ECSession alloc] init];
    }
    session.dateTime = [message.timestamp longLongValue];
    session.sessionId = message.sessionId;
    session.fromId = message.from;
    session.type = (int)message.messageBody.messageBodyType;

    NSNumber *number = [[AppModel sharedInstance] runModuleFunc:@"HXMessageMergeManager" :@"checkIsMergeMessage:" :@[message]];
    if (message.isBurnWithMessage) {//阅后即焚
        if ([message.from isEqualToString:[[Common sharedInstance] getAccount]]) {
            session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"您发送了一条悄悄话")];
        } else{
            session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"您收到了一条悄悄话")];
        }
    } else if ([number integerValue] == 1 &&
              message.messageBody.messageBodyType == MessageBodyType_File){
        session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"聊天记录")];
    } else {
        switch (message.messageBody.messageBodyType){
            case MessageBodyType_None: {
                if ([[message.messageBody class] isSubclassOfClass:[RXRevokeMessageBody class]]) {
                    RXRevokeMessageBody *revokeBody = (RXRevokeMessageBody *)message.messageBody;
                    session.isAt = NO;
                    session.text = revokeBody.text;
                }
            }
                break;
            case MessageBodyType_Text: {
                NSString *meetType;
                NSDictionary* userData = [MessageTypeManager getCusDicWithUserData:message.userData];
                if ([userData hasValueForKey:kRonxinMessageType]) {
                    meetType = [userData objectForKey:kRonxinMessageType] ;
                    
                }
                if (!meetType) {
                    //meetType 为空是 新消息类型
                    if ([userData hasValueForKey:SMSGTYPE]) {
                        meetType = [userData objectForKey:SMSGTYPE];
                    }
                    ECTextMessageBody *msg = (ECTextMessageBody *)message.messageBody;
                     if ([meetType isEqualToString:TYPE_CARD] || [userData hasValueForKey:@"ShareCard"]) {
                         NSInteger type = [[userData objectForKey:@"type"] integerValue];
                         NSRange range = [msg.text rangeOfString:@"]"];
                         NSString *name = [msg.text substringFromIndex:(range.location + range.length)];
                         if (type == 1) { //个人名片
                             session.text = [NSString stringWithFormat:@"[%@]%@",languageStringWithKey(@"个人名片"), name];
                         }
                         else if (type == 2) { //服务号名片
                             session.text = [NSString stringWithFormat:@"[%@]%@",languageStringWithKey(@"服务号名片"), name];
                         }
                     } else {
                         session.text = [NSString stringWithFormat:@"%@",msg.text];
                     }
                    if (msg.isAted) {
                        session.isAt = msg.isAted;
                    }
                }else{
                    // 旧的消息格式
                    ECTextMessageBody *msg = (ECTextMessageBody *)message.messageBody;
                    if (msg.isAted) {
                        session.isAt = msg.isAted;
                    }
                    if([meetType isEqualToString:kRONGXINVOICEMEETTING]){
                        //语音会议
                        session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"我发起了电话会议")];
                    }else if ([meetType isEqualToString:kRONGXINVIDEOMEETTING]){
                        //视频会议
                        session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"我发起了视频会议")];
                    }else{
                        session.text = [NSString stringWithFormat:@"%@",msg.text];
                    }
                }
            }
                break;
            case MessageBodyType_Image:
                session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"图片")];
                break;
            case MessageBodyType_Video:
                session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"视频")];
                break;
            case MessageBodyType_Voice:
                session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"语音")];
                break;
            case MessageBodyType_Call: {
                ECCallMessageBody *msg = (ECCallMessageBody *)message.messageBody;
                session.text = msg.callText;
            }
                break;
            case MessageBodyType_Location:{
                session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"位置")];
            }
                break;
            case MessageBodyType_Preview: {
                session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"图文混排")];
                ECPreviewMessageBody *msgBody = (ECPreviewMessageBody *)message.messageBody;
                session.text = [NSString stringWithFormat:@"[%@]%@",languageStringWithKey(@"链接"),msgBody.title];
            }
                break;
            case MessageBodyType_Command: {
                NSNumber *isCheckOANum = [[AppModel sharedInstance] runModuleFunc:@"HXOAMessageManager" :@"obtainIsOAMessage:" :@[message]];
                BOOL isCheckOA = [isCheckOANum boolValue];
                if (isCheckOA) {
                    [[AppModel sharedInstance] runModuleFunc:@"HXOAMessageManager" :@"setSessionWithSession:andMessage:" :@[session,message]];
                }
            }
                break;
            default:
                session.text = [NSString stringWithFormat:@"[%@]",languageStringWithKey(@"文件")];
                break;
        }
    }
    return session;
}


@end
