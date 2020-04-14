//
//  OnLineTipView.h
//  Chat
//
//  Created by 李晓杰 on 2019/9/21.
//  Copyright © 2019 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//宽度为103+name 高36为 的view
@interface OnLineTipView : UIView

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *tipLabel;

+ (OnLineTipView *)showInView:(UIView *)view frame:(CGRect)frame name:(NSString *)name isOnline:(BOOL)isOnline duration:(NSInteger)duration completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
