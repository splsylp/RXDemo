//
//  ChatViewBurnCell.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/11/16.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ChatViewBurnCell.h"

@implementation ChatViewBurnCell{
    UIImageView* _displayImage;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        _displayImage.layer.cornerRadius =_displayImage.frame.size.width/2;
        _displayImage.layer.masksToBounds=YES;
        _displayImage.image = ThemeImage(@"chat_snapchat_readed");
        
        if (self.isSender) {
            _displayImage.frame = CGRectMake(4, 2, 106.0f, 95.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-130.0f, self.portraitImg.frame.origin.y, 120.0f, 100.0f);
        } else {
            _displayImage.frame = CGRectMake(14, 2, 106.0f, 95.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 120.0f, 100.0f);
        }
        [self.bubbleView addSubview:_displayImage];
    }
    return self;
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 120.0f;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.bubleimg.image = nil;
    [super bubbleViewWithData:message];
}

@end
