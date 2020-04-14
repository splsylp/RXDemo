//
//  ChatSPTableViewController.m
//  ECSDKDemo_OC
//
//  Created by lrn on 15/11/2.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "ChatSPTableViewController.h"
#import "NSAttributedString+Color.h"

//NSString *const KResponderCustomChatViewTextCheckCellBubbleViewEvent = @"KResponderCustomChatViewTextCheckCellBubbleViewEvent";

#define screenScale fitScreenWidth

#define TitleH  21  //标题的高度
#define OtherH  17  //其他label的高度
#define LineH   5*fitScreenWidth //间距
@interface ChatSPTableViewController ()
@property (nonatomic, strong)NSDataDetector *detector;
@property (nonatomic, strong) NSArray *urlMatches;
@end

@implementation ChatSPTableViewController
{
    UILabel * labelCheck;//审批
    UILabel * labelPrompt;//提示
    UILabel * labelAPRVTitle;//标题
    UILabel *labelAPRV_Start;//开始时间提示
    UILabel * labelAPRV_End;//截止时间提示
    UILabel * labelLine;//间隔线
    UILabel *_labelAPRV_Src;//标题事件
    UILabel *_label;
    UIView * shView;//总事件View
    UILabel *startTimeLable;//开始时间
    UILabel *endTimeLabel;//截止时间
    UIImageView *arrowheadImg;//箭头
    UILabel *reasonLabel;//批注
    UILabel *showReason;//显示批注
}
-(instancetype) initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        shView = [[UIView alloc]init];
        shView.frame = CGRectMake(0.0f, 0.0f, 230*screenScale, 170*screenScale);
        [self.bubbleView addSubview:shView];
        //审批标签头
        labelCheck =[[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, 2*LineH, 180*screenScale, TitleH)];
        //        labelCheck.text=@"请假申请";
        labelCheck.font = ThemeFontLarge;
        [shView addSubview:labelCheck];
        
        //审批信息提示
        labelPrompt = [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, CGRectGetMaxY(labelCheck.frame)+LineH, 200*screenScale, OtherH)];
        labelPrompt.numberOfLines =0;
        labelPrompt.font = ThemeFontMiddle;
        labelPrompt.textColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.00f];
        [shView addSubview:labelPrompt];
        //理由
        reasonLabel = [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, CGRectGetMaxY(labelPrompt.frame)+LineH, 35, OtherH)];
        reasonLabel.text = @"批注:";
        reasonLabel.hidden = YES;
        reasonLabel.font = ThemeFontMiddle;
        reasonLabel.textColor = [UIColor colorWithRGB:0xff5454];
        [shView addSubview:reasonLabel];
        
        //显示理由
        showReason = [[UILabel alloc]initWithFrame:CGRectMake(reasonLabel.right, CGRectGetMaxY(labelPrompt.frame)+LineH, 210*screenScale-35, OtherH)];
        //        showReason.text = @"批注:";
        showReason.hidden = YES;
        showReason.textColor = [UIColor colorWithRGB:0xff5454];
        showReason.numberOfLines = 0;
        showReason.font = ThemeFontMiddle;
        //showReason.textColor = [UIColor colorWithRGB:0xff5454];
        [shView addSubview:showReason];
        
        
        labelAPRV_Start =  [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, 0, 65, OtherH)];
        labelAPRV_Start.text = @"开始时间:";
        labelAPRV_Start.textColor=[UIColor colorWithRed:0.72f green:0.73f blue:0.73f alpha:1.00f];
        labelAPRV_Start.font = ThemeFontMiddle;
        [shView addSubview:labelAPRV_Start];
        
        //用于显示开始时间
        startTimeLable =  [[UILabel alloc]initWithFrame:CGRectMake(labelAPRV_Start.right, 0,(215*screenScale-labelAPRV_Start.right)*screenScale , OtherH)];
        startTimeLable.textColor =[UIColor colorWithRed:0.38f green:0.78f blue:0.93f alpha:1.00f];
        startTimeLable.font =ThemeFontSmall;
        [shView addSubview:startTimeLable];
        
        //截止日期
        labelAPRV_End =  [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, CGRectGetMaxY(labelAPRV_Start.frame), 65, OtherH)];
        labelAPRV_End.text = @"结束时间:";
        labelAPRV_End.textColor=[UIColor colorWithRed:0.72f green:0.73f blue:0.73f alpha:1.00f];
        labelAPRV_End.font = ThemeFontMiddle;
        [shView addSubview:labelAPRV_End];
        
        //用于显示截止时间
        endTimeLabel =  [[UILabel alloc]initWithFrame:CGRectMake(labelAPRV_End.right, CGRectGetMaxY(labelAPRV_Start.frame),(215*screenScale-labelAPRV_End.right)*screenScale , OtherH)];
        //timeLable.text = @"2015-10-28";
        endTimeLabel.textColor =[UIColor colorWithRed:0.38f green:0.78f blue:0.93f alpha:1.00f];
        endTimeLabel.font =ThemeFontSmall;
        [shView addSubview:endTimeLabel];
        
        //请假类型label
        labelAPRVTitle =  [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, CGRectGetMaxY(labelAPRV_End.frame)+5*screenScale, 65, OtherH)];
        labelAPRVTitle.text = @"类型:";
        labelAPRVTitle.textColor=[UIColor colorWithRed:0.72f green:0.72f blue:0.73f alpha:1.00f];
        labelAPRVTitle.font = ThemeFontMiddle;
        [shView addSubview:labelAPRVTitle];
        
        //用于显示请假类型内容
        _labelAPRV_Src =  [[UILabel alloc]initWithFrame:CGRectMake(labelAPRVTitle.right, CGRectGetMinY(labelAPRVTitle.frame), (192*screenScale-labelAPRVTitle.right)*screenScale, OtherH)];
        _labelAPRV_Src.font = ThemeFontMiddle;
        _labelAPRV_Src.textColor = [UIColor colorWithRGB:0xff5454];
        [shView addSubview:_labelAPRV_Src];
        
        //分隔线
        labelLine= [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, CGRectGetMaxY(labelAPRVTitle.frame)+5*screenScale, 200*screenScale, 0.6)];
        labelLine.backgroundColor = [UIColor colorWithRed:0.81f green:0.82f blue:0.82f alpha:1.00f];
        [shView addSubview:labelLine];
        //查看详情
        _label= [[UILabel alloc]initWithFrame:CGRectMake(15*screenScale, CGRectGetMaxY(labelLine.frame)+LineH, 180*screenScale, OtherH)];
        _label.text = @"查看详情";
        _label.font = ThemeFontMiddle;
        [shView addSubview:_label];
        //箭头
        arrowheadImg =[[UIImageView alloc]initWithFrame:CGRectMake(200*screenScale, CGRectGetMaxY(labelLine.frame)+LineH, 12*screenScale, 12*screenScale)];
        arrowheadImg.image=ThemeImage(@"enter_icon_02");
        arrowheadImg.backgroundColor=[UIColor clearColor];
        [shView addSubview:arrowheadImg];
        
    }
    return self;
}
-(void)bubbleViewTapGesture:(UITapGestureRecognizer *)tap{
    
    [self dispatchCustomEventWithName:KResponderCustomChatViewTextCheckCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:tap];
}
+(CGFloat)getSpecialHightOfCellViewWith:(ECMessage *)message{
    NSDictionary *im_mode =  [MessageTypeManager getCusDicWithUserData:message.userData];
    //内容高度
    CGSize reasonSize = [[Common sharedInstance] widthForContent:[im_mode objectForKey:@"APRV_Remark"] withSize:CGSizeMake(180*screenScale, CGFLOAT_MAX) withLableFont:ThemeFontLarge.pointSize];
    CGSize promptSize = [[Common sharedInstance] widthForContent:[im_mode objectForKey:@"APRV_Content"] withSize:CGSizeMake(180*screenScale, CGFLOAT_MAX) withLableFont:ThemeFontLarge.pointSize];
    return promptSize.height + reasonSize.height + 190;
}
//废弃不使用
+(CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    
    return 180*fitScreenHeight;
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
        //内容
        labelPrompt.text = [im_mode objectForKey:@"APRV_Content"];
        CGSize promptSize = [self getTextSize:labelPrompt.text width:180*screenScale lableFont:ThemeFontLarge.pointSize];
        labelPrompt.height = promptSize.height;
        //理由 有就显示批准内容
        if([[im_mode objectForKey:@"APRV_Remark"] length] > 0){
            showReason.text = [im_mode objectForKey:@"APRV_Remark"];
            reasonLabel.hidden = NO;
            showReason.hidden = NO;

            CGSize reasonSize = [self getTextSize:showReason.text width:210*screenScale-35 lableFont:ThemeFontLarge.pointSize];
            showReason.height = reasonSize.height;
            showReason.originY = CGRectGetMaxY(labelPrompt.frame)+5*screenScale;
            startTimeLable.originY = CGRectGetMaxY(showReason.frame)+5*screenScale;
        }else{
            reasonLabel.hidden = YES;
            showReason.hidden = YES;
            startTimeLable.originY = CGRectGetMaxY(labelPrompt.frame)+5*screenScale;
        }
        //开始时间
        if([[im_mode objectForKey:@"APRV_StartDateTime"] length] > 0){
            long long timestamp = [[im_mode objectForKey:@"APRV_StartDateTime"]longLongValue];
            startTimeLable.text = [self getDateCheckString:timestamp];
        }
        //结束时间
        if([[im_mode objectForKey:@"APRV_EndDateTime"] length] > 0){
            long long timestamp = [[im_mode objectForKey:@"APRV_EndDateTime"] longLongValue];
            endTimeLabel.text = [self getDateCheckString:timestamp];
        }
        //判断收发消息类型
        NSString *currentCheckString =nil;
        //请假状态标红
        NSString *statusString = @"";
        //add yuxp  2017.12.4 新增会议类型
        NSInteger arrvType = [[im_mode objectForKey:@"APRV_Type"] integerValue];
        switch (arrvType) {
            case 1:{
                currentCheckString = [self getMessageTitletext:im_mode];
                statusString = [self getMessageStates:im_mode];
            }
                break;
            case 2:{
                currentCheckString = @"会议通知";
            }
                break;
            case 3:{
                currentCheckString = @"日志通知";
            }
                break;
            default:
                labelAPRVTitle.text = @"请假类型:";
                currentCheckString = [self getMessageTitletext:im_mode];
                statusString = [self getMessageStates:im_mode];
                break;
        }
        if(!KCNSSTRING_ISEMPTY(statusString)){
            labelCheck.attributedText = [NSAttributedString attributeStringWithContent:[NSString stringWithFormat:@"%@ (%@)",currentCheckString,statusString] keyWords:[NSString stringWithFormat:@"(%@)",statusString] colors:[UIColor colorWithRGB:0xff5454]];
        }else{
            labelCheck.text = currentCheckString;
        }
        //类型内容
        _labelAPRV_Src.text = [im_mode objectForKey:@"APRVTitle"];
        //修改坐标显示位置
        [self setChangeShowFrame];
    }
    [super bubbleViewWithData:message];
}

