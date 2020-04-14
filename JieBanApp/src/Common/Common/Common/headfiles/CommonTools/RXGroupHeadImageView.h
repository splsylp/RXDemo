//
//  RXGroupHeadImageView.h
//  MyHead
//
//  Created by zhouwh on 15/8/27.
//  Copyright (c) 2015年 zhouwh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXThirdPart.h"
//#import "UIImageView+WebCache"
@interface RXGroupHeadImageView : UIView
@property(nonatomic,strong)UIImageView *imgView;

/**
 * 群组头像生成
 * headerWH 头像的高宽
 * imageWH  图片的高宽
 * groupId 群组Id
 * memberArray 成员数组
 */
- (void)createHeaderViewH:(CGFloat)headerWH withImageWH:(CGFloat)imageWH groupId:(NSString *)groupId withMemberArray:(NSArray *)memberArray;

@end
