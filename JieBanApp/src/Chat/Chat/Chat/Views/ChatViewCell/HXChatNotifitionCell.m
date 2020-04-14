//
//  HXChatNotifitionCell.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/7/23.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXChatNotifitionCell.h"
#import <CoreText/CoreText.h>
#import "RXAttributeTextLabel.h"

@interface HXChatNotifitionCell()

@property (nonatomic, strong)NSRegularExpression *detector;
@property (nonatomic, strong) NSMutableArray *urlMatches; // url 或者电话号码 匹配出来的数组

@end

#define BubbleMaxSize CGSizeMake(kScreenWidth -40, 1000.0f)
@implementation HXChatNotifitionCell
{
    UIView  *_notiView;
    RXAttributeTextLabel *_notiLabel;
}
-(id)initWithNotifitionIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self=[super initWithNotifitionIsSender:isSender reuseIdentifier:reuseIdentifier])
    {
        
        _notiView =[[UIView alloc]initWithFrame:CGRectZero];
//        _notiView.backgroundColor=[UIColor colorWithRed:0.81f green:0.81f blue:0.81f alpha:1.00f];
        _notiView.backgroundColor=[UIColor colorWithHexString:@"#F7F7F7"];
        _notiView.layer.cornerRadius=5;
        _notiView.layer.masksToBounds = YES;
        
        [self.contentView addSubview:_notiView];
        
        _notiLabel = [RXAttributeTextLabel new];
        _notiLabel.textAlignment = NSTextAlignmentCenter;
        _notiLabel.font = ThemeFontSmall;
        _notiLabel.backgroundColor =[UIColor clearColor];
        _notiLabel.numberOfLines=0;
        _notiLabel.textColor = [UIColor colorWithHexString:@"333333"];
        _notiLabel.highlightedTextColor=[UIColor whiteColor];
        [_notiView addSubview:_notiLabel];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        _notiLabel.userInteractionEnabled = YES;
//        [_notiLabel addGestureRecognizer:tap];
       // [UIColor colorWithRed:0.94f green:0.94f blue:0.94f alpha:1.00f];
        
    }
    return self;
}


+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    CGFloat height = 0.0f;
    ECTextMessageBody *body = (ECTextMessageBody*)message;
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontMiddle.pointSize];
    height = bubbleSize.height+25;
    
    return height;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontSmall.pointSize];
    NSNumber *isShowNumber = objc_getAssociatedObject(self.displayMessage, &KTimeIsShowKey);
    BOOL isShow = isShowNumber.boolValue;
    _notiView.frame = CGRectMake((kScreenWidth-bubbleSize.width-6)/2,isShow?25+10:8, bubbleSize.width+6, bubbleSize.height+10);
    _notiLabel.frame = CGRectMake(3,0, _notiView.width-6, _notiView.height);
    
    NSDictionary *userdata = message.userDataToDictionary;
    if ([userdata hasValueForKey:@"groupNotice_rich_text"]) {
        NSArray *arr = [[userdata[@"groupNotice_rich_text"] base64DecodingString] arrayWithJsonString];
        NSMutableArray *allKeys = [NSMutableArray array];
        for (NSDictionary *dic in arr) {
            [allKeys addObjectsFromArray:dic.allKeys];
        }
        _notiLabel.attributedText = [self getAttributeWith:allKeys string:body.text orginFont:ThemeFontSmall orginColor:[UIColor colorWithHexString:@"333333"] attributeFont:ThemeFontSmall attributeColor:ThemeColor];
        [_notiLabel RX_addAttributeTapActionWithStrings:allKeys tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
            if (index<arr.count) {
                NSDictionary *dic = arr[index];
                NSString *account = dic[string];
                if (!KCNSSTRING_ISEMPTY(account)) {
                     [self dispatchCustomEventWithName:KResponderCustomChatViewCellNameTapEvent userInfo:@{@"account":account} tapGesture:nil];
                }
            }
        }];
    }else {
        _notiLabel.text =body.text;
    }
    if(bubbleSize.height > 20){
        [self SetTextAlignment];
    }
    [self ishowTimeLabel:isShow];
    [super bubbleViewWithData:message];
}

- (NSAttributedString *)getAttributeWith:(id)sender
                                  string:(NSString *)string
                               orginFont:(UIFont *)orginFont
                              orginColor:(UIColor *)orginColor
                           attributeFont:(UIFont *)attributeFont
                          attributeColor:(UIColor *)attributeColor
{
    __block  NSMutableAttributedString *totalStr = [[NSMutableAttributedString alloc] initWithString:string];
    [totalStr addAttribute:NSFontAttributeName value:orginFont range:NSMakeRange(0, string.length)];
    [totalStr addAttribute:NSForegroundColorAttributeName value:orginColor range:NSMakeRange(0, string.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:0.0f]; //设置行间距
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [totalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [totalStr length])];
    
    if ([sender isKindOfClass:[NSArray class]]) {
        __block NSString *oringinStr = string;
        __weak typeof(self) weakSelf = self;
        [sender enumerateObjectsUsingBlock:^(NSString *  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [oringinStr rangeOfString:str];
            if (range.length > 0) {
                [totalStr addAttribute:NSFontAttributeName value:attributeFont range:range];
                [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
                oringinStr = [oringinStr stringByReplacingCharactersInRange:range withString:[weakSelf getStringWithRange:range]];
            }
        }];
    }else if ([sender isKindOfClass:[NSString class]]) {
        NSRange range = [string rangeOfString:sender];
        [totalStr addAttribute:NSFontAttributeName value:attributeFont range:range];
        [totalStr addAttribute:NSForegroundColorAttributeName value:attributeColor range:range];
    }
    return totalStr;
}

- (NSString *)getStringWithRange:(NSRange)range
{
    NSMutableString *string = @"".mutableCopy;
    for (int i = 0; i < range.length ; i++) {
        [string appendString:@" "];
    }
    return string;
}


//显示位置 左右中
- (void)SetTextAlignment{
   NSString *showPost = objc_getAssociatedObject(self.displayMessage, @"HXTextAlignment");
   if([showPost isEqualToString:@"left"]){
       _notiLabel.textAlignment = NSTextAlignmentLeft;
   }else if ([showPost isEqualToString:@"right"]){
       _notiLabel.textAlignment = NSTextAlignmentRight;
   }else{
       _notiLabel.textAlignment = NSTextAlignmentCenter;
   }
}
///是否显示时间 通知专用
- (void)ishowTimeLabel:(BOOL)isShowTime{
    self.timeLabel.hidden = !isShowTime;
    if(isShowTime) {
        NSString *getTime = [ChatTools getDateDisplayString:self.displayMessage.timestamp.longLongValue];
        CGSize timeSize = [[Common sharedInstance] widthForContent:getTime withSize:CGSizeMake(200, 1000.0f) withLableFont:ThemeFontSmall.pointSize];
        self.timeLabel.frame = CGRectMake((kScreenWidth-timeSize.width-10)/2, 5,floor([NSString decimalwithFormat:@"0.0" floatV:timeSize.width].intValue + 10), floor(timeSize.height + 9));
        self.timeLabel.text = getTime;
        
    }
}

@end
