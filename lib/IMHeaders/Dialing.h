//
//  Dialing.h
//  Dialing
//
//  Created by wangming on 16/7/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KitBaseHeader.h"

typedef NS_ENUM(NSUInteger, RXCallFinishedState) {
    RXCallFinishedStateNormal = 100,            //正常挂断
    RXCallFinishedStateCallerCancelled = 101,   //主叫时,主叫挂断,未接通
    RXCallFinishedStateCalleeRefused = 102,     //主叫时,被叫拒绝
    RXCallFinishedStateCalledCancelled = 201,   //被叫时,对方挂断,未接通
    RXCallFinishedStateCalledRefused = 202,     //被叫时,拒绝接听
};

typedef void (^didFinish)(NSString *tel);
typedef void (^didFail)(NSError *error);

@interface Dialing : NSObject

@property(nonatomic,weak) id<ComponentDelegate> componentDelegate;//代理

@property (nonatomic,strong) id owner;
//是否需要隐藏缩小按钮
@property (nonatomic, assign) BOOL needHideReduceScreen;

//是否需要自动缩小按钮
@property (nonatomic, assign) BOOL autoHideReduceScreen;

@property (nonatomic, assign) RXCallFinishedState finishState;

+ (Dialing *)sharedInstance;
/**
 @brief 初始化SDK
 @discussion 初始化SDK，根据传入的userId建立本地库
 @return 返回类实例
 */
+(Dialing*)initWithUserId:(NSString *)userId;

/**
 @brief 获取通话记录界面
 @discussion 调用后启动通话界面
 @return 无返回值
 */
//-(UIViewController*)getDialingViewWithViewController;

/**
 @brief 获取语音通话记录界面
 @discussion 根据传入的参数获取语音通话界面
 dict 内容
 caller 被叫voip号码或者用户Id
 nickname 被叫昵称
 callType 呼叫类型
 callDirect 呼叫方向
 */
- (void)startCallViewWithDict:(NSDictionary*)dict;


/**
 @brief 显示选择菜单
 @param dict 类型 phone电话 ，nickname昵称,memberId account账号
 @param owner 容器，从哪个容器中弹出通话界面
 */
-(void)showViewSelectMenu:(NSDictionary *)dict andOwner:(UIViewController*)owner;

@end
