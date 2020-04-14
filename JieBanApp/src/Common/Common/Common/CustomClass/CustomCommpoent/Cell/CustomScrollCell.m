//
//  CustomScrollCell.m
//  ECSDKDemo_OC
//
//  Created by zhouwh on 15/8/7.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "CustomScrollCell.h"

@implementation CustomScrollCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40*fitScreenWidth, 36*fitScreenWidth)];
        [self.contentView addSubview:view];
        
        self.picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6*fitScreenHeight, 0, 30*fitScreenWidth, 30*fitScreenWidth)];
        self.picImageView.layer.masksToBounds = YES;
        self.picImageView.layer.cornerRadius = 4;
//        [self.picImageView.layer setCornerRadius:CGRectGetHeight(5)];//([self.picImageView bounds]) / 2
        [view addSubview:self.picImageView];
        
//        self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 36, 10)];
//        self.nameLab.font =ThemeFontSmall;
//        self.nameLab.textAlignment = NSTextAlignmentCenter;
//        [view addSubview:self.nameLab];
        
        _headView = [[RXGroupHeadImageView alloc] initWithFrame:CGRectMake(6*fitScreenHeight, 0, 30*fitScreenWidth, 30*fitScreenWidth)];
        _headView.backgroundColor = [UIColor clearColor];
        [view addSubview:_headView];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
