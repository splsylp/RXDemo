//
//  HXMergerMessageTextBubbleView.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "HXMergerMessageTextBubbleView.h"
#import "HXLinkLabel.h"


@interface HXMergerMessageTextBubbleView ()<HXLinkLabelDelegate>

//@property (nonatomic,strong) UILabel *mLabel;
@property (nonatomic,strong) HXLinkLabel *mLabel;

@property(nonatomic, strong) NSArray* matches;


@end


@implementation HXMergerMessageTextBubbleView

-(HXLinkLabel *)mLabel
{
    if(!_mLabel){
        _mLabel = [[HXLinkLabel alloc]initWithFrame:CGRectMake(0,0, kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT, 0)];
        _mLabel.delegate = self;
        //        _label.numberOfLines = 300;
        _mLabel.font = ThemeFontLarge;
        _mLabel.numberOfLines=0;
        _mLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
    }
    return _mLabel;
}


//-(UILabel *)mLabel
//{
//    if(!_mLabel){
//        _mLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT, 0)];
//        _mLabel.font            = ThemeFontLarge;
//        _mLabel.textColor       = [UIColor blackColor];
//        _mLabel.textAlignment   = NSTextAlignmentLeft;
//    }
//    return _mLabel;
//}

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10, BUBLEVIEW_TITLE_Disatance+EDGE_Distance_TOP+15*FitThemeFont,kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT, 30)];
    if (self) {
        [self addSubview:self.mLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _mLabel.frame = CGRectMake(0,0, self.width, self.height);
}

-(void)setModel:(HXMergeMessageModel *)model
{
    _model = model;
    self.mLabel.text = _model.merge_content;
    
    NSError *error = NULL;
//    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
  //  NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
     NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *detector = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];

    self.matches = [detector matchesInString:self.mLabel.text options:0 range:NSMakeRange(0, self.mLabel.text.length)];
    
    CGSize size = [model.merge_content sizeWithFont:ThemeFontLarge maxSize:CGSizeMake(kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT, 1000000) lineBreakMode:NSLineBreakByWordWrapping];
    self.mLabel.height = size.height;
    self.height        = size.height;
    [self highlightLinksWithIndex:NSNotFound];

}

+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model
{
    CGSize size = [model.merge_content sizeWithFont:ThemeFontLarge maxSize:CGSizeMake(model.bubbleW?model.bubbleW:(kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT), 1000000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}


#pragma mark -

- (void)label:(HXLinkLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(HXLinkLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
}

- (void)label:(HXLinkLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    
    for (NSTextCheckingResult *match in self.matches) {
        
        NSRange matchRange = [match range];
        if ([self isIndex:charIndex inRange:matchRange]) {
            NSString *url = [self.mLabel.text substringWithRange:matchRange];
            self.model.textUrl =url;

            if(self.bubbleViewClickBlock){
                self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Text);
            }
            break;
        }
        
    }
    
    
    
//    for (NSTextCheckingResult *match in self.matches) {
//    
//        
//        if ([match resultType] == NSTextCheckingTypeLink) {
//        
//            NSRange matchRange = [match range];
//            
//            if ([self isIndex:charIndex inRange:matchRange]) {
//                
//                self.model.textUrl = match.URL.absoluteString;
//                if(self.bubbleViewClickBlock){
//                    self.bubbleViewClickBlock(self.model,XSMergeMessageBublleEvent_Text);
//                }
//                break;
//            }
//        }
//    }
    
}

-(void)label:(HXLinkLabel *)label didCancelTouch:(UITouch *)touch {
    
    [self highlightLinksWithIndex:NSNotFound];
}

#pragma mark -

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [self.mLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches) {
        
//        if ([match resultType] == NSTextCheckingTypeLink) {
        
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
//        }
    }
    
    self.mLabel.attributedText = attributedString;
}




@end
