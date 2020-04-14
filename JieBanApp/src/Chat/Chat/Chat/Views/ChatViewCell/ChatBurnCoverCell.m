//
//  ChatBurnCoverCell.m
//  ECSDKDemo_OC
//
//  Created by 王文龙 on 16/7/11.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatBurnCoverCell.h"

#define BubbleMaxSize CGSizeMake(180.0f * fitScreenWidth, 1000.0f)
NSString *const KResponderCustomChatViewBurnTextCellBubbleViewEvent = @"KResponderCustomChatViewBurnTextCellBubbleViewEvent";

@implementation ChatBurnCoverCell{
    UILabel *_label;
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody {
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:languageStringWithKey(@"点击查看")  withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
    CGFloat height = bubbleSize.height + 47.0f;
    return height;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {

        _label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.bubbleView.frame.size.width - 15.0f, self.bubbleView.frame.size.height - 10.0f)];
        _label.textColor = [UIColor blackColor];

        _label.numberOfLines = 0;
        _label.font = ThemeFontLarge;
        _label.text = languageStringWithKey(@"点击查看");
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        _label.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_label];

        CGSize bubbleSize = [[Common sharedInstance] widthForContent:_label.text withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];

        _label.frame = CGRectMake(16.0f, 8, bubbleSize.width, bubbleSize.height + 5);
        self.bubbleView.frame = CGRectMake(self.portraitImg.right + 10.0f, self.portraitImg.originY, bubbleSize.width + 25.0f, bubbleSize.height + 21);
    }
    return self;
}

@end
