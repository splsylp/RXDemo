//
//  ChatGroupVotingCell.m
//  ECSDKDemo_OC
//
//  Created by 王文龙 on 16/7/15.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatGroupVotingCell.h"
#import "RXThirdPart.h"

#define CellH 110.0f
#define CellW 205.0f
#define margin 10.0f
#define titleH 20.0f
#define margin1 5.0f
@implementation ChatGroupVotingCell

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.font = ThemeFontMiddle;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImage *image = ThemeImage(@"attachment");
        _imgView = [[UIImageView alloc] initWithImage:image];
        _imgView.contentMode = UIViewContentModeScaleToFill;
        _imgView.userInteractionEnabled = NO;
        
        _detailLabel1 = [[UILabel alloc] init];
        _detailLabel1.numberOfLines = 0;
        _detailLabel1.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel1.font = ThemeFontMiddle;
        _detailLabel1.textColor = [UIColor grayColor];
        _detailLabel1.textAlignment = NSTextAlignmentJustified;
        
        _detailLabel2 = [[UILabel alloc] init];
        _detailLabel2.numberOfLines = 0;
        _detailLabel2.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel2.font = ThemeFontMiddle;
        _detailLabel2.textColor = [UIColor grayColor];
        _detailLabel2.textAlignment = NSTextAlignmentJustified;
        
        CGFloat imgViewWH = CellH-titleH-3*margin-margin1;
        if (isSender) {
            self.bubbleView.frame = CGRectMake(CGRectGetMinX(self.portraitImg.frame)-CellW-10, self.portraitImg.frame.origin.y, CellW, CellH);
            self.bubleimg.image =
            [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:33 topCapHeight:33];
            
            _titleLabel.frame = CGRectMake(margin+margin, margin, CellW-4*margin, titleH);
            _imgView.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame)+margin1,imgViewWH , imgViewWH);
            _detailLabel1.frame = CGRectMake(CGRectGetMaxX(_imgView.frame)+margin1, CGRectGetMaxY(_titleLabel.frame)+margin1, CellW-imgViewWH-4*margin-margin1, imgViewWH/3);
            _detailLabel2.frame = CGRectMake(CGRectGetMaxX(_imgView.frame)+margin1, CGRectGetMaxY(_titleLabel.frame)+margin1+imgViewWH/3, CellW-imgViewWH-4*margin-margin1, imgViewWH/3);
            
        } else {
            _titleLabel.frame = CGRectMake(margin+10, margin, CellW-3*margin, titleH);
            _imgView.frame = CGRectMake(margin+10, CGRectGetMaxY(_titleLabel.frame)+margin1, imgViewWH, imgViewWH);
            _detailLabel1.frame = CGRectMake(CGRectGetMaxX(_imgView.frame), CGRectGetMaxY(_titleLabel.frame)+margin1,CellW-imgViewWH-margin*4 -margin1, imgViewWH/3);
            _detailLabel2.frame = CGRectMake(CGRectGetMaxX(_imgView.frame), CGRectGetMaxY(_titleLabel.frame)+margin1+imgViewWH/3,CellW-imgViewWH-margin*4 -margin1, imgViewWH/3);
            
            self.bubbleView.frame = CGRectMake(CGRectGetMaxX(self.portraitImg.frame)+10.0f, self.portraitImg.frame.origin.y, CellW, CellH);
        }
        
        [self.bubbleView addSubview:_titleLabel];
        [self.bubbleView addSubview:_imgView];
        [self.bubbleView addSubview:_detailLabel1];
        [self.bubbleView addSubview:_detailLabel2];
    }
    return self;
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message {
    return 150.0f;
}

NSString *const KResponderCustomChatGroupVotingCellBubbleViewEvent = @"KResponderCustomChatGroupVotingCellBubbleViewEvent";

- (void)bubbleViewTapGesture:(id)sender {
    [self dispatchCustomEventWithName:KResponderCustomChatGroupVotingCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:sender];
}
- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    /*
     UserData={GroupVoting_Url="http://192.168.179.116:7774/2015-03-26/Corp/yuntongxun/inner/groupvote/vote/g800016554/15101513944/140";GroupVoting_Type="0";GroupVoting_Title="今晚吃什么";GroupVoting_Option1="米饭";GroupVoting_Option2="馒头";GroupVoting_ImageUrl="”;}
     GroupVoting_Type：0为单选，1为多选
     */
    NSDictionary* userData = message.userDataToDictionary;
    if ([userData hasValueForKey:@"GroupVoting_Url"]) {
        _titleLabel.text = [userData objectForKey:@"GroupVoting_Title"];
        if ([[userData objectForKey:@"GroupVoting_Type"] isEqualToString:@"1"]) {
            _detailLabel1.text = [NSString stringWithFormat:@"〇 %@",[userData objectForKey:@"GroupVoting_Option1"]];
            _detailLabel2.text = [NSString stringWithFormat:@"〇 %@",[userData objectForKey:@"GroupVoting_Option2"]];
        }else{
            _detailLabel1.text = [NSString stringWithFormat:@"〇 %@",[userData objectForKey:@"GroupVoting_Option1"]];
            _detailLabel2.text = [NSString stringWithFormat:@"〇 %@",[userData objectForKey:@"GroupVoting_Option2"]];
        }
        if ( [[userData objectForKey:@"GroupVoting_ImageUrl"] length] > 0){
            __weak UIImageView *weakImgView = _imgView;
            [_imgView sd_setImageWithURL:[NSURL URLWithString:[userData objectForKey:@"GroupVoting_ImageUrl"]] placeholderImage:ThemeImage(@"attachment") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    weakImgView.image = image;
                }
            }];
        }else{
            [_imgView sd_cancelCurrentImageLoad];
            _imgView.image = ThemeImage(@"aio_icon_group_vote");
        }
    }else{
        [_imgView sd_cancelCurrentImageLoad];
        _imgView.image = ThemeImage(@"aio_icon_group_vote");
    }
    [super bubbleViewWithData:message];
}

@end
