//
//  NSString+Ext.m
//  Lafaso
//
//  Created by yuxuanpeng MINA on 14-7-15.
//  Copyright (c) 2014年 Lafaso. All rights reserved.
//
#import "RXThirdPart.h"
#import "NSString+Ext.h"
#import "NSData+Ext.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "RX_SFHFKeychainUtils.h"
#import <CommonCrypto/CommonCryptor.h>


@implementation NSString (MD5)

- (NSString *)MD5EncodingString{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodingString];
}


@end
@implementation NSString (WebUrl)
//新加 |||
+(BOOL)isContainsEmoji:(NSString *)string {
    
    
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
    
}

//验证网址是否正确
+(BOOL)regularWebsiteIsvalid:(NSString *)validateUrl
{
    BOOL isValidWebsite = NO;
    //    NSMutableArray * chatTextMutableArray = [[NSMutableArray alloc]init];
    
    NSError *error = NULL;
    //        NSString * webSiteString = @"((https?|ftp|news):\\/\\/)?([a-z0-9]([a-z0-9\\-]*[\\.。])+(aero|arpa|biz|com|coop|edu|gov|info|int|jobs|mil|museum|name|nato|net|org|pro|travel|[a-z]{2})|(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))(\\/[a-z0-9_\\-\\.~]+)*(\\/([a-z0-9_\\-\\.]*)(\\?[a-z0-9+_\\-\\.%=&]*)?)?(#[a-z][a-z0-9_]*)?";
    
//    NSString * regulaStr = REGULAR_WEBSITE_STRING;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
//                                                                           options:NSRegularExpressionCaseInsensitive
//                                                                             error:&error];
    
    NSRegularExpression *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink error:nil];
    NSArray *arrayOfAllMatches = [detector matchesInString:validateUrl options:0 range:NSMakeRange(0, [validateUrl length])];
    
