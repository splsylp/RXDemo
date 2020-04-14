//
//  OnLineManager.m
//  Chat
//
//  Created by 李晓杰 on 2019/9/21.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import "OnLineManager.h"
#import "OnLineTipView.h"
@interface OnLineManager()

///内部计数
@property (nonatomic, assign) NSInteger oneLine;
@property (nonatomic, assign) NSInteger twoLine;

@end

@implementation OnLineManager

SYNTHESIZE_SINGLETON_FOR_CLASS(OnLineManager)

- (void)showTipInView:(UIView *)view name:(NSString *)name isOnline:(BOOL)isOnline duration:(NSInteger)duration{
    CGFloat width = 103 + 47;
    width = [name sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:98].width + 103;
    
    BOOL isLower = _oneLine > _twoLine;
    CGRect frame = CGRectMake(kScreenWidth - width, isLower * 72, width, 36);
    if (isLower) {
        _twoLine++;
    }else{
        _oneLine++;
    }
    [OnLineTipView showInView:view frame:frame name:name isOnline:isOnline duration:duration completion:^{
        if (isLower) {
            self->_twoLine--;
        }else{
            self->_oneLine--;
        }
    }];
}


@end
