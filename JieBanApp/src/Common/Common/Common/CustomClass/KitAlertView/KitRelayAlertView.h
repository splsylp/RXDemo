//
//  KitRelayAlertView.h
//  AddressBook
//
//  Created by yuxuanpeng on 2017/5/16.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YXPAlertViewCompletionHandler)(BOOL isConfirm,NSString *customParameter);

typedef enum : NSUInteger {
    YXP_relay=0,
    
} YXPAlertType;

@interface KitRelayAlertView : UIView

- (void)showSuperView:(UIView *)view;
-(UIImage *)getVideoImage:(NSString *)videoURL;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic,copy)YXPAlertViewCompletionHandler alertHandler;


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

-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType showContents:(NSArray *)showArray groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl;

/**
 新增的这个message 方便给二级小弹窗用
 */
-(id)initWithBlock:(YXPAlertViewCompletionHandler)completionHandler alertType:(YXPAlertType)alertType showContents:(NSArray *)showArray groupCount:(NSString *)count content:(NSString *)content description:(NSString *)descContent relayType:(RelayMessageType)relayType localPath:(NSString *)localPath remoteUrl:(NSString *)remoteUrl message:(ECMessage *)message;
@end
