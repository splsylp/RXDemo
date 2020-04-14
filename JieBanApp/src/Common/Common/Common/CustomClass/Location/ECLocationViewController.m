//
//  ECLocationViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/15.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ECLocationViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>


@interface ECLocationViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) ECLocationPoint *locationPoint;
@property(nonatomic,strong) CLGeocoder * geoCoder;

// LocalSearch Stuff...
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKLocalSearchRequest *localSearchRequest;
@property (nonatomic, strong) UITextField *searchField;

@property (nonatomic, strong) UIView *bottomMoveView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, retain) NSMutableArray *searchData;
@property (nonatomic, assign) NSInteger selectIndexRow;
@end

@implementation ECLocationViewController
{
    BOOL  _updateLocation;
    BOOL  _isHiddenBtn;
    BOOL  _isOpenAppleBtn;
    UIButton *_toUserLocationBtn;
}

- (instancetype)initWithLocationPoint:(ECLocationPoint*)locationPoint{
    self = [super init];
    if (self) {
        _locationPoint = locationPoint;
        _isOpenAppleBtn = YES;
        _selectIndexRow = 0;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    _geoCoder = [[CLGeocoder alloc] init];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    
    _toUserLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _toUserLocationBtn.frame = CGRectMake(0, 0, 44, 44);
    _toUserLocationBtn.center = CGPointMake(kScreenWidth-30, kScreenHeight-kTotalBarHeight-45);
    [_toUserLocationBtn addTarget:self  action:@selector(turnToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [_toUserLocationBtn setImage:ThemeImage(@"rx_poi_mylocation_btn_bg_normal") forState:UIControlStateNormal];
    [_toUserLocationBtn setImage:ThemeImage(@"rx_poi_mylocation_btn_bg_pressed") forState:UIControlStateHighlighted];
    [self.mapView addSubview:_toUserLocationBtn];
    
    if (!self.locationPoint) {
        UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        topView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:topView];
        
        UIImageView *imgView= [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 30, 30)];
        imgView.image = ThemeImage(@"title_bar_search");
        [topView addSubview:imgView];
        
        self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(40, 0, kScreenWidth-50, 40)];
        self.searchField.font = ThemeFontMiddle;
        self.searchField.returnKeyType = UIReturnKeySearch;
        self.searchField.delegate= self;
        self.searchField.placeholder = languageStringWithKey(@"搜索");
        self.searchField.font = SystemFontLarge;
        [topView addSubview:_searchField];
        
        self.bottomMoveView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-kTotalBarHeight, kScreenWidth, (kScreenHeight-kTotalBarHeight)/2 + 20)];
        self.bottomMoveView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_bottomMoveView];
        
        self.searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, (kScreenHeight-kTotalBarHeight)/2) style:UITableViewStylePlain];
        self.searchTableView.delegate = self;
        self.searchTableView.dataSource = self;
        [self.bottomMoveView addSubview:_searchTableView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth-60, 0, 60, 40);
        [btn addTarget:self  action:@selector(moveViewHiddenAction) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:languageStringWithKey(@"关闭") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.bottomMoveView addSubview:btn];
        
        
        
        UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        lpress.minimumPressDuration = 0.3;//按0.5秒响应longPress方法
        lpress.allowableMovement = 10.0;
        //给MKMapView加上长按事件
        [_mapView addGestureRecognizer:lpress];//mapView是MKMapView的实例
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = languageStringWithKey(@"位置");
    if (iOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
//    UIBarButtonItem * leftItem = nil;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        leftItem = [[UIBarButtonItem alloc] initWithImage:[ThemeImage(@"title_bar_back") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(popToBackClicked)];
//    } else {
//        leftItem = [[UIBarButtonItem alloc] initWithImage:ThemeImage(@"title_bar_back") style:UIBarButtonItemStyleDone target:self action:@selector(popToBackClicked)];
//    }
//    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIImage *normalImg = ThemeImage(@"title_bar_back");
    CGRect btnFrame = CGRectMake(-10, 0, 40, 40);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:btnFrame];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:normalImg forState:UIControlStateHighlighted];
    [button.imageView setContentMode:UIViewContentModeCenter];
    [button addTarget:self action:@selector(popToBackClicked) forControlEvents:UIControlEventTouchUpInside];
    UIView* frameView = [[UIView alloc] initWithFrame:btnFrame];
    [frameView addSubview:button];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:frameView];
    self.navigationItem.leftBarButtonItem = buttonItem;

    

    
    if (self.locationPoint) {
        [self.mapView addAnnotation:self.locationPoint];
        [self setRegion:self.locationPoint.coordinate];
    } else {
        _isHiddenBtn = YES;
        self.locationPoint   = [[ECLocationPoint alloc] init];
        if ([CLLocationManager locationServicesEnabled]) {
            if ([UIDevice currentDevice].systemVersion.integerValue>=8.0) {
                [_locationManager requestAlwaysAuthorization];
            }
            CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
            if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
                [self showToast:languageStringWithKey(@"请在设置-隐私里允许程序使用地理位置服务")];
            }else{
                self.mapView.showsUserLocation = YES;
                
            }
        }else{
            [self showToast:languageStringWithKey(@"请打开地理位置服务")];
        }
    }
    
}

