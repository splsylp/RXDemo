//
//  YXPExtension.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXPExtension : NSObject

@end

@interface KKAuthorizedManager : NSObject


/*
 检查是否授权【通讯录】
 #import <AddressBook/AddressBook.h>
 */
+ (BOOL)isAddressBookAuthorized_ShowAlert:(BOOL)showAlert;

/*
 检查是否授权【相册】
 #import <AssetsLibrary/AssetsLibrary.h>
 */
+ (BOOL)isAlbumAuthorized_ShowAlert:(BOOL)showAlert;

/*
 检查是否授权【相机】
 #import <AVFoundation/AVFoundation.h>
 */
+ (BOOL)isCameraAuthorized_ShowAlert:(BOOL)showAlert;


/*
 检查是否授权【地理位置】
 #import <MapKit/MapKit.h>
 */
+ (BOOL)isLocationAuthorized_ShowAlert:(BOOL)showAlert;

/*
 检查是否授权【麦克风】
 #import <AVFoundation/AVFoundation.h>
 */
+ (BOOL)isMicrophoneAuthorized_ShowAlert:(BOOL)showAlert;

/*
 检查是否授权【通知中心】
 */
+ (BOOL)isNotificationAuthorized;


@end

#pragma mark ==================================================
#pragma mark == NSData
#pragma mark ==================================================
//#import <CommonCrypto/CommonDigest.h>

typedef void(^KKImageConvertImageOneCompletedBlock)(NSData *imageData,NSInteger index);
typedef void(^KKImageConvertImageAllCompletedBlock)();

@interface NSData (KKNSDataExtension)

/**
 @brief 将图片压缩到指定大小
 @discussion 将图片压缩到指定大小
 @param imageArray UIImage数组
 @param imageDataSize 需要压缩到的图片数据大小范围值(单位KB)，比如100KB
 @param completedOneBlock 压缩一条数据完成回调block
 @param completedAllBlock 压缩所有数据完成回调block
 */
+ (void)convertImage:(NSArray*)imageArray
          toDataSize:(CGFloat)imageDataSize
convertImageOneCompleted:(KKImageConvertImageOneCompletedBlock)completedOneBlock
KKImageConvertImageAllCompletedBlock:(KKImageConvertImageAllCompletedBlock)completedAllBlock;
@end

#pragma mark ==================================================
#pragma mark ==NSDate
#pragma mark ==================================================

#define KKDateFormatter01 @"yyyy-MM-dd HH:mm:ss"
#define KKDateFormatter02 @"yyyy-MM-dd HH:mm"
#define KKDateFormatter03 @"yyyy-MM-dd HH"
#define KKDateFormatter04 @"yyyy-MM-dd"
#define KKDateFormatter05 @"yyyy-MM"
#define KKDateFormatter06 @"MM-dd"
#define KKDateFormatter07 @"HH:mm"

@interface NSDate (KKNSDateExtension)

/*日前*/
- (NSUInteger)day;

/*星期几*/
- (NSUInteger)weekday;

/*月份*/
- (NSUInteger)month;

/*年份*/
- (NSUInteger)year;

/*获取当前月有多少天*/
- (NSUInteger)numberOfDaysInMonth;

/*获取当前月有多少周*/
- (NSUInteger)weeksOfMonth;

/*获取前一天（昨天）*/
- (NSDate *)previousDate;

/*获取下一天（明天）*/
- (NSDate *)nextDate;

/*获取当前周的第一天*/
- (NSDate *)firstDayOfWeek;

/*获取当前周的最后一天*/
- (NSDate *)lastDayOfWeek;

/*获取下周的第一天*/
- (NSDate *)firstDayOfNextWeek;

/*获取下周的最后一天*/
- (NSDate *)lastDayOfNextWeek;

/*获取当前月的第一天*/
- (NSDate *)firstDayOfMonth;

/*获取当前月的最后一天*/
- (NSDate *)lastDayOfMonth;

/*获取当前月的第一天是星期几*/
- (NSUInteger)weekdayOfFirstDayInMonth;

/*获取上月的第一天*/
- (NSDate *)firstDayOfPreviousMonth;

/*获取下月的第一天*/
- (NSDate *)firstDayOfNextMonth;

/*获取当前季度的第一天*/
- (NSDate *)firstDayOfQuarter;

/*获取当前季度的最后一天*/
- (NSDate *)lastDayOfQuarter;

- (NSDate *)theDayOfNextMonth;

- (NSDate *)theDayOfNextWeek;


#pragma mark == NSDate 字符串方法

//根据格式获取当前时间
+ (NSString*)getStringWithFormatter:(NSString*)formatterString;

/**
 oldDateString：旧日期字符串
 oldFormatterString： oldDateString的格式
 newFormatterString： 要返回的日期字符串的格式
 */
