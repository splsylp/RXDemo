//
//  NSAttributedString+Color.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/19.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Color)
/**
 *  对指定内定进行着色，keywords数组与colors数组相对应
 *
 *  @param content  全部内容
 *  @param keyWord  关键字
 *  @param color    关键字对应颜色
 *
 *  @return
 */
+(NSAttributedString *)attributeStringWithContent:(NSString *)content
                               keyWords:(NSString *)keyWord
                                 colors:(UIColor *)color;
//字母
+(NSAttributedString *)attributeletterWithContent:(NSString *)content
                                         keyWords:(NSString *)keyWord colors:(UIColor *)color;
/**
 *  对指定内定进行着色，keywords数组与colors数组相对应
 *
 *  @param content  全部内容
 *  @param keyWord  关键字
 *  @param firstLetter  首字母
 *  @param pinyin  拼音
 *  @param chinaese  汉字
 *  @param color    关键字对应颜色
 *
 *  @return 富文本
 */

+(NSAttributedString *)attributeChinaesewithContent:(NSString *)content keyWords:(NSString *)keyWord firstLetter:(NSString *)firstLetter pinyin:(NSString *)pinyin chinaese:(NSString *)chinaese colors:(UIColor *)color;

/**
 返回姓名职位富文本

 @param nameAttributedString 只包含姓名的富文本
 @param placeStr 职位名称
 @param placeColor 职位的颜色
 @return 富文本
 */
+(NSMutableAttributedString *)setAttributedStringWithNameAttributedString:(NSAttributedString *)nameAttributedString withPlaceString:(NSString *)placeStr withPlaceColor:(UIColor *)placeColor;
@end
