//
//  ChatWebUrlCell.m
//  Chat
//
//  Created by 胡伟 on 2019/8/9.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "ChatWebUrlCell.h"

#define CellH 110.0f
#define CellW 205.0f * fitScreenWidth
#define margin 10.0f
#define titleH 20.0f
#define margin1 5.0f
#define BubbleMaxSize CGSizeMake(185.0f*fitScreenWidth, 200.0f)

@interface ChatWebUrlCell ()

@property (nonatomic, weak) UIView *lineView;

@end

@implementation ChatWebUrlCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        self.isSender = isSender;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = ThemeFontMiddle;
        
        _imgView = [[FLAnimatedImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleToFill;
        _imgView.backgroundColor = [UIColor colorWithHexString:@"EFEFEF"];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.numberOfLines = 3;
        _detailLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _detailLabel.font = ThemeFontSmall;
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.textAlignment = NSTextAlignmentJustified;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.lineView = lineView;
        _lineView.hidden = YES;
        
        _urlLabel = [[UILabel alloc] init];
        _urlLabel.textColor = [UIColor colorWithHexString:@"1B7BD3"];
        _urlLabel.font = ThemeFontLarge;
        _urlLabel.hidden = YES;
        
        CGSize bubbleSize = CGSizeMake(CellW - 20, 20);
        if (isSender) {
            self.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:33 topCapHeight:33];
            [self setUpUIFrame:bubbleSize];
            
        } else {
            self.bubleimg.image = [ThemeImage(@"chat_sender_preView_left.png") stretchableImageWithLeftCapWidth:22.0f topCapHeight:33.0f];
            [self setUpUIFrame:bubbleSize];
        }
        
        [self.bubbleView addSubview:_titleLabel];
        [self.bubbleView addSubview:_imgView];
        [self.bubbleView addSubview:_detailLabel];
        [self.bubbleView addSubview:_lineView];
        [self.bubbleView addSubview:_urlLabel];
    }
    return self;
}

- (void)setUpUIFrame:(CGSize)bubbleSize {
    CGFloat imgViewWH = 42;
    _titleLabel.frame = CGRectMake(margin, margin, CellW - 4 * margin, titleH);
    _detailLabel.frame = CGRectMake(_titleLabel.left, CGRectGetMaxY(_titleLabel.frame)+margin1, CellW-imgViewWH - 3 * margin, imgViewWH + 3);
    _imgView.frame = CGRectMake(CellW - margin - imgViewWH, CGRectGetMaxY(_titleLabel.frame)+margin1, imgViewWH , imgViewWH);

    if (self.isSender) {
        self.portraitImg.originX = kScreenWidth - 10.0f - self.portraitImg.width;
        self.bubbleView.frame = CGRectMake(CGRectGetMinX(self.portraitImg.frame)-CellW - 10, self.portraitImg.frame.origin.y, CellW, 20 + CellH);
    }
    else {
        self.portraitImg.originX = 10.0f;
        self.bubbleView.frame = CGRectMake(CGRectGetMaxX(self.portraitImg.frame) + 10.0f, self.portraitImg.frame.origin.y, CellW, 20 + CellH);
    }
    if (bubbleSize.height > 0) {
        _lineView.hidden = _urlLabel.hidden = NO;
        _lineView.frame = CGRectMake(margin, _imgView.bottom + margin, CellW - 2 *margin, 0.5);
        _urlLabel.frame = CGRectMake(margin, _lineView.bottom + 10, bubbleSize.width, 20);
    }
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    return 160.0f;
}

- (void)bubbleViewTapGesture:(id)sender {
    [self dispatchCustomEventWithName:@"KResponderCustomChatViewWebCellBubbleViewEvent" userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:sender];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    self.isSender = (message.messageState == ECMessageState_Receive && ![message.from isEqualToString:FileTransferAssistant]) ? NO : YES;
    if (isopenReceipte) {//已读未读
        [self.receipteBtn removeFromSuperview];
        if (self.isSender) {
            [self.contentView addSubview:self.receipteBtn];
        }
    }
    NSDictionary *dic = [MessageTypeManager getCusDicWithUserData:message.userData];
    if (dic && dic[@"title"]) {
        _titleLabel.text = dic[@"title"];
        _detailLabel.text = dic[@"desc"];
        _urlLabel.text = dic[@"url"];
        [_imgView sd_setImageWithURL:[NSURL URLWithString:dic[@"img"]] placeholderImage:ThemeImage(@"icon_linkfailure")];
        if (dic[@"title"] && dic[@"url"]) {
            CGSize bubbleSize = [[Common sharedInstance] widthForContent:dic[@"url"] withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
            [self setUpUIFrame:bubbleSize];
        }
    }
    [super bubbleViewWithData:message];
}

@end
