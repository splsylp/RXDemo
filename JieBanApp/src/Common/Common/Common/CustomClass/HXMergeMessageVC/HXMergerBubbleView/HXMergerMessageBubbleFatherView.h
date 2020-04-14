//
//  HXMergerMessageBubbleFatherView.h
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXMergeMessageModel.h"
#import "MergeMessageViewConst.h"

#define BubbleViewWidth (kScreenWidth-(EDGE_Distance_LEFT+MERGE_HEAD_WITH+10)-EDGE_Distance_RIGHT)


@interface HXMergerMessageBubbleFatherView : UIView

{
    HXMergeMessageModel *_model;
}



@property (nonatomic,strong) HXMergeMessageModel *model;

@property (nonatomic,strong) void (^bubbleViewClickBlock) (HXMergeMessageModel *model,XSMergeMessageBublleEvent EventType);

+ (CGFloat)heightForBubbleWithObject:(HXMergeMessageModel *)model;


@end
