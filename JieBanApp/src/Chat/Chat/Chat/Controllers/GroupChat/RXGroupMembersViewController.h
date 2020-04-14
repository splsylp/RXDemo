//
//  RXGroupMembersViewController.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/9/15.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "BaseViewController.h"
#import "RXGroupMemberCell.h"



@protocol RXGroupMembersViewDelegate <NSObject>

- (void)RXGroupMembersViewWithSelectMembers:(NSArray *)members;

@end

@interface RXGroupMembersViewController : BaseViewController

@property (nonatomic, assign) id<RXGroupMembersViewDelegate>memberDelegate;
@property (nonatomic, strong) NSArray * selectMember;//已选的用户
@property (nonatomic, assign) BOOL isFromVideoMeeting;//是否从会议中跳转
@property (nonatomic, strong) NSArray * memberArr;
@property (nonatomic, assign) RXGroupMembersStyle style;

@end
