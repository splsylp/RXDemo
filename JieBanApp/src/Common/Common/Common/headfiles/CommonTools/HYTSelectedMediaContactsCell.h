//
//  HYTSelectedMediaContactsCell.h
//  HIYUNTON
//
//  Created by yuxuanpeng on 14-11-9.
//  Copyright (c) 2014年 hiyunton.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXGroupHeadImageView.h"

#import "RXMyFriendList.h"
#import "KitCompanyAddress.h"
#import "Common.h"
#import "KitAddressBook.h"
#define kHYTSelectedMediaContactsCell  @"selectedMediaContactsCellIdentifier"
@class HYTSelectedMediaContactsCell;

@protocol HYTSelectedMediaContactsCellDelegate <NSObject>
@optional
-(void)selectedMediaContactsCell:(HYTSelectedMediaContactsCell*)dialingTableViewCell selected:(BOOL)selected;

- (void)didSelectPersonCell:(HYTSelectedMediaContactsCell*)dialingTableViewCell;

- (void)didSelectPersonCellWithHeadImg:(HYTSelectedMediaContactsCell*)dialingTableViewCell;
@end

@interface HYTSelectedMediaContactsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet RXGroupHeadImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton; //默认不选中 不隐藏
@property (nonatomic,strong) NSString *account;
//@property (weak, nonatomic) IBOutlet UILabel * positionLabel;
@property (nonatomic ,assign) NSInteger section;

@property (weak,nonatomic) id <HYTSelectedMediaContactsCellDelegate> delegate;
// 设置联系人cell
- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard;
// 设置联系人cell
//- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard
// 设置联系人cell
- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard searchText:(NSString *)searchText withDepartmentString:(NSString *)departmentString;

// 设置联系人cell
- (void)setPersonDataIndexPath:(NSIndexPath *)indexPath CompanyData:(KitCompanyAddress *)adressData withCard:(BOOL)isSendCard searchText:(NSString *)searchText withDepartmentString:(NSString *)departmentString withShowPhoneNumber:(BOOL)isShowPhoneNumber;
// 设置群组头像
-(void)setGroupHeaderView:(NSString *)groupId withArray:(NSArray *)array;
// 设置头像
-(void)setHeadViewImageAddressBook:(KitAddressBook *)adressData;
// 设置头像
-(void)setHeadViewImageCompanyAddress:(KitCompanyAddress *)adressData;
// 设置在线离线
-(void)setupSubTitleLabel;
@end
