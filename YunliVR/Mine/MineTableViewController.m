//
//  MineTableViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/6.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "MineTableViewController.h"
#import "MineTableViewCell.h"
#import "HSDownloadManager.h"
#import "XFWkwebView.h"
#import "AppDelegate.h"
#import <UIColor+Wonderful.h>


NSString * const myVideosPageSegue = @"myVideosPageSegue";
NSString * const helpPageSegue = @"helpPageSegue";
NSString * const aboutPageSegue = @"aboutPageSegue";


@interface MineTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSInteger downloadTaskConut;

@end


@implementation MineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"YUNLI VR";
    
    self.tableView.backgroundColor = [UIColor whiteSmoke];
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteSmoke];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // banner
        return 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentRealRowNumeber = 0;
    
    for (NSUInteger i = 0; i < indexPath.section; ++i) {
        currentRealRowNumeber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    currentRealRowNumeber = currentRealRowNumeber + indexPath.row + 1;
    
    MineTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MineTableViewCell"];
    
    cell.allowWWANSwitch.hidden = YES;
    
    switch (currentRealRowNumeber) {
        case 1:
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MineBanner.jpg"]];
            cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
            [cell backgroundView].clipsToBounds = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.iconImageView.hidden = YES;
            cell.mineTextLabel.hidden = YES;
            
            break;
            
        case 2:
            cell.mineTextLabel.text = @"我的视频";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSUInteger badgeCnt = [[[HSDownloadManager sharedInstance] getTasks] count];
            
            if (badgeCnt > 0) {
                cell.badgeString = [NSString stringWithFormat:@"%lu", (unsigned long)badgeCnt];
                NSLog(@"current count is : %lu", badgeCnt);
            } else {
                cell.badgeString = nil;
            }
            
            cell.badge.radius = 8.75;
            cell.badgeRightOffset = 40;
            cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
            
            cell.iconImageView.image = [[UIImage imageNamed:@"video_player"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            break;
            
        case 3:
            cell.mineTextLabel.text = @"仅 Wi-Fi 环境下进行下载";
            cell.allowWWANSwitch.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.iconImageView.image = [[UIImage imageNamed:@"wifi"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            if (((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN == YES) {
                cell.allowWWANSwitch.on = NO;
            } else {
                cell.allowWWANSwitch.on = YES;
            }
            
            break;
            
        case 4:
            cell.mineTextLabel.text = @"使用帮助";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.iconImageView.image = [[UIImage imageNamed:@"signs"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            break;
            
        case 5:
            cell.mineTextLabel.text = @"关于云粒";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.iconImageView.image = [[UIImage imageNamed:@"people"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return 200;
    else return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 计算当下是第几行
    NSInteger currentRealRowNumeber = 0;
    
    for (NSUInteger i = 0; i < indexPath.section; ++i) {
        currentRealRowNumeber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    currentRealRowNumeber = currentRealRowNumeber + indexPath.row + 1;
    
    switch (currentRealRowNumeber) {
        case 1:
            break;
        case 2:
            [self performSegueWithIdentifier:myVideosPageSegue sender:self];
            break;
        case 3:
            break;
        case 4:
            [self performSegueWithIdentifier:helpPageSegue sender:self];
            break;
        case 5: {
            XFWkwebView *webView = [[XFWkwebView alloc] init];
            [webView loadWebURLSring:@"http://www.cloudsand.cn"];
            [self.navigationController pushViewController:webView animated:YES];
            }
            break;
    }
}

@end
