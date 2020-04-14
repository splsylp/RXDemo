//
//  HXDocumentImageFileView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXBaseView.h"

@class HXDocumentImageFileView;
@protocol HXDocumentImageFileViewDelegate <NSObject>

- (BOOL)SelectImageFileView_CanSelected:(HXDocumentImageFileView*)aView;

- (void)SelectImageFileView_SelectedChanged:(HXDocumentImageFileView*)aView;

@end

@interface HXDocumentImageFileView : RXBaseView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign)SelectCacheDocumentType type;
@property (nonatomic,assign)NSInteger WBFlag;
@property (nonatomic,retain)UITableView *table;
@property (nonatomic,retain)NSMutableDictionary *dataSource;
@property (nonatomic,retain)NSMutableDictionary *selectedAlbumImages;
@property (nonatomic,retain)NSMutableDictionary *selectedCacheImages;
@property (nonatomic,assign)id<HXDocumentImageFileViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame selectCacheDocumentType:(SelectCacheDocumentType)aType;

- (void)loadDataSource;
@end
