//
//  MSSBrowseCollectionViewCell.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/5.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSBrowseLoadingView.h"
#import "MSSBrowseZoomScrollView.h"
#import "MSSBrowseModel.h"

@class MSSBrowseCollectionViewCell;

typedef void(^MSSBrowseCollectionViewCellTapBlock)(MSSBrowseCollectionViewCell *browseCell);
typedef void(^MSSBrowseCollectionViewCellLongPressBlock)(MSSBrowseCollectionViewCell *browseCell);

@interface MSSBrowseCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)MSSBrowseZoomScrollView *zoomScrollView; // 滚动视图
@property (nonatomic,strong)MSSBrowseLoadingView *loadingView; // 加载视图
@property (nonatomic,strong)MSSBrowseModel *browseItem;

/** scrollBlock */
@property(nonatomic,copy)void (^scrollBlock)(CGPoint offset);

/** endScrollBlock */
@property(nonatomic,copy)void (^endScrollBlock)(UIScrollView *scrollView);

/** willEndScrollBlock */
@property(nonatomic,copy)void (^willEndScrollBlock)(UIScrollView *scrollView,CGPoint velocity,CGPoint *targetContentOffset);

- (void)tapClick:(MSSBrowseCollectionViewCellTapBlock)tapBlock;
- (void)longPress:(MSSBrowseCollectionViewCellLongPressBlock)longPressBlock;

@end
