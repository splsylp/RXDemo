//
//  MSSBrowseLoadingView.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/5.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSSBrowseLoadingView : UIView

- (void)startAnimation;
- (void)stopAnimation;
@property (nonatomic,assign)CGFloat angle;

@end
