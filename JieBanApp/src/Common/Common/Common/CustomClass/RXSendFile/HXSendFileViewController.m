//
//  HXSendFileViewController.m
//  ECSDKDemo_OC
//
//  Created by ywj on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "HXSendFileViewController.h"

#import "HXSelectCacheDocumentBar.h"
/**....文件缓存View.....*/
#import "HXDocumentFileView.h"
#import "HXDocumentImageFileView.h"
#import "HXDocumentOtherFileView.h"
#import "HYTApiClient+Ext.h"

@interface HXSendFileViewController ()<HXSelectCacheDocumentBarDelegate,HXDocumentFileViewViewDelegate,HXDocumentImageFileViewDelegate,HXDocumentOtherFileViewDelegate>

@property(nonatomic,strong)HXSelectCacheDocumentBar *selectBarView;//选择器

@property(nonatomic,strong)HXDocumentFileView *fileView;
@property(nonatomic,strong)HXDocumentImageFileView *imgFileView;
@property(nonatomic,strong)HXDocumentOtherFileView *otherView;

@end

@implementation HXSendFileViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = languageStringWithKey(@"文件");
    if(iOS7){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if (_limitSelectCount < 1) {
        _limitSelectCount = 1;//不设置默认为1个。恒丰默认发9个图
    }
    [self initUI];
    [self setBarButtonWithNormalImg:ThemeImage(@"title_bar_back") highlightedImg:ThemeImage(@"title_bar_back") target:self action:@selector(dissmissVC) type:NavigationBarItemTypeLeft];
}

- (void)dissmissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)initUI{
    [self selectObjectChanged];

    _selectBarView = [[HXSelectCacheDocumentBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SelectCacheDocumentBar_Height)];
    _selectBarView.delegate = self;
    [self.view addSubview:_selectBarView];
    
    _fileView = [[HXDocumentFileView alloc] initWithFrame:CGRectMake(0, SelectCacheDocumentBar_Height, kScreenWidth, kScreenHeight-kTotalBarHeight-SelectCacheDocumentBar_Height) selectCacheDocumentType:SelectCacheDocumentType_Document];
    _fileView.WBFlag = self.WBFlag;
    _fileView.delegate=self;
    [self.view addSubview:_fileView];
    
    _imgFileView = [[HXDocumentImageFileView alloc] initWithFrame:CGRectMake(0, SelectCacheDocumentBar_Height, kScreenWidth, kScreenHeight-kTotalBarHeight-SelectCacheDocumentBar_Height) selectCacheDocumentType:SelectCacheDocumentType_Image];
    _imgFileView.WBFlag = self.WBFlag;
    _imgFileView.delegate = self;
    [self.view addSubview:_imgFileView];
    
    _otherView = [[HXDocumentOtherFileView alloc] initWithFrame:CGRectMake(0, SelectCacheDocumentBar_Height, kScreenWidth, kScreenHeight-kTotalBarHeight-SelectCacheDocumentBar_Height) selectCacheDocumentType:SelectCacheDocumentType_Other];
    _otherView.delegate = self;
    [self.view addSubview:_otherView];
    
    [self selectSegmentIndex:0];
}

- (void)SelectCacheDocumentBar:(HXSelectCacheDocumentBar*)aSegmentedBarView selectedIndex:(NSInteger)aIndex{
    [self selectSegmentIndex:aIndex];
}

- (void)selectSegmentIndex:(NSInteger)aIndex{
    _fileView.hidden = YES;
    _imgFileView.hidden = YES;
    _otherView.hidden = YES;
    if (aIndex == 0) {
        _fileView.hidden = NO;
        [_fileView loadDataSource];
    }else if (aIndex == 1){
        _imgFileView.hidden = NO;
        [_imgFileView loadDataSource];
    }else if (aIndex == 2){
        _otherView.hidden = NO;
        [_otherView loadDataSource];
    }
}


- (BOOL)SelectDocumentFileView_CanSelected:(HXDocumentFileView *)aView{
    return [self canSelectObject];
}

- (void)SelectDocumentFileView_SelectedChanged:(HXDocumentFileView *)aView{
    [self selectObjectChanged];
}

- (BOOL)SelectImageFileView_CanSelected:(HXDocumentImageFileView*)aView{
    return [self canSelectObject];
}

- (void)SelectImageFileView_SelectedChanged:(HXDocumentImageFileView*)aView{
    [self selectObjectChanged];
}

- (BOOL)SelectOtherFileView_CanSelected:(HXDocumentOtherFileView*)aView{
    return [self canSelectObject];
}

- (void)SelectOtherFileView_SelectedChanged:(HXDocumentOtherFileView*)aView{
    [self selectObjectChanged];
}

- (BOOL)canSelectObject{
    NSInteger count = 0;
    count = count + [_fileView.selectedDataSource count];
    count = count + [_imgFileView.selectedAlbumImages count];
    count = count + [_imgFileView.selectedCacheImages count];
    count = count + [_otherView.selectedDataSource count];
    if (count == _limitSelectCount) {
        [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"已达上限")];
        return NO;
    }
    else{
        return YES;
    }
}

- (void)selectObjectChanged{
    NSInteger count = 0;
    count = count + [_fileView.selectedDataSource count];
    count = count + [_imgFileView.selectedAlbumImages count];
    count = count + [_imgFileView.selectedCacheImages count];
    count = count + [_otherView.selectedDataSource count];
    
    if (count>0) {
        //右边
        NSString *title = [NSString stringWithFormat:@"%@(%ld/%ld)",languageStringWithKey(@"确定"),(unsigned long)count,_limitSelectCount];
        [self setNavRightButtonTitle:title enable:YES selector:@selector(navigationRightButtonClicked)];
    }
    else{
        //右边
        NSString *title = languageStringWithKey(@"确定");
        [self setNavRightButtonTitle:title enable:NO selector:nil];
    }
}

- (void)navigationRightButtonClicked{
    if (!(self.delegate && [self.delegate respondsToSelector:@selector(SelectCacheDocumentViewController:didSelectCacheObjects:albumObjects:)])
        ) {
        return;
    }
    NSMutableArray *CacheObjects = [NSMutableArray array];
    [CacheObjects addObjectsFromArray:[_fileView.selectedDataSource allValues]];
    [CacheObjects addObjectsFromArray:[_imgFileView.selectedCacheImages allValues]];
    [CacheObjects addObjectsFromArray:[_otherView.selectedDataSource allValues]];

    NSMutableArray *AlbumObjects = [NSMutableArray array];
    [AlbumObjects addObjectsFromArray:[_imgFileView.selectedAlbumImages allValues]];

    if ([self.delegate respondsToSelector:@selector(SelectCacheDocumentViewController:didSelectCacheObjects:albumObjects:)]) {
        [self.delegate SelectCacheDocumentViewController:self didSelectCacheObjects:CacheObjects albumObjects:AlbumObjects];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
