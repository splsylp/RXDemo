//
//  YHCConferenceDelegate.h
//  YHCConference
//
//  Created by 王文龙 on 2018/5/2.
//  Copyright © 2018年 wwl. All rights reserved.
//
#import "YHCPlugDelegate.h"

@protocol YHCConferenceDelegate <NSObject>

@optional
//会议相关信息通知
- (void)onReceivedConferenceNotification:(ECConferenceNotification*)info;
//会议页面点击共享
-(void)onConfShare:(YHCShareInfo*)shareInfo withType:(YHCConfShareType) type;
@end
