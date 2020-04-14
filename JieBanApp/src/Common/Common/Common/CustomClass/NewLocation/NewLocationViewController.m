//
//  ViewController.m
//  LocationDemo
//
//  Created by zhangmingfei on 2017/6/8.
//  Copyright © 2017年 com.ronglian. All rights reserved.
//

#import "NewLocationViewController.h"
#import "QMapKit.h"
#import "QMapSearchKit.h"
#import "UIImage+deal.h"
#import "RXAttributedStringBuilder.h"
#import "UISearchBar+RXAdd.h"

#define IOS7 [[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0
#define KNOTIFICATION_onReceivedGroupNotice    @"KNOTIFICATION_onReceivedGroupNotice"

@interface NewLocationViewController ()<QMapViewDelegate,QMSSearchDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) QMapView *mapView;

//@property (nonatomic, strong) UISearchBar *searchBar;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
//@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchController *searchController;
#pragma clang diagnostic pop
@property (nonatomic, strong) QMSSearcher *searcher;

@property (nonatomic, strong) QPointAnnotation *positionAnno; //大头针 放弃 改为使用图片

@property (nonatomic, strong) UIImageView *centerImageView;//中心点 使用图片

@property (nonatomic, strong) QUserLocation *positionLocation; //定位点

@property (nonatomic, strong) NSMutableArray *nearbyArr; //附近信息
@property (nonatomic, strong) QMSReverseGeoCodeSearchOption *regeocoder;//附近相关


@property (nonatomic, strong) NSMutableArray *searchArr;//搜索到的信息
@property (nonatomic, strong) QMSPoiSearchOption *poiSearchOption;//搜索相关

@property (nonatomic, assign) NSInteger selectedIndex; //选中cell对应的row 默认为0

@property (nonatomic, strong) UITableView *tableView;//显示附近数据

@property (nonatomic, assign) NSInteger searchIndex;//搜索出来的数据 对应的分页页数 默认为1 为0表示没数据

@property(nonatomic,strong) ECLocationPoint *locationPoint;//传出去的数据

@property (nonatomic, strong) UITableView *backTableView;//最底部的tableview

@property (nonatomic, copy) NSString *cityName;
//点击搜索后出来的视图
@property (nonatomic, strong) UIView *searchBackView;

@property (nonatomic, strong) UITableView *searchTableView;//展示搜搜的tableview

@end

@implementation NewLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"位置";
    self.view.backgroundColor = [UIColor whiteColor];
    self.nearbyArr = [NSMutableArray array];
    self.searchArr = [NSMutableArray array];
    self.selectedIndex = 0;
    self.searchIndex = 1;
    self.locationPoint = [[ECLocationPoint alloc] init];
    self.cityName = [[NSString alloc] init];
    
    self.backTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 44.0f+iPhoneStatusBarHeight, kScreenWidth, kScreenHeight -44-iPhoneStatusBarHeight) style:UITableViewStylePlain];
    self.backTableView.scrollEnabled = NO;
    self.backTableView.bounces = NO;
    self.backTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.backTableView];
    [self setSearchUI];
    
    [self setNavUI];

    // Do any additional setup after loading the view, typically from a nib.
    //如果您的系统版本高于iOS7.0，地图会根据按所在界面的status bar，navigationbar，与tabbar的高度，自动调整inset,可以在QmapView初始化之前添加如下设置
    if (IOS7)
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //地图
    self.mapView = [[QMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200+self.searchBar.height)];
    self.mapView.delegate = self;
    [self.backTableView insertSubview:self.mapView belowSubview:self.searchBar];
    
//    UIImage *pinImg = [UIImage getImageWithName:@"redPin_lift"];
//     UIImage *pinImg = ThemeImage(@"redPin_lift");
    UIImage *pinImg = ThemeImage(@"redPin_lift");
    self.centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.centerImageView.center = CGPointMake(self.mapView.width/2, self.mapView.height/2);//-62
    self.centerImageView.image = pinImg;
    [self.mapView addSubview:self.centerImageView];

    
    
    
    //定位button
    UIButton *positionBtn = [[UIButton alloc] init];
