//
//  YHCConnectDelegate.h
//  YHCManager
//
//  Created by 王文龙 on 2018/5/2.
//  Copyright © 2018年 wwl. All rights reserved.
//
#import "ECConferenceNotification.h"

@protocol YHCConnectDelegate <NSObject>

-(void)onConnectState:(ECConnectState)state  failed:(ECError*)error;;

@end