+ (NSString*)getStringFromOldDateString:(NSString*)oldDateString
                       withOldFormatter:(NSString*)oldFormatterString
                           newFormatter:(NSString*)newFormatterString;

/**
 date：日期
 formatterString： 要返回的日期字符串的格式
 */
+ (NSString*)getStringFromDate:(NSDate*)date dateFormatter:(NSString*)formatterString;

/**
 string：日期字符串
 formatterString： string的格式
 */
+ (NSDate*)getDateFromString:(NSString*)string dateFormatter:(NSString*)formatterString;

/**
 oldDateString：旧时间字符串
 oldFormatterString： oldDateString的格式
 defaultFormatterString： 要返回的日期字符串的格式
 返回 @"刚刚";@"%d秒前";@"%d分钟前";@"%d小时前";或者根据defaultFormatterString返回的字符串
 */
+ (NSString*)timeAwayFromNowWithOldDateString:(NSString*)oldDateString oldFormatterString:(NSString*)oldFormatterString defaultFormatterString:(NSString*)defaultFormatterString;

/**
 oldDate：旧时间
 defaultFormatterString： 要返回的日期字符串的格式
 返回 @"刚刚";@"%d秒前";@"%d分钟前";@"%d小时前";或者根据defaultFormatterString返回的字符串
 */
+ (NSString*)timeAwayFromNowWithOldDate:(NSDate*)oldDate defaultFormatterString:(NSString*)defaultFormatterString;

/**
 date1String01：时间字符串1
 date1String02：时间字符串2
 formatter01： date1String01的格式
 formatter02： date1String02的格式
 */
+ (BOOL)isString:(NSString*)date1String01 earlierThanString:(NSString*)date1String02 formatter01:(NSString*)formatter01 formatter02:(NSString*)formatter02;

/**
 date1String01：时间字符串1
 date02：时间2
 formatter02： date1String02的格式
 */
+ (BOOL)isString:(NSString*)date1String01 earlierThanDate:(NSDate*)date02 formatter01:(NSString*)formatter01;

/**
 date01：时间1
 date1String02：时间字符串2
 formatter02： date1String02的格式
 */
+ (BOOL)isDate:(NSDate*)date01 earlierThanString:(NSString*)dateString02 formatter02:(NSString*)formatter02;

/**
 date01：时间1
 date01：时间2
 */
+ (BOOL)isDate:(NSDate*)date01 earlierThanDate:(NSDate*)date02;

/**
 判断时间是否超过N天了
 date01：需要判断的日期
 days：超过N天了
 */
+ (BOOL)isDate:(NSDate*)date01 beforeNDays:(NSUInteger)days;

/**
 判断时间是否超过N天了
 date01：需要判断的日期
 formatterString：date01的格式
 days：超过N天了
 */
+ (BOOL)isDateString:(NSString*)dateString formatter:(NSString*)formatterString afterNDay:(NSUInteger)days;

@end

#pragma mark ==================================================
#pragma mark ==NSDateFormatter
#pragma mark ==================================================

@interface NSDateFormatter (KKNSDateFormatterExtension)

/**
 返回：星期几
 */
- (NSString *)weekday:(NSDate *)date;

/**
 返回：几日
 */
- (NSString *)day:(NSDate *)date;

/**
 返回：几月
 */
- (NSString *)month:(NSDate *)date;

/**
 返回：多少年
 */
- (NSString *)year:(NSDate *)date;


@end

#pragma mark ==================================================
#pragma mark ==UIView
#pragma mark ==================================================


#define ApplicationFrame  [[UIScreen mainScreen] applicationFrame]
#define ApplicationSize   [[UIScreen mainScreen] applicationFrame].size
#define ApplicationWidth  [[UIScreen mainScreen] applicationFrame].size.width
#define ApplicationHeight [[UIScreen mainScreen] applicationFrame].size.height
#define ViewWidth(view)  view.bounds.size.width
#define ViewHeight(view) view.bounds.size.height
#define ViewCenter(view) CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2.0)

@interface UIView (KKUIViewExtension)

@property (nonatomic,retain) id tagInfo;

/*快照*/
- (UIImage *)snapshot;

/*清除背景颜色*/
- (void)clearBackgroundColor;

/*设置背景图片*/
- (void)setBackgroundImage:(UIImage *)image;

/*设置View层顺序*/
- (void)setIndex:(NSInteger)index;

/*设置为最顶层View*/
- (void)bringToFront;

/*设置为最底层View*/
- (void)sendToBack;

/*设置边框颜色 和 边框宽度*/
- (void)setBorderColor:(UIColor *)color width:(CGFloat)width;

/*设置圆角*/
- (void)setCornerRadius:(CGFloat)radius;

/*设置外阴影*/
- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset blurRadius:(CGFloat)blurRadius;

