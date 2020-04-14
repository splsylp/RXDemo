//
//  MSSBrowseZoomScrollView.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/5.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MSSBrowseZoomScrollViewTapBlock)(void);

@interface MSSBrowseZoomScrollView : UIScrollView<UIScrollViewDelegate>
@property (nonatomic,assign)BOOL isSingleTap;
@property (nonatomic,strong)FLAnimatedImageView *zoomImageView;
//@property (nonatomic,strong)UIImageView *zoomImageView;

/** scrollBlock */
@property(nonatomic,copy)void (^scrollBlock)(CGPoint offset);

/** endScrollBlock */
@property(nonatomic,copy)void (^endScrollBlock)(UIScrollView *scrollView);

/** willEndScrollBlock */
@property(nonatomic,copy)void (^willEndScrollBlock)(UIScrollView *scrollView,CGPoint velocity,CGPoint *targetContentOffset);

- (void)tapClick:(MSSBrowseZoomScrollViewTapBlock)tapBlock;

@end
