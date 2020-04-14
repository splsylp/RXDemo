//
//  ChatViewCardCell.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 16/7/27.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ChatViewCardCell.h"

#define CellH 110.0f
#define CellW ((kScreenWidth*2/3)-10)
//分割线
#define LineColor [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f]

@implementation ChatViewCardCell{
    UIView *line;
}

- (instancetype)initWithIsSender:(BOOL)isSender reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithIsSender:isSender reuseIdentifier:reuseIdentifier]) {
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textColor = [UIColor grayColor];
        self.titleLab.font =ThemeFontSmall;
        [self.bubbleView addSubview:self.titleLab];
        
        line = [[UIView alloc] init];
        line.backgroundColor = LineColor;
        [self.bubbleView addSubview:line];
        
        self.photoImg = [[UIImageView alloc] init];
        [self.bubbleView addSubview:self.photoImg];
        
        self.nameLab = [[UILabel alloc] init];
        self.nameLab.font = ThemeFontLarge;
        [self.bubbleView addSubview:self.nameLab];
        
        self.phoneLab = [[UILabel alloc] init];
        self.phoneLab.textColor = [UIColor colorWithHexString:@"#999999"];
        self.phoneLab.font = ThemeFontMiddle;
        [self.bubbleView addSubview:self.phoneLab];
        
        self.publicNameLab = [[UILabel alloc] init];
        self.publicNameLab.font = ThemeFontLarge;
        self.publicNameLab.numberOfLines = 0;
        [self.bubbleView addSubview:self.publicNameLab];
        
        if (isSender) {
            self.bubbleView.frame = CGRectMake(CGRectGetMinX(self.portraitImg.frame) - CellW - 10, self.portraitImg.originY, CellW-10, CellH - 10);
            self.bubleimg.image = [ThemeImage(@"chat_sender_preView") stretchableImageWithLeftCapWidth:33 topCapHeight:33];
            
            self.photoImg.frame = CGRectMake(15, 15, 50, 50);
            self.nameLab.frame = CGRectMake(self.photoImg.right + 5, self.photoImg.originY, self.bubbleView.width - self.photoImg.right - 10, 20);
            self.phoneLab.frame = CGRectMake(self.photoImg.right + 5, self.nameLab.bottom + 10, 120, 20);
            line.frame = CGRectMake(8, self.photoImg.bottom + 10, CellW - 18, 1);
            self.titleLab.frame = CGRectMake(15, line.bottom + 3, CellW - 50, 15);
            
            self.publicNameLab.frame = CGRectMake(self.photoImg.right + 5, self.photoImg.originY, self.bubbleView.width - self.photoImg.right - 10, self.photoImg.height);
        } else {
            self.bubbleView.frame = CGRectMake(CGRectGetMaxX(self.portraitImg.frame) + 10.0f, self.portraitImg.originY, CellW - 10, CellH - 10);
            
            self.photoImg.frame = CGRectMake(15, 15, 50, 50);
            self.nameLab.frame = CGRectMake(self.photoImg.right + 5, self.photoImg.originY, self.bubbleView.width - self.photoImg.right - 10, 20);
            self.phoneLab.frame = CGRectMake(self.photoImg.right + 5, self.nameLab.bottom + 10, 120, 20);
            line.frame = CGRectMake(8, self.photoImg.bottom + 10, CellW - 18, 1);
            self.titleLab.frame = CGRectMake(15, line.bottom + 3, CellW - 50, 15);
            
            self.publicNameLab.frame = CGRectMake(self.photoImg.right + 5, self.photoImg.originY, self.bubbleView.width - self.photoImg.right - 10, self.photoImg.height);
        }
        self.photoImg.layer.cornerRadius = 4.f;
        self.photoImg.layer.masksToBounds = YES;
    }
    return self;
}

+ (CGFloat)getHightOfCellViewWith:(ECMessageBody *)message{
    return 120.0f;
}

NSString *const KResponderCustomChatViewCardCellBubbleViewEvent = @"KResponderCustomChatViewCardCellBubbleViewEvent";

- (void)bubbleViewTapGesture:(id)sender {
    [self dispatchCustomEventWithName:KResponderCustomChatViewCardCellBubbleViewEvent userInfo:@{KResponderCustomECMessageKey:self.displayMessage} tapGesture:sender];
}

- (void)bubbleViewWithData:(ECMessage *)message{
    self.displayMessage = message;
    NSDictionary *imCard_jsonDic = [MessageTypeManager getCusDicWithUserData:message.userData];
    NSDictionary *cardData = [imCard_jsonDic hasValueForKey:SMSGTYPE] ? imCard_jsonDic:imCard_jsonDic[ShareCardMode];
    
    //1个人 2服务号
    NSInteger type = [cardData[@"type"] integerValue];//个人

    self.nameLab.frame = CGRectMake(self.nameLab.originX, self.nameLab.originY, self.nameLab.width, self.nameLab.height);
    if (type == 1) {
        self.titleLab.text = languageStringWithKey(@"个人名片");
        NSDictionary *dict = [[Chat sharedInstance].componentDelegate getDicWithId:cardData[@"account"] withType:0];
        NSString *userStatus = dict[Table_User_status];
        if([userStatus isEqualToString:@"3"]){
            self.photoImg.image = ThemeDefaultHead(self.photoImg.size,RXleaveJobImageHeadShowContent,cardData[@"account"]);
        }else{
            [self.photoImg setImageWithURLString:dict[@"avatar"] urlmd5:dict[@"urlmd5"] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.photoImg.size, dict[Table_User_member_name],cardData[@"account"]) withRefreshCached:NO];
        }
        self.phoneLab.hidden = NO;
        self.nameLab.hidden = NO;
        self.publicNameLab.hidden = YES;
        NSString *strPhone = dict[@"mobile"];
        self.phoneLab.text = clientShowInfomation?(HXLevelisFristAndSecond([dict[@"level"] intValue],dict[@"account"]))?hiddenMobileAndShowDefault:!KCNSSTRING_ISEMPTY(strPhone)?strPhone:@"":!KCNSSTRING_ISEMPTY(strPhone)?strPhone:@"";
        if ([dict[Table_User_member_name] length]>0) {
            NSString *deptName = [[Chat sharedInstance].componentDelegate getDeptNameWithDeptID:dict[Table_User_department_id]];
            self.phoneLab.text = deptName;
        }
        
        self.nameLab.text = dict[@"member_name"]?dict[@"member_name"]:[cardData objectForKey:@"account"];
//        if ([dict[Table_User_position_name] length]>0) {
//            self.nameLab.text = [NSString stringWithFormat:@"%@ | %@",self.nameLab.text,dict[Table_User_position_name]];
//        }
        self.nameLab.attributedText = [NSAttributedString setAttributedStringWithNameAttributedString:self.nameLab.attributedText withPlaceString:dict[Table_User_position_name] withPlaceColor:[UIColor colorWithHexString:@"#666666"]];
        
    }else if(type == 2){
        self.titleLab.text = languageStringWithKey(@"服务号名片");
        [self.photoImg sd_setImageWithURL:[cardData objectForKey:@"pn_photourl"] placeholderImage:ThemeImage(@"attachment.png") options:0];
        self.publicNameLab.text = [cardData objectForKey:@"pn_name"];
        self.phoneLab.hidden = YES;
        self.nameLab.hidden = YES;
        self.publicNameLab.hidden = NO;
    }
    [super bubbleViewWithData:message];
}


- (NSDictionary *)getShareCardDic:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return dict;
}

@end
