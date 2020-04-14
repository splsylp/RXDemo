//
//  KCUtils_Time.h
//  KX3
//
//  Created by peng zhi on 12-8-20.
//  Copyright (c) 2012年 kaixin001. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCUtils_Time : NSObject
//设置真实时间
+ (void)setRealTime:(NSTimeInterval) time;
//获取当前时间 毫秒为小数
+ (NSTimeInterval)getCurrentTime;

//系统启动时间 毫秒
+ (time_t)getSystemUptime;


//通过时间字符串 转换NsDate
+ (NSDate *)getDateByString:(NSString *)timeString;
//取得当天开始的时间
+ (NSTimeInterval)getTodayStartTime;
//取得当前周的所有 NSDate 一周是指从周一到周日
+ (NSMutableArray *)daysInCurrrentWeek;
//取得由date指定的日期的天开始时间
+ (NSTimeInterval)getDayStartTimeByDate:(NSDate*)date;
//毫秒数转成NSDate GTM 时区 + 东区 - 西区 所以是 +0
+ (NSDate *)getNSDataBySecondsFrom1970:(NSTimeInterval)secs;
//毫秒数转成NSDate GTM 时区 + 东区 - 西区 中国 是东八区 所以是 +8
+ (NSDate *)getNSDataBySecondsFrom1970:(NSTimeInterval)secs withGTM:(int)GTM;

/**
 ymd
 ydmhis
 **/
+ (NSString *)getDateStringByFormat:(NSString *)theFormat;

//转换为聊天/记录/消息时间格式
+ (NSString *)convert2ChatTime:(NSTimeInterval)secs;

/**
 * 有些显示时间的地方比较窄，可使用该转换格式(如个人主人的来访)
 *
 * 时间显示规则：
 * 今天：只显示时间，如“9:02”“22:41”
 * 昨天、前天：“昨天 17:24”“前天 3:06”
 * 更早：不显示具体时间，只显示来访的日期：如：9月18日
 *
 */
+ (NSString *)convert2ShortTime:(NSTimeInterval)secs;

/*
 转换为消息中心的时间格式
 */
+ (NSString *)convert2MsgTime:(NSTimeInterval)secs;

/**
 * 转换为最近来访的时间格式
 */
+ (NSString *)convert2VisitorTime:(NSTimeInterval)secs;

@end
