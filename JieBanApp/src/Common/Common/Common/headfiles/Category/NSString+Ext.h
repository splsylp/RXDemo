//
//  NSString+Ext.h
//  Lafaso
//
//  Created by yuxuanpeng MINA on 14-7-15.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

/**
 *  MD5加密
 *
 *  @return 加密后字符串
 */
- (NSString *)MD5EncodingString;

- (CGSize) sizeForFont:(UIFont*)font
     constrainedToSize:(CGSize)constraint
         lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

@interface NSString (base64)

/**
 *  base64加密
 *
 *  @return 加密有字符串
 */
- (NSString *)base64EncodingString;

/**
 *  base64解密
 *
 *  @return 字符串
 */
- (NSString *)base64DecodingString;

+(NSString *)uncompressStr:(NSString *)jsonString;

@end

@interface NSString (WebUrl)

/**
 *  validateUrl网址检测
 *
 *  @return YES /NO
 */
+(BOOL)regularWebsiteIsvalid:(NSString *)validateUrl;


//网址正则表达式匹配
+(NSMutableArray*) regularExpressionMatchWebsiteWithString:(NSString *)searchText;

@end


@interface NSString (NSDictionary)

- (NSMutableDictionary*)coverDictionary;

- (NSMutableDictionary*)coverToDictionary;

/**
 @brief json字符串转换成对象
 */
- (NSDictionary*)dictionaryFromJSONString;
/// eagle json 转 字典
-(NSDictionary *)getDictFromJsonString;
//去掉空格和换行
+ (NSString *)returnJSONStringWithDictionary:(id)dictionary;

//jsonstring to dictionary
- (NSDictionary *)dictionaryWithJsonString;
@end

@interface NSString (NSArray)

- (id)arrayWithJsonString;

@end

@interface NSString (SHA1)

/**
 *  SHA1加密
 *
 *  @param key 密钥
 *
 *  @return
 */
//- (NSData *)HMACSHA1EncodeDataWithKey:(NSString *)key;

@end

@interface NSString (AES)

#define TRIPLEDESKEY @"hfbank2016101011"

/* ase加密处理
 * baseString base加密后的字符串
 * encodedKey 加密的秘钥
 **/
+ (NSString *)encoded_ase:(NSString *)baseString withkey:(NSString *)encodedKey;

+ (NSData *)encoded_aseData:(NSData *)fileData withkey:(NSString *)encodedKey;

/* ase解密处理
 * baseString base加密后的字符串
 * encodedKey 解密的秘钥
 **/
+ (NSString *)decoded_ase:(NSString *)baseString withKey:(NSString *)decodedKey;

+ (NSData *)decoded_aseData:(NSData *)fileData withKey:(NSString *)decodedKey;

@end

@interface NSString (url)

/**
 *  urlencode
 *
 *  @return encode后字符串
 */
- (NSString *)URLEncodingString;

/**
 *  urldecode
 *
 *  @return decode后字符串
 */
//- (NSString *)URLDecodingString;

@end

@interface NSString (Regex)

/**
 *  是否是手机号码
 *
 *  @return YES or NO
 */
- (BOOL)isMobileNumber;

/// 不包含 \； \"； \\； /； \b； \f； \n； \r； \t； &； >； <；
- (BOOL)isGroupNameAvailable;

/**
 *  是否是规则的手机号(固号)
 *
 *  @return Yes or No
 */
- (BOOL)isMobileNumberWithIsFixedNumber:(BOOL)isFixedNumber;


/**
 *  是否是规则的名字
 *
 *  @return Yes or No
 */
- (BOOL)isNameForUserAndConf;

+ (BOOL)isIncludeChineseInString:(NSString*)str;


/**
 数字或字母组成

 @param passString
 @return
 */
- (BOOL)isModfilyPassWordCorrect:(NSString *)passString;

@end

@interface NSString (Device)

/**
 *  手机IMEI
 *
 *  @return
 */
+ (NSString *)imei;

/**
 *  手机MAC地址
 *
 *  @return 
 */
+ (NSString *)macAddress;

- (BOOL)myContainsString:(NSString*)other;
+(BOOL)isContainsEmoji:(NSString *)string;

/**
 @brief 钥匙串获取UUID add keven
 @return UUID
 */
+ (NSString *)getDeviceUUIDInKeychains;


/** 1:Android、2：iOS、3：H5、4：pc 5：mac
 @brief 设备类型 add keven
 @return 设备类型
 */
+ (NSString *)getDeviveName:(NSString *)devivetype;

@end


@interface NSString (uuid)

+ (NSString *)uuidString;

+ (NSString *)fileMessageUUid:(NSString *)userData;

@end

@interface NSString (filePath)

//保存图片 并返回路径
+ (NSString *)saveImageDataToFilePath:(NSData *)imageData;

+ (NSString *)getDefault_link;
+ (NSString *)getNowTimeTimestamp;

///add by 李晓杰 去emoji
- (NSString *)disable_emoji;
///add by 李晓杰 更新获取沙盒路径
- (NSString *)xj_documentPath;
///格式话小数 四舍五入类型
+ (NSString *)decimalwithFormat:(NSString *)format  floatV:(float)floatV;
@end

