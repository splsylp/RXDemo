//
//  LanguageTools.m
//  TestSDK
//
//  Created by tianao on 2017/9/19.
//  Copyright © 2017年 田傲. All rights reserved.
//

#import "LanguageTools.h"


#define Language_Key @"RL_languageKey"



@implementation LanguageTools

+ (id)sharedInstance{
    static dispatch_once_t onceToken;
    static LanguageTools *tool;
    dispatch_once(&onceToken, ^{
        tool = [[LanguageTools alloc]init];
    });
    return  tool;
    
}
// 根据语言名获取bundle
- (NSBundle *)bundle
{
    NSString * setLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:Language_Key];
    //默认是简体中文
    if (setLanguage == nil || [setLanguage isEqualToString:@"zh-Hans-CN"]) {
        setLanguage = Chinese_Simple;
    }
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:setLanguage ofType:@"lproj"];
    
    return [NSBundle bundleWithPath:bundlePath];
}
// 根据key获取value
- (NSString *)getStringForKey:(NSString *)key
{
    NSBundle * bundle = [[LanguageTools sharedInstance] bundle];
    if (bundle) {
        NSString * valueString = NSLocalizedStringFromTableInBundle(key, @"Localizable", bundle, @"HelloWord");
        if (!KCNSSTRING_ISEMPTY(valueString)) {
            return valueString;
        }
        DDLogInfo(@"\n********** have not add key **********\n \"%@\" = \"%@\" \n****************************",key,key);
        return NSLocalizedString(key, @"HelloWord");
    }
    return NSLocalizedString(key, @"HelloWord");
}

- (void)setNewLanguage:(NSString *)language
{
    NSString * setLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:Language_Key];
    if ([language isEqualToString:setLanguage]) {
        return;
    }
    // 简体中文
    else if ([language isEqualToString:Chinese_Simple]) {
        [[NSUserDefaults standardUserDefaults] setObject:Chinese_Simple forKey:Language_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // 繁体中文
    else if ([language isEqualToString:Chinese_Traditional]) {
        [[NSUserDefaults standardUserDefaults] setObject:Chinese_Traditional forKey:Language_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // 英文
    else if ([language isEqualToString:English_US]) {
        [[NSUserDefaults standardUserDefaults] setObject:English_US forKey:Language_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 韩语
    else if ([language isEqualToString:Korean]) {
        [[NSUserDefaults standardUserDefaults] setObject:Korean forKey:Language_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


@end
