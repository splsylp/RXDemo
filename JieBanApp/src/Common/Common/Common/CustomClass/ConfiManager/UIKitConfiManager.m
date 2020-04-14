//
//  UIKitConfiManager.m
//  guodiantong
//
//  Created by chaizhiyong on 14-12-8.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import "UIKitConfiManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSDate+Ext.h"
#import <AVFoundation/AVFoundation.h>
#define kMsgSoundStyle    @"msg_sound_style"
#define kMsgSoundaVailableStatus    @"msg_sound_vailable_status"               //声音开启状态
#define kMsgVibrateaVailableStatus    @"msg_vibrate_vailable_status"           //振动开启状态
#define kNewMsgNotiVailableStatus     @"new_msg_noti_vailable_status"          //新消息通知开启状态

#define kBackgroundMsgNotiVailableStatus     @"background_msg_noti_vailable_status"//新消息通知开启状态
#define kBackgroundMsgNotiStartTime     @"background_msg_noti_start_time"//新消息通知开启状态
#define kBackgroundMsgNotiEndTime     @"background_msg_noti_end_time"//新消息通知开启状态

#define kCompanyMsgNotiNoDisturbingVailableStatus     @"company_msg_noti_no_disturbingvailable_status"//新消息通知开启状态


@implementation UIKitConfiManager

+(BOOL)msgVibrateVailableStatus
{
    NSString* status = [[NSUserDefaults standardUserDefaults]objectForKey:kMsgVibrateaVailableStatus];
    if (status && status.length > 0) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;  //未设置默认可用
    }
}


+(void)setMsgVibrateVailableStatus:(BOOL)status
{
    if (status) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kMsgVibrateaVailableStatus];
//        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kMsgVibrateaVailableStatus];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)newMsgNotiVailableStatus
{
    NSString* status = [[NSUserDefaults standardUserDefaults]objectForKey:kNewMsgNotiVailableStatus];
    if (status && status.length > 0) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;  //未设置默认可用
    }
}

+(void)setNewMsgNotiVailableStatus:(BOOL)status
{
    if (status) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kNewMsgNotiVailableStatus];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kNewMsgNotiVailableStatus];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)msgSoundVailableStatus
{
    NSString* status = [[NSUserDefaults standardUserDefaults]objectForKey:kMsgSoundaVailableStatus];
    if (status && status.length > 0) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
       return YES;  //未设置默认可用
    }
}

+(void)setMsgSoundVailableStatus:(BOOL)status
{
    if (status) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kMsgSoundaVailableStatus];
//        AudioServicesPlaySystemSound (1331);//声音
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kMsgSoundaVailableStatus];
//        AudioServicesDisposeSystemSoundID(1336);
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (NSString*)msgNotifSoundId
{
   NSString* sid = [[NSUserDefaults standardUserDefaults]objectForKey:kMsgSoundStyle];
    if (sid && sid.length > 0) {
        return sid;
    }
   return [NSString string];
}

+ (void)setNewMsgNotifSoundId:(NSString*)sid
{
     [[NSUserDefaults standardUserDefaults]setObject:sid forKey:kMsgSoundStyle];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)playSystemSound:(NSString*)systemSoundId
{
    if ([UIKitConfiManager backgroundNotifiVailableAllday]) { //需要整天提醒
        if (systemSoundId && systemSoundId.length > 0) {
            SystemSoundID id = [systemSoundId intValue];
            AudioServicesPlaySystemSound(id);
        }else{
            SystemSoundID id = 1012;
            AudioServicesPlaySystemSound(id);
        }
    }else{
        NSString* startTime = [UIKitConfiManager backgroundNotifiSatrtTime];
        if (startTime && startTime.length > 0) {
            BOOL isExist = [NSDate isBetweenFromTime:[NSDate getDateWithTimeStamp:startTime] toTime:[NSDate getDateWithTimeStamp:[UIKitConfiManager backgroundNotifiEndTime]]];
            if(isExist){
                if (systemSoundId && systemSoundId.length > 0) {
                    SystemSoundID id = [systemSoundId intValue];
                    AudioServicesPlaySystemSound(id);
                }
            }
        }else{
            BOOL isExist = [NSDate isBetweenFromHour:8 toHour:23];
            if(isExist){
                if (systemSoundId && systemSoundId.length > 0) {
                    SystemSoundID id = [systemSoundId intValue];
                    AudioServicesPlaySystemSound(id);
                }
            }
        }
    }
    
}

+ (void)playSystemVibrate{
     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


//后台消息提醒时段是否是整天
+ (BOOL)backgroundNotifiVailableAllday
{
    NSString* status = [[NSUserDefaults standardUserDefaults]objectForKey:kBackgroundMsgNotiVailableStatus];
    if (status && status.length > 0) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;  //未设置默认可用
    }
}

+(void)setBackgroundNotifiVailableAllday:(BOOL)status
{
    if (status) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kBackgroundMsgNotiVailableStatus];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kBackgroundMsgNotiVailableStatus];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)backgroundNotifiSatrtTime
{
    NSString*startTime = [[NSUserDefaults standardUserDefaults]objectForKey: kBackgroundMsgNotiStartTime];
    if (startTime && startTime.length > 0) {
        return startTime;
    }
    return [NSString string];
}

+ (void)setBackgroundNotifiStartTime:(NSString*)time
{
    if (time && time.length > 0) {
        [[NSUserDefaults standardUserDefaults]setObject:time forKey:kBackgroundMsgNotiStartTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


+(NSString*)backgroundNotifiEndTime
{
    NSString*endTime = [[NSUserDefaults standardUserDefaults]objectForKey: kBackgroundMsgNotiEndTime];
    if (endTime && endTime.length > 0) {
        return endTime;
    }
    return [NSString string];
}

+ (void)setBackgroundNotifiEndTime:(NSString*)time
{
    if (time && time.length > 0) {
        [[NSUserDefaults standardUserDefaults]setObject:time forKey:kBackgroundMsgNotiEndTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(BOOL)companyNotifiNoDisturbingVailable
{
    NSString* status = [[NSUserDefaults standardUserDefaults]objectForKey:kCompanyMsgNotiNoDisturbingVailableStatus];
    if (status && status.length > 0) {
        if ([status isEqualToString:@"1"]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;  //未设置默认可用
    }}

+ (void)setCompanyNotifiNoDisturbingVailable:(BOOL)status
{
    if (status) {
        [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:kCompanyMsgNotiNoDisturbingVailableStatus];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:kCompanyMsgNotiNoDisturbingVailableStatus];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isBetweenCompanyNotifiTimes
{
    return [UIKitConfiManager isBetweenCompanyNotifiTimes];
}
@end
