//
//  NSDate+Ext.m
//  Pickers
//
//  Created by yuxuanpeng on 14-7-30.
//
//

#import "NSDate+Ext.h"
#import "KCConstants_string.h"
@implementation NSDate (Ext)
//是当天返回 返回 12：00 格式 昨天的 返回 昨天  其他的返回 10/20

+ (NSString*)getGregorianCalendarWithTimeStamp:(NSString*)timeStamp
{
    if(timeStamp == nil || timeStamp.length == 0){
        return [NSString string];
    }
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeStamp floatValue]];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString]){
        [dateFormat setDateFormat:@"HH:mm"];//设定时间格式
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [dateFormat setTimeZone:timeZone];
        NSString *dateString = [dateFormat stringFromDate:date];
        return dateString;
    } else if ([dateString isEqualToString:yesterdayString]){
        return languageStringWithKey(@"昨天");
    }else{
        [dateFormat setDateFormat:@"MM/dd"];//设定时间格式
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [dateFormat setTimeZone:timeZone];
        NSString *dateString = [dateFormat stringFromDate:date];
        return dateString;
    }
    return [NSString string];
}

//是 当天返回---今天12：00格式, 昨天的返回--昨天+时间格式 , 其他的返回 10/20+时间
+ (NSString*)getGregorianCalendarAndTimeWithTimeStamp:(NSDate*)Datetime{
    if (&time == nil) {
        return [NSString string];
    }
    DDLogInfo(@"日期:%@",Datetime);
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDate *tomorrow, *yesterday;
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    NSString * dateString = [[Datetime description] substringToIndex:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];//设定时间格式
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    NSString *time = [dateFormatter stringFromDate:Datetime];
    if ([dateString isEqualToString:todayString]){
        return [NSString stringWithFormat:@"%@ %@",time,languageStringWithKey(@"今天")];
    } else if ([dateString isEqualToString:yesterdayString]){
        return [NSString stringWithFormat:@"%@ %@",time,languageStringWithKey(@"昨天")];
    }else if ([dateString isEqualToString:tomorrowString]){
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
        NSDateComponents *components = [calendar components: NSCalendarUnitHour|NSCalendarUnitMinute  fromDate:Datetime];
        NSInteger month = [components month];
        NSInteger day = [components day];
        return [NSString stringWithFormat:@"%ld/%ld %@",(long)month,(long)day,time];
    }else{
        return dateString;
    }
}
/**
 /////  和当前时间比较
 ////   1）1分钟以内 显示        :    刚刚
 ////   2）1小时以内 显示        :    X分钟前
 ///    3）今天或者昨天 显示      :    今天 09:30   昨天 09:30
 ///    4) 今年显示              :   09月12日
 ///    5) 大于本年      显示    :    2013/09/09
 **/
+ (NSString *)formateDate:(NSString *)dateString withFormate:(NSString *) formate
{
    
    @try {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formate];
        
        NSDate * nowDate = [NSDate date];
        
        /////  将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
        /////  取当前时间和转换时间两个日期对象的时间间隔
        /////  这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        //// 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
        if (time<=60) {  //// 1分钟以内的
            dateStr = languageStringWithKey(@"刚刚");
        }else if(time<=60*60){  ////  一个小时以内的
            
            int mins = time/60;
            dateStr = [NSString stringWithFormat:@"%d%@",mins,languageStringWithKey(@"分钟前")];
            
        }else if(time<=60*60*24){   //// 在两天内的
            
            [dateFormatter setDateFormat:@"YYYY/MM/dd"];
            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //// 在同一天
                dateStr = [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"今天"),[dateFormatter stringFromDate:needFormatDate]];
            }else{
                ////  昨天
                dateStr = [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"昨天"),[dateFormatter stringFromDate:needFormatDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                NSString *tep = nil;
                if (isEnLocalization) {
                     tep =[NSString stringWithFormat:@"MM-dd"];
                }else{
                     tep =[NSString stringWithFormat:@"MM月dd日"];
                }
               
                [dateFormatter setDateFormat:tep];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
}

+(NSString *)compareDate:(NSDate *)date
{
    if (date == nil) {
        return [NSString string];
    }
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString]){
        return languageStringWithKey(@"今天");
    } else if ([dateString isEqualToString:yesterdayString]){
        return languageStringWithKey(@"昨天");
    }else if ([dateString isEqualToString:tomorrowString]){
        return languageStringWithKey(@"明天");
    }else{
        return dateString;
    }
}

