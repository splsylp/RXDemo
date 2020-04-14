//
//  CustomScrollCell.h
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/7.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXGroupHeadImageView.h"

@interface CustomScrollCell : UITableViewCell

@property(nonatomic, strong) UIImageView * picImageView;
@property(nonatomic, strong) UILabel * nameLab;
@property(nonatomic, strong) RXGroupHeadImageView * headView;

@end
