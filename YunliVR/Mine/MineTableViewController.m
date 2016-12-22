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
#import "AppDelegate.h"
#import <UIColor+Wonderful.h>

/**
 *  常量
 */
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

//    // 解决tableViewCell被NavigationBar遮住的问题
//    CGRect rect = self.navigationController.navigationBar.frame;
//    float y = rect.size.height + rect.origin.y;
//    self.tableView.contentInset = UIEdgeInsetsMake(y, 0, 0, 0);
    
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 设置两个section之间的距离
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0;
}

// 修改footer的颜色
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
//            cell.iconImageView.backgroundColor = [UIColor goldColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.iconImageView.image = [[UIImage imageNamed:@"people"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            break;
    }
    
    return cell;
}

// cell中每一行的高度
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
    
    
    NSLog(@"%ld %ld currentrow:%ld", (long)indexPath.section, (long)indexPath.row, (long)currentRealRowNumeber);
    
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
        case 5:
            [self performSegueWithIdentifier:aboutPageSegue sender:self];
            break;
    }
    
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
