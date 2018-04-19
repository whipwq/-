//
//  TestViewController.m
//  ShardLocation
//
//  Created by yons on 16/9/1.
//  Copyright © 2016年 yons. All rights reserved.
//

#import "TestViewController.h"
#import "MapTableViewCell.h"
#import "userInfo.h"
#import "MapViewController.h"

@interface TestViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView*tableView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
   [self.tableView registerNib:[UINib nibWithNibName:@"MapTableViewCell" bundle:nil] forCellReuseIdentifier:@"mapcell"];
    [self.view addSubview:self.tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MapTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"mapcell" forIndexPath:indexPath];
    NSLog(@"%@",[userInfo sharedUserInfo].mapImage);
    //cell.mapImageView=[[UIImageView alloc]init];
    cell.mapImageView.image=[userInfo sharedUserInfo].mapImage;
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MapViewController* mapVc=[MapViewController new];
    [self presentViewController:mapVc animated:YES completion:nil];
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
