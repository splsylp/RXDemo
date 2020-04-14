//
//  chatViewLocationCell.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/16.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ChatViewLocationCell.h"
//获取控制器  做跳转用
#import "UIView+CurrentController.h"
#import "ChatViewController.h"
//位置控制器
#import "ECLocationViewController.h"

#import "ShowLocationViewController.h"
#define kLocationCellW 190.0f
#define kLocationCellH 190.0f

#define BubbleMaxSize CGSizeMake(190.0f, 1000.0f)

NSString *const KResponderCustomChatViewLocationCellBubbleViewEvent = @"KResponderCustomChatViewLocationCellBubbleViewEvent";

@implementation ChatViewLocationCell {
    UIImageView* _displayImage;
    UIImageView* _gifFlagImage;
    UILabel* _locationLabel;
}

- (instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        _displayImage = [[UIImageView alloc] init];
        _displayImage.contentMode = UIViewContentModeScaleAspectFill;
        _displayImage.clipsToBounds = YES;
        
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = [UIColor whiteColor];
        _locationLabel.backgroundColor = [UIColor whiteColor];
        _locationLabel.alpha = 1;
        _locationLabel.textColor = [UIColor colorWithHexString:@"#39404E"];
        _locationLabel.font = ThemeFontMiddle;
        _locationLabel.numberOfLines = 1;
        _locationLabel.clipsToBounds = YES;
        
        _displayImage.frame = CGRectMake(0, 40, kLocationCellW*fitScreenWidth, kLocationCellH*fitScreenWidth);
        
        if (self.isSender) {
            _locationLabel.frame = CGRectMake(0, kLocationCellH*fitScreenWidth-45, kLocationCellW*fitScreenWidth-20, 40.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-(kLocationCellW + 10)*fitScreenWidth, self.portraitImg.frame.origin.y, kLocationCellW*fitScreenWidth, kLocationCellH*fitScreenWidth);
        } else {
            _locationLabel.frame = CGRectMake(0, kLocationCellH*fitScreenWidth-45, kLocationCellW*fitScreenWidth-20, 40.0f);
            self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10.0f+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, kLocationCellW*fitScreenWidth, kLocationCellH*fitScreenWidth);
        }
        
        [self.bubbleView addSubview:_displayImage];
        [self.bubbleView addSubview:_locationLabel];
    }
    return self;
}

- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewLocationCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
    if (![Common sharedInstance].isIMMsgMoreSelect) {
        ECLocationMessageBody *msgBody = (ECLocationMessageBody*)self.displayMessage.messageBody;
        ECLocationPoint *point = [[ECLocationPoint alloc] initWithCoordinate:msgBody.coordinate andTitle:msgBody.title];

        ShowLocationViewController *locationVC = [[ShowLocationViewController alloc] initWithLocationPoint:point];
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:locationVC];
        ChatViewController *chatVC = (ChatViewController *)[self getCurrentViewController];

        [chatVC presentViewController:nav animated:YES completion:^{
            
        }];
    }
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return kLocationCellH * 0.5 + 40 + 20;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    
    ECLocationMessageBody *locationBody = (ECLocationMessageBody *)message.messageBody;
    _locationLabel.text = [NSString stringWithFormat:@"  %@",locationBody.title];
    [_locationLabel sizeToFit];
    _displayImage.image = ThemeImage(@"chatView_location_map");
    
    NSString* fileName =[NSString stringWithFormat:@"%@.jpg", locationBody.title];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image) {
        _displayImage.image = image;
        UIImage *backImage = [[UIImage alloc] init];
        if (self.isSender) {
            backImage = ThemeImage(@"chating_right_02");
        } else {
            backImage = ThemeImage(@"chating_left_01");
        }
        // 渲染
        backImage = [ChatTools getThemeColorImage:backImage withColor:[UIColor clearColor]];
        self.bubleimg.image = [backImage stretchableImageWithLeftCapWidth:20.0f topCapHeight:20.0f];
        [self setupUIFrame];
        
    } else {
        UIImage *backImage = ThemeImage(@"chatView_location_map");
        _displayImage.image = backImage;
        [self setupUIFrame];
    }
    [super bubbleViewWithData:message];
}

- (void)setupUIFrame {
    CGFloat newWidth = kLocationCellW;
    if (newWidth < 160*iPhone6FitScreenWidth) {
        newWidth = 160*iPhone6FitScreenWidth;
    }
    CGFloat newHeight = kLocationCellW * 0.5;
    _locationLabel.frame = CGRectMake(0, 0, newWidth, 40.0f);
    _displayImage.frame = CGRectMake(0, _locationLabel.height, newWidth, newHeight);
    
    if (self.isSender) {
        self.bubbleView.frame = CGRectMake(self.portraitImg.originX - newWidth - 10, self.portraitImg.originY, newWidth, newHeight + _locationLabel.height);
    }
    else {
        self.bubbleView.frame = CGRectMake((self.portraitImg.originX + 14.0f + self.portraitImg.width), self.portraitImg.originY, newWidth, newHeight + _locationLabel.height);
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_locationLabel.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *mmaskLayer = [[CAShapeLayer alloc] init];
    mmaskLayer.frame = _locationLabel.bounds;
    mmaskLayer.path = maskPath.CGPath;
    _locationLabel.layer.mask = mmaskLayer;
    
    UIBezierPath *imagePath = [UIBezierPath bezierPathWithRoundedRect:_displayImage.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *imagemaskLayer = [[CAShapeLayer alloc] init];
    imagemaskLayer.frame = _displayImage.bounds;
    imagemaskLayer.path = imagePath.CGPath;
    _displayImage.layer.mask = imagemaskLayer;
}
@end
