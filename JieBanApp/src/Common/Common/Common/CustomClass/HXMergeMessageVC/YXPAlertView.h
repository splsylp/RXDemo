//
//  YXPAlertView.h
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/12/7.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

//const char YXPMessageRealy;

typedef enum : NSUInteger {
    YXP_relay=0,
    
} YXPAlertType;

typedef void(^YXPAlertViewCompletionHandler)(BOOL isConfirm,NSString *customParameter);

@interface YXPAlertView : UIView

/*
 * alertType 提示框显示类型
 * title 标题
 * content 内容
 * description 详情
 * image 图片
 * headView 群组头像的view
 * relayType 转发的消息类型
 * localPath  本地路径缓存
 * remoteUrl  远程路径地址
 **/

-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType title:(NSString *)title groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent image:(UIImage *)image relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl;

//合并转发
-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType title:(NSString *)title groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent  sessiongArray:(NSArray *)sessiongArray relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl;


- (void)showSuperView:(UIView *)view;

@property (nonatomic, strong) UIButton *confirmBtn;


@end
