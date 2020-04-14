//
//  NSAttributedString+Color.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "NSAttributedString+Color.h"

@implementation NSAttributedString (Color)
//数字
+(NSAttributedString *)attributeStringWithContent:(NSString *)content
                                         keyWords:(NSString *)keyWord
                                           colors:(UIColor *)color
{
    /// eagle 增加代码包含防崩溃
    if (content.length == 0) {
        return nil;
    }
    // 设置标签文字
    NSMutableAttributedString *attrituteString = [[NSMutableAttributedString alloc] initWithString:content];
    
        if (keyWord) {
            // 获取标红的位置和长度
          NSRange range  = [content rangeOfString:keyWord];
            // 设置标签文字的属性
            [attrituteString setAttributes:@{NSForegroundColorAttributeName:color} range:range];
    }
    
    return attrituteString;
}
//字母
+(NSAttributedString *)attributeletterWithContent:(NSString *)content
    keyWords:(NSString *)keyWord colors:(UIColor *)color
{
    /// eagle 增加代码包含防崩溃
    if (content.length == 0) {
        return nil;
    }
    // 设置标签文字
    NSMutableAttributedString *attrituteString = [[NSMutableAttributedString alloc] initWithString:content];
    for(int i=0;i<keyWord.length;i++)
    {
        if (keyWord) {
            // 获取标红的位置和长度
            NSString *str =[keyWord substringWithRange:NSMakeRange(i, 1)];
            NSRange range  = [content rangeOfString:str];
            // 设置标签文字的属性
            [attrituteString setAttributes:@{NSForegroundColorAttributeName:color} range:range];
        }
    }
    
    return attrituteString;
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

+(NSAttributedString *)attributeChinaesewithContent:(NSString *)content keyWords:(NSString *)keyWord firstLetter:(NSString *)firstLetter pinyin:(NSString *)pinyin chinaese:(NSString *)chinaese colors:(UIColor *)color{
    /// eagle 增加代码包含防崩溃
    if (content.length == 0) {
        return nil;
    }
     NSMutableAttributedString *attrituteString = [[NSMutableAttributedString alloc] initWithString:content];
    // 获取标红的位置和长度
    NSRange nameRange  = [content rangeOfString:keyWord];
//    if([self isIncludeChineseInString:keyWord]){
    if(nameRange.location != NSNotFound){
        if (keyWord) {
            // 获取标红的位置和长度
//            NSRange range  = [content rangeOfString:keyWord];
            // 设置标签文字的属性
            [attrituteString setAttributes:@{NSForegroundColorAttributeName:color} range:nameRange];
        }
    }else{
        NSString *strName = [self searchChineseInPy:pinyin chinese:chinaese firstLetter:firstLetter searchLetter:keyWord];
        if (strName) {
            // 获取标红的位置和长度
            NSRange range  = [content rangeOfString:strName];
            // 设置标签文字的属性
            [attrituteString setAttributes:@{NSForegroundColorAttributeName:color} range:range];
        }
    }
   
    return attrituteString;
}

//拼音找汉字
+ (NSString *)searchChineseInPy:(NSString *)py chinese:(NSString *)simCharacters firstLetter:(NSString *)firstLet searchLetter:keyWord{
    if (keyWord == nil) {
        keyWord = @"";
    }
    //首先判断首字母
    NSString *chinaese = nil;
    if(simCharacters){
        if(KCNSSTRING_ISEMPTY(firstLet)){
            firstLet = [RX_KCPinyinHelper quickConvert:simCharacters];
        }
        if(KCNSSTRING_ISEMPTY(py)){
            py = [RX_KCPinyinHelper pinyinFromChiniseString:simCharacters];
        }
        //首字母先判断 不区分大小写
        NSRange range = [firstLet rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound){
            chinaese = [simCharacters substringWithRange:range];
            return chinaese;
        }
        NSRange rangePy = [py rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        if(rangePy.location != NSNotFound){
            chinaese = [self isFirstPrefix:NO withSimCharacters:simCharacters withKeyWords:keyWord witFirstLettrr:firstLet];
        }
    }
    return chinaese;
}
//以首字母方式进行判断 不符合要求 直接dismiss
+(NSString *)isFirstPrefix:(BOOL)isTure withSimCharacters:(NSString *)simCharacters withKeyWords:(NSString *)words witFirstLettrr:(NSString *)firstLet
{
    NSString *name =nil;
    NSString *wordsFirst =[words substringWithRange:NSMakeRange(0, 1)];
    for(int i =0;i<firstLet.length;i++)
    {
        if([wordsFirst rangeOfString:[firstLet substringWithRange:NSMakeRange(i, 1)] options:NSCaseInsensitiveSearch].location !=NSNotFound)
        {
                NSString *lengthStr =@"";
                NSInteger len =0;
                for(int j =i;j<simCharacters.length;j++)
                {
                    len++;
                    lengthStr =[NSString stringWithFormat:@"%@%@",lengthStr,[RX_KCPinyinHelper pinyinFromChiniseString:[simCharacters substringWithRange:NSMakeRange(j , 1)]]];
                    
                    if(lengthStr.length>=words.length)
                    {
                       name =[NSString stringWithFormat:@"%@",[simCharacters substringWithRange:NSMakeRange(i , len)]];
                        return name;
                    }
                }
         }
     }
    
    return name;
}
+(NSMutableAttributedString *)setAttributedStringWithNameAttributedString:(NSAttributedString *)nameAttributedString withPlaceString:(NSString *)placeStr withPlaceColor:(UIColor *)placeColor{
    
    NSString *placeString = !KCNSSTRING_ISEMPTY(placeStr)?[NSString stringWithFormat:@" | %@",placeStr]:@"";
    NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc]initWithAttributedString:nameAttributedString];
    NSInteger index = placeString.length;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:placeString];
    [str addAttribute:NSForegroundColorAttributeName value:placeColor range:NSMakeRange(0, index)];
    [str addAttribute:NSFontAttributeName value:ThemeFontMiddle range:NSMakeRange(0, index)];
    [nameStr appendAttributedString:str];
    return nameStr;
}
    
@end
