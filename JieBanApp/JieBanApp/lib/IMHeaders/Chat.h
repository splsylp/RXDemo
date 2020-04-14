//
//  Chat.h
//  Chat
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KitBaseHeader.h"
@interface Chat : NSObject
@property (nonatomic, strong)UIViewController *groupListForMeeting;
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(Chat);

//根据sessionId获取聊天界面
- (UIViewController *)getChatViewControllerWithSessionId:(NSString *)sessionId;

/*
 @brief 根据选择联系人界面所选择的数据开始聊天
 @param exceptData 传进聊天界面的数据
 @param addData 要添加的群组成员的数组
 @param completion 成功的回调
 @param failed 失败回调
 */
- (void)getChatViewControllerWithexceptData:(NSDictionary *)exceptData withAddDatas:(NSArray *)addData completion:(void(^)(UIViewController *controller))completion failed:(void(^)(NSString *codeStr))failed;

//获取会话列表
- (UIViewController *)getSessionViewController;

// 新建群组聊天
- (UIViewController *)startChattingGroup;

//未读消息数
- (NSInteger)unreadMessageCount;

//设置个人信息
- (void)setPersonInfoWithUserName:(NSString *)userName withUserAcc:(NSString *)userAcc;


//创建message并发送 - 文字
- (void)sendTextMessageWithText:(NSString*)text userData:(NSString*)userData receiver:(NSString *)receiver;

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

@end
