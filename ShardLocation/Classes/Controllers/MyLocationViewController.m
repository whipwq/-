//
//  MyLocationViewController.m
//  ShardLocation
//
//  Created by yons on 16/8/30.
//  Copyright © 2016年 yons. All rights reserved.
//

#import "MyLocationViewController.h"
#import "PoiInfoTableViewCell.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "TestViewController.h"
#import "userInfo.h"
#import "RouteSearchViewController.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define UTBMKSPAN 0.02
@interface MyLocationViewController ()<BMKGeoCodeSearchDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,BMKPoiSearchDelegate>
@property(nonatomic,strong)BMKMapView* mapView;
@property(nonatomic,strong)BMKGeoCodeSearch* geoCodeSearch;
@property(nonatomic,strong)BMKLocationService* locService;
@property(nonatomic,strong)CLGeocoder *geocoder;
@property(nonatomic,strong)BMKUserLocation* userLocation;
@property(nonatomic,strong)UITableView* poiInfoTabVew;
@property(nonatomic,strong)UIImageView* flagImageView;
@property(nonatomic,strong)UIView* searchView;
@property(nonatomic,strong)UISearchBar* searchBar;
@property(nonatomic,strong)BMKPoiSearch* poiSearch;
@property(nonatomic,strong)UITableView* searchResultTabView;
@property(nonatomic,strong)UIButton* searchBtn;
//翻地理编码检索结果数组
@property(nonatomic,strong)NSMutableArray* poiInfosArray;
//是否点击cell
@property(nonatomic,assign)BOOL cellSlet;
//正Poi检索结果数组
@property(nonatomic,strong)NSMutableArray* searchResultArray;

@property(nonatomic,strong)UIBarButtonItem* sendBtnItem;
@property(nonatomic,strong)UIBarButtonItem* routeBtnItem;

@end

@implementation MyLocationViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [_mapView viewWillAppear];
    // 设置代理
    self.mapView.delegate       = self;
    self.locService.delegate    = self;
    self.geoCodeSearch.delegate = self;
    self.poiSearch.delegate     = self;
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [_mapView viewWillDisappear];
    // 代理致空
    self.mapView.delegate       = nil;
    self.locService.delegate    = nil;
    self.geoCodeSearch.delegate = nil;
    self.poiSearch.delegate     = nil;
}

-(UIButton*)searchBtn{
    
    if (_searchBtn== nil) {
        _searchBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.frame=CGRectMake(0, 64,SCREENWIDTH, 40);
       

    }
    return _searchBtn;
}


-(UISearchBar*)searchBar{
    
    if (_searchBar == nil) {
        _searchBar = [UISearchBar new];
        _searchBar.frame        = CGRectMake(0, 20, SCREENWIDTH-60, 44);
        _searchBar.delegate     = self;
        _searchBar.placeholder  = @"请输入你要搜索的内容";
        
    }
    
    return _searchBar;
}


-(UITableView*)searchResultTabView{
    
    if (_searchResultTabView == nil) {
        _searchResultTabView =[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
        _searchResultTabView.dataSource = self;
        _searchResultTabView.delegate = self;
        _searchResultTabView.hidden = YES;
    }
    
    return _searchResultTabView;
}




-(UIView*)searchView{
    
    if (_searchView == nil) {
        _searchView = [UIView new];
        _searchView.frame = self.view.bounds;
        _searchView.hidden = YES;
        _searchView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
    }
    return _searchView;
}


-(UIImageView*)flagImageView{
    
    if (_flagImageView==nil) {
        
        _flagImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"flag"]];
        _flagImageView.frame=CGRectMake(self.view.center.x-15,self.view.center.y*0.5-30-32,40,30);
        
    }
    
    return _flagImageView;
}



// 懒加载mapview
-(BMKMapView*)mapView{
    
    if (_mapView==nil) {
        
        _mapView=[[BMKMapView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+104, self.view.frame.size.width,SCREENHEIGHT*0.5-64)];
        
        // 设置地图的模式
        _mapView.mapType=BMKMapTypeStandard;
        // 显示定位图层
        _mapView.showsUserLocation = YES;
        // 设置定位模式
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        // 设置是否可以旋转
        _mapView.rotateEnabled = NO;
        // 是否显示比例尺
        _mapView.showMapScaleBar = YES;
        // 比例尺的位置
        _mapView.mapScaleBarPosition = CGPointMake(SCREENWIDTH-50, 0);
        
    }
    
    return _mapView;
}
// 懒加载locService
-(BMKLocationService*)locService{
    
    if (_locService==nil) {
        _locService=[[BMKLocationService alloc]init];
        // 设置每移动20米定一次位
        _locService.distanceFilter=25;
        // 设置定位服务的精度
        _locService.desiredAccuracy=kCLLocationAccuracyBest;
    }
    
    
    return _locService;
}


