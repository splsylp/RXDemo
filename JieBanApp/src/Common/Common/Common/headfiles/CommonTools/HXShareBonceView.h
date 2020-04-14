//
//  HXShareBonceView.h
//  ECSDKDemo_OC
//
//  Created by 王明哲 on 16/9/2.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HYTBaseDialog.h"

typedef void (^ClickButtonBlock)(NSInteger buttonTag);

@interface HXShareBonceView : HYTBaseDialog

//创建视图
- (void)createBonceViewWithFrame:(CGRect)frame buttonBlock:(ClickButtonBlock)block;

@end