+ (NSString *)speCompareCurDate
{
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    //用[NSDate date]可以获取系统当前时间
     return [dateFormatter stringFromDate:[NSDate date]];
}

//2014-10-5 12:00:00 转成date
+(NSDate*)coverDateWithFormatter:(NSString*)time
{
    return [self coverDateWithFormatter:time format:nil];
}
//date 转化为 2014-10-5 12:00:00
+(NSString *)getStringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+(NSDate *)coverDateWithFormatter:(NSString *)time format:(NSString *)format
{
    if (time == nil || time.length == 0) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if(KCNSSTRING_ISEMPTY(format)) format = @"YYYY-MM-dd HH:mm:ss";
    [formatter setDateFormat:format]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    return [formatter dateFromString:time];
}

+ (BOOL)isBetweenFromTime:(NSDate*)fromTime toTime:(NSDate*)toTime
{
    if (fromTime == nil || toTime == nil) {
        return NO;
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *components_start = [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour|NSCalendarUnitMinute  fromDate:fromTime];
   
    NSInteger hour_start = [components_start hour];
    NSInteger minute_start = [components_start minute];
    
    NSDateComponents *components_end= [calendar components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour|NSCalendarUnitMinute  fromDate:toTime];
    
    NSInteger hour_end = [components_end hour];
    NSInteger minute_end = [components_end minute];
    
    NSDate *date_start = [self getCustomDateWithHour:hour_start minute:minute_start];
    NSDate *date_end = [self getCustomDateWithHour:hour_end minute:minute_end];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date_start]==NSOrderedDescending && [currentDate compare:date_end]==NSOrderedAscending){
        return YES;
    }
    return NO;
}

+ (BOOL)isBetweenFromHour:(NSInteger)fromHour toHour:(NSInteger)toHour
{
    NSDate *date_start = [self getCustomDateWithHour:fromHour minute:0];
    NSDate *date_end = [self getCustomDateWithHour:toHour minute:0];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date_start]==NSOrderedDescending && [currentDate compare:date_end]==NSOrderedAscending){
        return YES;
    }
    return NO;
}
/**
 * @brief 生成当天的某个点（返回的是伦敦时间，可直接与当前时间[NSDate date]比较）
 * @param hour 如hour为“8”，就是上午8:00（本地时间）
 */
+ (NSDate *)getCustomDateWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

// 返回1564128240 十位
- (NSString*)getTimestamp
{
    NSTimeInterval a=[self timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", a];
}
//获取当前时间戳 1564128239742 十三位
+ (NSString *)getCurrentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

// 获取时间戳 1564128239742 十三位
+ (NSString *)getTimeStrWithDate:(NSDate *)date{
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}


+ (NSDate *)getDateWithTimeStamp:(NSString*)timeStamp
{
    if(timeStamp ==nil && timeStamp.length == 0){
        return nil;
    }
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeStamp intValue]];
    return date;
}
//传入时间戳 返回格式 上午 8:00
+ (NSString*)getGregorianWithTimeStamp:(NSString *)timeStamp
{
    if (timeStamp == nil || timeStamp.length == 0) {
        return [NSString string];
    }
    NSDate* date = [NSDate getDateWithTimeStamp:timeStamp];
    NSString* time = [NSDate getGregorianWithdate:date];
    return time;
}

//传入NSDate 返回格式 上午 8:00
+ (NSString*)getGregorianWithdate:(NSDate *)date
{
    if (date == nil) {
        return [NSString string];
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *components = [calendar components: NSCalendarUnitHour|NSCalendarUnitMinute  fromDate:date];
    
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
   
    NSString* AMPM = (hour - 12) > 0 ? languageStringWithKey(@"下午"): languageStringWithKey(@"上午");
    hour = (hour - 12) > 0 ? (hour - 12):hour;
    NSString* time = [NSString stringWithFormat:@"%@ %02d:%02d",AMPM, (int)hour,(int)minute];
    return time;
}
//时间显示内容
+(NSString *)getDateString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
        if (nowCmps.day==myCmps.day) {
            NSString *tep = [NSString stringWithFormat:@"%@ HH:mm:ss",languageStringWithKey(@"今天")];
            dateFmt.dateFormat = tep;
        } else if ((nowCmps.day-myCmps.day)==1) {
            NSString*tep = [NSString stringWithFormat:@"%@ HH:mm:ss",languageStringWithKey(@"昨天")];
            dateFmt.dateFormat = tep;
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFmt stringFromDate:myDate];
}