//    NSArray *arrayOfAllMatches = [regex matchesInString:validateUrl options:0 range:NSMakeRange(0, [validateUrl length])];
    NSString* substringForMatch = @"";
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        substringForMatch = [validateUrl substringWithRange:match.range];
    }
    if ([substringForMatch isEqualToString:validateUrl]) {
        isValidWebsite = YES;
    }
    return isValidWebsite;
}
//网址正则表达式匹配
+(NSMutableArray*) regularExpressionMatchWebsiteWithString:(NSString *)searchText
{
    NSMutableArray * UrltMutableArray = [[NSMutableArray alloc]init];
    
    NSError *error = NULL;
    //        NSString * webSiteString = @"((https?|ftp|news):\\/\\/)?([a-z0-9]([a-z0-9\\-]*[\\.。])+(aero|arpa|biz|com|coop|edu|gov|info|int|jobs|mil|museum|name|nato|net|org|pro|travel|[a-z]{2})|(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))(\\/[a-z0-9_\\-\\.~]+)*(\\/([a-z0-9_\\-\\.]*)(\\?[a-z0-9+_\\-\\.%=&]*)?)?(#[a-z][a-z0-9_]*)?";
    
    NSString * webSiteString =REGULAR_WEBSITE_STRING;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:webSiteString options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSUInteger matchWebSiteNum = [regex numberOfMatchesInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    if (matchWebSiteNum > 0) {
        //获取所有匹配的数组
        NSArray *matchWebsiteArray = [regex matchesInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
        //        for (int i = 0; i < matchWebSiteNum; i++) {
        //            NSTextCheckingResult *result = [matchWebsiteArray objectAtIndex:i];
        //
        //            [chatTextMutableArray addObject:textMatchModel];
        //        }
        
        [UrltMutableArray addObjectsFromArray:matchWebsiteArray];
    }
    return UrltMutableArray;
}
@end
@implementation NSString (NSDictionary)

- (NSMutableDictionary*)coverToDictionary
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    NSString *str = [self stringByReplacingOccurrencesOfString:@"{" withString:@""];
    NSString *stra = [str stringByReplacingOccurrencesOfString:@"}" withString:@""];
    NSString *currentStr = [stra stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *newStr = [currentStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSArray* arr = [newStr componentsSeparatedByString:@","];
    for (int i = 0; i < arr.count; i++) {
        NSString* str = [arr objectAtIndex:i];
        NSString* tempStr = [str stringByReplacingOccurrencesOfString:@":" withString:@"="];
        NSArray *tempArr =[tempStr componentsSeparatedByString:@"="];
        if (tempArr.count > 1) {
            NSString* currentKey = [tempArr objectAtIndex:0];
            NSString *key = [currentKey stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* currentValue = [tempArr objectAtIndex:1];
            NSString *value =[currentValue stringByReplacingOccurrencesOfString:@" " withString:@""];
            [dic setValue:value forKey:key];
        }
    }
    return dic;
}

- (NSMutableDictionary*)coverDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //    # #114665  编辑图文消息时，文本不识别英文状态下“；”和“{}”  
//    NSString *str = [self stringByReplacingOccurrencesOfString:@"{" withString:@""];
//    NSString *stra = [str stringByReplacingOccurrencesOfString:@"}" withString:@""];

    NSString *str = self;
    //去第一个{
    if (self.length > 0) {
       NSString *first = [self substringToIndex:1];
        if ([first isEqualToString:@"{"]) {
            str = [self substringFromIndex:1];
        }
    }
    //去最后一个}
    if (str.length > 0) {
        NSString *last = [str substringFromIndex:str.length - 1];
        if ([last isEqualToString:@"}"]) {
            str = [str substringToIndex:str.length - 1];
        }
    }
    //去掉\"
    NSString *newStr = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    NSArray *arr = [newStr componentsSeparatedByString:@";"];
    for (int i = 0; i < arr.count; i++) {
        NSString *str = [arr objectAtIndex:i];
        NSRange range = [str rangeOfString:@"="];
        if (range.location != NSNotFound) {
            
            NSString *subStr = [str substringFromIndex:range.location+1];
            NSString *key = [str substringToIndex:range.location];
            [dic setValue:subStr forKey:key];
        }
        
        //        NSArray* tempArr = [str componentsSeparatedByString:@"="];
        //        if (tempArr.count > 1) {
        //            NSString* key = [tempArr objectAtIndex:0];
        //            NSString* value = [tempArr objectAtIndex:1];
        //            [dic setValue:value forKey:key];
        //        }
    }
    return dic;
}
/**
 @brief json字符串转换成对象
 */
- (NSDictionary*)dictionaryFromJSONString{
    if (self && [self isKindOfClass:[NSString class]]) {
        NSData *aJsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:aJsonData options:NSJSONReadingMutableContainers error:&error];
        if (jsonObject != nil && error == nil && [jsonObject isKindOfClass:[NSDictionary class]]){
            return jsonObject;
        }else{
            // 解析错误
            return nil;
        }
    }else{
        // 解析错误
        return nil;
    }
}

+ (NSString *)returnJSONStringWithDictionary:(id )dictionary{
    
    
    NSString *jsonString = [[NSString alloc]init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"type":@"resume",@"data":@{}}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" "withString:@""options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n"withString:@""options:NSLiteralSearch range:range2];
    
    return mutStr;
}
/// eagle json 转 字典
-(NSDictionary *)getDictFromJsonString{
    NSDictionary *dic = [self dictionaryFromJSONString];
    if (dic) {
        return dic;
    }else{
        dic = [self coverToDictionary];
    }
    return dic;
}

//jsonstring to dictionary
- (NSDictionary *)dictionaryWithJsonString {
    if (self == nil) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end


@implementation NSString (NSArray)
#pragma mark -json串转换成数组
- (id)arrayWithJsonString {
    if (self == nil) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                   options:NSJSONReadingMutableContainers
                                                     error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}
@end

@implementation NSString (base64)

- (NSString *)base64EncodingString
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodingString];
}

- (NSString *)base64DecodingString {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    if (!data) {
        data = [GTMBase64 decodeString:self];
    }
    NSString *domainBase64 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return domainBase64;
}

+ (NSString *)uncompressStr:(NSString *)jsonString{
    if(jsonString){
        //解密64
        NSData *testData = [GTMBase64 decodeString:jsonString];
        //转成字符串
        NSString *testStr1 = [[NSString alloc]initWithData:testData encoding:NSUTF8StringEncoding];
        //iso解码 转化成data
        NSData *gipIsoData = [testStr1 dataUsingEncoding:NSISOLatin1StringEncoding];
        //解压
        NSData *gzipData = [gipIsoData gzipInflate];
        //转化成字符串
        NSString *gzipString = [[NSString alloc]initWithData:gzipData encoding:NSUTF8StringEncoding];
        return gzipString;
    }
    return nil;
}

@end

@implementation NSString (SHA1)

//- (NSData *)HMACSHA1EncodeDataWithKey:(NSString *)key
//{
//    return [[self dataUsingEncoding:NSUTF8StringEncoding] HMACSHA1EncodeDataWithKey:key];
//}

@end

@implementation NSString (url)

- (NSString *) URLEncodingString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)self,  NULL,  (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",  kCFStringEncodingUTF8));
}

