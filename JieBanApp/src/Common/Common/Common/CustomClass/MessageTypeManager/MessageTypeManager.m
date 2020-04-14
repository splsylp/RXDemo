//
//  MessageTypeManager.m
//  Common
//
//  Created by 王文龙 on 2017/6/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "MessageTypeManager.h"

@implementation MessageTypeManager
///change by李晓杰 现在先判断是否是json 不是再用以前的判断
+ (NSDictionary *)getCusDicWithUserData:(NSString *)userData{
    if ([self dictionaryWithJsonString:userData]) {
        return [self dictionaryWithJsonString:userData];
    }
    
    NSMutableDictionary *im_modeDic = [NSMutableDictionary dictionary];
    NSRange ran = [userData rangeOfString:@"UserData="];
    NSString *str = nil;
    if (ran.location == NSNotFound) {
        str = userData;
        NSRange ran = [userData rangeOfString:[NSString stringWithFormat:@"%@,",kFileTransferMsgNotice_CustomType]];
        //合并转发消息需要做这个判断
        NSRange ran1 = [userData rangeOfString:[NSString stringWithFormat:@"%@,",kMergeMessage_CustomType]];
        if (ran.location != NSNotFound) {
            NSInteger index = ran.location + ran.length;
            str = [userData substringFromIndex:index];
            str = [str base64DecodingString];
            NSRange tempRange = [str rangeOfString:[NSString stringWithFormat:@"%@,",kMergeMessage_CustomType]];
            if (tempRange.location != NSNotFound) {
                NSInteger index = tempRange.location + tempRange.length;
                str = [str substringFromIndex:index];
                str = [str base64DecodingString];
            }
        }else if (ran1.location != NSNotFound) {
            NSInteger index = ran1.location + ran1.length;
            str = [userData substringFromIndex:index];
            str = [str base64DecodingString];
        }
        im_modeDic = [self getDicFromJsonStr:str];
    }else{
        NSInteger index = ran.location + ran.length;
        str = [userData substringFromIndex:index];
        im_modeDic = [str coverDictionary];
    }
    return im_modeDic;
}

+ (NSMutableDictionary *)getDicFromJsonStr:(NSString *)message{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return [NSMutableDictionary dictionaryWithDictionary:dict];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){
//        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
