//
//  SessionViewController.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"


//设置登录状态
typedef enum {
    linking,
    failed,
    success,
    relinking,
} LinkJudge;

//设置收取离线消息状态
typedef enum :NSUInteger {
    receiveOfflineReceiving=0,
    receiveOfflinefailed,
    receiveOfflineSuccess
}ReceiveOfflineStates;

@interface SessionViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UIActionSheetDelegate>

@property (nonatomic,assign)BOOL isLogin;
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,strong) NSDictionary * dict;//红包相关

-(void)prepareDisplay;
-(void)updateLoginStates:(LinkJudge)link;

+ (UIViewController *)sharedInstance;

@end