/*
 *long 型字符串
 *和当前时间比较
 *1）1分钟以内 显示        :    刚刚
 *2）1小时以内 显示        :    X分钟前
 *3）今天或者昨天 显示      :    今天 09:30   昨天 09:30
 *4)  17天之内的 显示       :    几天之内
 *5) 今年显示              :   09月12日
 *6) 大于本年      显示    :    2013/09/09
 *
 **/

+(NSString *)getShowDateLongString:(NSString *)dateString
{
    if(!dateString)
    {
        return nil;
    }
    
    NSTimeInterval tempMilli = [dateString longLongValue];
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDate * nowDate = [NSDate date];
    NSCalendar* systemCalender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents * dateComparison = [systemCalender components:unitFlags
                                                          fromDate:myDate
                                                            toDate:nowDate
                                                           options:NSCalendarWrapComponents];
    // hanwei 同事圈时间规则 30天内显示xx天前，30后的显示年月日
    if (dateComparison.month > 0 || dateComparison.day>30) {
        
        NSString * yearStr = [dateFormatter stringFromDate:myDate];
        NSString *nowYear = [dateFormatter stringFromDate:nowDate];
        
        NSString *tep = nil;
        if (isEnLocalization) {
            tep = [NSString stringWithFormat:@"yyyy-MM-dd"];
        }else{
            tep = [NSString stringWithFormat:@"yyyy年MM月dd日"];
        }
             [dateFormatter setDateFormat:tep];
            return  [dateFormatter stringFromDate:myDate];

        
    }
    else if (dateComparison.day > 0){
        return [NSString stringWithFormat:@"%@%@", @(dateComparison.day),languageStringWithKey(@"天前")];
    }
    else if (dateComparison.hour > 0){
        return [NSString stringWithFormat:@"%@%@", @(dateComparison.hour),languageStringWithKey(@"小时前")];
    }
    else if (dateComparison.minute > 0){
        return [NSString stringWithFormat:@"%@%@", @(dateComparison.minute),languageStringWithKey(@"分钟前")];
    }else{
        return languageStringWithKey(@"刚刚");
    }
    return nil;
}
/*
 *long 型字符串
 *和当前时间比较
 *1）1分钟以内 显示        :    刚刚
 *2）1小时以内 显示        :    X分钟前
 *3）今天或者昨天 显示      :    今天 09:30   昨天 09:30
 *4) 今年显示              :   09月12日
 *5) 大于本年      显示    :    2013/09/09
 **/