- (void)turnToUserLocation{
    if (_updateLocation && self.locationPoint) {
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [self reverseGeoLocation:_mapView.userLocation.coordinate];
        _mapView.centerCoordinate = _mapView.userLocation.coordinate;
        [self moveViewHiddenAction];
    }else if (self.locationPoint){
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [self reverseGeoLocation:self.locationPoint.coordinate];
        _mapView.centerCoordinate = self.locationPoint.coordinate;
        [self moveViewHiddenAction];
    }
}

-(void)showToast:(NSString*)str {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:languageStringWithKey(@"提示") message:str delegate:self cancelButtonTitle:languageStringWithKey(@"取消") otherButtonTitles:nil, nil];
    [alert show];
}

- (void)popToBackClicked {
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)sendLocation {
    if (self.locationPoint == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:languageStringWithKey(@"提示") message:languageStringWithKey(@"未定位到位置，请等待") delegate:self cancelButtonTitle:languageStringWithKey(@"取消") otherButtonTitles:nil, nil];
        [alert show];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSendUserLocation:)] && self.locationPoint) {
        [self popToBackClicked];
        [self.delegate onSendUserLocation:self.locationPoint];
    }
}

- (void)setRightItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSendUserLocation:)] && self.locationPoint) {
    
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:languageStringWithKey(@"发送") style:UIBarButtonItemStyleDone target:self action:@selector(sendLocation)];
        //    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:61/255.0 green:198/255.0 blue:124/255.0 alpha:1]} forState:UIControlStateNormal];
        [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

#pragma mark 设置区域
- (void)setRegion:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion theRegion;
    theRegion.center = coordinate;
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [_mapView setRegion:theRegion animated:NO];
}
#pragma mark - MKMapView 代理
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    if (!_updateLocation) {
//        return;
//    }
//
//    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
//    [self reverseGeoLocationRound:centerCoordinate];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
//    if (!_updateLocation) {
//        return;
//    }
//    [_mapView removeAnnotations:_mapView.annotations];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if ((!_updateLocation) && self.locationPoint) {
        _updateLocation = YES;
        [self reverseGeoLocation:userLocation.coordinate];
        [self setRegion:userLocation.coordinate];
        
    }
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *reusePin = @"PinAnnotation";
    MKPinAnnotationView * pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reusePin];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusePin];
    }
    if (_isOpenAppleBtn == YES) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:ThemeImage(@"location_GPS") forState:UIControlStateNormal];
        [button sizeToFit];
        pin.rightCalloutAccessoryView = button;
    }
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = annotation.title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font =ThemeFontSmall;
    [titleLabel sizeToFit];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    pin.detailCalloutAccessoryView = titleLabel;
    
    pin.canShowCallout	= YES;
    pin.pinColor = MKPinAnnotationColorRed;
    pin.animatesDrop = YES;
    pin.selected = YES;
    
    if (annotation == mapView.userLocation) {
        titleLabel.text = languageStringWithKey(@"当前位置");
        pin.pinColor = MKPinAnnotationColorGreen;
    }else if ([annotation isEqual:self.locationPoint]){
        pin.pinColor = MKPinAnnotationColorPurple;
    }
    return pin;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    [_mapView selectAnnotation:self.locationPoint animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    UIActionSheet *action = [[UIActionSheet alloc] init];
    [action addButtonWithTitle:languageStringWithKey(@"苹果地图导航")];
    [action addButtonWithTitle:languageStringWithKey(@"取消")];
    action.delegate = self;
    action.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [action showInView:self.view];
}
#pragma mark - reverseGeoLocation
- (void)reverseGeoLocation:(CLLocationCoordinate2D)locationCoordinate2D{
    if (self.geoCoder.isGeocoding) {
        [self.geoCoder cancelGeocode];
    }
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinate2D.latitude longitude:locationCoordinate2D.longitude];
    __weak typeof(self) weakSelf = self;
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            CLPlacemark *mark = [placemarks firstObject];
            NSString * title  = mark.name;
            ECLocationPoint *ponit = [[ECLocationPoint alloc] initWithCoordinate:locationCoordinate2D andTitle:title];
            strongSelf.locationPoint = ponit;
            [strongSelf.mapView addAnnotation:ponit];
            [strongSelf.mapView selectAnnotation:self.locationPoint animated:YES];
            [strongSelf setRightItem];
        } else {
            strongSelf.locationPoint = nil;
        }
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.locationPoint.coordinate addressDictionary:@{@"title":self.locationPoint.title}];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = self.locationPoint.title;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if ([textField.text isEqualToString:@""]) {
        return NO;
    }
    CLLocationCoordinate2D centerCoordinate = _mapView.region.center;
    [self issueLocalSearchLookup:textField.text usingCoordinate2D:centerCoordinate];
    return YES;
}

