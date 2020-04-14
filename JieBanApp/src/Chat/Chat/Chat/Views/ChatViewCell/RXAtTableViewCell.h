//
//  RXAtTableViewCell.h
//  Chat
//
//  Created by 杨大为 on 2017/4/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXGroupHeadImageView.h"

@interface RXAtTableViewCell : UITableViewCell
@property (nonatomic, strong) RXGroupHeadImageView* groupHeadView;
@property(nonatomic,strong)UIImageView *userHeadImg;//用户头像
@property(nonatomic,strong)UILabel *userNameLable;//姓名
@property(nonatomic,strong)UILabel *userMobileLable;//号码
@property(nonatomic,strong)UILabel *positionLab;//职位
@property(nonatomic,strong)NSIndexPath *indexPath;

@end