+(NSString *)getDateLongString:(NSString *)dateString
{
    @try {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSTimeInterval tempMilli = [dateString longLongValue];
        NSTimeInterval seconds = tempMilli/1000.0;
        NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        NSDate * nowDate = [NSDate date];
        
        /////  将需要转换的时间转换成 NSDate 对象
        /////  取当前时间和转换时间两个日期对象的时间间隔
        /////  这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:myDate];
        
        //// 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
        if (time<=60) {  //// 1分钟以内的
            dateStr = languageStringWithKey(@"刚刚");
        }else if(time<=60*60){  ////  一个小时以内的
            
            int mins = time/60;
            dateStr = [NSString stringWithFormat:@"%d%@",mins,languageStringWithKey(@"分钟前")];
            
        }else if(time<=60*60*24){
            int houses =time/60/60;
            dateStr =[NSString stringWithFormat:@"%d%@",houses,languageStringWithKey(@"小时前")];
            
        }else if(time<=60*60*24*2){   //// 在两天内的
            
            NSString *tep = nil;
            if (isEnLocalization) {
                tep = [NSString stringWithFormat:@"yyyy-MM-dd"];
            }else{
                tep = [NSString stringWithFormat:@"yyyy年MM月dd日"];
            }
            [dateFormatter setDateFormat:tep];
            NSString * need_yMd = [dateFormatter stringFromDate:myDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //// 在同一天
                dateStr = [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"今天"),[dateFormatter stringFromDate:myDate]];
            }else{
                ////  昨天
                dateStr = [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"昨天"),[dateFormatter stringFromDate:myDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:myDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                NSString *tep = nil;
                if (isEnLocalization) {
                    tep = [NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                }else{
                     tep = [NSString stringWithFormat:@"yyyy年MM月dd日 HH:mm:ss"];
                }
               
                [dateFormatter setDateFormat:tep];
                dateStr = [dateFormatter stringFromDate:myDate];
            }else{
                NSString *tep = nil;
                if (isEnLocalization) {
                    tep = [NSString stringWithFormat:@"yyyy-MM-dd"];
                }else{
                    tep = [NSString stringWithFormat:@"yyyy年MM月dd日"];
                }
                [dateFormatter setDateFormat:tep];
                dateStr = [dateFormatter stringFromDate:myDate];
            }
        }
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
}

//时间显示内容 返回星期几 加 yyyy--MM-DD HH:MM
+ (NSString *)getDatePublicString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay| NSCalendarUnitWeekday | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd";
    } else {
        if (nowCmps.day==myCmps.day) {
           
            dateFmt.dateFormat = @"HH:mm";
        } else if ((nowCmps.day-myCmps.day)==1) {
            dateFmt.dateFormat =  [NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"昨天")];
        }else if(myCmps.weekday==2) {
            dateFmt.dateFormat= [NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期一")];
        }else if(myCmps.weekday==3) {
            dateFmt.dateFormat=[NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期二")];
        }else if(myCmps.weekday==4) {
            dateFmt.dateFormat=[NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期三")];
        }
        else if(myCmps.weekday==5) {
            dateFmt.dateFormat=[NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期四")];
        } else if(myCmps.weekday==6) {
            dateFmt.dateFormat=[NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期五")];
        } else if(myCmps.weekday==7) {
            dateFmt.dateFormat=[NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期六")];
        } else if(myCmps.weekday==1) {
            dateFmt.dateFormat=[NSString stringWithFormat:@"%@ HH:mm",languageStringWithKey(@"星期日")];
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
        }
    }
    return [dateFmt stringFromDate:myDate];
}

//返回MM月dd日
+ (NSString*)getGregorianCalendarWithTimeLongStamp:(NSString*)timeStamp
{
    NSTimeInterval tempMilli = [timeStamp longLongValue];
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd";
    } else {
        
        if (isEnLocalization) {
             dateFmt.dateFormat =  [NSString stringWithFormat:@"MM-dd"];
        }else{
             dateFmt.dateFormat =  [NSString stringWithFormat:@"MM月dd%日"];
        }
       
    }
    return [dateFmt stringFromDate:myDate];
}

- (NSString*)getRFC3339Time
{
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [rfc3339DateFormatter stringFromDate:self];
}
+ (NSDate *)dateFromRFC3339TimeString:(NSString *)str{
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [rfc3339DateFormatter dateFromString:str];
}

#pragma mark  - 通话时间计算
+ (NSString *)calculateTime:(NSString *)startTimeString endTime:(NSString *)endTimeString {
    ///强转
    startTimeString = [NSString stringWithFormat:@"%@",startTimeString];
    endTimeString = [NSString stringWithFormat:@"%@",endTimeString];

    NSTimeInterval start = startTimeString.length == 13 ? [startTimeString longLongValue]/1000:[startTimeString longLongValue];
    NSTimeInterval end = endTimeString.length==13 ? [endTimeString longLongValue]/1000:[endTimeString longLongValue];
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:start];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:end];
    NSCalendar *systemCalender = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond;
    NSDateComponents * dateComparison = [systemCalender components:unitFlags fromDate:startDate toDate:endDate options:NSCalendarWrapComponents];
    NSString *timeStr = @"";
    if (dateComparison.hour > 0) {
        timeStr = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)dateComparison.hour, (int)dateComparison.minute, (int)dateComparison.second];
    }else {
        timeStr = [NSString stringWithFormat:@"%02d:%02d", (int)dateComparison.minute, (int)dateComparison.second];
    }
    
    return timeStr;
}

@end