//    positionBtn.backgroundColor = [UIColor blueColor];
    positionBtn.frame = CGRectMake(self.view.bounds.size.width - 50, CGRectGetMaxY(self.mapView.frame)- 5, 40, 40);
//    [positionBtn setTitle:@"定位" forState:UIControlStateNormal];
//    [positionBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [positionBtn setImage:ThemeImage(@"newposition") forState:UIControlStateNormal];
    [positionBtn setImage:ThemeImage(@"newposition_on") forState:UIControlStateHighlighted];
    [positionBtn addTarget:self action:@selector(positionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:positionBtn];
    [self.view bringSubviewToFront:positionBtn];
    
    
    //tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame), self.view.bounds.size.width, self.view.bounds.size.height- CGRectGetMaxY(self.mapView.frame)-64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.backTableView addSubview:self.tableView];
    
    //如果您感觉初始化后显示的地图锯齿太过明显可以按如下代码设置一下缩放级别
    //这里的zoomlevel并没有使用整数，是因为地图SDK中的zoomlevel调整是左开右闭的。
    //这里加了0.01，实际使用的底图是12级的
    [self.mapView setZoomLevel:15.01];
    
    //用户可以通过对QMapView对象设置地图的拖动、缩放及比例尺的显示和隐藏。示例代码如下

    //地图平移，默认YES
    _mapView.scrollEnabled = YES;
    //地图缩放，默认YES
    _mapView.zoomEnabled = YES;
    //比例尺是否显示，ƒF默认YES
    _mapView.showsScale = YES;
    
    //用户可以通过对QMapView对象获取地图的中心坐标、视图范围等信息。示例代码如下
    /*
     //当前缩放级别
     _mapView.zoomLevel;
     //最小缩放级别
     _mapView.minZoomLevel;
     //最大缩放级别
     _mapView.maxZoomLevel;
     //中心点坐标
     _mapView.centerCoordinate;
     //当前视图范围
     _mapView.region;
     */
    
    //开启定位功能
    [_mapView setShowsUserLocation:YES];
    

    //添加手势识别
    //拖拽手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(gestureAction:)];
    [panGestureRecognizer setDelegate:self];
    [_mapView addGestureRecognizer:panGestureRecognizer];
    //轻扫
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(gestureAction:)];
    [swipeGestureRecognizer setDelegate:self];
    [_mapView addGestureRecognizer:swipeGestureRecognizer];
    
    //搜索相关
    self.poiSearchOption = [[QMSPoiSearchOption alloc] init];

    
    //tableview
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), self.view.bounds.size.width, kScreenHeight-kTotalBarHeight-CGRectGetMaxY(self.searchBar.frame)) style:UITableViewStylePlain];
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    [self.backTableView addSubview:self.searchTableView];
    self.searchTableView.hidden = YES;
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}
// 快速编译方法，无需调用
- (void)injected{
    NSLog(@"eagle.injected");
}
//SDK还提供了mapView:regionWillChangeAnimated:和mapView:regionDidChangeAnimated:两个委托，方便用户在地图视图变化时实现自己的业务。示例代码如下：

-(void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    DDLogInfo(@"Region:\ncenter:[%f,%f]\nspan:[%f,%f]",
          _mapView.region.center.latitude,
          _mapView.region.center.longitude,
          _mapView.region.span.latitudeDelta,
          _mapView.region.span.longitudeDelta);
//    //初始化设置地图中心点坐标需要异步加入到主队列
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.mapView setCenterCoordinate:_mapView.region.center
//                                zoomLevel:self.mapView.zoomLevel animated:YES];
//    });
    
    
    if (self.selectedIndex == 0) {
        //动画效果
        [UIView animateWithDuration:0.4 animations:^{
            self.centerImageView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y- 62 - 15-22);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
//                self.centerImageView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y- 62-22);
                self.centerImageView.center = CGPointMake(self.mapView.width/2, self.mapView.height/2-20);//-62
            } completion:nil];
        }];
        
        self.regeocoder = [[QMSReverseGeoCodeSearchOption alloc] init];
        
        NSString *locationStr = [NSString stringWithFormat:@"%f,%f",_mapView.region.center.latitude,_mapView.region.center.longitude];
        
        [self.regeocoder setLocation:locationStr];
        //返回坐标点附近poi列表
        [self.regeocoder setGet_poi:YES];
        //设置坐标所属坐标系，以返回正确地址，默认为腾讯所用坐标系
        [self.regeocoder setCoord_type:QMSReverseGeoCodeCoordinateTencentGoogleGaodeType];
        [self.searcher searchWithReverseGeoCodeSearchOption:self.regeocoder];
        
    } else {
//        self.centerImageView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y- 62-22);
        self.centerImageView.center = CGPointMake(self.mapView.width/2, self.mapView.height/2-20);
    }
    
}

