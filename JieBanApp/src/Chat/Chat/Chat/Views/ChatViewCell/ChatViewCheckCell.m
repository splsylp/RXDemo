//
//  ChatViewCheckCell.m
//  ECSDKDemo_OC
//
//  Created by yuxuanpeng on 16/2/3.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCheckCell.h"
#import <CoreText/CoreText.h>
NSString *const KResponderCustomChatViewTextCheckCellBubbleViewEvent = @"KResponderCustomChatViewTextCheckCellBubbleViewEvent";

#define BubbleMaxSize CGSizeMake(180.0f, 1000.0f)

@implementation ChatViewCheckCell

-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        
        shView = [[UIView alloc] init];
        shView.frame = CGRectMake(0.0f, 0.0f, 230, 160);
        [self.bubbleView addSubview:shView];

        spimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 230, 40)];
        spimage.image = [ThemeImage(@"chating_left_a") resizableImageWithCapInsets:UIEdgeInsetsMake(17.5, 17.5, 2,17.5) resizingMode:UIImageResizingModeStretch];
        spimage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [shView addSubview:spimage];

        checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 230, 120)];
        checkImage.image = [ThemeImage(@"chating_left_b") resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 15, 7.5,15) resizingMode:UIImageResizingModeStretch];
        //checkImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [shView addSubview:checkImage];

        labelCheck = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 180, 20)];
        labelCheck.text = languageStringWithKey(@"审批");
        labelCheck.font = ThemeFontLarge;
        [spimage addSubview:labelCheck];

        labelPrompt = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 16)];
        labelPrompt.font =ThemeFontSmall;
        labelPrompt.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
        [checkImage addSubview:labelPrompt];

        labelAPRV_End = [[UILabel alloc] initWithFrame:CGRectMake(15, 38, 77, 15)];
        labelAPRV_End.text = languageStringWithKey(@"审批截止日期:");
        labelAPRV_End.textColor= [UIColor colorWithRed:0.72f green:0.73f blue:0.73f alpha:1.00f];
        labelAPRV_End.font =ThemeFontSmall;
        [checkImage addSubview:labelAPRV_End];

        timeLable =  [[UILabel alloc]initWithFrame:CGRectMake(labelAPRV_End.right+5, 38,215-labelAPRV_End.right , 15)];
        //timeLable.text = @"2015-10-28";
        timeLable.textColor = [UIColor colorWithRed:0.38f green:0.78f blue:0.93f alpha:1.00f];
        timeLable.font =ThemeFontSmall;
        [checkImage addSubview:timeLable];

        labelAPRVTitle =  [[UILabel alloc] initWithFrame:CGRectMake(15, 60, 52, 15)];
        labelAPRVTitle.text = languageStringWithKey(@"申请标题:");
        labelAPRVTitle.textColor = [UIColor colorWithRed:0.72f green:0.72f blue:0.73f alpha:1.00f];
        labelAPRVTitle.font =ThemeFontSmall;
        [checkImage addSubview:labelAPRVTitle];

        _labelAPRV_Src = [[UILabel alloc] initWithFrame:CGRectMake(labelAPRVTitle.right+7, 60, 192-labelAPRVTitle.right, 15)];
        //_labelAPRV_Src.text = @"年假婚假连清16天";
        _labelAPRV_Src.font =ThemeFontSmall;
        [checkImage addSubview:_labelAPRV_Src];

        labelLine = [[UILabel alloc] initWithFrame:CGRectMake(15, 81, 200, 1)];
        labelLine.backgroundColor = [UIColor colorWithRed:0.81f green:0.82f blue:0.82f alpha:1.00f];
        [checkImage addSubview:labelLine];

        _label= [[UILabel alloc]initWithFrame:CGRectMake(15, 93, 180, 15)];
        _label.text = languageStringWithKey(@"查看详情");
        _label.font =ThemeFontSmall;
        [checkImage addSubview:_label];

        arrowheadImg = [[UIImageView alloc] initWithFrame:CGRectMake(195, 94, 14, 14)];
        arrowheadImg.image = ThemeImage(@"enter_icon_02");
        arrowheadImg.backgroundColor = [UIColor clearColor];
        [checkImage addSubview:arrowheadImg];
    }
    return self;
}
-(void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    
    //    [self dispatchCustomEventWithName:KResponderCustomChatViewTextCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage}];
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewTextCheckCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
}

+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    return 180;
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;

    ECTextMessageBody *body = (ECTextMessageBody *)self.displayMessage.messageBody;
    if (body.text == nil) {
        body.text = @"";
    }
    if (self.isSender) {
        return;
    }
    NSDictionary *im_mode = message.userDataToDictionary;
    if([im_mode hasValueForKey:@"IM_Mode"]){
        //NSString *timestamp = self.displayMessage.timestamp;
        if([[im_mode objectForKey:@"APRV_EndDateTime"] length] > 0){
            NSString *timestamp =[NSString stringWithFormat:@"%lld", (long long)[im_mode objectForKey:@"APRV_EndDateTime"]];
            timeLable.text = [self getDateCheckString:timestamp.longLongValue];
        }
        _labelAPRV_Src.text = [im_mode objectForKey:@"APRVTitle"];
        labelPrompt.text = [im_mode objectForKey:@"APRV_Content"];
    }
    self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 230, 160);
    self.bubleimg.hidden = YES;
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
