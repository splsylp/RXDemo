//
//  ChatTools.m
//  Chat
//
//  Created by zhangmingfei on 2016/10/28.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatTools.h"

@implementation ChatTools

//时间显示内容 沟通列表 服务号
+(NSString *)getSessionDateDisplayString:(long long) miliSeconds{
    
    if(miliSeconds==1) {
        return  @"";
    }
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay| NSCalendarUnitWeekday | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDate *nowDate = [NSDate date];
    NSDateComponents *nowCmps = [calendar components:unit fromDate:nowDate];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {//不同年
        dateFmt.dateFormat = @"yyyy/MM/dd";
    } else {
        if (nowCmps.month == myCmps.month) {//同一个月的
            if (nowCmps.day==myCmps.day) {//当天的显示小时和分钟
                dateFmt.dateFormat=@"HH:mm";
                return [dateFmt stringFromDate:myDate];
            }else if((nowCmps.day-myCmps.day)==1) {//相差一天的显示昨天
                return languageStringWithKey(@"昨天");
            }
        }else {//不是同一个月的。这种情况肯定不存在同一天的，可能存在昨天
        }
        
        if (nowDate.timeIntervalSince1970 - myDate.timeIntervalSince1970<7*24*60*60) {//一周内
            if (nowCmps.weekday-myCmps.weekday == 1 ) {
                return languageStringWithKey(@"昨天");
            }else if(myCmps.weekday==2) {
                return languageStringWithKey(@"星期一");
            }else if(myCmps.weekday==3) {
                return languageStringWithKey(@"星期二");
            }else if(myCmps.weekday==4) {
                return languageStringWithKey(@"星期三");
            }else if(myCmps.weekday==5) {
                return languageStringWithKey(@"星期四");
            } else if(myCmps.weekday==6) {
                return languageStringWithKey(@"星期五");
            } else if(myCmps.weekday==7) {
                return languageStringWithKey(@"星期六");
            } else if(myCmps.weekday==1) {
                return languageStringWithKey(@"星期日");
            }
        }else {
            dateFmt.dateFormat = @"MM/dd";
        }
    }
    return [dateFmt stringFromDate:myDate];
}

//时间显示内容 聊天界面 详情界面显示时间
+(NSString *)getDateDisplayString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
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
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"HH:mm";
        } else if ((nowCmps.day-myCmps.day)==1) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"昨天"),[dateFmt stringFromDate:myDate]];
        }else if(myCmps.weekday==2) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期一"),[dateFmt stringFromDate:myDate]];
        }else if(myCmps.weekday==3) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期二"),[dateFmt stringFromDate:myDate]];
        }else if(myCmps.weekday==4) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期三"),[dateFmt stringFromDate:myDate]];
        }else if(myCmps.weekday==5) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期四"),[dateFmt stringFromDate:myDate]];
        } else if(myCmps.weekday==6) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期五"),[dateFmt stringFromDate:myDate]];
        } else if(myCmps.weekday==7) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期六"),[dateFmt stringFromDate:myDate]];
        } else if(myCmps.weekday==1) {
            dateFmt.dateFormat = @"HH:mm";
            return [NSString stringWithFormat:@"%@ %@",languageStringWithKey(@"星期日"),[dateFmt stringFromDate:myDate]];
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm";
        }
    }
    return [dateFmt stringFromDate:myDate];
}

//时间显示内容
+ (NSString *)getDateDisplayStringWithSession:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.day==myCmps.day) {
        dateFmt.dateFormat=@"HH:mm";
    } else if((nowCmps.day-myCmps.day)==1) {
        return languageStringWithKey(@"昨天");
    }else if((nowCmps.day-myCmps.day)==2) {
        return languageStringWithKey(@"前天");
    }else if(nowCmps.year != myCmps.year){
        dateFmt.dateFormat = @"yyyy-MM-dd";
    }  else {
        dateFmt.dateFormat = @"MM-dd";
    }
    return [dateFmt stringFromDate:myDate];
}


#pragma mark 获取在线状态
+ (NSString*)getDeviceWithType:(ECDeviceType)type{
    switch (type) {
        case ECDeviceType_AndroidPhone:
            return languageStringWithKey(@"Android");
            
        case ECDeviceType_iPhone:
            return languageStringWithKey(@"iPhone");
            
        case ECDeviceType_iPad:
            return languageStringWithKey(@"iPad");
            
        case ECDeviceType_AndroidPad:
            return languageStringWithKey(@"Android Pad");
            
        case ECDeviceType_PC:
            return @"Windows";
            
        case ECDeviceType_Web:
            return @"Web";
            
        case ECDeviceType_Mac:
            return @"Mac";
            
        default:
            return languageStringWithKey(@"未知");
    }
}

+ (NSString*)getNetWorkWithType:(ECNetworkType)type{
    switch (type) {
        case ECNetworkType_WIFI:
            return @"WIFI";
            
        case ECNetworkType_4G:
            return @"4G";
            
        case ECNetworkType_3G:
            return @"3G";
            
        case ECNetworkType_GPRS:
            return @"GRPS";
            
        case ECNetworkType_LAN:
            return @"Internet";
        default:
            return languageStringWithKey(@"其他");
    }
}


+ (CGFloat)isIphone6PlusProPortionHeight{
    if(iPhone6plus){
        return kScreenHeight/667;
    }
    return 1.0;
}

/**
 @brief 根据主题颜色渲染图片
 */
+ (UIImage *)getThemeColorImage:(UIImage *)image withColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end