#pragma mark - 检索周边
//逆地理解析(坐标位置描述)结果回调接口
- (void)searchWithReverseGeoCodeSearchOption:(QMSReverseGeoCodeSearchOption *) reverseGeoCodeSearchOption didReceiveResult:(QMSReverseGeoCodeSearchResult *) reverseGeoCodeSearchResult {
//    NSLog(@"address =====  %@",reverseGeoCodeSearchResult.address);
//    NSLog(@"recommend =====  %@",reverseGeoCodeSearchResult.formatted_addresses.recommend);
//    NSLog(@"rough =====  %@",reverseGeoCodeSearchResult.formatted_addresses.rough);
    [self.nearbyArr removeAllObjects];
    QMSPoiData *poi = [[QMSPoiData alloc] init];
    poi.address = reverseGeoCodeSearchResult.formatted_addresses.recommend;
    poi.title = @"";
    poi.location = _mapView.region.center;
    [self.nearbyArr addObject:poi];
    [self.nearbyArr addObjectsFromArray:reverseGeoCodeSearchResult.poisArray];
    [self.tableView reloadData];
    
    DDLogInfo(@"%@",reverseGeoCodeSearchResult.ad_info.province);
    
    self.locationPoint.coordinate = CLLocationCoordinate2DMake(0, 0);
    self.locationPoint.title = @"";
    
    self.locationPoint.coordinate = _mapView.region.center;
    self.locationPoint.title = reverseGeoCodeSearchResult.formatted_addresses.recommend;
    
    if (self.cityName.length<1) {
        self.cityName = reverseGeoCodeSearchResult.ad_info.city;
        
        //地区检索
        [self.poiSearchOption setBoundaryByRegionWithCityName:self.cityName autoExtend:YES];
    }
//    self.locationPoint = [[ECLocationPoint alloc] initWithCoordinate:_mapView.region.center andTitle:reverseGeoCodeSearchResult.formatted_addresses.recommend];
}


#pragma mark - 定位
- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    self.cityName = @"";
    //刷新位置
    self.positionLocation = userLocation;
    //初始化设置地图中心点坐标需要异步加入到主队列
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView setCenterCoordinate:userLocation.coordinate
                            zoomLevel:self.mapView.zoomLevel animated:YES];
    });
    
}
/**
 *  生成图片
 *
 *  @param color  图片颜色
 *  @param height 图片高度
 *
 *  @return 生成的图片
 */