- (UIActivityIndicatorView *)activityIndicatorView;

- (UIViewController *)viewController;

typedef enum{
    UIViewGradientColorDirection_TopBottom = 1,//从上到下
    UIViewGradientColorDirection_BottomTop = 2,//从下到上
    UIViewGradientColorDirection_LeftRight = 3,//从左到右
    UIViewGradientColorDirection_RightLeft = 4,//从右到左
}UIViewGradientColorDirection;
//设置渐变色的View
- (void)setBackgroundColorFromColor:(UIColor*)startUIColor toColor:(UIColor*)endUIColor direction:(UIViewGradientColorDirection)direction;

//截图当前view成图片
-(UIImage *)getImageFromSelf;


//=================设置遮罩相关=================
@property (nonatomic,retain)UIBezierPath *bezierPath;
- (void)setMaskWithPath:(UIBezierPath*)path;
- (void)setMaskWithPath:(UIBezierPath*)path withBorderColor:(UIColor*)borderColor borderWidth:(float)borderWidth;
- (BOOL)containsPoint:(CGPoint)point;
//=================设置遮罩相关=================

@end


#pragma mark ==================================================
#pragma mark ==UIImageView
#pragma mark ==================================================
@interface UIImageView (Extension)

//可以自动识别图片类型 并支持显示Gif动态图片
- (void)showImageData:(NSData*)imageData;

//可以自动识别图片类型 并支持显示Gif动态图片
- (void)showImageData:(NSData*)imageData inFrame:(CGRect)rect;

@end


#pragma mark ==================================================
#pragma mark ==UIImage
#pragma mark ==================================================
@interface UIImage (KKUIImageExtension)
#define UIImageExtensionType_PNG  @"png"
#define UIImageExtensionType_BMP  @"bmp"
#define UIImageExtensionType_JPG  @"jpeg"
#define UIImageExtensionType_GIF  @"gif"
#define UIImageExtensionType_TIFF @"tiff"

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/*返回：
 @"image/jpeg";
 @"image/bmp";
 @"image/png";
 @"image/gif";
 @"image/tiff";
 */
+ (NSString *) contentTypeForImageData:(NSData *)data;

/*返回：
 @"png"
 @"bmp"
 @"jpeg"
 @"gif"
 @"tiff"
 */
+ (NSString *) contentTypeExtensionForImageData:(NSData *)data;

- (UIImage*)convertImageToScale:(double)scale;

- (UIImage *)watermarkImage:(NSString *)text;

@end

#pragma mark ==================================================
#pragma mark ==NSString
#pragma mark ==================================================
@interface NSDictionary (YXPStringExtension)

//转成String类型
-(NSString*)getStringForKey:(NSString*)key;

@end
#pragma mark ==================================================
#pragma mark ==NSBundle
#pragma mark ==================================================
@interface NSBundle (KKNSBundleExtension)

/*Bundle相关*/
+ (NSString *)bundleIdentifier;
+ (NSString *)bundleBuildVersion;
+ (NSString *)bundleVersion;
+ (float)bundleMiniumOSVersion;
+ (NSString *)bundlePath;

/*编译信息相关*/
+ (int)buildXcodeVersion;

/*是否开启了推送通知*/
+ (BOOL)isOpenPushNotification;


/*路径相关*/
+ (NSString *)homeDirectory;
+ (NSString *)documentDirectory;
+ (NSString *)libaryDirectory;
+ (NSString *)tmpDirectory;
+ (NSString *)temporaryDirectory;
+ (NSString *)cachesDirectory;

@end

#pragma mark ==================================================
#pragma mark ==KKUIButtonExtension
#pragma mark ==================================================
typedef NS_ENUM(NSInteger, ButtonContentAlignment) {
    ButtonContentAlignmentLeft = 1,
    ButtonContentAlignmentCenter = 2,
    ButtonContentAlignmentRight = 3,
} ;

typedef NS_ENUM(NSInteger, ButtonContentLayoutModal) {
    ButtonContentLayoutModalVertical = 1,//垂直对齐
    ButtonContentLayoutModalHorizontal = 2,//水平对齐
} ;

typedef NS_ENUM(NSInteger, ButtonContentTitlePosition) {
    ButtonContentTitlePositionBefore = 1,//标题在图片的左边或者上边
    ButtonContentTitlePositionAfter = 2,//标题在图片的右边或者下边
} ;

@interface UIButton (Extension)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)controlState;

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state contentMode:(UIViewContentMode)contentMode;

/**
 设置UIButton的图片和标题的对其方式
 contentAlignment //整体左、中、右对齐
 contentLayoutModal //图片与标题的布局方式，上下布局、左右并排布局
 contentTitlePosition //标题是否在图片的前面
 aSpace 图片与标题之间是否留间隙，间隙大小
 aEdgeInsets 整体靠左、靠右对其的时候，是否要紧靠边缘。当aEdgeInsets的left、right为0的时候就是紧靠边缘
 */