-(BMKPoiSearch*)poiSearch{
    
    if (_poiSearch==nil) {
        _poiSearch=[[BMKPoiSearch alloc]init];
    }
    
    return _poiSearch;
    
}

// 懒加载geoCodeSearch
-(BMKGeoCodeSearch*)geoCodeSearch{
    
    if (_geoCodeSearch==nil) {
        _geoCodeSearch=[[BMKGeoCodeSearch alloc]init];
    }
    
    return _geoCodeSearch;
}

// 懒加载tableView
-(UITableView*)poiInfoTabVew{
    
    if (_poiInfoTabVew==nil) {
        
        _poiInfoTabVew = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, SCREENHEIGHT*0.5+40, SCREENWIDTH, SCREENHEIGHT*0.5-40) style:UITableViewStylePlain];
        _poiInfoTabVew.delegate = self;
        _poiInfoTabVew.dataSource = self;
    }
    
    return _poiInfoTabVew;
}

-(NSMutableArray*)searchResultArray{
    
    if (_searchResultArray==nil) {
        _searchResultArray=[NSMutableArray array];
    }
    return _searchResultArray;
}



// 懒加载poiInfosArray
-(NSMutableArray*)poiInfosArray{
    
    if (_poiInfosArray==nil) {
        
        _poiInfosArray=[NSMutableArray array];
    }
    
    return _poiInfosArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的位置";
    [self.searchBtn addTarget:self action:@selector(searchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn setBackgroundImage:[UIImage imageNamed:@"searbutton"] forState:UIControlStateNormal];
    [self.view addSubview:self.searchBtn];
    [self.view insertSubview:self.mapView atIndex:0];
    [self.mapView addSubview:self.flagImageView];
    [self.view addSubview:self.poiInfoTabVew];
    [self.poiInfoTabVew registerNib:[UINib nibWithNibName:@"PoiInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"poiInfo"];
    [self.searchResultTabView registerNib:[UINib nibWithNibName:@"PoiInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"poiInfo"];
    [self setNavigationItems];
    // 开启定位
    [self.locService startUserLocationService];
    [self.view addSubview:self.searchView];
    [self.searchBar showsCancelButton];
    [self.searchView addSubview:self.searchBar];
    
}

-(void)searchBtnClicked{
    
    self.searchView.hidden=NO;
    [self.searchBar becomeFirstResponder];
    UIButton* searchCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchCancelBtn.frame = CGRectMake(SCREENWIDTH-50, 20, 40, 44);
    searchCancelBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [searchCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [searchCancelBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [searchCancelBtn addTarget:self action:@selector(searchCanelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBar setTranslucent:YES];
    [self.searchView addSubview:self.searchResultTabView];
    [self.searchView addSubview:searchCancelBtn];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

-(void)setNavigationItems{
    
    self.sendBtnItem  = [[UIBarButtonItem alloc]initWithTitle:@"发送位置" style:UIBarButtonItemStyleDone target:self action:@selector(sendBtnClicked)];
    
    self.routeBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"路径规划" style:UIBarButtonItemStyleDone target:self action:@selector(routeBtnClicked)];
    
    self.navigationItem.leftBarButtonItem=self.routeBtnItem;
    self.navigationItem.rightBarButtonItem=self.sendBtnItem;
    
    
    
}

-(void)routeBtnClicked{
    
    RouteSearchViewController* routeVc = [RouteSearchViewController new];
    
    [self.navigationController pushViewController:routeVc animated:YES];
    
    
}


// 发送位置信息
-(void)sendBtnClicked{
    
    
    TestViewController*vc=[[TestViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (UIImage*)screenView:(UIView *)view{


    return [self.mapView takeSnapshot:self.mapView.bounds];
}

-(void)searchCanelBtnClicked{
    
    self.searchView.hidden=YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.searchBar resignFirstResponder];
}



// 定位成功的代理方法
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    // 更新用户位置
    [self.mapView updateLocationData:userLocation];
    
    [userInfo sharedUserInfo].mapImage  = [self screenView:self.mapView];
    [userInfo sharedUserInfo].latitude  = self.userLocation.location.coordinate.latitude;
    [userInfo sharedUserInfo].longitude = self.userLocation.location.coordinate.longitude;
    // 将用户位置存在内存中
    self.userLocation = userLocation;
    
    // mapView以用户位置为中心，设置region
    BMKCoordinateRegion fitsRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(userLocation.location.coordinate,BMKCoordinateSpanMake(UTBMKSPAN,UTBMKSPAN))];
    [self.mapView setRegion:fitsRegion animated:YES];
    
    // 以用户位置发起反geo检索
    [self startReverseGeocodesearchWith:userLocation.location.coordinate];
    
    

}

//发起反向地理编码检索
-(void)startReverseGeocodesearchWith:(CLLocationCoordinate2D)coordinate{
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];

    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
    
    BOOL flag = [self.geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

//发起poi检索
-(void)startPoisearchWith:(NSString*)keyWord{

    BMKCitySearchOption *option = [[BMKCitySearchOption alloc] init];
    option.pageIndex    = 0;
    option.pageCapacity = 20;
    option.city=@"成都";
    option.keyword=keyWord;
    
    //发送请求
    BOOL flag = [self.poiSearch poiSearchInCity:option];
    if (flag) {
        NSLog(@"发送请求成功....");
    }
    else{
        NSLog(@"发送请求失败....");
    }
    
}


//接收反向地理编码检索结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error ==BMK_SEARCH_NO_ERROR){
        
       //1.移除上一次所有检索结果
        [self.poiInfosArray removeAllObjects];
        
       //2.保存本次检索的结果
        [self.poiInfosArray addObjectsFromArray:result.poiList];
        
       //3.刷新tabView
        [self.poiInfoTabVew reloadData];
        

    }
}
//接收poi检索的结果
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    
    
    if (errorCode ==BMK_SEARCH_NO_ERROR){
        
        [self.searchResultArray removeAllObjects];
        [self.searchResultArray addObjectsFromArray:poiResult.poiInfoList];
        [self.searchResultTabView reloadData];
    }
}


#pragma mark tableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView==self.poiInfoTabVew) {
        return self.poiInfosArray.count;
    }else{
        return self.searchResultArray.count;
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==self.poiInfoTabVew){
        //复用自定义cell
        PoiInfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"poiInfo" forIndexPath:indexPath];
        
         //取出indexPath对应的模型
        BMKPoiInfo*poiInfo=self.poiInfosArray[indexPath.row];
        cell.nameLabel.text=poiInfo.name;
        cell.addressLabel.text=poiInfo.address;
 
    return cell;
    }
    
    else{
        
        //复用自定义cell
        PoiInfoTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"poiInfo" forIndexPath:indexPath];
        BMKPoiInfo*poiInfo=self.searchResultArray[indexPath.row];
        cell.nameLabel.text=poiInfo.name;
        cell.addressLabel.text=poiInfo.address;
        
    return cell;
    };
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

//点中cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==self.poiInfoTabVew) {
        // 设置为点中cell状态
         self.cellSlet=YES;
        [self moveToRegionWithModleArray:self.poiInfosArray WithIndexPath:indexPath];
        
    }
    else{

        self.searchView.hidden=YES;
        [self.searchBar resignFirstResponder];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self moveToRegionWithModleArray:self.searchResultArray WithIndexPath:indexPath];
        
    }

}

