//
//  KitSearchTableViewCell.h
//  ccp_ios_kit
//
//  Created by yuxuanpeng on 16/3/1.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kKitSearchTableViewCellIdentifier  @"searchTableViewCellIdentifier"
@class KitSearchTableViewCell;
@protocol KitSearchTableViewCellDelegate <NSObject>

-(void)searchTableViewCell:(KitSearchTableViewCell*)dialingTableViewCell selectedIndex:(NSInteger)index;
-(void)tapSearchTableViewCell:(KitSearchTableViewCell*)searchTableViewCell;
@end
@interface KitSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) id <KitSearchTableViewCellDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *tapView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLable;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *subTitleLable;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *locationLable;
@property (strong, nonatomic) IBOutlet UIButton *enterBtn;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *lineImageView;
- (IBAction)actionHandle:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *searchShowTitle;

@end
