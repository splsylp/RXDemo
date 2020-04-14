//
//  RXGroupMemberCell.m
//  Chat
//
//  Created by apple on 2019/11/20.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "RXGroupMemberCell.h"

@interface RXGroupMemberCell ()

@property (nonatomic, strong) UIImageView *picImage;

@property (nonatomic, strong) UILabel *nameLab;

@property (nonatomic, strong) UILabel *phoneNumLab;

@property (nonatomic, strong) UILabel *positionLab;

@property (nonatomic, strong) UILabel *roleLabel;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation RXGroupMemberCell

- (instancetype)initWithInTableView:(UITableView *)tableView withStyle:(RXGroupMembersStyle)style atIndexPath:(nonnull NSIndexPath *)indexPath {
    
    RXGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personTableViewCell"];
        if (cell == nil) {
            cell = [[RXGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.style = style;
            cell.indexPath = indexPath;
            cell.backgroundColor = [UIColor whiteColor];
            
            UIButton *selectBtn = [UIButton new];
            cell.selectBtn = selectBtn;
            if(style == RXGroupMembersStyleSetAdmin) {
                selectBtn.frame = CGRectMake(10, 17, 22, 22);
            }
            else {
                selectBtn.frame = CGRectZero;
            }
            [selectBtn setImage:KKThemeImage(@"choose_icon") forState:UIControlStateNormal];
            [selectBtn setImage:KKThemeImage(@"choose_icon_on") forState:UIControlStateSelected];
            [cell.contentView addSubview:selectBtn];
            
            UIImageView * picImage = [[UIImageView alloc] initWithFrame:CGRectMake(selectBtn.right + 10, 10*FitThemeFont, 36*FitThemeFont, 36*FitThemeFont)];
            cell.picImage = picImage;
            picImage.layer.cornerRadius=5;
            picImage.layer.masksToBounds=YES;
            picImage.contentMode = UIViewContentModeScaleAspectFill;
            [cell.contentView addSubview:picImage];
            
            UILabel * nameLab = [[UILabel alloc] initWithFrame:CGRectMake(picImage.right + 12*FitThemeFont, 7*FitThemeFont, 80*FitThemeFont, 20*FitThemeFont)];
            cell.nameLab = nameLab;
            nameLab.font = ThemeFontLarge;
            [cell.contentView addSubview:nameLab];
            
            UILabel *positionLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right+10, 7*FitThemeFont, 150*FitThemeFont, 20*FitThemeFont)];
            cell.positionLab = positionLab;
            positionLab.font = ThemeFontMiddle;
            positionLab.backgroundColor = [UIColor clearColor];
            positionLab.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:positionLab];
            
            UILabel * phoneNumLab = [[UILabel alloc] initWithFrame:CGRectMake(picImage.right + 12*FitThemeFont, 32*FitThemeFont, 100*FitThemeFont, 16*FitThemeFont)];
            cell.phoneNumLab = phoneNumLab;
            phoneNumLab.font = ThemeFontMiddle;
            phoneNumLab.textColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:phoneNumLab];
            
            UILabel *roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 70, 18, 43, 20)];
            cell.roleLabel = roleLabel;
            roleLabel.font = ThemeFontMiddle;
            roleLabel.textAlignment = NSTextAlignmentRight;
            roleLabel.textColor = [UIColor colorWithHexString:@"666666"];
            [cell.contentView addSubview:roleLabel];
            
            if (style == RXGroupMembersStyleDeleteAdmin) {
                UIButton *delBtn = [UIButton new];
                if (isEnLocalization) {
                    delBtn.frame = CGRectMake(kScreenWidth - 96, 15, 80, 26);
                } else {
                    delBtn.frame = CGRectMake(kScreenWidth - 66, 15, 50, 26);
                }
                delBtn.backgroundColor = [UIColor colorWithHex:0xD4D4D4];
                delBtn.layer.borderWidth = 1;
                delBtn.layer.borderColor = [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1.0].CGColor;
                delBtn.layer.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0].CGColor;
                delBtn.layer.cornerRadius = 4;
                [delBtn setTitle:languageStringWithKey(@"移除") forState:UIControlStateNormal];
                [delBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                delBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [delBtn addTarget:cell action:@selector(delBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:delBtn];
            }
            
            // 分割线
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 55*FitThemeFont, kScreenWidth-10, 1)];
            lineView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];;
            [cell.contentView addSubview:lineView];
            
//            if(_isGroupInfo && _isAuther){
//                //增加侧滑删除 ios8以上有 否则长按删除
//                if(!iOS8){
//                    UILongPressGestureRecognizer  * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
//                    [cell.contentView addGestureRecognizer:longPress];
//                    cell.contentView.userInteractionEnabled = YES;
//                }
//            }
        }
    return cell;
}

