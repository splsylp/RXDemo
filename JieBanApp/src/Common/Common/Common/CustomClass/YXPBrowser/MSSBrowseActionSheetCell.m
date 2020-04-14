//
//  MSSBrowseActionSheetCell.m
//  MSSBrowse
//
//  Created by yuxuanpeng on 16/2/14.
//  Copyright © 2016年 yuxuanpeng. All rights reserved.
//

#import "MSSBrowseActionSheetCell.h"
#import "MSSBrowseDefine.h"

@implementation MSSBrowseActionSheetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self createCell];
    }
    return self;
}

- (void)createCell {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    
    _bottomLineView = [[UIView alloc]init];
    _bottomLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.contentView addSubview:_bottomLineView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, 0, self.mssWidth, self.height);
    CGFloat lineHeight = 1.0 / [UIScreen mainScreen].scale;
    self.bottomLineView.frame = CGRectMake(0, self.height - lineHeight, self.mssWidth, lineHeight);
}

@end
