//
//  DeviceStateViewController.h
//  Chat
//
//  Created by 杨大为 on 2018/1/10.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceStateViewController : UIViewController
///0未登录 1pc 2mac
@property(nonatomic ,assign) NSInteger deviceType;
@property (nonatomic ,assign) BOOL isExitPC; //

@end