- (UIImage*)GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - 搜索
- (void)setSearchUI {
    if (self.searchController) {
        self.searchController = nil;
    }
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,kScreenWidth, 44)];
    [self.searchBar setDelegate:self];
    [self.searchBar layoutSubviews];
    self.searchBar.placeholder = @"搜索地点";
    
    UIImage* searchBarBg = [self GetImageWithColor:[UIColor whiteColor] andHeight:32.0f];
    //设置背景图片
    [self.searchBar setBackgroundImage:searchBarBg];
    //设置背景色
    [self.searchBar setBackgroundColor:[UIColor whiteColor]];
    //设置文本框背景
    [self.searchBar setBackgroundImage:searchBarBg];
    
    self.backTableView.tableHeaderView = self.searchBar;
    
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
    
    UITextField * searchField = [self.searchBar rx_getSearchTextFiled];
    searchField.layer.masksToBounds = YES;
    
    if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
        NSArray *searchSubviews = [self.searchBar.subviews[0] subviews];
        for (UIView *subView in searchSubviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                subView.layer.cornerRadius = 6;
                subView.layer.masksToBounds = YES;
                subView.layer.borderColor = [UIColor colorWithHexString:@"#F0F0F0"].CGColor;
                subView.layer.borderWidth = 1;
                break;
            }else if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                subView.alpha = 0.0f;
            }else if([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")] ){
                NSLog(@"Keep textfiedld bkg color");
                subView.backgroundColor = [UIColor yellowColor];
            }else{
                
            }
            
        }
    }
    
    if (iOS7) {
        [self.searchBar setBackgroundImage:[UIColor createImageWithColor:UIColorFromRGB(0xF3F7F9)] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    }else{
        [self.searchBar setBackgroundImage:ThemeImage(@"searchBar_bg")];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    //搜索显示控制器
//    self.searchController =[[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
//     self.searchController.searchResultsTableView.backgroundColor=[UIColor whiteColor];
//    [self.searchController setDelegate:self];
#pragma clang diagnostic pop
//    self.searchController.searchResultsDataSource = self;
//    self.searchController.searchResultsDelegate = self;
//    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc]init];
//    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(setSeparatorInset:)])
//    {
//        [self.searchController.searchResultsTableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    if ([self.searchController.searchResultsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.searchController.searchResultsTableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    //    self.searchController.searchResultsTableView.backgroundColor=self.view.backgroundColor;
//    self.searchController.searchResultsTableView.backgroundColor=[UIColor whiteColor];
//    self.searchController.searchResultsTableView.separatorStyle =UITableViewCellSeparatorStyleNone;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self];
    self.searcher = [[QMSSearcher alloc] init];
    self.searchBar.backgroundColor = [UIColor clearColor];
    [self.searcher setDelegate:self];
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    //找到取消按钮
    UIButton *cancleBtn = [searchBar valueForKey:@"cancelButton"];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    //修改颜色
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.searchController.searchBar.tintColor = [UIColor blackColor];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchArr removeAllObjects];
    
    //分页
    [self.poiSearchOption setPage_size:20];
    [self.poiSearchOption setPage_index:1];
    [self.poiSearchOption setKeyword:searchText];
    [self.searcher searchWithPoiSearchOption:self.poiSearchOption];
//    [self.searchController setValue:@"没有找到相关结果" forKey:@"noResultsMessage"];
    self.searchTableView.hidden = self.searchArr.count<=0;
    [self.searchTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    self.searchTableView.hidden = YES;
}

//查询出现错误
- (void)searchWithSearchOption:(QMSSearchOption *)searchOption
              didFailWithError:(NSError*)error {

}

//poi查询结果回调函数
- (void)searchWithPoiSearchOption:(QMSPoiSearchOption *)poiSearchOption
                 didReceiveResult:(QMSPoiSearchResult *)poiSearchResult{
//    [self.searchController setValue:@"没有找到相关结果" forKey:@"noResultsMessage"];
    if (poiSearchResult.dataArray.count == 0) {
        self.searchIndex = 0;
        return;
    }
    [self.searchArr addObjectsFromArray:poiSearchResult.dataArray];
    self.searchTableView.hidden = self.searchArr.count<=0;
    [self.searchTableView reloadData];

}

#pragma mark - 点击定位
- (void)positionBtnClick {
    //初始化设置地图中心点坐标需要异步加入到主队列
    self.selectedIndex = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView setShowsUserLocation:YES];
        [self.mapView setCenterCoordinate:self.positionLocation.coordinate
                                zoomLevel:self.mapView.zoomLevel animated:YES];
    });
}

#pragma mark - 手势
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
//拖动地图时的回调
-(void)gestureAction:(UIGestureRecognizer *)gestureRecognizer {
    self.selectedIndex = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView setShowsUserLocation:NO];
    });
}

