//
//  HXMergeMessageFatherCell.h
//  ECSDKDemo_OC
//
//  Created by 陈长军 on 2017/3/31.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MergeMessageViewConst.h"

@class HXMergeMessageModel;
@class HXMergerMessageBubbleFatherView;

@interface HXMergeMessageFatherCell : UITableViewCell

@property (nonatomic,strong) UIImageView *mHeaderImageView; //头像

@property (nonatomic,strong) UILabel     *mNameLabel;   //名字

@property (nonatomic,strong) UILabel     *mTimeLabel;   //时间

-(instancetype)initWithEachMergeMessageModel:(HXMergeMessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier;

+(CGFloat)returnHeightWithModel:(HXMergeMessageModel*)model;

+ (NSString *)cellIdentifierForMessageModel:(HXMergeMessageModel *)model;

@property (nonatomic,strong) HXMergeMessageModel *model;

+(UIView *)returnSecontionFooterView;


@property (nonatomic,strong) void (^bubbleViewClickBlock) (HXMergeMessageModel *model,XSMergeMessageBublleEvent EventType);


@property (nonatomic,strong) HXMergerMessageBubbleFatherView      *mBubbleView;  //详情View


#define FooterHeight 10


@end
