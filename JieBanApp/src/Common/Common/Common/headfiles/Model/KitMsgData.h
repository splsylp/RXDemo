/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.yuntongxun.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "BaseModel.h"

#define locationTitle @"title"
#define locationLat   @"lat"
#define locationLon   @"lon"

@class ECSession;
@class ECMessage;
@class ECGroup;
@class ECMessageBody;

@interface KitMsgData : BaseModel

+ (KitMsgData *)sharedInstance;

#pragma mark - session表相关
///使用事务来入库
-(void)updateSessionArr:(NSArray<ECSession *> *)resourse useTransaction:(BOOL)useTransaction;
///新增或修改session
- (void)updateSession:(ECSession *)session;
///新增草稿
- (void)addNewDraftText:(ECSession *)message;
///更新草稿
- (void)updateDraft:(NSString *)draft withSessionID:(NSString *)sessionID;
///根据sessionid获取Session
- (ECSession *)loadSessionWithID:(NSString *)sessionID;
///根据sessionId删除
- (void)deleteSession:(NSString *)sessionId;
///查询所有sessions key为sessionid  value为session对象
- (NSMutableDictionary *)loadAllSessions;
///根据ECMessage转成session插入消息
- (void)addNewMessage:(ECMessage *)message andSessionId:(NSString *)sessionId;
///根据ECMessage转成session插入消息 这里没有插入数据库
- (ECSession *)addNewMessage2:(ECMessage *)message andSessionId:(NSString *)sessionId ;
///添加离线消息
- (ECSession *)addOfflineMessage:(ECMessage *)message andSessionId:(NSString *)sessionId;
//删除单个聊天的所有消息，保留通道
- (void)deletemessageid:(NSString *)sessonid;
- (void)deleteMessage:(ECMessage *)message andPre:(ECMessage *)premessage;
///未读session数量
- (NSInteger)getUnreadMessageCountFromSession;
/// 设置消息未读为零
- (void)setUnreadMessageCountZeroWithSessionId:(NSString *)sessionId;
/// 设置所有消息未读为零
- (void)setAllUnreadMessageCountZero;
///更新是否是消息提醒的状态
- (BOOL)updateMessageNoticeid:(NSString *)sessionid withNoticeStatus:(BOOL)isNoticeStatus;
///按dateTime排序的sessionid
- (NSArray<NSString *> *)getMyCustomSession;
///按dateTime排序的sessionid
- (NSArray<NSString *> *)getMyNewCustomSession;
///更新会话和聊天表
- (void)updateSrcMessage:(NSString *)sessionId msgid:(NSString *)msgId withDstMessage:(ECMessage *)dstmessage;
///新增公众号消息
- (void)addNewPublicMessage:(id)message andSessionId:(NSString *)sessionId;
///删除公众号会话
- (void)deletePublicMessage:(NSString *)sessionId;
//删除公众号消息 更新沟通列表的数据 publicDic:pnid(公众号) msgTitle(标题) ptime(时间)
- (void)deletePublicMessage:(NSString *)sessionId withPreNum:(NSDictionary *)publicDic;
//清空表
- (NSInteger)clearGroupMessageTable;
#pragma mark - im_groupinfo表相关
///增加一条消息
- (BOOL)addGroupID:(ECGroup *)group;
///增加多条消息
- (NSInteger)addGroupIDs:(NSArray*)messages;
///获取群组ID、名字
- (NSArray<ECGroup *> *)getGroupCountOfGroupInfo;
///根据name 倒序筛选查询群组
- (NSArray<ECGroup *> *)getGroupWithSearchText:(NSString *)searchText;
//获取群组个数
- (NSInteger)getGroupAllCount;
///根据groupId查groupName
- (NSString *)getGroupName:(NSString *)groupId andGroupName:(NSString *)groupName;
///根据groupId查name
- (NSString *)getGroupNameOfId:(NSString *)groupId;
///根据groupId查ECGroup对象
- (ECGroup *)getGroupByGroupId:(NSString *)groupId;
///返回的是字典 ECGroup里没有isGroupMember字段 字典里有
- (NSArray *)getGroupInformation:(NSString *)groupId;
//刷新成员在群中的状态
- (BOOL)updateMemberStateInGroupId:(NSString *)groupId memberState:(int)memberState;
#pragma mark - chat表相关
///撤回消息
- (BOOL)updateMessage:(NSString *)sessionId msgid:(NSString *)msgId withMessage:(ECMessage *)message;
///根据sessionId查询某个时间前的n条聊天数据
- (NSArray<ECMessage *> *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp andASC:(BOOL)asc;
//按照文字去搜索消息
- (NSArray<ECMessage *> *)getSomeMessagesWithSearhStr:(NSString *)searchStr ofSession:(NSString *)sessionId;
///根据messageId 和 sessionId查询
- (ECMessage *)getMessagesWithMessageId:(NSString *)messageId  OfSession:(NSString *)sessionId;
///查询所有的image消息
- (NSArray *)getAllImageMessageOfSessionId:(NSString *)sessionId;

///查询所有的图片和视频消息
- (NSArray *)getAllMediaMessageOfSessionId:(NSString *)sessionId;

///查询所有的文件消息
- (NSArray *)getAllFileMessageOfSessionId:(NSString *)sessionId;

///查询某个对话的所有消息
- (NSArray *)getAllMessageWithSessionId:(NSString *)sessionId;

//增加多条消息
- (void)addMessageArr:(NSArray<ECMessage *> *)messageArr;
//增加单条消息
- (BOOL)addMessage:(ECMessage *)message;
//删除单条消息
- (BOOL)deleteMessage:(NSString *)msgId andSession:(NSString *)sessionId;
//删除某个会话的所有消息
- (NSInteger)deleteMessageOfSession:(NSString *)sessionId;
//获取会话的某个时间点之前的count条消息
- (NSArray<ECMessage *> *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp;
//获取会话的某个时间点之后的count条消息
- (NSArray<ECMessage *> *)getSomeMessagesCount:(NSInteger)count OfSession:(NSString*)sessionId afterTime:(long long)timesam;
///修改单条消息的下载路径
- (BOOL)updateMessageLocalPath:(NSString *)msgId withPath:(NSString *)path withDownloadState:(NSInteger)state;
//修改单条本地消息的下载路径
- (BOOL)updateLocationMessageLocalPath:(NSString *)msgId withPath:(NSString *)path;
//更新某消息的状态
- (BOOL)updateState:(NSInteger)state ofMessageId:(NSString *)msgId;
//更新某消息的uuid
- (BOOL)updateUuid:(NSString *)uuid ofMessageId:(NSString *)msgId;
///更新文件消息体的服务器远程文件路径
- (BOOL)updateMessageRemotePathByMessageId:(NSString *)messageId remotePath:(NSString *)remotePath;
//更新某消息计算好的高度
- (BOOL)updateHeight:(int)height ofMessageId:(NSString *)msgId;
//更新某消息未读数
- (BOOL)updateUnreadCount:(NSInteger)unreadCount ofMessageId:(NSString *)msgId;

//获取某消息未读数
- (NSInteger)getUnreadCountByMessageId:(NSString *)msgId;

//更新某消息 类型和userdata
- (BOOL)updateMsgType:(ECMessageBody *)body UserData:(NSString *)userData ofMessageId:(NSString *)msgId;
//重发，更新某消息的消息id
- (BOOL)updateMessageId:(NSString *)msdNewId andTime:(long long)time ofMessageId:(NSString *)msgOldId;
//更新语音消息是否播放的状态
- (BOOL)updateMessageState:(NSString *)messageId andUserData:(NSString *)userData;
///更新是否已读
- (BOOL)updateMessageReadStateByMessageId:(NSString *)messageId isRead:(BOOL)isRead;
///获取n条未读消息数，根据根据当前时间
- (NSArray<ECMessage *> *)getUnreadMessageDependCurrendTimeOfSessionId:(NSString*)sessionId andSize:(NSInteger)pageSize;
///获取会话的某个时间点之前的 是否已读消息
- (NSArray<ECMessage *> *)getAllMessagesCount:(NSInteger)count OfSession:(NSString *)sessionId beforeTime:(long long)timesamp andIsRead:(BOOL)isread;
///根据sessionId 查n条 当前时间点前的数据 按时间排序
- (NSArray<ECMessage *> *)getLatestHundredMessageOfSessionId:(NSString *)sessionId andSize:(NSInteger)pageSize andASC:(BOOL)asc;
///查时间段
- (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId startTime:(NSDate *)startTime endTime:(NSDate *)endTime;
///根据用户查消息
- (NSArray<ECMessage *> *)getMessagesBySessionId:(NSString *)sessionId sender:(NSString *)sender;
// 根据msgID查询消息
- (ECMessage *)getMessageById:(NSString *)SID;
#pragma mark - 李晓杰处理图片消息的宽高预读
- (BOOL)updateImageSize:(CGSize)size ofMessageId:(NSString *)msgId;
- (CGSize)caculateImageSize:(NSData *)imageData;





///删除所有消息
- (BOOL)deleteAllSessionAndGroupnoticeData;
- (BOOL)deleteAllGroupInfo;

@end
