//
//  RouteSearchViewController.m
//  ShardLocation
//
//  Created by yons on 16/9/2.
//  Copyright © 2016年 yons. All rights reserved.
//

#import "RouteSearchViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define UTBMKSPAN 0.02
#import "userInfo.h"
@interface RouteSearchViewController ()<BMKMapViewDelegate,BMKShareURLSearchDelegate,BMKRouteSearchDelegate>

@property (weak, nonatomic) IBOutlet UIView *mapContentView;
@property (weak, nonatomic) IBOutlet UITextField *startTexfilde;
@property (weak, nonatomic) IBOutlet UITextField *endTexfiled;
@property (weak, nonatomic) IBOutlet UIButton *moveStyle;
@property (nonatomic,strong) BMKMapView* mapView;
@property (nonatomic,strong) BMKShareURLSearch* shareURLSearch;
@property (nonatomic,strong) UIBarButtonItem* searBtnItem;
@property (nonatomic,strong) BMKRouteSearch* routeSearch;
@end

@implementation RouteSearchViewController


-(void)viewWillAppear:(BOOL)animated{
    
    self.mapView.delegate = self;
    self.shareURLSearch.delegate = self;
    self.routeSearch.delegate = self;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    self.mapView.delegate = nil;
    self.shareURLSearch.delegate = nil;
    self.routeSearch.delegate = nil;
}



-(BMKMapView*)mapView{
    
    if (_mapView==nil) {
        
        _mapView = [[BMKMapView alloc]initWithFrame:self.mapContentView.bounds];
    }
    
    return _mapView;
}

-(BMKRouteSearch*)routeSearch{
    
    if (_routeSearch==nil) {
        
        _routeSearch = [BMKRouteSearch new];
    }
    
    return _routeSearch;
}

-(BMKShareURLSearch*)shareURLSearch{
    
    if (_shareURLSearch==nil) {
        
        _shareURLSearch = [BMKShareURLSearch new];
    }
    
    return _shareURLSearch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapContentView addSubview: self.mapView];
    [self moveToUserRegion];
    [self setNavigationItems];
    
}

-(void)moveToUserRegion{
    
    userInfo* info=[userInfo sharedUserInfo];
    BMKCoordinateRegion fitsRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(CLLocationCoordinate2DMake(info.latitude, info.longitude),BMKCoordinateSpanMake(UTBMKSPAN,UTBMKSPAN))];
    [self.mapView setRegion:fitsRegion animated:YES];
    BMKPointAnnotation *annotation = [BMKPointAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(info.latitude, info.longitude);
    annotation.title      = @"当前位置";
    [self.mapView addAnnotation:annotation];
}

-(void)setNavigationItems{
    
    self.searBtnItem  = [[UIBarButtonItem alloc]initWithTitle:@"查询" style:UIBarButtonItemStyleDone target:self action:@selector(sendBtnClicked)];
    
    self.navigationItem.rightBarButtonItem = self.searBtnItem;
    
}


-(void)sendBtnClicked{
    
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    if ([self.startTexfilde.text isEqualToString:@"我的位置"]) {
        start.pt=CLLocationCoordinate2DMake([userInfo sharedUserInfo].latitude, [userInfo sharedUserInfo].longitude);
    }
    else{
        start.name = self.startTexfilde.text;
    }
   
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = self.endTexfiled.text;
    BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
    transitRouteSearchOption.city = @"成都";
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to   = end;
    
    BOOL flag = [self.routeSearch transitSearch:transitRouteSearchOption];
   
    if(flag)
    {
        NSLog(@"bus检索发送成功");
    }
    else
    {
        NSLog(@"bus检索发送失败");
    }
    
}

- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    
    if (error == BMK_SEARCH_NO_ERROR){
        
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:1];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        NSLog(@"%ld",size);
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
            
            NSLog(@"%d",i);
            if (i==1) {
                BMKPointAnnotation *annotation = [BMKPointAnnotation new];
                annotation.coordinate = plan.starting.location;
                annotation.title      = @"起点";
                [self.mapView addAnnotation:annotation];
            }else if(i==size-1){
                
                BMKPointAnnotation *annotation = [BMKPointAnnotation new];
                annotation.coordinate = plan.terminal.location;
                annotation.title      = @"终点";
                [self.mapView addAnnotation:annotation];
            }
            
            BMKPointAnnotation *annotation = [BMKPointAnnotation new];
            annotation.coordinate = transitStep.entrace.location;
            annotation.title      = transitStep.instruction;;
            [self.mapView addAnnotation:annotation];
            
            
            planPointCounts += transitStep.pointsCount;
        }
        
//c的方式结构体转结构体指针
//        BMKMapPoint *tempPoints = malloc(sizeof(BMKMapPoint) *planPointCounts);
//        
//        for (int i = 0; i < size; i++) {
//            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
//            for (int j = 0; j<transitStep.pointsCount; j++) {
//                
//                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(transitStep.points[j].x, transitStep.points[j].y);
//                BMKMapPoint point = BMKMapPointForCoordinate(coordinate);
//                tempPoints[j] = point;
//            }
//            
//            
//        }
//        
//        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:tempPoints count:planPointCounts];
//        [_mapView addOverlay:polyLine];
//        
//        [self mapViewFitPolyLine:polyLine];
        
        
//c++方式结构体转结构体指针
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];

        
    }
}


- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}


- (BMKAnnotationView*)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"annotation";
    
    // 大头针的复用
    BMKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
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

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
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
