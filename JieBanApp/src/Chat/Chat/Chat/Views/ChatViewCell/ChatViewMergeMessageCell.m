//
//  ChatViewMergeMessageCell.m
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/30.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ChatViewMergeMessageCell.h"
#import "HXMessageMergeManager.h"
static NSString *const huiChe = @"[rx_str_merge_des]"; //PC端回车转换有问题,用这个字符串替换

#define Edge_CEll 17

@interface ChatViewMergeMessageCell ()

@property (nonatomic,strong) UILabel *mTitleLabel;  // 标题
@property (nonatomic,strong) UILabel *mDesLabel;    //描述
@property (nonatomic,strong) UIView  *mLineView;    //细线
@property (nonatomic,strong) UILabel *mChatIndexLabel;//聊天记录

@end

@implementation ChatViewMergeMessageCell

- (UILabel *)mChatIndexLabel{
    if(!_mChatIndexLabel){
        _mChatIndexLabel = [[UILabel alloc] init];
        _mChatIndexLabel.textColor = [UIColor grayColor];
        _mChatIndexLabel.font =ThemeFontSmall;
        _mChatIndexLabel.text = languageStringWithKey( @"聊天记录");
    }
    return _mChatIndexLabel;
}

- (UILabel *)mTitleLabel{
    if(!_mTitleLabel){
        _mTitleLabel = [[UILabel alloc] init];
        _mTitleLabel.textColor = [UIColor blackColor];
        _mTitleLabel.font = ThemeFontLarge;
    }
    return _mTitleLabel;
}

- (UIView *)mLineView{
    if(!_mLineView){
        _mLineView = [[UIView alloc] init];
        _mLineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    }
    return _mLineView;
}

- (UILabel *)mDesLabel{
    if(!_mDesLabel){
        _mDesLabel = [[UILabel alloc] init];
        _mDesLabel.textColor = [UIColor grayColor];
        _mDesLabel.font =ThemeFontSmall;
        _mDesLabel.numberOfLines = 0;
    }
    return _mDesLabel;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        [self.bubbleView addSubview:self.mTitleLabel];
        [self.bubbleView addSubview:self.mDesLabel];
        [self.bubbleView addSubview:self.mLineView];
        [self.bubbleView addSubview:self.mChatIndexLabel];
        self.bubleimg.hidden =  NO;
        if (isSender) {
            self.bubbleView.frame = CGRectMake(CGRectGetMinX(self.portraitImg.frame) - CellW - 10, self.portraitImg.originY, CellW - 10, CellH - 10);
        } else {
            self.bubbleView.frame = CGRectMake(CGRectGetMaxX(self.portraitImg.frame) + 10.0f, self.portraitImg.originY, CellW - 10, CellH - 10);
        }
        self.mTitleLabel.frame = CGRectMake(Edge_CEll, 10, self.bubbleView.width - Edge_CEll * 2, 20);
        self.mDesLabel.frame = CGRectMake(Edge_CEll, self.mTitleLabel.bottom + 5, CellW - Edge_CEll * 2, 0);
        self.mChatIndexLabel.frame = CGRectMake(Edge_CEll, 0, 100, ChatWord_Height);
        self.mLineView.frame = CGRectMake(Edge_CEll, 0, CellW - 2 * Edge_CEll , 1);
    }
    return self;
}
+ (CGFloat)getHightOfCellViewWithMessage:(ECMessage *)message{
    NSDictionary *im_jsonDic = [HXMessageMergeManager jsonDicWithBase64UserData:message.userData];
    NSString *oriString = im_jsonDic[@"msgDesc"] ? im_jsonDic[@"msgDesc"]:im_jsonDic[@"merge_messageDes"];
    if (oriString == nil) {
        oriString = @"";
    }

    NSMutableString *tempString = [[NSMutableString alloc] initWithString:oriString];
    NSString *newString = [tempString stringByReplacingOccurrencesOfString:huiChe withString:@"\n"];
    CGFloat height1 = [newString ? newString:@"" sizeWithFont:ThemeFontSmall maxSize:CGSizeMake(CellW - 2 * Edge_CEll,300) lineBreakMode:NSLineBreakByWordWrapping].height;
    CGFloat height = 10 + 20 + 5 + height1 + DesLabe_Line_distance+ChatWord_Height;
    return height + Bubble_Cell_Distance + 20;
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 0;
}

NSString *const KResponderCustomChatViewMergeMessageCellBubbleViewEvent = @"KResponderCustomChatViewMergeMessageCellBubbleViewEvent";

- (void)bubbleViewTapGesture:(id)sender{
    [self dispatchCustomEventWithName:KResponderCustomChatViewMergeMessageCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:sender];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    NSDictionary *im_jsonDic = message.userDataToDictionary;
    
    NSString *title = im_jsonDic[@"title"] ? im_jsonDic[@"title"] : im_jsonDic[@"merge_title"];
    if (title == nil) {
        title = @"";
    }
    self.mTitleLabel.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:title];

    NSString *desc = im_jsonDic[@"msgDesc"] ? im_jsonDic[@"msgDesc"] : im_jsonDic[@"merge_messageDes"];
    if (desc == nil) {
        desc = @"";
    }
    NSMutableString *tempString = [[NSMutableString alloc] initWithString:desc];
    NSString *newString = [tempString stringByReplacingOccurrencesOfString:huiChe withString:@"\n"];
    self.mDesLabel.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:newString];

    CGFloat height = [self.mDesLabel.text sizeWithFont:ThemeFontSmall maxSize:CGSizeMake(CellW - 2 * Edge_CEll,300) lineBreakMode:NSLineBreakByWordWrapping].height;
    self.mDesLabel.height = height;
    
    self.mLineView.top = self.mDesLabel.bottom +DesLabe_Line_distance;
    self.mChatIndexLabel.top = self.mLineView.bottom+2;
    self.bubbleView.height = self.mChatIndexLabel.bottom+5;
    self.bubleimg.frame = self.bubbleView.bounds;

    if(self.isSender){
        self.bubleimg.image = [ThemeImage(@"chat_sender_preView.png") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    }else{
         self.bubleimg.image = [ThemeImage(@"chat_sender_preView_left.png") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
    }
    [super bubbleViewWithData:message];
}


@end
