//
//  ThemeManager.h
//  UserCenter
//
//  Created by zhangmingfei on 2016/11/29.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

//主题发生改变的通知 
UIKIT_EXTERN  NSString *const NotificationName_ThemeHasChanged;

@interface ThemeManager : NSObject

#define ThemeImage(name)        [ThemeManager imageWithName:name]
#define ThemeImagePath(key)     [ThemeManager imagePathWithKey:key]
#define ThemeGifImagePath(key)  [ThemeManager gifImagePathWithKey:key]
#define ThemeColor              [ThemeManager themeColor]
#define ThemeFont(key)          [ThemeManager fontWithKey:key];

+ (ThemeManager *)sharedInstance;


+ (UIImage *)imageWithName:(NSString *)name;

/*key对应的value的值格式：
 #RGB、#ARGB 、#RRGGBB 、#AARRGGBB 、R,G,B,A
 */
+ (UIColor *)themeColor;

@end
