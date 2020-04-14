//
//  ChatViewCoopCell.m
//  ECSDKDemo_OC
//
//  Created by lrn on 15/11/2.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "ChatViewCoopCell.h"
NSString *const KResponderCustomChatViewTextCoopCellBubbleViewEvent = @"KResponderCustomChatViewTextCoopCellBubbleViewEvent";

#define BubbleMaxSize CGSizeMake(180.0f, 1000.0f)

@interface ChatViewCoopCell ()
@property (nonatomic, strong)NSDataDetector *detector;
@property (nonatomic, strong) NSArray *urlMatches;
@end

@implementation ChatViewCoopCell
{
    UILabel * labelCheck;//审批
    UILabel * labelPrompt;//提示
    UILabel * labelLine;//间隔线
    UILabel *_label;
    UIView * shView;//总事件View
    UIImageView * spimage;//审批图片1
    UIImageView * checkImage;//审批图片2
    UIImageView *arrowheadImg;//箭头
}
- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        
        shView = [[UIView alloc] init];
        shView.frame = CGRectMake(0.0f, 0.0f, 230, 110);
        [self.bubbleView addSubview:shView];
        
        if(isSender){
            spimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 230, 40)];
            spimage.image = [ThemeImage(@"coop_right_a") resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15,20) resizingMode:UIImageResizingModeStretch];
        }else{
            spimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 230, 40)];
            spimage.image = [ThemeImage(@"coop_left_a") resizableImageWithCapInsets:UIEdgeInsetsMake(15, 20, 15,15) resizingMode:UIImageResizingModeStretch];
        }
//        spimage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [shView addSubview:spimage];

        checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 230, 70)];
        checkImage.image = [ThemeImage(@"coop_right_b") resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 15, 7.5,15) resizingMode:UIImageResizingModeStretch];
        [shView addSubview:checkImage];
        labelCheck = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 180, 20)];
        labelCheck.text=languageStringWithKey(@"文件协同");
        labelCheck.font = ThemeFontLarge;
        [spimage addSubview:labelCheck];

        labelPrompt = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 16)];
        labelPrompt.text = languageStringWithKey(@"邀请你加入文件协同");
        labelPrompt.font = ThemeFontMiddle;
        labelPrompt.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
        [checkImage addSubview:labelPrompt];
        
        labelLine = [[UILabel alloc] initWithFrame:CGRectMake(15, 31, 200, 1)];
        labelLine.backgroundColor = [UIColor colorWithRed:0.81f green:0.82f blue:0.82f alpha:1.00f];
        [checkImage addSubview:labelLine];

        _label = [[UILabel alloc] initWithFrame:CGRectMake(15, 43, 180, 15)];
        _label.text = languageStringWithKey(@"进入");
        _label.font =ThemeFontSmall;
        [checkImage addSubview:_label];

        arrowheadImg = [[UIImageView alloc] initWithFrame:CGRectMake(195, 44, 14, 14)];
        arrowheadImg.image = ThemeImage(@"enter_icon_02");
        arrowheadImg.backgroundColor = [UIColor clearColor];
        [checkImage addSubview:arrowheadImg];
    }
    return self;
}
- (void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    [self dispatchCustomEventWithName:KResponderCustomChatViewTextCoopCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 130;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
    if (body.text == nil) {
        body.text = @"";
    }
    labelPrompt.text = body.text;
    if (self.isSender){
        self.bubbleView.frame = CGRectMake(self.frame.size.width-230- 20 -self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 230, 110);
        self.bubleimg.hidden=YES;
        checkImage.frame = CGRectMake(0, 40, 230, 70);
    }else{
        checkImage.frame = CGRectMake(6, 40, 230, 70);
        self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 230, 110);
        self.bubleimg.hidden=YES;
    }
    [super bubbleViewWithData:message];
}
//时间显示内容
-(NSString *)getDateCheckString:(long long) miliSeconds{
    
    NSTimeInterval tempMilli = miliSeconds;
    NSTimeInterval seconds = tempMilli/1000.0;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    } else {
//        if (nowCmps.day==myCmps.day) {
//            dateFmt.dateFormat = @"今天 HH:mm:ss";
//        } else if ((nowCmps.day-myCmps.day)==1) {
//            dateFmt.dateFormat = @"昨天 HH:mm:ss";
//        } else {
//            dateFmt.dateFormat = @"MM-dd HH:mm:ss";
//        }
         dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return [dateFmt stringFromDate:myDate];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

@end
