//
//  Chat.h
//  Chat
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseComponent.h"
//#import "QMapServices.h"
//#import "QMSSearchServices.h"

@interface Chat : BaseComponent

@property (nonatomic, strong)UIViewController *groupListForMeeting;
@property (nonatomic,assign)BOOL isSessionEdgQueue;//沟通表是否异步刷新
@property (nonatomic,assign)BOOL isChatViewScroll;//消息列表是否正在滑动

//SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(Chat);
+ (Chat *)sharedInstance;

//根据sessionId获取聊天界面
- (UIViewController *)getChatViewControllerWithSessionId:(NSString *)sessionId;

//根据sessionId获取集中监控平台聊天界面
- (UIViewController *)getOAShowDetailVCSessionId:(NSString *)sessionId;


//根据传过来的数据开始聊天
- (void)getChatViewControllerWithData:(NSDictionary *)data completion:(void(^)(UIViewController *controller))completion failed:(void(^)(void))failed;

//获取会话列表
- (UIViewController *)getSessionViewController;

//获取我的群组列表
- (UIViewController *)getGroupListViewController;

//获取群组成员列表
- (UIViewController *)getGroupListViewControllerWithMembers:(NSMutableArray *) members withType:(NSNumber *)type;

//语音会议中获取群组成员列表
- (UIViewController *)getVoiceConfGroupControllerMembers:(NSMutableArray *)members withType:(NSNumber *)type;

//创建message并发送
- (void)sendTextMessageWithText:(NSString*)text userData:(NSString *)userData receiver:(NSString *)receiver;

//合并转发
- (id)sendMergeMessageAndSelectResultArray:(NSArray *)selectContectData andView:(UIView *)view;

//请假审批
- (UIViewController *)getRXWorkingWebViewController;

//群组成员列表选择页面
- (UIViewController *)getGroupListViewControllerWithParam:(NSDictionary *)param;

//- (ECMessage *)sendMessageWithType:(NSNumber *)type dic:(NSDictionary *)dic;

- (void)sendRedMessageWithText:(NSString *)text userData:(NSString *)userData sessionId:(NSString *)sessionId;
///供给外部 统一发消息方法 messagebody消息体 dic包含参数(type定义类型,sessionId)
- (ECMessage *)sendMessageWithMessageBody:(ECMessageBody *)messageBody dic:(NSDictionary *)dic;
//未读消息数
- (NSInteger)unreadMessageCount;

//设置个人信息
- (void)setPersonInfoWithUserName:(NSString *)userName withUserAcc:(NSString *)userAcc;

/**
 查询用户所在群组
 */
- (void)getQueryOwnGroupsWithBlock:(void(^)(NSArray *))callBack;

/*
 @brief  查询群组信息
 @param groupId 群组id
 @param callBack 用于接收返回数据
 */

- (void)getGroupDetailInfoWithId:(NSString *)groupId  WithBlock:(void(^)(NSDictionary *))callBack;

/*
 @brief  查询群组成员
 @param groupId 群组id
 @param callBack 用于接收返回数据
 */
- (void)getQueryGroupMembersWithId:(NSString *)groupId  WithBlock:(void(^)(NSArray *))callBack;

/*
 @brief 根据选择联系人界面所选择的数据开始聊天
 @param exceptData 传进聊天界面的数据
 @param addData 要添加的群组成员的数组
 @param completion 成功的回调
 @param failed 失败回调
 */
- (void)getChatViewControllerWithexceptData:(NSDictionary *)exceptData withAddDatas:(NSArray *)addData completion:(void(^)(UIViewController *controller))completion failed:(void(^)(NSString *codeStr))failed;

//二维码加群方法提取到这里
- (void)qrcodeToJoinGroupChat:(NSDictionary *)QRcodeDic controller:(UIViewController *)controller;

@end
