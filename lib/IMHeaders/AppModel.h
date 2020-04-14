//
//  AppModel.h
//  AppModel
//
//  Created by wangming on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KitBaseHeader.h"
typedef void(^completion)(NSArray *obj);
#define ThemeDefaultHead(size,name,account) [[AppModel sharedInstance] drawDefaultHeadImageWithHeadSize:size andNameString:name andAccount:account]

@interface AppModel : NSObject<UIApplicationDelegate>

@property (nonatomic,strong) id owner;
@property (nonatomic,weak) id<AppModelDelegate>appModelDelegate;
@property (nonatomic,assign) BOOL loginstate;
@property (strong,nonatomic) completion YHCcompletion;// 有会回调

+ (AppModel *)sharedInstance;

//加载serveradd配置
- (void)initServerAddr;

/**
 @brief 登录
 @discussion 登录，根据传入的登录信息进行登录
 @param loginInfo 登录时传递进来的用户信息   包含以下参数：
 @"account" 账号
 @"mobile" 手机号
 @"member_name" 姓名
 @"App_AppKey" appKey
 @"App_Token" appToken
 @"mode" 登录模式
 @param LoginCompletion 登录失败返回的错误信息
 */
- (void)loginSDK:(NSDictionary*)loginInfo :(void(^)(NSError* error)) LoginCompletion;

/**
 @brief 登出
 @discussion 登出，退出登录
 @param LogoutCompletion 登出失败返回的错误信息
 */
-(void)logout:(void(^)(NSError* error)) LogoutCompletion;
/**
 可以传入的值为以下几个，默认是 (1 << 2)，传入0是关闭日志
 1 << 0,
 1 << 1,
 1 << 2,
 1 << 3,
 1 << 4
 */
-(void)setLogLevel:(NSUInteger)level;

/**
 @brief 方法调用
 @discussion 方法调用，根据传入的参数，调用各类中的方法
 @param moduleName 要调用方法的类名
 @param funcName 要调用的方法名
 @param parms 要传递给方法的参数
 @return 要调用方法的返回值
 */
-(id)runModuleFunc:(NSString*)moduleName :(NSString*)funcName :(NSArray*)parms;

/**
 设置角标
 */
-(void)setAppleBadgeNumber:(NSInteger)badgeNumber;
/**
 @brief 用户默认头像
 */
- (UIImage *)drawDefaultHeadImageWithHeadSize:(CGSize)size andNameString:(NSString *)name andNameString:(NSString *)account;
/**
 @brief 根据用户的选择更换图片资源
 @param name  图片名字
 */
- (UIImage *)imageWithName:(NSString *)name;

- (UIColor *)themNavigationBarTitleColor:(NSString *)themeColor;

/**
 @brief 获取应用未读信息数
 @return 应用未读信息数
 */
- (NSInteger)getAppleBadgeNumberCount;

@end
