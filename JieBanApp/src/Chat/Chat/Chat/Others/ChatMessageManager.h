//
//  ChatMessageManager.h
//  Chat
//
//  Created by zhangmingfei on 2016/10/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ChatMoreActionBar.h"
#pragma mark - zmf 表情云相关 先屏蔽
//#import <BQMM/BQMM.h>

#define KNOTIFICATION_SendMessageCompletion       @"KNOTIFICATION_SendMessageCompletion"
#define KNOTIFICATION_DownloadMessageCompletion   @"KNOTIFICATION_DownloadMessageCompletion"
#define KNOTIFICATION_ReceiveMessageDelete   @"KNOTIFICATION_ReceiveMessageDelete"
#define KNOTIFICATION_SendFileMessageCompletion  @"KNOTIFICATION_SendFileMessageCompletion"

#define KErrorKey   @"kerrorkey"
#define KMessageKey @"kmessagekey"

@interface ChatMessageManager : NSObject

//被@人数组
@property (nonatomic, strong) NSMutableArray *AtPersonArray;
//阅后即焚相关
@property (nonatomic, strong) NSTimer *delMsgTimer;
@property (nonatomic, strong) NSMutableArray *delMsgArr;
@property (nonatomic, copy) NSString *sessionIdNow;

+ (ChatMessageManager *)sharedInstance;
//发送用户状态
- (void)sendUserState:(int)state to:(NSString *)to;

#pragma mark - 阅后即焚相关
- (void)addDelMsgWithDelMsgArr:(NSMutableArray *)arr;
#pragma mark - 消息文件预下载
//下载消息的附件
- (void)downloadMediaMessage:(ECMessage*)message andCompletion:(void(^)(ECError *error, ECMessage* message))completion;

#pragma mark - 重发消息 入库
- (ECMessage *)resendMessage:(ECMessage *)message;
#pragma mark - 发送转发消息 入库
- (ECMessage *)sendForwardMessageByMessage:(ECMessage *)message;
#pragma mark - 发送cmd消息方法 不入库

- (void)sendCmdMessageByDic:(NSDictionary *)dic;
- (void)sendCmdMessageByDic:(NSDictionary *)dic callBack:(void(^)(ECError *error, ECMessage *amessage))callBack;
#pragma mark - 发送消息方法 入库
///准备整理成统一的发送消息messagebody消息体 dic包含参数(type定义类型,sessionId)最后会把所有发消息统一成这个
- (ECMessage *)sendMessageWithMessageBody:(ECMessageBody *)messageBody dic:(NSDictionary *)dic;

- (void)updateUnreadMessageCountFromNetWorkByMessage:(ECMessage *)message version:(NSString *)version success:(void (^)(NSInteger unReadCount))success;

- (void)setBasicInfo:(NSMutableDictionary *)mDic;
@end
