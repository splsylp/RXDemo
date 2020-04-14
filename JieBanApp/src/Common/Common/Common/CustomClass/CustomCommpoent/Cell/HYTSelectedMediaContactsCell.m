//
//  HYTSelectedMediaContactsself.m
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-9.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import "HYTSelectedMediaContactsCell.h"
//水印视图
#include "WaterBackView.h"
#import "NSAttributedString+Color.h"
#import "UIImage+deal.h"
#import "UIImageView+Md5.h"
#import "RXThirdPart.h"

#import "KitAddressBook.h"
@implementation HYTSelectedMediaContactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = ThemeFontLarge;
    self.subTitleLabel.font =ThemeFontSmall;
    self.subTitleLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.titleLabel.text = @"";
    self.subTitleLabel.text = @"";
    _userHeadImageView.layer.cornerRadius = 4;//_userHeadImageView.frame.size.width/2;
    _userHeadImageView.layer.masksToBounds = YES;
    _groupImageView.layer.cornerRadius = 4;//_groupImageView.frame.size.width/2;
    _groupImageView.layer.masksToBounds = YES;
    _groupImageView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    self.selectedButton.hidden = NO;
    
    self.backgroundView = [[WaterBackView alloc] initWithFrame:self.contentView.frame];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.contentView addGestureRecognizer:tap];
    
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTapClick)];
    _userHeadImageView.userInteractionEnabled = YES;
    [_userHeadImageView addGestureRecognizer:tap2];
    
    [self.selectedButton setImage:ThemeImage(@"choose_icon") forState:UIControlStateNormal];
    [self.selectedButton setImage:ThemeImage(@"choose_icon_on") forState:UIControlStateSelected];
    
    // 默认不选中 不隐藏
    [self.selectedButton setSelected:NO];
    self.selectedButton.hidden = NO;
    
    self.selectionStyle=UITableViewCellSelectionStyleGray;
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView.hidden = NO;
}

- (void)setSelectedButton:(UIButton *)selectedButton {
    _selectedButton = selectedButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if (_selectedButton.hidden) {
//        self.selectButtonWidth.constant = 0;
//    }
//    else {
//        self.selectButtonWidth.constant = 50;
//    }
}

- (void)tapClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPersonCell:)]) {
        [self.delegate didSelectPersonCell:self];
    }
}

