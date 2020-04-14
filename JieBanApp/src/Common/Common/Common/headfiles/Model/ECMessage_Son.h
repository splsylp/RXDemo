//
//  ECMessage_Son.h
//  Common
//
//  Created by lxj on 2018/8/22.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RXThirdPart.h"

@interface ECMessage_Son : ECMessage

///主键自增
@property(nonatomic ,assign) int tid;
///消息类型枚举 同MessageBodyType
@property(nonatomic ,assign) NSInteger msgType;
///文本信息
@property (nonatomic, strong) NSString *text;
///文件消息体的本地文件路径
@property (nonatomic, strong) NSString *localPath;
///文件消息体的服务器远程文件路径
@property (nonatomic, strong) NSString *remotePath;
///时间
@property (nonatomic, strong) NSString *serverTime;
///下载状态 同ECMediaDownloadStatus
@property(nonatomic ,assign) NSInteger dstate;
///很多消息变量存这里
@property (nonatomic, strong) NSString *remark;
///文件消息体的显示名
@property (nonatomic, strong) NSString *displayName;
@property(nonatomic ,assign) CGFloat height;
///add by 李晓杰 图片的高度
@property(nonatomic ,assign) CGFloat imageHeight;
@property(nonatomic ,assign) CGFloat imageWight;
///用于断点续传 标识符
@property (nonatomic, strong) NSString *uuid;
///消息未读数 群聊的时候展示
@property(nonatomic ,assign) NSInteger unreadCount;

#pragma mark - 增
///使用事务来入库
+ (BOOL)insertData:(NSArray<ECMessage *> *)resourse useTransaction:(BOOL)useTransaction;
+ (BOOL)addNewChat:(ECMessage *)message;
#pragma mark - 删
///根据messageId和sessionid删除
+ (BOOL)deleteMessageId:(NSString *)messageId andSession:(NSString *)sessionId;
///根据sessionid删除
+ (BOOL)deleteMessageBySessionId:(NSString *)sessionId;
///删除所有聊天消息
+ (BOOL)deleteAllMessage;
#pragma mark - 改
///将发送中的消息改为发送失败
+ (BOOL)updateMessageSendFileBySessionId:(NSString *)sessionId;
///撤回消息
+ (BOOL)updateMessage:(NSString *)sessionId msgid:(NSString *)msgId withMessage:(ECMessage *)message;
///根据msgId设置下载状态和路径
+ (BOOL)updateMessageLocalPathByMsgId:(NSString *)msgId withPath:(NSString *)path withDownloadState:(NSInteger)state;
///根据msgId设置下载路径
+ (BOOL)updateLocationMessageLocalPathByMsgId:(NSString *)msgId withPath:(NSString *)path;
//更新某消息的状态
+ (BOOL)updateState:(NSInteger)state messageId:(NSString *)msgId;
//更新某消息uuid
+ (BOOL)updateUuid:(NSString *)uuid messageId:(NSString *)msgId;
//更新某消息计算好的高度
+ (BOOL)updateHeight:(int)height ofMessageId:(NSString *)msgId;
//更新某消息 类型和userdata
+ (BOOL)updateMsgType:(ECMessageBody *)body UserData:(NSString *)userData ofMessageId:(NSString *)msgId;
//重发，更新某消息的消息id
+ (BOOL)updateMessageId:(NSString *)msdNewId andTime:(long long)time ofMessageId:(NSString *)msgOldId;
//更新语音消息是否播放的状态
+ (BOOL)updateMessageState:(NSString *)messageId andUserData:(NSString *)userData;
///更新是否已读状态
+ (BOOL)updateMessageReadStateByMessageId:(NSString *)messageId isRead:(BOOL)isRead;
///更新文件消息体的服务器远程文件路径
+ (BOOL)updateMessageRemotePathByMessageId:(NSString *)messageId remotePath:(NSString *)remotePath;
///更新图片的大小size
+ (BOOL)updateImageSize:(CGSize)size ofMessageId:(NSString *)msgId;
//更新某消息的未读数
+ (BOOL)updateUnreadCount:(NSInteger)unreadCount ofMessageId:(NSString *)msgId;
//获取某消息未读数
+ (NSInteger)getUnreadCountByMessageId:(NSString *)msgId;
#pragma mark - 查
///根据messageId和sessionId查询消息
+ (ECMessage *)getMessageByMessageId:(NSString *)messageId sessionId:(NSString *)sessionId;

///根据sessionId查询消息
+ (NSArray<ECMessage *> *)getMessageBySessionId:(NSString *)sessionId;

///根据sessionId 查n条 当前时间点前的数据 asc排序
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId beforeTime:(long long)time count:(NSInteger)count asc:(BOOL)asc;
///根据sessionId 查n条 某个时间点前的数据
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId beforeTime:(long long)time count:(NSInteger)count;
///根据sessionId 查n条 某个时间点前的数据 区分已读未读
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId beforeTime:(long long)time count:(NSInteger)count isRead:(BOOL)isRead;
///根据sessionId 查n条 某个时间点后的数据
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId afterTime:(long long)time count:(NSInteger)count;
///根据sessionId和msgType查询消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId msgType:(NSInteger)msgType;

///根据sessionId查询图片和视频消息
+ (NSArray<ECMessage *> *)getMediaMessagesBySessionId:(NSString *)sessionId;

///根据sessionId查询消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId;

///根据输入和sessionid查询文本消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId searchText:(NSString *)searchText;

///查询时间段内的消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId startTime:(NSString *)startTime endTime:(NSString *)endTime;
///根据用户查消息
+ (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId sender:(NSString *)sender;
#pragma mark - 李晓杰
///计算图片的高度
+ (CGSize)caculateImageSize:(NSData *)imageData;
@end