@end

@implementation NSString (Regex)

- (BOOL)isNameForUserAndConf{
    NSString *nameRegex = @"^[a-zA-Z0-9\u4E00-\u9FA5]+$";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nameRegex];
    return [pre evaluateWithObject:self];
}

- (BOOL)isMobileNumber
{
    return [self isMatchedByRegex:@"^1\\d{10}$"];
}


/// 不包含 \； \"； \\； /； \b； \f； \n； \r； \t； &； >； <；
- (BOOL)isGroupNameAvailable
{
//    return [self isMatchedByRegex:@"^((?!<|\\|＆|>|/).)*$"];
    //哎 还是用containsString吧
    if ([self containsString:@"\\"] ||
//        [self containsString:@"\\"] ||
        [self containsString:@"/"] ||
//        [self containsString:@"\b"] ||
//        [self containsString:@"\f"] ||
//        [self containsString:@"\n"] ||
//        [self containsString:@"\r"] ||
//        [self containsString:@"\t"] ||
        [self containsString:@"＆"] ||
        [self containsString:@"&"] ||
        [self containsString:@"<"] ||
        [self containsString:@">"]) {
        return NO;
    }
    return YES;
}

/**
 *  是否是规则的手机号(固号)
 *
 *  @return Yes or No
 */
// 正则判断手机号码地址格式
- (BOOL)isMobileNumberWithIsFixedNumber:(BOOL)isFixedNumber
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,184,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|7[0-9]|8[0-35-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,184,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|7[8]|8[2478])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|7[6]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,177,180,189
     22         */
    NSString * CT = @"^1((33|53|77|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-9]|\\d{3})\\d{7,8}$";
    
    NSString * PHS2 = @"^\\d{3,15}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs;
    NSPredicate *regextestphs2;
    if(isFixedNumber)
    {
        regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
        regextestphs2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS2];
    }
    
    if (([regextestmobile evaluateWithObject:self] == YES)
        || ([regextestcm evaluateWithObject:self] == YES)
        || ([regextestct evaluateWithObject:self] == YES)
        || ([regextestcu evaluateWithObject:self] == YES)
        || ([regextestphs evaluateWithObject:self] == YES)
        || ([regextestphs2 evaluateWithObject:self] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (BOOL)isIncludeChineseInString:(NSString*)str {
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}

-(BOOL)isModfilyPassWordCorrect:(NSString *)passString
{
    
    //NSString *regex = @"^[A-Za-z0-9]+$";
    if (!KCNSSTRING_ISEMPTY(passString)) {
        
        NSString *curStr=nil;
        for(int i=0;i<[passString length];i++)
        {
            //NSString *allStr=isPassWordLimitDigitalLetter;
            curStr =[passString substringWithRange:NSMakeRange(i, 1)];
            if(!([isPassWordLimitDigitalLetter rangeOfString:curStr].location !=NSNotFound))
            {
                return NO;
            }
        }
    }
    
    return YES;
}

@end

@implementation NSString (Device)

+ (NSString *)imei
{
    return [[NSString macAddress] MD5EncodingString];
}

+ (NSString *)macAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);//add by xuanwenchao at 2012.12.04
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (BOOL)myContainsString:(NSString*)other {
    
    if ([[UIDevice currentDevice].systemVersion integerValue] >7) {
        return [self containsString:other];
    }
    NSRange range = [self rangeOfString:other];
    return (range.location == NSNotFound?NO:YES);
}

#pragma mark -

/**
 @brief 钥匙串获取UUID.add by keven
 @return UUID
 */
+ (NSString *)getDeviceUUIDInKeychains {
    NSString *username = @"username";
    NSString *serviceName = @"serviceName";
    NSString *UUIDStr =  [RX_SFHFKeychainUtils getPasswordForUsername:username
                                                     andServiceName:serviceName
                                                              error:nil];
    if (KCNSSTRING_ISEMPTY(UUIDStr)) {
        UUIDStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [RX_SFHFKeychainUtils storeUsername:username
                             andPassword:UUIDStr
                          forServiceName:serviceName
                          updateExisting:1
                                   error:nil];
    }
    DDLogInfo(@"-------getDeviceUUIDInKeychains:%@",UUIDStr);
    return UUIDStr;
}

+ (NSString *)getDeviveName:(NSString *)devivetype{
    if (KCNSSTRING_ISEMPTY(devivetype) || ![devivetype respondsToSelector:@selector(intValue)]) {
        return @"未知设备";
    }
    
    NSString * name  = @"其它设备";
    int type = [devivetype intValue];
    switch (type) {
        case 1:
        {
            name = @"Android";
        }
            break;
        case 2:
        {
            name = @"iOS";
        }
            break;
        case 3:
        {
            name = @"H5";
        }
            break;
        case 4:
        {
            name = @"Windows";
        }
            break;
        case 5:
        {
            name = @"Mac";
        }
            break;
    }
    return name;
}


@end

@implementation NSString (AES)

+ (NSData *)encoded_aseData:(NSData *)fileData withkey:(NSString *)encodedKey{
    
    NSUInteger dataLength = fileData.length;
    
    // 为结束符'\\0' +1
    char keyPtr[kCCKeySizeAES256 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [encodedKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL,
                                          fileData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        
        NSData *newData = [[NSData dataWithBytes:(const void *)encryptedBytes length:(NSUInteger)actualOutSize] base64EncodedDataWithOptions:0];
        free(encryptedBytes);
        
        return newData;
    }
    free(encryptedBytes);
    return nil;
}

+ (NSData *)decoded_aseData:(NSData *)fileData withKey:(NSString *)decodedKey{
    
    //直接对data进行base64解密
    //NSString *baseString = [[NSString alloc]initWithData:fileData encoding:0];
    
    // NSData *decryptData =  [[NSData alloc]initWithBase64EncodedString:baseString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptData =[GTMBase64 decodeData:fileData];
    NSUInteger dataLength = decryptData.length;
    
    // 为结束符'\\0' +1
    char keyPtr[kCCKeySizeAES256 + 1];
    
    //const void *vkey = (const void *)[decodedKey UTF8String];
    bzero(keyPtr, sizeof(keyPtr));
    memset(keyPtr, 0,sizeof(keyPtr));
    [decodedKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    
    // NSData *initVector=[@"" dataUsingEncoding:NSUTF8StringEncoding];
    //decryptedBytes
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          (kCCOptionPKCS7Padding|kCCOptionECBMode),  // 系统默认使用 ECB，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL,
                                          decryptData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        NSData *newData =[NSData dataWithBytesNoCopy:decryptedBytes length:(NSInteger)actualOutSize];
        return newData;
    }
    free(decryptedBytes);
    return nil;
}


+ (NSString *)encoded_ase:(NSString *)baseString withkey:(NSString *)encodedKey{
    
    NSData *contentData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    
    // 为结束符'\\0' +1
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [encodedKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          nil,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行 base64 编码
        return [[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(encryptedBytes);
    return nil;
    
}

+ (NSString *)decoded_ase:(NSString *)baseString withKey:(NSString *)decodedKey{
    
    NSData *contentData =  [[NSData alloc]initWithBase64EncodedString:baseString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //[[NSData alloc]initWithBase64EncodedString:baseString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSUInteger dataLength = contentData.length;
    
    // 为结束符'\\0' +1
    char keyPtr[kCCKeySizeAES128 + 1];
    
    memset(keyPtr, 0, sizeof(keyPtr));
    [decodedKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // 密文长度 <= 明文长度 + BlockSize
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    
    // NSData *initVector=[@"" dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          nil,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        // 返回解密后的字符串
        return [[NSString alloc]initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize]
                                    encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return nil;
}

@end
@implementation NSString (uuid)

+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

+ (NSString *)fileMessageUUid:(NSString *)userData{
    NSString *fileUUid = nil;
    if(!KCNSSTRING_ISEMPTY(userData)){
        if([userData rangeOfString:kFileTransferMsgNotice_CustomType].location!= NSNotFound){
            NSString * keyStr = [NSString stringWithFormat:@"%@,",kFileTransferMsgNotice_CustomType];
            NSString * userDataCove = [[userData substringFromIndex:keyStr.length] base64DecodingString];
            NSDictionary *userDataDic = [NSJSONSerialization JSONObjectWithData:[userDataCove dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            fileUUid = userDataDic[@"HX_fileUuid"];
        }else{
            NSDictionary *userDataDic = [NSJSONSerialization JSONObjectWithData:[[userData base64DecodingString] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if([userDataDic hasValueForKey:@"HX_fileUuid"]){
                fileUUid = [userDataDic objectForKey:@"HX_fileUuid"];
            }
        }
    }
    return fileUUid;
}


@end

@implementation NSString (filePath)


+ (NSString *)saveImageDataToFilePath:(NSData *)imageData
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString* fileName =[NSString stringWithFormat:@"%@.jpg", [formater stringFromDate:[NSDate date]]];
    
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    [imageData writeToFile:filePath atomically:YES];
    
    return filePath;    
}

+ (NSString *)getDefault_link{
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"default_link.png"];
    //如果不存在 需要先写入
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        UIImage *headImage = ThemeImage(@"ios_rx_logo");
        NSData *imageData = UIImagePNGRepresentation(headImage);
        [imageData writeToFile:imagePath atomically:YES];
    }
    return imagePath;
}
+ (NSString *)getNowTimeTimestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

///add by 李晓杰 去emoji
- (NSString *)disable_emoji{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    return modifiedString;
}
- (NSString *)xj_documentPath{
    if (![self containsString:@"/Caches/"]) {
        return self;
    }
    NSRange range = [self rangeOfString:@"/Caches/"];
    NSString *newStr = [self substringFromIndex:range.location + range.length - 1];
    ///新的沙盒路径
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    ///拼接上
    NSString *lastPath = [cachesPath stringByAppendingPathComponent:newStr];
    return lastPath;
}
+ (NSString *)decimalwithFormat:(NSString *)format  floatV:(float)floatV{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:format];
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}
@end
