//
//  RXFCReplyData.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/5/18.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "KitBaseData.h"

@interface RXFCReplyData : KitBaseData
@property(nonatomic,strong)NSString * rid;//评论ID
@property(nonatomic,strong)NSString * msgId;//同事圈ID
@property(nonatomic,strong)NSString * phoneNum;//手机号
@property(nonatomic,strong)NSString * account;//帐号
@property(nonatomic,strong)NSString * ctime;//时间
@property(nonatomic,strong)NSString * content;//内容
@property(nonatomic,strong)NSString * unRead;//是否未读
@property(nonatomic,strong)NSString * replyAccount;//评论者
@property(nonatomic,strong)NSString * replyPhoneNum;//评论者


//单条插入
+ (void)insertSingleReplyMsgData:(RXFCReplyData *)data;
+ (void)insertSingleReplyMsgReplyData:(NSDictionary *)replyJson;
//批量插入
+ (void)insertReplisMsgData:(NSArray *)json;
//获取某条同事圈的点赞
+ (NSMutableArray *)getReplisOfFCMessageWithMsgId:(NSString *)msgId;
//获取最新的点赞
+ (NSMutableArray *)getCurrentTimeReplyDataWithCount:(int)count;
//获取未读的点赞
+ (NSMutableArray *)getAllUnreadReplyData;
//删除同事圈下的所有评论
+ (void)deleteReplyWithMsgId:(NSString *)msgId;
//删除
+ (bool)deleteReplyWithRid:(NSString *)rid;
//全部删除
+ (bool)deleteAllReplyMessage;

@end
