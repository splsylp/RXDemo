//
//  RXAttributedStringBuilder.h
//  Common
//
//  Created by 高源 on 2018/8/23.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RXAttributedStringBuilder;

/**属性字符串区域***/
@interface RXAttributedStringRange : NSObject


-(RXAttributedStringRange*)setFont:(UIFont*)font;              //字体
-(RXAttributedStringRange*)setTextColor:(UIColor*)color;       //文字颜色
-(RXAttributedStringRange*)setBackgroundColor:(UIColor*)color; //背景色
-(RXAttributedStringRange*)setParagraphStyle:(NSParagraphStyle*)paragraphStyle;  //段落样式
-(RXAttributedStringRange*)setLigature:(BOOL)ligature;  //连体字符，好像没有什么作用
-(RXAttributedStringRange*)setKern:(CGFloat)kern; //字间距
-(RXAttributedStringRange*)setLineSpacing:(CGFloat)lineSpacing;   //行间距
-(RXAttributedStringRange*)setStrikethroughStyle:(int)strikethroughStyle;  //删除线
-(RXAttributedStringRange*)setStrikethroughColor:(UIColor*)StrikethroughColor NS_AVAILABLE_IOS(7_0);  //删除线颜色
-(RXAttributedStringRange*)setUnderlineStyle:(NSUnderlineStyle)underlineStyle; //下划线
-(RXAttributedStringRange*)setUnderlineColor:(UIColor*)underlineColor NS_AVAILABLE_IOS(7_0);  //下划线颜色
-(RXAttributedStringRange*)setShadow:(NSShadow*)shadow;                          //阴影
-(RXAttributedStringRange*)setTextEffect:(NSString*)textEffect NS_AVAILABLE_IOS(7_0);
-(RXAttributedStringRange*)setAttachment:(NSTextAttachment*)attachment NS_AVAILABLE_IOS(7_0); //将区域中的特殊字符: NSAttachmentCharacter,替换为attachement中指定的图片,这个来实现图片混排。
-(RXAttributedStringRange*)setLink:(NSURL*)url NS_AVAILABLE_IOS(7_0);   //设置区域内的文字点击后打开的链接
-(RXAttributedStringRange*)setBaselineOffset:(CGFloat)baselineOffset NS_AVAILABLE_IOS(7_0);  //设置基线的偏移量，正值为往上，负值为往下，可以用于控制UILabel的居顶或者居低显示
-(RXAttributedStringRange*)setObliqueness:(CGFloat)obliqueness NS_AVAILABLE_IOS(7_0);   //设置倾斜度
-(RXAttributedStringRange*)setExpansion:(CGFloat)expansion NS_AVAILABLE_IOS(7_0);  //压缩文字，正值为伸，负值为缩

-(RXAttributedStringRange*)setStrokeColor:(UIColor*)strokeColor;  //中空文字的颜色
-(RXAttributedStringRange*)setStrokeWidth:(CGFloat)strokeWidth;   //中空的线宽度


//可以设置多个属性
-(RXAttributedStringRange*)setAttributes:(NSDictionary*)dict;

//得到构建器
-(RXAttributedStringBuilder*)builder;

@end


/*属性字符串构建器*/
@interface RXAttributedStringBuilder : NSObject

+(RXAttributedStringBuilder*)builderWith:(NSString*)string;


-(id)initWithString:(NSString*)string;

-(RXAttributedStringRange*)range:(NSRange)range;  //指定区域,如果没有属性串或者字符串为nil则返回nil,下面方法一样。
-(RXAttributedStringRange*)allRange;      //全部字符
-(RXAttributedStringRange*)lastRange;     //最后一个字符
-(RXAttributedStringRange*)lastNRange:(NSInteger)length;  //最后N个字符
-(RXAttributedStringRange*)firstRange;    //第一个字符
-(RXAttributedStringRange*)firstNRange:(NSInteger)length;  //前面N个字符
-(RXAttributedStringRange*)characterSet:(NSCharacterSet*)characterSet;             //用于选择特殊的字符
-(RXAttributedStringRange*)includeString:(NSString*)includeString all:(BOOL)all;   //用于选择特殊的字符串
-(RXAttributedStringRange*)regularExpression:(NSString*)regularExpression all:(BOOL)all;   //正则表达式


//段落处理,以\n结尾为一段，如果没有段落则返回nil
-(RXAttributedStringRange*)firstParagraph;
-(RXAttributedStringRange*)nextParagraph;


//插入，如果为0则是头部，如果为-1则是尾部
-(void)insert:(NSInteger)pos attrstring:(NSAttributedString*)attrstring;
-(void)insert:(NSInteger)pos attrBuilder:(RXAttributedStringBuilder*)attrBuilder;

-(NSAttributedString*)commit;

@end

NS_ASSUME_NONNULL_END