/**
 *  周边检索
 */


// Ex: [self issueLocalSearchLookup:@"grocery"];
-(void)issueLocalSearchLookup:(NSString *)searchString usingCoordinate2D:(CLLocationCoordinate2D )coordinate {

    if (KCNSSTRING_ISEMPTY(searchString)) {
        return;
    }
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01f, 0.01f);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
//    MKCoordinateRegion region = MKCoordinateRegionMake(self.coords, self.mapView.region.span);
    
    // Create the search request
    self.localSearchRequest = [[MKLocalSearchRequest alloc] init];
    self.localSearchRequest.region = region;
    self.localSearchRequest.naturalLanguageQuery = searchString;
    
    [SVProgressHUD showWithStatus:languageStringWithKey(@"正在搜索...")];
    
    // Perform the search request...
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:self.localSearchRequest];
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [SVProgressHUD dismiss];
        if(error){
            
            DDLogInfo(@"localSearch startWithCompletionHandlerFailed!  Error: %@", error);
            return;
            
        } else {

            
            [self.searchData removeAllObjects];
            
            [self->_mapView removeOverlays:self->_mapView.overlays];
            [self->_mapView removeAnnotations:self->_mapView.annotations];
            
            self->_selectIndexRow = 0;
            if (response.mapItems.count>0) {
                
                for (int i = 0; i<response.mapItems.count; i++) {
                    MKMapItem *mapItem = response.mapItems[i];
                    ECLocationPoint *point = [[ECLocationPoint alloc] initWithCoordinate:mapItem.placemark.location.coordinate andTitle:mapItem.name];
                    [self.mapView addAnnotation:point];
                    [self->_searchData addObject:point];
                    if (i==0) {
                        self.locationPoint = point;
                        [self setRightItem];
                        [self setRegion:mapItem.placemark.location.coordinate];
                    }
                }

                [self moveViewShowAction];
            }else{
                [self moveViewHiddenAction];
            }

            [self->_searchTableView reloadData];
        }
    }];  
}

#pragma mark ===UITableViewDelegate,UITableViewDataSource===
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = NO;
    }
    
    if (_selectIndexRow == indexPath.row){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    ECLocationPoint *point = self.searchData[indexPath.row];
    
    cell.textLabel.text = point.title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectIndexRow = indexPath.row;

    ECLocationPoint *point1 = _searchData[_selectIndexRow];
    self.locationPoint = point1;
    
    MKPinAnnotationView * pin = (MKPinAnnotationView *)[_mapView viewForAnnotation:point1];
    pin.pinColor = MKPinAnnotationColorPurple;
    [self setRightItem];
    [self setRegion:point1.coordinate];
    
    
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    for (ECLocationPoint *point in _searchData) {
        [self.mapView addAnnotation:point];
    }
    
    [tableView reloadData];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){  //这个状态判断很重要
        //坐标转换
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        //这里的touchMapCoordinate.latitude和touchMapCoordinate.longitude就是你要的经纬度，
        DDLogInfo(@"%f",touchMapCoordinate.latitude);
        DDLogInfo(@"%f",touchMapCoordinate.longitude);
        
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [self reverseGeoLocation:touchMapCoordinate];
        [self moveViewHiddenAction];
    }
}

- (void)moveViewHiddenAction{
    [UIView animateWithDuration:.25 animations:^{
        self.mapView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTotalBarHeight);
        self.bottomMoveView.frame = CGRectMake(0, kScreenHeight-kTotalBarHeight, kScreenWidth, (kScreenHeight-kTotalBarHeight)/2 + 20);
        self->_toUserLocationBtn.center = CGPointMake(kScreenWidth-30, kScreenHeight-kTotalBarHeight-45);
    }];
}
- (void)moveViewShowAction{
    [UIView animateWithDuration:.25 animations:^{
        self.mapView.frame = CGRectMake(0, 0, kScreenWidth, (kScreenHeight-kTotalBarHeight)/2+40);
        self.bottomMoveView.frame = CGRectMake(0, (kScreenHeight-kTotalBarHeight)/2 - 20, kScreenWidth, (kScreenHeight-kTotalBarHeight)/2 + 20);
        self->_toUserLocationBtn.center = CGPointMake(kScreenWidth-30, kScreenHeight-kTotalBarHeight-45);
    }];
}

- (NSMutableArray *)searchData{
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}

-(void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    self.localSearch = nil;
    self.localSearchRequest = nil;
}


@end
