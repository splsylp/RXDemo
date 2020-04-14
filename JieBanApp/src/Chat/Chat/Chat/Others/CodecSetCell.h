//
//  CodecSetCell.h
//  Chat
//
//  Created by yongzhen on 2018/5/9.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodecSetCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic ,assign) BOOL selected; //是否选中
@property (nonatomic, strong) UIButton *selectedBtn; // 选择按钮
-(void)setValeWithDic:(NSDictionary *)dic;
@end
