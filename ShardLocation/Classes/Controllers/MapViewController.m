//
//  MapViewController.m
//  ShardLocation
//
//  Created by yons on 16/9/1.
//  Copyright © 2016年 yons. All rights reserved.
//

#import "MapViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "userInfo.h"
#define UTBMKSPAN 0.02
@interface MapViewController ()
@property(nonatomic,strong)BMKMapView* mapView;
@property(nonatomic,strong)UIButton* backBtn;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView=[[BMKMapView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    userInfo* info=[userInfo sharedUserInfo];
    BMKCoordinateRegion fitsRegion = [self.mapView regionThatFits:BMKCoordinateRegionMake(CLLocationCoordinate2DMake(info.latitude, info.longitude),BMKCoordinateSpanMake(UTBMKSPAN,UTBMKSPAN))];
    [self.mapView setRegion:fitsRegion animated:YES];
    BMKPointAnnotation *annotation = [BMKPointAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(info.latitude, info.longitude);
    annotation.title      = @"当前位置";
    [self.mapView addAnnotation:annotation];
    
    
    self.backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame=CGRectMake(self.view.frame.size.width-100, self.view.frame.size.height-60, 80, 40);
    [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn setAlpha:0.6];
    self.backBtn.backgroundColor =[UIColor greenColor];
    [self.backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    
}

-(void)backBtnClicked{
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
