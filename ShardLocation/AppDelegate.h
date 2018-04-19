//
//  AppDelegate.h
//  ShardLocation
//
//  Created by yons on 16/8/30.
//  Copyright © 2016年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic)BMKMapManager*mapManager;
@end

