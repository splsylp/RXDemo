//
//  HXDocumentFileView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXBaseView.h"

@class HXDocumentFileView;

@protocol HXDocumentFileViewViewDelegate <NSObject>

- (BOOL)SelectDocumentFileView_CanSelected:(HXDocumentFileView*)aView;

- (void)SelectDocumentFileView_SelectedChanged:(HXDocumentFileView*)aView;

@end

@interface HXDocumentFileView : RXBaseView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign)SelectCacheDocumentType type;
@property (nonatomic,assign)NSInteger WBFlag;
@property (nonatomic,retain)UITableView *table;
@property (nonatomic,retain)NSMutableDictionary *dataSource;
@property (nonatomic,retain)NSMutableDictionary *selectedDataSource;
@property (nonatomic,assign)id<HXDocumentFileViewViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame selectCacheDocumentType:(SelectCacheDocumentType)aType;

- (void)loadDataSource;
@end