- (void)headTapClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPersonCellWithHeadImg:)]) {
        [self.delegate didSelectPersonCellWithHeadImg:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)actionHandle:(id)sender {
    UIButton* button = (UIButton*)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedMediaContactsCell: selected:)]) {
        [self.delegate selectedMediaContactsCell:self selected:button.selected];
    }
}
// 设置群组头像
-(void)setGroupHeaderView:(NSString *)groupId withArray:(NSArray *)array{
    [self.userHeadImageView sd_cancelCurrentImageLoad];
    self.userHeadImageView.image = ThemeImage(@"icon_groupdefaultavatar");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(array.count>1) {
                self.userHeadImageView.hidden = YES;
                self.groupImageView.hidden = NO;
                [self.groupImageView createHeaderViewH:self.groupImageView.width withImageWH:self.groupImageView.width groupId:groupId withMemberArray:array];
            }else{
                self.userHeadImageView.hidden = NO;
                self.groupImageView.hidden = YES;
            }
        });
    });
}
//设置企业 联系人cell
- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard{
    [self setPersonDataIndexPath:indexPath CompanyData:adressData withCard:isSendCard searchText:nil withDepartmentString:nil];
}
// 设置企业 联系人cell
- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard searchText:(NSString *)searchText withDepartmentString:(NSString *)departmentString{
    self.userHeadImageView.hidden = NO;
    self.groupImageView.hidden = YES;
    // 是否发送名片
    if (isSendCard == YES) {
        self.selectedButton.hidden = YES;
    }
    
    // 设置头像
    [self setHeadViewImageCompanyAddress:adressData];
    
    // 文字
    self.titleLabel.attributedText = [NSAttributedString attributeChinaesewithContent:adressData.name keyWords:searchText firstLetter:adressData.fnmname pinyin:adressData.pyname chinaese:adressData.name colors:[UIColor redColor]];
    //手机号显示规则，如果有就显示手机号（phoneNum），没有就显示用户名（mobilenum）
    NSString *mShowNumber = nil;
    if(adressData.mobilenum.length!=0){
        mShowNumber = adressData.mobilenum;
    }else if(adressData.account.length!=0){
        mShowNumber = adressData.account;
    }else{
        mShowNumber = @"";
    }
    //    /// eagle 显示部门
    //    if (adressData.department_id) {
    //        mShowNumber = KCNSSTRING_ISEMPTY(adressData.department_id)?@"":[NSString stringWithFormat:@"%@",[[AppModel sharedInstance] getDeptNameWithDeptID:adressData.department_id]];
    //
    //    }
     self.account = adressData.account;
    if (![adressData.account isEqualToString:FileTransferAssistant]) {
        self.subTitleLabel.attributedText = clientShowInfomation?(HXLevelisFristAndSecond(adressData.level,adressData.account)?[NSAttributedString attributeStringWithContent:hiddenMobileAndShowDefault keyWords:nil colors:[UIColor redColor]]:[NSAttributedString attributeStringWithContent:mShowNumber keyWords:searchText colors:[UIColor redColor]]):[NSAttributedString attributeStringWithContent:mShowNumber keyWords:searchText colors:[UIColor redColor]];
        if (ISLEVELMODE && adressData.level <= [[[Common sharedInstance] getUserLevel] intValue] - 2) {
            self.subTitleLabel.text = languageStringWithKey(@"**********");
        }
    }
    
    CGSize size = [adressData.name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
    self.titleLabel.frame = CGRectMake(self.titleLabel.originX, (60*FitThemeFont-self.titleLabel.size.height)/2, size.width, self.titleLabel.size.height);
    
    if ([adressData.account isEqualToString:FileTransferAssistant]) {
    }else{
        departmentString = !KCNSSTRING_ISEMPTY(departmentString)?[NSString stringWithFormat:@" | %@",departmentString]:@"";
        NSInteger index = self.titleLabel.text.length;
        self.titleLabel.text = [self.titleLabel.text stringByAppendingString:departmentString];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:self.titleLabel.text];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1] range:NSMakeRange(index, (self.titleLabel.text.length - index))];
        [str addAttribute:NSFontAttributeName value:ThemeFontSmall range:NSMakeRange(index, (self.titleLabel.text.length - index))];
        self.titleLabel.attributedText = str;
    }
    
}
// 设置联系人cell
- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard searchText:(NSString *)searchText withDepartmentString:(NSString *)departmentString withShowPhoneNumber:(BOOL)isShowPhoneNumber{
    self.userHeadImageView.hidden = NO;
    self.groupImageView.hidden = YES;
    // 是否发送名片
    if (isSendCard == YES) {
        self.selectedButton.hidden = YES;
    }
    // 设置头像
    [self setHeadViewImageCompanyAddress:adressData];
    // 文字
    self.titleLabel.attributedText = [NSAttributedString attributeChinaesewithContent:adressData.name keyWords:searchText firstLetter:adressData.fnmname pinyin:adressData.pyname chinaese:adressData.name colors:ThemeColor];
    NSString *departMentName = nil;
        /// 姓名职位部门
        if (adressData.department_id) {
            departMentName = KCNSSTRING_ISEMPTY(adressData.department_id)?@"":[NSString stringWithFormat:@"%@",[[AppModel sharedInstance] getDeptNameWithDeptID:adressData.department_id]];
        }
//    if (![adressData.account isEqualToString:FileTransferAssistant]) {
//         self.subTitleLabel.text = departMentName;
//        if (ISLEVELMODE && adressData.level <= [[[Common sharedInstance] getUserLevel] intValue] - 2) {
//            self.subTitleLabel.text = languageStringWithKey(@"**********");
//        }
//    }
    self.account = adressData.account;

    if (searchText.length > 0) {
        self.subTitleLabel.text = departMentName;
    } else {
        self.account = adressData.account;
        if ([adressData.nameId isEqualToString:FileTransferAssistant]) {
            self.subTitleLabel.text = nil;
        }else {
            if (adressData.online == 1) {
                self.subTitleLabel.text = languageStringWithKey(@"[在线]");
            }else{
                self.subTitleLabel.text = languageStringWithKey(@"[离线]");
            }
        }
    }
    
    CGSize size = [adressData.name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ThemeFontLarge,NSFontAttributeName, nil]];
    self.titleLabel.frame = CGRectMake(self.titleLabel.originX, (60*FitThemeFont-self.titleLabel.size.height)/2, size.width, self.titleLabel.size.height);
    
    if ([adressData.account isEqualToString:FileTransferAssistant]) {
    }else{
        self.titleLabel.attributedText = [NSAttributedString setAttributedStringWithNameAttributedString:self.titleLabel.attributedText withPlaceString:departmentString withPlaceColor:[UIColor colorWithHexString:@"#666666"]];
        

    }
}
-(void)setupSubTitleLabel{
    // 最近联系人展示在线部门
    KitCompanyAddress *address = [KitCompanyAddress getCompanyAddressInfoDataWithAccount:self.account];
    if (address){
        NSString *departMentName = nil;
        /// 姓名职位部门
        if (address.department_id) {
            departMentName = KCNSSTRING_ISEMPTY(address.department_id)?@"":[NSString stringWithFormat:@"%@",[[AppModel sharedInstance] getDeptNameWithDeptID:address.department_id]];
        }
        if (![address.account isEqualToString:FileTransferAssistant]) {
            self.subTitleLabel.text = departMentName;
        }
    }
    
    // 最近联系人展示在线离线
    //   if ([self.account isEqualToString:FileTransferAssistant] || [self.account isEqualToString:@"rx4"] || [self.account isEqualToString:YHC_CONFMSG]) {
    //
    //   }else{
    //       // 从缓存读取
    //       NSString * stateStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_netState",self.account]];
    //       if ([stateStr isEqualToString:languageStringWithKey(@"对方不在线")]) {
    //           self.subTitleLabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[离线]")];
    //       }else{
    //           self.subTitleLabel.text = [NSString stringWithFormat:@" %@",languageStringWithKey(@"[在线]")];
    //       }
    //   }
}

