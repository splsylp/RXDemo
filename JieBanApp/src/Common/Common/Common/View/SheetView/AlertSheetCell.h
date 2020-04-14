//
//  AlertSheetCell.h
//  Common
//
//  Created by 韩微 on 2017/8/15.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlertSheetCell : UITableViewCell



+ (CGFloat)getHightOfCellViewWith:(NSString *)str;
@property (nonatomic, strong) UILabel *textlabel;
- (void)getTextWith:(NSString *)text withWidth:(CGFloat)width;
+(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width;

@end
