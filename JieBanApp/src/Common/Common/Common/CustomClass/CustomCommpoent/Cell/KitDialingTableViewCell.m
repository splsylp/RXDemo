//
//  KitDialingTableViewCell.m
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-17.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import "KitDialingTableViewCell.h"


@interface KitDialingTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *tapView;

@end

@implementation KitDialingTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _titleLable.font = ThemeFontMiddle;
    _subTitleLable.font = ThemeFontSmall;
    _locationLable.font = ThemeFontSmall;
    _timeLable.font = ThemeFontSmall;
    [_btnGoNext setImage:ThemeImage(@"enter_icon_01") forState:UIControlStateNormal];
    
    UILongPressGestureRecognizer* LongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    LongPress.minimumPressDuration = 1.0;
    [self.tapView addGestureRecognizer:LongPress];
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandle)];
    tap.numberOfTapsRequired = 1;
    [self.tapView addGestureRecognizer:tap];
    self.lineView.frame =CGRectMake(self.lineView.frame.origin.x, self.frame.size.height - 0.5, kScreenWidth, 0.5);
    self.lineView.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)tapHandle
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tapDialingTableViewCell:)]){
        [self.delegate tapDialingTableViewCell:self];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        @try {
            if(self.delegate && [self.delegate respondsToSelector:@selector(longPressDialingTableViewCell:)]){                                                [self.delegate longPressDialingTableViewCell:self];
            }
        }
        @catch (NSException *exception) {
              DDLogInfo(@"----self.tag-------%d--------- 选择联系人长按",(int)self.tag);
        }
        @finally {
            
        }
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
    }
}

- (IBAction)actionHandle:(id)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(dialingTableViewCell:selectedIndex:)]){
        [self.delegate dialingTableViewCell:self selectedIndex:self.tag];
    }
}

@end
