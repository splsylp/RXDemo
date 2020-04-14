//
//  ChatViewCallTextCell.m
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/11/30.
//  Copyright © 2015年 ronglian. All rights reserved.
//
#import <CoreText/CoreText.h>

#import "ChatViewCallTextCell.h"

NSString *const KResponderCustomChatViewCallTextCellBubbleViewEvent = @"KResponderCustomChatViewCallTextCellBubbleViewEvent";

#define BubbleMaxSize CGSizeMake(180.0f*fitScreenWidth, 1000.0f)
@interface ChatViewCallTextCell()
@property (nonatomic, strong)NSDataDetector *detector;
@property (nonatomic, strong) NSArray *urlMatches;
@end
@implementation ChatViewCallTextCell{
    UILabel *_label;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        if (isSender) {
            _label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-6.0f)];
        }else{
            _label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 2.0f, self.bubbleView.frame.size.width-15.0f, self.bubbleView.frame.size.height-6.0f)];
        }
        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        _label.numberOfLines = 0;
        _label.font = ThemeFontLarge;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
        _label.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_label];
    }
    return self;
}

- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    [self dispatchCustomEventWithName:KResponderCustomChatViewCallTextCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
    CGPoint point = [tap locationInView:_label];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in self.urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            if ([self isIndex:charIndex inRange:matchRange]) {
                [[UIApplication sharedApplication] openURL:match.URL];
                break;
            }
        }
    }
}

+(CGFloat)getHightOfCellViewWithMessage:(ECMessage *)message{
    CGFloat height = 0.0f;
    ECCallMessageBody *body = (ECCallMessageBody*) message.messageBody;
    CGSize bubbleSize;
    if ([message getHeight]<=0) {
        bubbleSize = [[Common sharedInstance] widthForContent:body.callText withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
        [message  setHeight: bubbleSize.height];
        [[KitMsgData sharedInstance] updateHeight:bubbleSize.height ofMessageId: message.messageId];
    }else{
        bubbleSize = CGSizeMake(BubbleMaxSize.width,[message getHeight]);
    }

    // if (bubbleSize.height>45.0f) {
    height = bubbleSize.height+40.0f;
    // }
    return height;
    
    
    //    if (bubbleSize.height>45.0f) {
    //        height = bubbleSize.height+20.0f;
    //    }
    return height;
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    CGFloat height = 0.0f;
    ECCallMessageBody *body = (ECCallMessageBody*)message;
    CGSize bubbleSize = [[Common sharedInstance] widthForContent:body.callText withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];

    // if (bubbleSize.height>45.0f) {
    height = bubbleSize.height+40.0f;
    // }
    return height;
    
    
//    if (bubbleSize.height>45.0f) {
//        height = bubbleSize.height+20.0f;
//    }
    return height;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    NSMutableAttributedString* optimizedAttributedText = [_label.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [_label.attributedText enumerateAttributesInRange:NSMakeRange(0, [_label.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName]) {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:_label.font range:NSMakeRange(0, [_label.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:_label.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
        
        if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        }
        
        [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
        [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
    }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = _label.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_label.attributedText length]), path, NULL);
    CFRelease(framesetter);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = _label.numberOfLines > 0 ? MIN(_label.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_label.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            } else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _label.attributedText = attributedString;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECCallMessageBody *body = (ECCallMessageBody *)self.displayMessage.messageBody;
    if (body.callText == nil) {
        body.callText = @"";
    }
    self.urlMatches = [self.detector matchesInString:body.callText options:0 range:NSMakeRange(0, body.callText.length)];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:body.callText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [body.callText length])];
    [attributedString addAttribute:NSFontAttributeName value:ThemeFontLarge range:NSMakeRange(0, [body.callText length])];
    [_label setAttributedText:attributedString];
    [self highlightLinksWithIndex:NSNotFound];

    CGSize bubbleSize;
    if ([self.displayMessage getHeight]<=0) {
        bubbleSize = [[Common sharedInstance] widthForContent:body.callText withSize:BubbleMaxSize withLableFont:ThemeFontLarge.pointSize];
        [self.displayMessage setHeight: bubbleSize.height];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [[KitMsgData sharedInstance] updateHeight:bubbleSize.height ofMessageId: self.displayMessage.messageId andSession:self.displayMessage.sessionId];
//        });
    }else{
        bubbleSize = CGSizeMake(BubbleMaxSize.width,[self.displayMessage getHeight]);
    }
    CGFloat repairHeight = 0;
#pragma clang diagnostic pop
    if (bubbleSize.height<40.0f) {
        repairHeight=0.7;
    }
    if (self.isSender) {
        _label.frame = CGRectMake(9.0f, 10.0f+repairHeight, bubbleSize.width, bubbleSize.height);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x-bubbleSize.width-25.0f-10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+25.0f, bubbleSize.height+20+repairHeight*2);
    } else {
        _label.frame = CGRectMake(16.0f, 10.0f+repairHeight, bubbleSize.width, bubbleSize.height);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+self.portraitImg.frame.size.width+10.0f, self.portraitImg.frame.origin.y, bubbleSize.width+25.0f, bubbleSize.height+20+repairHeight*2);
    }
    [super bubbleViewWithData:message];
}

@end
