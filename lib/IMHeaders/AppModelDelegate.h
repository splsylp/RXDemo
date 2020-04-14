//
//  AppModelDelegate.h
//  AppModel
//
//  Created by wangming on 2016/12/5.
//  Copyright © 2016年 ronglian. All rights reserved.
//
#import "KitBaseHeader.h"

#ifndef AppModelDelegate_h
#define AppModelDelegate_h

@protocol AppModelDelegate <NSObject>

@optional
-(NSDictionary *)onGetUserInfo;
-(NSString *)getDeptNameWithDeptID:(NSString *)deptID;
-(void)getChatVCWithAccount:(NSString *)account;//插件用的接口，调用聊天接口
-(void)startCallForPlugiInViewWithDict:(NSString *)dict ;//插件用的接口，调用音视频呼叫

/*
 @brief 获取联系人信息
 @param id 联系人的个人信息
 @param type 0:根据account获取，1:根据手机号获取
 @return 联系人信息
*/
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type;

/*
 @brief 选择联系人界面
 @param exceptData需要传进选择联系人界面的数据, @"members"：单聊再选人时原有人组成的数
 组，@"message"：转发的消息，@"groupId"：群聊再选人的groupId
 @return 选择联系人界面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(SelectObjectType)type;

/**
 获取成员列表
 */
-(UIViewController *)getMemberListVCWithData:(NSDictionary *)data;

/*
 @brief 联系人详情界面
 @param data:联系人账号(字符串类型，对方的账号)
 @return 详情界面
 */
-(UIViewController *)getContactorInfosVCWithData:(id)data;


/*
 @brief 定制聊天界面点击加号后的功能
 @param isGroup:是群组界面还是点对点界面
 @param members:群聊是群成员id，单聊是对方的id
 @param myImagesArr：图片数组 ，myTextArr:标题数组，mySelectorArr:点击事件数组
 @param completion(myImagesArr, myTextArr, mySelectorArr);
 */
- (void)getChatMoreArrayWithIsGroup:(BOOL)isGroup andMembers:(NSArray *)members completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion;

/*
 @brief 定制会话列表界面右上角"+"号功能列表
 @param currentVC:当前的会话列表界面
 @param myImagesArr：图片数组 ，myTextArr:标题数组，mySelectorArr:点击事件数组
 @param completion(myImagesArr, myTextArr, mySelectorArr);
 */
- (void)getSessionMoreArrayWithCurrentVc:(UIViewController *)currentVC completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion;

@end


#endif
