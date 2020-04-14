//
//  RXDeptSelectTableViewCell.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/21.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RXDeptSelectTableViewCell;

@protocol RXSelectedDeptCellDelegate <NSObject>
@optional
-(void)selectedDeptCell:(RXDeptSelectTableViewCell *)dialingTableViewCell selected:(BOOL)selected;

- (void)didSelectDeptCell:(RXDeptSelectTableViewCell *)dialingTableViewCell;

@end

@interface RXDeptSelectTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * deptLab;
@property (nonatomic, weak) IBOutlet UIButton * selectDept;
@property (strong, nonatomic) IBOutlet UIImageView *enterImageV;
@property (nonatomic,strong) UIView *lineView;// 下面的横线
@property (nonatomic, weak) id<RXSelectedDeptCellDelegate>delegate;
@property (nonatomic, assign) BOOL isSelectBtn;

@end
