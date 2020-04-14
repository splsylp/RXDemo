//
//  ThemeManager.m
//  UserCenter
//
//  Created by zhangmingfei on 2016/11/29.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ThemeManager.h"

NSString * const NotificationName_ThemeHasChanged = @"NotificationName_ThemeHasChanged";

@implementation ThemeManager

+ (ThemeManager *)sharedInstance {
    static ThemeManager *ThemeManager_sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ThemeManager_sharedInstance = [[self alloc] init];
    });
    return ThemeManager_sharedInstance;
}

+ (UIImage *)imageWithName:(NSString *)name {
    //偏好设置读取 用户选择的类型 没有就是默认
    NSString *themeType = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeType"];
    if (!themeType) {
        themeType = @"default";
    }
    
    if ([themeType isEqualToString:@"default"]) {
        return [UIImage imageNamed:name];
        
    } else if ([themeType isEqualToString:@"red"]) {
        //换bundle
    } else if ([themeType isEqualToString:@"blue"]) {
        //换bundle
    }
    return nil;
}

/*key对应的value的值格式：
 #RGB、#ARGB 、#RRGGBB 、#AARRGGBB 、R,G,B,A
 */
+ (UIColor *)themeColor {
    
    //偏好设置读取 用户选择的类型 没有就是默认
    NSString *themeType = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeType"];
    if (!themeType) {
        themeType = @"default";
    }
    //根据用户选择的类型 去获取plist里存储的颜色值
    NSString *themePath = [[NSBundle mainBundle] pathForResource:@"themeColor.plist" ofType:nil];
    NSDictionary *themeDict = [NSDictionary dictionaryWithContentsOfFile:themePath];
    NSString *colorString = themeDict[themeType];
    
    
    if ([colorString hasPrefix:@"#"]) {
        return [ThemeManager colorWithHex:colorString];
    }
    else {
        NSArray *colorList = [colorString componentsSeparatedByString:@","];
        
        if ([colorList count] > 3) {
            CGFloat r = [[colorList objectAtIndex:0] floatValue];
            CGFloat g = [[colorList objectAtIndex:1] floatValue];
            CGFloat b = [[colorList objectAtIndex:2] floatValue];
            CGFloat a = [[colorList objectAtIndex:3] floatValue];
            
            if (r>1.0f) {
                r= r/255.0f;
            }
            
            if (g>1.0f) {
                g= g/255.0f;
            }
            
            if (b>1.0f) {
                b= b/255.0f;
            }
            
            return [UIColor colorWithRed:r
                                   green:g
                                    blue:b
                                   alpha:a];
        }
        else {
#ifdef DEBUG
            NSLog(@"warning:【主题加载】颜色：颜色值格式错误，格式应该是#FFFFFF或者R,G,B,A 例如134,135,136,1.0");
#endif
            return nil;
        }
    }
}

+ (UIColor *) colorWithHex: (NSString *) hexString {
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [ThemeManager colorComponentFrom: colorString start: 0 length: 1];
            
            green = [ThemeManager colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [ThemeManager colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [ThemeManager colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [ThemeManager colorComponentFrom: colorString start: 1 length: 1];
            
            green = [ThemeManager colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [ThemeManager colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [ThemeManager colorComponentFrom: colorString start: 0 length: 2];
            
            green = [ThemeManager colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [ThemeManager colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [ThemeManager colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [ThemeManager colorComponentFrom: colorString start: 2 length: 2];
            
            green = [ThemeManager colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [ThemeManager colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            
            break;
            
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}


@end
