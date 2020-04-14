//
//  KitDialingTableViewCell.h
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-17.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kKitDialingTableViewCellIdentifier  @"KitDialingTableViewCellIdentifier"
@class KitDialingTableViewCell;

@protocol KitDialingTableViewCellDelegate <NSObject>

-(void)dialingTableViewCell:(KitDialingTableViewCell*)dialingTableViewCell selectedIndex:(NSInteger)index;

-(void)longPressDialingTableViewCell:(KitDialingTableViewCell*)dialingTableViewCell;
-(void)tapDialingTableViewCell:(KitDialingTableViewCell*)dialingTableViewCell;

@end

@interface KitDialingTableViewCell : UITableViewCell
@property (weak,nonatomic)id<KitDialingTableViewCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *locationLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIButton *btnGoNext;
@property (weak, nonatomic) IBOutlet UIImageView *voipImageView;

@end

