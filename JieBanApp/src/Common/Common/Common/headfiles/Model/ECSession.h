//
//  ECSession.h
//  CCPiPhoneSDK
//
//  Created by wang ming on 14-12-10.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface ECSession : BaseModel
/**
 @property
 @brief 会话ID
 */
@property (nonatomic, copy) NSString *sessionId;

/**
 @property
 @brief 发送者
 */
@property (nonatomic, copy) NSString *fromId;

/**
 @property
 @brief 创建时间 显示的时间 毫秒
 */
@property (nonatomic, assign) long long dateTime;

/**
 @property
 @brief 与消息表msgType一样
 */
@property (nonatomic, assign) int type;

/**
 @property
 @brief 显示的内容
 */
@property (nonatomic, copy) NSString *text;

/**
 @property
 @brief 未读消息数
 */
@property (nonatomic,assign) NSInteger unreadCount;

/**
 @property
 @brief 总消息数
 */
@property (nonatomic, assign) int sumCount;

/**
 @property
 @brief 是否被@了
 */
@property (nonatomic, assign) BOOL isAt;
/**
 *  草稿字段
 */
@property (nonatomic, copy) NSString *draft;

///新增字段 是否提醒
@property (nonatomic, assign) BOOL isNotice;

///不记录表里
/**
 @property
 @@brief 消息ID
 */
@property (nonatomic,retain) NSString *messageId;

#pragma mark - 增
///使用事务来入库
+ (BOOL)insertSessionArr:(NSArray<ECSession *> *)resourse useTransaction:(BOOL)useTransaction;
///新增或修改session
+ (BOOL)addNewSession:(ECSession *)session;
#pragma mark - 删
///根据sessionId删除
+ (BOOL)deleteSessionBySessionId:(NSString *)sessionId;
///根据type删除
+ (BOOL)deleteSessionType:(NSString *)type;
///删除所有会话
+ (BOOL)deleteAllSession;
#pragma mark - 改
///更新是否消息提醒
+ (BOOL)updateSessionNoticeBySessionId:(NSString *)sessionId isNotice:(BOOL)isNotice;
#pragma mark - 查
///根据sessionid查询
+ (ECSession *)getSessionBySessionId:(NSString *)sessionId;
///按时间倒序查所有session
+ (NSArray<ECSession *> *)getAllSession;
///未读消息数量
+ (NSInteger)getUnreadSessionCount;

@end
