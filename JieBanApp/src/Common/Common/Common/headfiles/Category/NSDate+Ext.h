//
//  NSDate+Ext.h
//  Pickers
//
//  Created by yuxuanpeng on 14-7-30.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Ext)
// 返回1564128240 十位
- (NSString*)getTimestamp; //返回时间戳

//获取当前时间戳 1564128239742 十三位
+ (NSString *)getCurrentTimeStr;
// 获取时间戳 1564128239742 十三位
+ (NSString *)getTimeStrWithDate:(NSDate *)date;

//是当天返回 返回 12：00 格式 昨天的 返回 昨天  其他的返回 10/20
+ (NSString*)getGregorianCalendarWithTimeStamp:(NSString*)timeStamp;
//是 当天返回---今天12：00格式, 昨天的返回--昨天+时间格式 , 其他的返回 10/20+时间
+ (NSString*)getGregorianCalendarAndTimeWithTimeStamp:(NSDate*)Datetime;

//返回格式  上午  12：00：00
+ (NSString *)compareDate:(NSDate *)date;
//返回格式  2014-12-00  12：00：00
+ (NSString *)speCompareCurDate;
+ (NSString *)formateDate:(NSString *)dateString withFormate:(NSString *) formate;
+ (NSDate*)coverDateWithFormatter:(NSString*)time;  //2014-10-5 12:00:00 转成date
+(NSDate *)coverDateWithFormatter:(NSString *)time format:(NSString *)format;

+ (BOOL)isBetweenFromTime:(NSDate*)fromTime toTime:(NSDate*)toTime; //判断当前时间是否在一天的某个时间段内

+ (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour;

+ (NSDate *)getDateWithTimeStamp:(NSString*)timeStamp;

//返回格式 上午 8:00
+ (NSString*)getGregorianWithTimeStamp:(NSString *)timeStamp;

//传入NSDate 返回格式 上午 8:00
+ (NSString*)getGregorianWithdate:(NSDate *)date;
//传date 返回 2014-10-5 12:00:00
+(NSString *)getStringFromDate:(NSDate *)date;
//传(long long )返回 2014-10-5 12:00:00
+(NSString *)getDateString:(long long) miliSeconds;
//传(long long )返回 xxxx年-xx月-xx日 12:00:00 几天之内 刚刚 几分钟前

+(NSString *)getShowDateLongString:(NSString *)dateString;
+(NSString *)getDateLongString:(NSString *)dateString;

//时间显示内容 返回星期几 加 yyyy年MM月DD日 HH:MM
+(NSString *)getDatePublicString:(long long) miliSeconds;
//返回MM月dd日
+ (NSString*)getGregorianCalendarWithTimeLongStamp:(NSString*)timeStamp;

- (NSString*)getRFC3339Time;
+ (NSDate *)dateFromRFC3339TimeString:(NSString *)str;

//通话时间计算
+ (NSString *)calculateTime:(NSString *)startTimeString endTime:(NSString *)endTimeString;
@end