#pragma mark - tableview
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f*FitThemeFont;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.backTableView) {
        return 0;
    }
    
    if (tableView == self.searchTableView) {
        return self.searchArr.count>0 ?self.searchArr.count :0;
    }
    if (self.nearbyArr.count>0) {
        return self.nearbyArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.backTableView) {
        return nil;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"];
        //标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 5.0f*FitThemeFont, self.view.bounds.size.width - 45.0f*FitThemeFont, 24.0f*FitThemeFont)];
        titleLabel.font = ThemeFontLarge;
        titleLabel.textColor = [UIColor colorWithHexString:@"#39404E"];
        titleLabel.tag = 100;
        [cell.contentView addSubview:titleLabel];
        //位置
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 29.0f*FitThemeFont, self.view.bounds.size.width - 45.0f*FitThemeFont, 20.0f*FitThemeFont)];
        addressLabel.font = ThemeFontMiddle;
        addressLabel.textColor = [UIColor colorWithHexString:@"#768196"];
        addressLabel.tag = 200;
        [cell.contentView addSubview:addressLabel];
        //选中图片
        UIImageView *selectImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 30.0f*FitThemeFont, 17.0f*FitThemeFont, 20.0f*FitThemeFont, 20.0f*FitThemeFont)];
        selectImg.contentMode = UIViewContentModeScaleAspectFit;
        selectImg.image = ThemeImage(@"location_icon_choose"); //locationSelected
        selectImg.tag = 300;
        [cell.contentView addSubview:selectImg];
        //定位的描述
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, self.view.bounds.size.width - 45.0f*FitThemeFont, 54.0f*FitThemeFont)];
        desLabel.font = ThemeFontLarge;
        desLabel.textColor = [UIColor blackColor];
        desLabel.tag = 400;
        [cell.contentView addSubview:desLabel];
        [cell.contentView bringSubviewToFront:desLabel];
    }
    UILabel *titleLabel = [cell.contentView viewWithTag:100];
    UILabel *addressLabel = [cell.contentView viewWithTag:200];
    UIImageView *selectImg = [cell.contentView viewWithTag:300];
    UILabel *desLabel = [cell.contentView viewWithTag:400];
    selectImg.hidden = YES;
    desLabel.hidden = YES;
    titleLabel.text = @"";
    addressLabel.text = @"";
    desLabel.text = @"";
    
    if (tableView == self.searchTableView) {
        if (self.searchArr.count > 0) {
            QMSPoiData *poi = self.searchArr[indexPath.row];
            if (poi) {
//                DDLogInfo(@"poi.title == %@---- poi.address = %@",poi.title,poi.address);
                RXAttributedStringBuilder *builder = [RXAttributedStringBuilder builderWith:poi.title];
                [[builder allRange] setTextColor:[UIColor colorWithHexString:@"#39404E"]];
                [[builder includeString:self.searchBar.text all:NO] setTextColor:ThemeColor];
                titleLabel.attributedText = builder.commit;
                addressLabel.text = poi.address;
            }
        }
    }else{
        QMSReGeoCodePoi *poi = self.nearbyArr[indexPath.row];
        if (indexPath.row == 0) {
            desLabel.hidden = NO;
//           DDLogInfo(@"poi.title == %@---- poi.address = %@",poi.title,poi.address);
            desLabel.text = poi.address;
        } else {
            if (poi) {
//                 DDLogInfo(@" poi.title == %@---- poi.address = %@",poi.title,poi.address);
                titleLabel.text = poi.title;
                addressLabel.text = poi.address;
            }
        }
        if (indexPath.row == self.selectedIndex) {
            selectImg.hidden = NO;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.backTableView) {
        return;
    }
    if (tableView == self.searchTableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *selectImg =[cell.contentView viewWithTag:300];
        selectImg.hidden = NO;
        
        QMSPoiData *poi = self.searchArr[indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView setCenterCoordinate:poi.location
                                        zoomLevel:self.mapView.zoomLevel animated:YES];
            [_mapView setShowsUserLocation:NO];
        });
        self.searchBar.text = @"";
        self.searchBar.showsCancelButton = NO;
        [self.searchArr removeAllObjects];
        self.selectedIndex = 0;
        [self.searchBar endEditing:YES];
        [self.searchBar resignFirstResponder];
        self.searchTableView.hidden = YES;
    }else {
        self.selectedIndex = indexPath.row;
        [self.tableView reloadData];
         QMSReGeoCodePoi *poi = self.nearbyArr[indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([info isKindOfClass:[NSString class]]) {
//                NSString *title = (NSString *)info;
//                [self.mapView setCenterCoordinate:self.positionLocation.coordinate
//                                        zoomLevel:self.mapView.zoomLevel animated:YES];
//            } else {
//                                        zoomLevel:self.mapView.zoomLevel animated:YES];
//            }
//            QMSReGeoCodePoi *poi = (QMSReGeoCodePoi *)info;
            [self.mapView setCenterCoordinate:poi.location zoomLevel:self.mapView.zoomLevel animated:YES];
            self.locationPoint.coordinate = CLLocationCoordinate2DMake(0, 0);
            self.locationPoint.title = @"";
            
            self.locationPoint.coordinate = self.positionLocation.coordinate;
            self.locationPoint.title = poi.address;
        });
    }
}

