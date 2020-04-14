//
//  HYTCommonContactsTableViewCell.h
//  HIYUNTON
//
//  Created by yuxuanpeng on 15-1-12.
//  Copyright (c) 2015年 hiyunton.com. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kHYTCommonContactsTableViewCellIdentifier  @"commonContactsTableViewCellIdentifier"
@class HYTCommonContactsTableViewCell;

@protocol  HYTCommonContactsTableViewCellDelegate <NSObject>

- (void)HYTCommonContactsTableViewCell:(HYTCommonContactsTableViewCell*)cell indexPath:(NSIndexPath*)indexPath;
@end

@interface HYTCommonContactsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headPortraitImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel * mobilelabel;
//@property (weak, nonatomic) IBOutlet UIButton *invitationBtn;
@property (retain, nonatomic) NSIndexPath *indexPath;
@property (weak,nonatomic) id<HYTCommonContactsTableViewCellDelegate>delegate;

@end
