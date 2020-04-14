//
//  RXUnReadPCData.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/5/20.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KitBaseData.h"

@interface RXUnReadPCData : KitBaseData

@property(nonatomic,strong)NSString * uid;//评论ID、点赞ID
@property(nonatomic,strong)NSString * msgId;//同事圈ID
@property(nonatomic,strong)NSString * phoneNum;//手机号
@property(nonatomic,strong)NSString * account;//帐号
@property(nonatomic,strong)NSString * ctime;//时间
@property(nonatomic,strong)NSString * content;//内容(评论，点赞为nil)
@property(nonatomic,strong)NSString * type;//类型(点赞、评论)
@property(nonatomic,strong)NSString * isRead;//未读消息 1 已读  0 未读
@property(nonatomic,strong)NSString * replyPhoneNum;//被回复人
@property(nonatomic,strong)NSString * replyAccount;//被回复人

//插入未读动态消息
+ (void)insertSingleUnReadMsgData:(RXUnReadPCData *)data;
//获取所有未读消息
+ (NSMutableArray *)getAllUnReadPCMessage;
//获取历史消息
+ (NSMutableArray *)getUnReadPCMessageWithCount:(int)count withTimeStr:(NSString *)time;
//获取历史消息
+ (NSMutableArray *)getUnReadPCMessageWithCount:(int)count;
//删除所有消息
+ (bool)deleteAllUnReadMessage;
//删除指定uid消息
+ (bool)deleteUnReadMessageWithUid:(NSString *)uid;
//删除指定msgId消息
+ (void)deleteUnReadPCMessageWithMsgId:(NSString *)msgId;
//修改消息未读状态
+ (void)updateUnReadStatusWithResourse:(NSArray *)resourse;

@end