#pragma mark - 快到底部的时候刷新
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView) {
        if (self.searchArr.count <10 || self.searchIndex == 0) {
            
        } else if (indexPath.row == self.searchArr.count -10) {
            self.searchIndex ++;
            //分页
            [self.poiSearchOption setPage_size:20];
            [self.poiSearchOption setPage_index:self.searchIndex];
            [self.poiSearchOption setKeyword:self.searchBar.text];
            [self.searcher searchWithPoiSearchOption:self.poiSearchOption];
        }
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.searchTableView) {
        [self.searchBar endEditing:YES];
        [self.searchBar resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 导航栏按钮
- (void)setNavUI {
    [self setBarItemTitle:languageStringWithKey(@"发送") titleColor:@"000000" target:self action:@selector(sendLocation) type:NavigationBarItemTypeRight];
    
    CGRect btnFrame = CGRectMake(0, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setImage:ThemeImage(@"title_bar_back") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(popToBackClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (void)popToBackClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)sendLocation {
    if (self.locationPoint == nil || self.locationPoint.coordinate.latitude == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未定位到位置，请等待" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (self.NewLocationDelegate && [self.NewLocationDelegate respondsToSelector:@selector(onSendUserLocation:)] && self.locationPoint) {
        [SVProgressHUD show];
        self.view.userInteractionEnabled = NO;
        //定义pointAnnotation
        QPointAnnotation *yinke = [[QPointAnnotation alloc] init];
        //    yinke.title = self.locationPoint.title;
        yinke.coordinate = self.locationPoint.coordinate;
        //向mapview添加annotation
        [_mapView addAnnotation:yinke];
        
        //关闭定位功能
        [_mapView setShowsUserLocation:NO];
        
        [self saveViewImage];
    //        //截图并存储
        [self.NewLocationDelegate onSendUserLocation:self.locationPoint];
        [self popToBackClicked];
        
    }
}

- (void)saveViewImage{
    
    [_mapView takeSnapshotInRect:CGRectMake(0, _mapView.top + 56, kScreenWidth, kScreenWidth * 0.5)withCompletionBlock:^(UIImage *resultImage, CGRect rect) {
        [self saveToDocment:resultImage];
        [SVProgressHUD dismiss];
    }];
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    static NSString *pointReuseIndentifier = @"pointReuseIdentifier";
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {
        QAnnotationView *annotationView = (QAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[QPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:pointReuseIndentifier];
        }
        UIImage *image = ThemeImage(@"redPin_lift");
        annotationView.image = image;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}


- (NSString *)saveToDocment:(UIImage *)image{
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", self.locationPoint.title];
    NSString *filePath = [image saveToDocumentWithFileName:fileName];
    dispatch_async(dispatch_get_main_queue(), ^{
        //发个通知去刷新聊天界面
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceivedGroupNotice object:nil];
    });
    return filePath;
}

@end
