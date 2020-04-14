//
//  HXDocumentOtherFileView.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "RXBaseView.h"

@protocol HXDocumentOtherFileViewDelegate ;

@interface HXDocumentOtherFileView : RXBaseView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign)SelectCacheDocumentType type;
@property (nonatomic,retain)UITableView *table;
@property (nonatomic,retain)NSMutableArray *dataSource;
@property (nonatomic,retain)NSMutableDictionary *selectedDataSource;
@property (nonatomic,assign)id<HXDocumentOtherFileViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame selectCacheDocumentType:(SelectCacheDocumentType)aType;

- (void)loadDataSource;


@end


@protocol HXDocumentOtherFileViewDelegate <NSObject>

- (BOOL)SelectOtherFileView_CanSelected:(HXDocumentOtherFileView*)aView;

- (void)SelectOtherFileView_SelectedChanged:(HXDocumentOtherFileView*)aView;

@end
