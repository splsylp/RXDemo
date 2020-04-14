//
//  ChatRevokeCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/6/13.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatRevokeCell.h"
#import "RXRevokeMessageBody.h"

#define BubbleMaxSize CGSizeMake(260.0f, 80.0f)
@interface ChatRevokeCell ()

@property (nonatomic, strong) UILabel *revokeLabel;

@end

@implementation ChatRevokeCell

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)messageBody {
    CGFloat height = 40.0f;
    RXRevokeMessageBody *body = (RXRevokeMessageBody *)messageBody;
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontSmall.pointSize];
    if (bubbleSize.height > 45.0f) {
        height = bubbleSize.height + 20.0f;
    }
    return height;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30.0f)];
        [self.contentView addSubview:self.timeLabel];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font =ThemeFontSmall;
        self.timeLabel.backgroundColor = self.backgroundColor;
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.hidden = YES;
        
        _revokeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-110)/2,CGRectGetMaxY(self.timeLabel.frame), 110, 20.0f)];
        _revokeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_revokeLabel];
        _revokeLabel.font = ThemeFontLarge;
        _revokeLabel.textColor = [UIColor whiteColor];
        _revokeLabel.highlightedTextColor = [UIColor whiteColor];
        _revokeLabel.backgroundColor = [UIColor lightGrayColor];
        _revokeLabel.layer.cornerRadius = 4;
        _revokeLabel.layer.masksToBounds = YES;
        _revokeLabel.numberOfLines = 0;
    }
    return self;
}
- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    RXRevokeMessageBody *body = (RXRevokeMessageBody *)self.displayMessage.messageBody;
    _revokeLabel.text = body.text;
    //是否显示时间
    NSNumber *isShowNumber = objc_getAssociatedObject(self.displayMessage, &KTimeIsShowKey);
    BOOL isShow = isShowNumber.boolValue;
    self.timeLabel.hidden = !isShow;
    
    CGRect frame = _revokeLabel.frame;
    CGSize size = [[Common sharedInstance] widthForContent:body.text withSize:BubbleMaxSize withLableFont:ThemeFontSmall.pointSize];
    frame.size.width = size.width+10;
    frame.size.height = size.height + 5;
    frame.origin.x = (self.frame.size.width - frame.size.width)/2;
    if (isShow) {
        self.timeLabel.text = [ChatTools getDateDisplayString:self.displayMessage.timestamp.longLongValue];
    } else {
        frame.origin.y = 0;
    }
    _revokeLabel.frame = frame;
    [super bubbleViewWithData:message];
}
@end