- (NSString *)getDateCheckString:(long long ) miliSeconds{
    NSTimeInterval tempMilli = miliSeconds;
    //    NSDate *currentDate = [NSDate date];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:tempMilli];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd hh:ss";
    NSString *string = [formatter stringFromDate:date];
    return string;
}

//add yuxp 2017.12.4 修改坐标显示
- (void)setChangeShowFrame{
    reasonLabel.originY = showReason.originY;
    labelAPRV_Start.originY = startTimeLable.originY;
    endTimeLabel.originY = CGRectGetMaxY(startTimeLable.frame)+LineH;
    labelAPRV_End.originY = endTimeLabel.originY;
    labelAPRVTitle.originY = CGRectGetMaxY(endTimeLabel.frame)+LineH;
    _labelAPRV_Src.originY = labelAPRVTitle.originY;
    labelLine.originY = CGRectGetMaxY(_labelAPRV_Src.frame)+LineH+2*screenScale;
    _label.originY = CGRectGetMaxY(labelLine.frame)+LineH;
    arrowheadImg.originY = CGRectGetMaxY(labelLine.frame)+LineH;
    shView.height = arrowheadImg.bottom+LineH+4;
    self.bubbleView.frame = CGRectMake(self.portraitImg.frame.origin.x+10+self.portraitImg.frame.size.width, self.portraitImg.frame.origin.y, 230*screenScale, shView.height);
}

#pragma mark 消息数据解析
//获取审批标题
- (NSString *)getMessageTitletext:(NSDictionary *)im_Dic{
    NSString *currentCheckString = nil;
    if([[im_Dic objectForKey:@"CREATE_YN"] length] > 0){
        currentCheckString = @"请假审批";
    }else{
        currentCheckString = @"请假申请";
    }
    return currentCheckString;
}

//获取审批状态
- (NSString *)getMessageStates:(NSDictionary *)im_Dic{
    NSInteger status = [im_Dic intValueForKey:@"APRV_Status"];
    NSString *statusString = @"";
    if (status == 3) {
        statusString = @"审批中";
    }else if(status==4){
        statusString = @"通过";
    }else if (status==5){
        statusString = @"未通过";
    }
    return statusString;
}

- (CGSize)getTextSize:(NSString *)string width:(CGFloat)width lableFont:(NSInteger)font{
    CGSize textSize = [[Common sharedInstance] widthForContent:string withSize:CGSizeMake(width, CGFLOAT_MAX) withLableFont:font];
    return textSize;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

@end