-(void)moveToRegionWithModleArray:(NSArray*)modelArray WithIndexPath:(NSIndexPath *)indexPath{
    
    //1.取出对应的BMKPoiInfo模型
    BMKPoiInfo* poiInfo=modelArray[indexPath.row];
    
    //2.根据模型的位置，改变mapView的region
    BMKCoordinateRegion fitsRegion =[self.mapView regionThatFits:BMKCoordinateRegionMake(poiInfo.pt,BMKCoordinateSpanMake(UTBMKSPAN,UTBMKSPAN))];
    [self.mapView setRegion:fitsRegion animated:YES];
    
    //3.移除所有大头针
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    //4.创建大头针
    BMKPointAnnotation *annotation = [BMKPointAnnotation new];
    annotation.coordinate = poiInfo.pt;
    annotation.title      = poiInfo.name;
    [self.mapView addAnnotation:annotation];

    
}

//自定义大头针
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"annotation";
    
    // 大头针的复用
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置动画效果
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}

//地图region改变时触发的代理方法
-(void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    //判断是否为cell点中致使的本次方法触发，如果是则此方法不做任何处理
    if (self.cellSlet) {
        
        //把cellSlet置为NO;
        self.cellSlet=NO;
        
        return;
    }
    
    //不是点中cell触发的region的改变，而是拖动地图发生的region变化，就根据拖动地图后，mapView中心的经纬度，发起发地理编码检索，刷新tableView，展示拖动地图后，周围的PoiInfos;
    
    //小红旗动画
    [self flagAnoimated];
    
    //开启反地理编码检索
    [self startReverseGeocodesearchWith:mapView.centerCoordinate];
    

}

//小红旗动画

-(void)flagAnoimated{
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGRect frame=CGRectMake(self.flagImageView.frame.origin.x, self.flagImageView.frame.origin.y-20, self.flagImageView.frame.size.width, self.flagImageView.frame.size.height);
        self.flagImageView.frame=frame;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            CGRect frame=CGRectMake(self.flagImageView.frame.origin.x, self.flagImageView.frame.origin.y+20, self.flagImageView.frame.size.width, self.flagImageView.frame.size.height);
            self.flagImageView.frame=frame;
            
        } completion:nil];
    }];
    
}

//点中搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    self.searchResultTabView.hidden=NO;
    [self.searchBar resignFirstResponder];
    [self startPoisearchWith:self.searchBar.text];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
