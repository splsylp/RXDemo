//
//  ChatViewPreviewCell.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/22.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewPreviewCell.h"
#import "RXThirdPart.h"

#define CellH 90.0f
#define CellW 205.0f * fitScreenWidth
#define margin 10.0f
#define titleH 20.0f
#define margin1 5.0f
#define BubbleMaxSize CGSizeMake(185.0f*fitScreenWidth, 200.0f)

@interface ChatViewPreviewCell ()

@property (nonatomic, weak) UIView *lineView;

@end

@implementation ChatViewPreviewCell

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        self.isSender = isSender;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = ThemeFontMiddle;

        UIImage *image = ThemeImage(@"ios_rx_logo");
        _imgView = [[UIImageView alloc] initWithImage:image];
        _imgView.contentMode = UIViewContentModeScaleToFill;
        _imgView.userInteractionEnabled = NO;
        _imgView.backgroundColor = [UIColor clearColor];
        
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
        
        CGSize bubbleSize = CGSizeZero;
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
    }
    return self;
}

- (void)setUpUIFrame:(CGSize)bubbleSize {
    CGFloat imgViewWH = 42;
    _titleLabel.frame = CGRectMake(margin, margin, CellW - 4 * margin, titleH);
    _detailLabel.frame = CGRectMake(_titleLabel.left, CGRectGetMaxY(_titleLabel.frame)+margin1, CellW-imgViewWH - 3 * margin, imgViewWH + 3);
    _imgView.frame = CGRectMake(CellW - margin - imgViewWH, CGRectGetMaxY(_titleLabel.frame)+margin1, imgViewWH , imgViewWH);
    if (self.isSender) {
        self.bubbleView.frame = CGRectMake(CGRectGetMinX(self.portraitImg.frame)-CellW - 10, self.portraitImg.frame.origin.y, CellW, bubbleSize.height + CellH);
    }
    else {
        self.bubbleView.frame = CGRectMake(CGRectGetMaxX(self.portraitImg.frame) + 10.0f, self.portraitImg.frame.origin.y, CellW, bubbleSize.height + CellH);
    }
    if (bubbleSize.height > 0) {
        _lineView.hidden = _urlLabel.hidden = NO;
        _lineView.frame = CGRectMake(margin, _imgView.bottom + margin, CellW - 2 *margin, 0.5);
    }
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 110;
}

NSString *const KResponderCustomChatViewPreviewCellBubbleViewEvent = @"KResponderCustomChatViewPreviewCellBubbleViewEvent";

- (void)bubbleViewTapGesture:(id)sender {
    [self dispatchCustomEventWithName:KResponderCustomChatViewPreviewCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:sender];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECPreviewMessageBody *body = (ECPreviewMessageBody *)message.messageBody;
    _titleLabel.text = body.title;
    _detailLabel.text = body.desc;
    _urlLabel.text = body.url;
    if (body.remotePath.length > 7 && body.thumbnailRemotePath.length < 7) {
        body.thumbnailRemotePath = body.remotePath;
    }

    if (message.messageState == ECMessageState_Receive &&
               body.thumbnailRemotePath.length > 0) {
        __weak UIImageView *weakImgView = _imgView;
        [_imgView sd_setImageWithURL:[NSURL URLWithString:body.thumbnailRemotePath] placeholderImage:ThemeImage(@"ios_rx_logo") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakImgView.image = image;
            }
        }];
    }else if (body.thumbnailRemotePath.length > 0){
        __weak UIImageView *weakImgView = _imgView;
        [_imgView sd_setImageWithURL:[NSURL URLWithString:body.thumbnailRemotePath] placeholderImage:ThemeImage(@"ios_rx_logo") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakImgView.image = image;
            }
        }];
    } else {
        ///add by 李晓杰
        if ([body.thumbnailLocalPath hasSuffix:@"_thum"]) {
            body.thumbnailLocalPath = [body.thumbnailLocalPath substringToIndex:body.thumbnailLocalPath.length - 5];
        }
        body.thumbnailLocalPath = [NSString stringWithFormat:@"%@/Library/Caches/%@",NSHomeDirectory(),body.thumbnailLocalPath.lastPathComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:body.thumbnailLocalPath]) {
            UIImage *image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
            _imgView.image = image;
        }else{
            _imgView.image = ThemeImage(@"ios_rx_logo");
        }
    }
    [super bubbleViewWithData:message];
}
@end
