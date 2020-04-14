//
//  ChatTools.h
//  Chat
//
//  Created by zhangmingfei on 2016/10/28.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatTools : NSObject
//时间显示内容
+ (NSString *)getDateDisplayString:(long long) miliSeconds;

//时间显示内容 沟通列表 服务号 群组列表
+(NSString *)getSessionDateDisplayString:(long long) miliSeconds;

+ (NSString *)getDateDisplayStringWithSession:(long long) miliSeconds;

+ (CGFloat)isIphone6PlusProPortionHeight;
//获取设备类型
+ (NSString*)getDeviceWithType:(ECDeviceType)type;
//获取网络类型
+ (NSString*)getNetWorkWithType:(ECNetworkType)type;
/**
 @brief 根据主题颜色渲染图片
 */
+ (UIImage *)getThemeColorImage:(UIImage *)image withColor:(UIColor *)color;
@end
