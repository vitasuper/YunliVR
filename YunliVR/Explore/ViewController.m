//
//  ViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/11/7.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "ViewController.h"
#import "VRVideoIntroTableViewCell.h"
#import "VRVideoIntroViewController.h"
#import "GVRPanoramaView.h"
#import "GVRVideoView.h"
#import <BmobSDK/Bmob.h>
#import <YYWebImage/YYWebImage.h>
#import <MJRefresh.h>

@interface ViewController () <GVRWidgetViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *photoArray;
    
    NSMutableArray *videoNameArray;
    NSMutableArray *coverImgURLArray;
    NSMutableArray *videoIntroArray;
    NSMutableArray *videoURLArray;
    
    NSString *videoName;
    NSString *coverImgURL;
    NSString *videoIntro;
    NSString *videoURL;
    
    UIView *currentView;
    GVRWidgetDisplayMode currentDisplayMode;
    BOOL refreshing;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"YUNLI VR";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    photoArray = [[NSMutableArray alloc] initWithObjects:@"sindhu_beach.jpg", @"grand_canyon.jpg", @"underwater.jpg", nil];

    currentDisplayMode = kGVRWidgetDisplayModeEmbedded;
    
    videoNameArray = [[NSMutableArray alloc] init];
    coverImgURLArray = [[NSMutableArray alloc] init];
    videoIntroArray = [[NSMutableArray alloc] init];
    videoURLArray = [[NSMutableArray alloc] init];
    
    [self getVRVideoInfo];
    self.tableView.separatorStyle = NO;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        refreshing = YES;
        
        NSLog(@"TEST1: start refreshing!");
        
        [self getVRVideoInfo];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 读取后端数据表

- (void)getVRVideoInfo {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"BasicInfo"];
    // 查找表的数据
    
    [videoNameArray removeAllObjects];
    [coverImgURLArray removeAllObjects];
    [videoIntroArray removeAllObjects];
    [videoURLArray removeAllObjects];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            [videoNameArray addObject:[obj objectForKey:@"videoName"]];
            NSLog(@"%@", [obj objectForKey:@"videoName"]);
            [coverImgURLArray addObject:[obj objectForKey:@"coverImgURL"]];
            [videoIntroArray addObject:[obj objectForKey:@"videoIntro"]];
            [videoURLArray addObject:[obj objectForKey:@"videoURL"]];;
        }
        
        NSLog(@"TEST2");
        
        if (refreshing) {
            refreshing = NO;
            NSLog(@"TEST3: Stop refreshing~~");
            [self.tableView.mj_header endRefreshing];
        }
        
        [self.tableView reloadData];
    }];
    
}


#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return coverImgURLArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VRVideoIntroTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"VRVideoIntroTableViewCell"];
    [cell coverImageView].yy_imageURL = [NSURL URLWithString:[coverImgURLArray objectAtIndex:indexPath.row]];
    
//    // 原生格式的添加圆角
//    cell.coverImageView.layer.cornerRadius = 10.0f;
//    cell.coverImageView.layer.masksToBounds = YES;
    
    // 切除图片超过框的部分
    [cell coverImageView].clipsToBounds = YES;
    
    cell.titleLabel.text = [videoNameArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    videoName = [videoNameArray objectAtIndex:indexPath.row];
    coverImgURL = [coverImgURLArray objectAtIndex:indexPath.row];
    videoIntro = [videoIntroArray objectAtIndex:indexPath.row];
    videoURL = [videoURLArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toVRVideoIntroSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVRVideoIntroSegue"]) {
        VRVideoIntroViewController *dest = segue.destinationViewController;
        dest.coverImgURL = coverImgURL;
        dest.videoIntro = videoIntro;
        dest.videoName = videoName;
        dest.videoURL = videoURL;
    }
}

@end
