//
//  MSSBrowseCollectionViewCell.m
//  MSSBrowse
//
//  Created by yuxuanpeng on 15/12/5.
//  Copyright © 2015年 yuxuanpeng. All rights reserved.
//

#import "MSSBrowseCollectionViewCell.h"
#import "MSSBrowseDefine.h"

@interface MSSBrowseCollectionViewCell ()

@property (nonatomic,copy)MSSBrowseCollectionViewCellTapBlock tapBlock;
@property (nonatomic,copy)MSSBrowseCollectionViewCellLongPressBlock longPressBlock;

@end

@implementation MSSBrowseCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createCell];
    }
    return self;
}

- (void)createCell
{
    _zoomScrollView = [[MSSBrowseZoomScrollView alloc]init];
    __weak __typeof(self)weakSelf = self;
    [_zoomScrollView tapClick:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.tapBlock(strongSelf);
    }];
    [self.contentView addSubview:_zoomScrollView];
    
    _zoomScrollView.scrollBlock = ^(CGPoint offset) {
        !weakSelf.scrollBlock?:weakSelf.scrollBlock(offset);
    };
    
    _zoomScrollView.endScrollBlock = ^(UIScrollView *scrollView) {
        !weakSelf.endScrollBlock?:weakSelf.endScrollBlock(scrollView);
    };
    
    _zoomScrollView.willEndScrollBlock = ^(UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset) {
        !weakSelf.willEndScrollBlock?:weakSelf.willEndScrollBlock(scrollView,velocity,targetContentOffset);
    };
    
    
    _loadingView = [[MSSBrowseLoadingView alloc]init];
    [_zoomScrollView addSubview:_loadingView];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [self.contentView addGestureRecognizer:longPressGesture];
}

- (void)tapClick:(MSSBrowseCollectionViewCellTapBlock)tapBlock
{
    _tapBlock = tapBlock;
}

- (void)longPress:(MSSBrowseCollectionViewCellLongPressBlock)longPressBlock
{
    _longPressBlock = longPressBlock;
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if(_longPressBlock)
    {
        if(gesture.state == UIGestureRecognizerStateBegan)
        {
            _longPressBlock(nil);
        }
    }
}

@end
