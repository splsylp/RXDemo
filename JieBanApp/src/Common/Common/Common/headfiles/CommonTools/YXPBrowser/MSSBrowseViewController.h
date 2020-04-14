//
//  MSSBrowseViewController.h
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/23.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSBrowseActionSheet.h"
#import "BaseViewController.h"

@interface MSSBrowseViewController : BaseViewController <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSArray * clickArr;//对图片操作的事件数组
@property (nonatomic, assign) BOOL isLoadLoc;

- (instancetype)initWithBrowseItemArray:(NSArray *)browseItemArray currentIndex:(NSInteger)currentIndex;
- (void)showBrowseViewController;

@end