- (void)setButtonContentAlignment:(ButtonContentAlignment)contentAlignment
         ButtonContentLayoutModal:(ButtonContentLayoutModal)contentLayoutModal
       ButtonContentTitlePosition:(ButtonContentTitlePosition)contentTitlePosition
        SapceBetweenImageAndTitle:(CGFloat)aSpace
                       EdgeInsets:(UIEdgeInsets)aEdgeInsets;

@end

#pragma mark ==================================================
#pragma mark ==UITableViewCell
#pragma mark ==================================================
@interface UITableViewCell (Extesion)

- (void)setBackgroundViewColor:(UIColor *)color;

- (void)setBackgroundViewImage:(UIImage *)image;

- (void)setSelectedBackgroundViewColor:(UIColor *)color;

- (void)setSelectedBackgroundViewImage:(UIImage *)image;

@end

#pragma mark ==================================================
#pragma mark ==NSDictionary
#pragma mark ==================================================

@interface NSDictionary (KKNSDictionaryExtension)

+ (BOOL)isDictionaryNotEmpty:(id)dictionary;

+ (BOOL)isDictionaryEmpty:(id)dictionary;

/**
 从字典里获取BOOL值
 */
- (BOOL)boolValueForKey:(id)key;

/**
 从字典里获取int值
 */
- (int)intValueForKey:(id)key;

/**
 从字典里获取NSInteger值
 */
- (NSInteger)integerValueForKey:(id)key;

/**
 从字典里获取float值
 */
- (float)floatValueForKey:(id)key;

/**
 从字典里获取double值
 */
- (double)doubleValueForKey:(id)key;

/*
 获取NSString对象，有可能返回nil
 */
- (NSString *)stringValueForKey:(id)aKey;

/*
 获取NSString对象，不可能返回nil
 */
- (NSString*)validStringForKey:(id)aKey;

/*
 获取NSDictionary对象，有可能返回nil
 */
- (NSDictionary *)dictionaryValueForKey:(id)aKey;

/*
 获取NSDictionary对象，不可能返回nil
 */
- (NSDictionary*)validDictionaryForKey:(id)aKey;

/*
 获取NSArray对象，有可能返回nil
 */
- (NSArray *)arrayValueForKey:(id)aKey;

/*
 获取NSArray对象，不可能返回nil
 */
- (NSArray*)validArrayForKey:(id)aKey;

/**
 从字典里获取有价值的对象
 如果自己是nil或者key是nil,则返回值为nil，否则都会有返回值（至少都是@“”）,
 */
//- (id)valuableObjectForKey:(id)aKey;

/**
 @brief 转换成json字符串
 */
- (NSString *)translateToJSONString;

/**
 @brief json字符串转换成对象
 */
+ (NSDictionary *)dictionaryFromJSONData:(NSData *)aJsonData;

@end

#pragma mark ==================================================
#pragma mark ==UIFont
#pragma mark ==================================================
@interface UIFont (KKUIFontExtension)

+ (CGSize)sizeOfFont:(UIFont*)aFont;

@end

#pragma mark ==================================================
#pragma mark ==NSString
#pragma mark ==================================================
//#import <CommonCrypto/CommonDigest.h>
/* 刘波 */
#define URL_EXPRESSION @"[hH][tT][tT][pP][sS]?://[a-zA-Z0-9+\\-*/`!@#$%^&()_~,.?<>:;\"\'\\[\\]\\{\\}_=|€£¥•‰]*"

/* 杨峰 */
//#define URL_EXPRESSION @"((https?|ftp|gopher|telnet|file|notes|ms-help):((//)|(\\\\))+[\\w\\d:#@%/;$()~_?\\+-=\\\\.&]*"

/* 新浪 */
//#define URL_EXPRESSION @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])"

@interface NSString (KKNSStringExtension)

+ (BOOL)isStringNotEmpty:(id)string;

+ (BOOL)isStringEmpty:(id)string;
//去掉字符串中的所有空白（Tab、Space、换行......）
- (NSString *)trimWhitespace;

//去掉字符串首尾的空格
-(NSString*)trimLeftAndRightSpace;

/*去除空格*/
-(NSString*)trimAllSpace;

//去掉数字
- (NSString*)trimNumber;

/*去除html标签*/
- (NSString *)trimHTMLTag;

- (BOOL)isEmail;

- (BOOL)isWebUrl;

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width;

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size;

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width inset:(UIEdgeInsets)inset;

- (CGSize)sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width inset:(UIEdgeInsets)inset lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)size inset:(UIEdgeInsets)inset lineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