- (void)setMebmerInfo:(KitGroupMemberInfoData *)mebmerInfo {
    _mebmerInfo = mebmerInfo;
    KitGroupMemberInfoData * dataInfo = _mebmerInfo;
    self.roleLabel.adjustsFontSizeToFitWidth = YES;
    if ([dataInfo.role isEqualToString:@"1"]) {
            self.roleLabel.text = languageStringWithKey(@"群主");
        }
        else if ([dataInfo.role isEqualToString:@"2"] && _style != RXGroupMembersStyleDeleteAdmin){
            self.roleLabel.text = languageStringWithKey(@"管理员");
        }
        else {
            self.roleLabel.text = @"";
        }
        
        NSDictionary *companyInfo = [[Chat sharedInstance].componentDelegate getDicWithId:dataInfo.memberId withType:0];
        if(companyInfo) {
            NSString *nameStr = companyInfo[Table_User_member_name];
            self.nameLab.text = !KCNSSTRING_ISEMPTY(nameStr)?nameStr:dataInfo.memberName;
            if ([self.nameLab.text isEqualToString:dataInfo.memberId]) {
                self.nameLab.text = @"无名称";
            }
            NSString *deptName = [[AppModel sharedInstance] getDeptNameWithDeptID:companyInfo[@"department_id"]];
            if (KCNSSTRING_ISEMPTY(deptName)) {
                deptName = companyInfo[@"depart_name"];
            }
            self.phoneNumLab.text = deptName;

            self.positionLab.text = companyInfo[Table_User_position_name]?[NSString stringWithFormat:@"  |  %@",companyInfo[Table_User_position_name]]:@"";
            
            NSString *headImageUrl = companyInfo[Table_User_avatar];
            if (!KCNSSTRING_ISEMPTY(headImageUrl) && companyInfo[Table_User_urlmd5]) {
    #if isHeadRequestUserMd5
                [picImage setImageWithURLString:headImageUrl urlmd5:companyInfo[Table_User_urlmd5] options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(picImage.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]) withRefreshCached:NO];
    #else
                [self.picImage sd_setImageWithURL:[NSURL URLWithString:headImageUrl] placeholderImage:ThemeDefaultHead(self.picImage.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
    #endif
            }else{
    #pragma mark zmfg HYTVoipInfoData相关 该走哪一个?
                [self.picImage sd_cancelCurrentImageLoad];
                self.picImage.image = ThemeDefaultHead(self.picImage.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]);
            }
        } else {
            self.nameLab.text = !(KCNSSTRING_ISEMPTY(dataInfo.memberName))?dataInfo.memberName:@"无名称";
            if ([self.nameLab.text isEqualToString:dataInfo.memberId]) {
                self.nameLab.text = @"无名称";
            }
            NSString *deptName = [[AppModel sharedInstance] getDeptNameWithDeptID:companyInfo[@"department_id"]];
            self.phoneNumLab.text = deptName;
            
            self.positionLab.text = @"";
            if (!KCNSSTRING_ISEMPTY(dataInfo.headUrl)) {
    #if isHeadRequestUserMd5
                [self.picImage setImageWithURLString:dataInfo.headUrl urlmd5:dataInfo.headMd5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(picImage.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]) withRefreshCached:NO];
    #else
                [self.picImage sd_setImageWithURL:[NSURL URLWithString:dataInfo.headUrl] placeholderImage:ThemeDefaultHead(self.picImage.size, companyInfo[Table_User_member_name], companyInfo[Table_User_account]) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
    #endif
            } else{
                [self.picImage sd_cancelCurrentImageLoad];
                self.picImage.image = ThemeDefaultHead(self.picImage.size, dataInfo.memberId, dataInfo.memberId);
            }
        }
    
    //适配名字和职位长度
    CGSize size = [self.nameLab.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
    CGFloat nameWidth = size.width;
    CGFloat posiWidth = self.positionLab.width;
    CGFloat maxWidth = kScreenWidth - 60;
    if ([dataInfo.role isEqualToString:@"1"] || [dataInfo.role isEqualToString:@"2"]) {
        maxWidth = kScreenWidth - 130;
    }
    if (nameWidth + posiWidth > maxWidth) {
        nameWidth = size.width > 120 ? 120 : size.width;
        posiWidth = self.positionLab.width > maxWidth - nameWidth ? maxWidth - nameWidth : self.positionLab.width;
    }
    
    self.nameLab.frame = CGRectMake(self.nameLab.originX, self.nameLab.originY, nameWidth, self.nameLab.size.height);
    self.positionLab.frame = CGRectMake(self.nameLab.right, self.positionLab.originY, posiWidth, self.positionLab.height);
}

- (void)delBtnClicked {
    RXCommonDialog *dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
    [dialog showTitle:[NSString stringWithFormat:@"确定将%@移出群管理员列表?",self.nameLab.text] subTitle:nil ensureStr:languageStringWithKey(@"确定") cancalStr:languageStringWithKey(@"取消") selected:^(NSInteger index) {
        if (index == 1) {
            if ([self.gmDelegate respondsToSelector:@selector(deleteAdminAtIndexPath:)]) {
                [self.gmDelegate deleteAdminAtIndexPath:self.indexPath];
            }
        }
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectBtn.selected = selected;
    // Configure the view for the selected state
}

@end
