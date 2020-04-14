//
//  KitGroupSelectViewController.h
//  Chat
//
//  Created by yongzhen on 17/2/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseViewController.h"

@interface KitGroupSelectViewController : BaseViewController
@property (nonatomic, assign) BOOL isFromVideoMeeting;//是否从会议中跳转
@property (nonatomic, strong) NSMutableArray * selectMembers;//已选的用户
@property (nonatomic, copy) NSArray *allMembersArray;

@property (nonatomic, assign) BOOL isFromVoiceConfMeeting;//语音会议
@property (nonatomic, assign) NSInteger isAppConf; // 0 手机参会 1 app参会
@property (nonatomic, copy) NSString * groupId;//群组ID
@property (nonatomic, assign) NSInteger conferenceType;//会议类型
@property (nonatomic, strong) UIViewController * chatVC;

@end