#pragma mark 手机联系人cell
- (void)setAddressPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitAddressBook *)adressData withCard:(BOOL)isSendCard{
    [self setAddressPersonDataIndexPath:indexPath CompanyData:adressData withCard:isSendCard searchText:nil withDepartmentString:nil];
}
// 设置手机联系人cell
- (void)setAddressPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitAddressBook *)adressData withCard:(BOOL)isSendCard searchText:(NSString *)searchText withDepartmentString:(NSString *)departmentString{
    NSDictionary *mobileDic =adressData.phones;
    NSString *keyMobile=nil;
    if(mobileDic.count>0)
    {
        keyMobile=mobileDic.allKeys[0];
    }
    NSString *mobilenum =[mobileDic objectForKey:keyMobile];
    self.selectedButton.userInteractionEnabled=YES;
    
    //是否选中
    if ([mobilenum isEqualToString:[[Common sharedInstance] getMobile]] && indexPath.row==0) {
        self.selectedButton.hidden = YES;
    }
    
    [self setHeadViewImageAddressBook:adressData];
    self.titleLabel.text = adressData.name;
    
}
// 设置头像
-(void)setHeadViewImageCompanyAddress:(KitCompanyAddress *)adressData{
    [self setHeadViewImageUrlString:adressData.photourl withUrlMD5:adressData.urlmd5 withAccountId:adressData.account withName:adressData.name];
}
// 设置头像
-(void)setHeadViewImageAddressBook:(KitAddressBook *)adressData{
    [self setHeadViewImageUrlString:adressData.photourl withUrlMD5:adressData.urlmd5 withAccountId:adressData.account withName:adressData.name];
}

// 设置头像
-(void)setHeadViewImageUrlString:(NSString *)urlString withUrlMD5:(NSString *)urlmd5 withAccountId:(NSString *)accountId withName:(NSString *)name{
    if ([accountId isEqualToString:FileTransferAssistant]) {
        self.userHeadImageView.image = ThemeImage(@"icon_filetransferassistant");
    }else{
        if(!KCNSSTRING_ISEMPTY(urlString)) {
#if isHeadRequestUserMd5
            [self.userHeadImageView setImageWithURLString:urlString urlmd5:urlmd5 options:SDWebImageRefreshCached placeholderImage:ThemeDefaultHead(self.userHeadImageView.size, name,accountId) withRefreshCached:NO];
#else
            NSURL *url =[NSURL URLWithString:urlString];
            [self.userHeadImageView sd_setImageWithURL:url placeholderImage:ThemeDefaultHead(self.userHeadImageView.size, name,accountId) options:SDWebImageRefreshCached|SDWebImageRetryFailed];
#endif
        }else
        {
            [self.userHeadImageView sd_cancelCurrentImageLoad];
            self.userHeadImageView.image = nil;
            self.userHeadImageView.image=ThemeDefaultHead(self.userHeadImageView.size, name,accountId);
        }
    }
}
@end
