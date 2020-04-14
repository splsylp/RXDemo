//
//  YHCPlugDelegate.h
//  ConferenceDemo
//
//  Created by 王文龙 on 2018/5/2.
//  Copyright © 2018年 wwl. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface YHCExceptData : NSObject
@property(nonatomic, copy) NSArray *exitMembers;
@property(nonatomic, assign) int maxMember;
@property(nonatomic, copy) NSString *confId;
@property(nonatomic, copy) NSString *confName;
@end

@interface YHCShareInfo : NSObject
@property(nonatomic, copy) NSString *inviterId;
@property(nonatomic, copy) NSString *inviterName;
@property(nonatomic, copy) NSString *createrId;
@property(nonatomic, copy) NSString *createrName;
@property(nonatomic, copy) NSString *confId;
@property(nonatomic, copy) NSString *confName;
@property(nonatomic, copy) NSString *startTime;
@end

typedef enum : NSUInteger {
    YHCConfShareType_SMS,
    YHCConfShareType_QQ,
    YHCConfShareType_WEIXIN,
} YHCConfShareType;


/**
 *  选人的场景
 */
typedef NS_ENUM(NSInteger, YHCSelectObjectType){
    
    YHCSelectObjectType_None = 0,//无
    
    YHCSelectObjectType_ConfInfoSelectMember = 101,//会议详情选人
    
    YHCSelectObjectType_ConfOnlineSelectMember = 102,//会议中选人
    
    YHCSelectObjectType_ConfOnlineSelectPhoneMember = 103,//会议中选手机联系人
    
    YHCSelectObjectType_GroupCreateSelectMember = 104,//创建群聊选人
    
    YHCSelectObjectType_GroupChatSelectMember = 105,//群组中选人
    
    YHCSelectObjectType_TransmitSelectMember = 106,//转发选人
    
};

@protocol YHCPlugDelegate <NSObject>

@optional
//获取联系人信息
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type;//0,根据account获取，1根据手机号获取
/**
 获取选择联系人页面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(YHCExceptData *)exceptData withType:(YHCSelectObjectType)type completion:(void(^)(NSArray *membersArr))completion;
@end
