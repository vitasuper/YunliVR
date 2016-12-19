//
//  MineTableViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/6.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "MineTableViewController.h"
#import "MineTableViewCell.h"

/**
 *  常量
 */
NSString * const myVideosSegue = @"myVideosSegue";
NSString * const aboutSegue = @"aboutSegue";



@interface MineTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSInteger downloadTaskConut;

@end

@implementation MineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor lightGrayColor];

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
    view.tintColor = [UIColor lightGrayColor];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 3;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger currentRealRowNumeber = (indexPath.section > 0 ? [self tableView:tableView numberOfRowsInSection:indexPath.section - 1] : 0) + indexPath.row + 1;
    
    MineTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MineTableViewCell"];
    
    
    switch (currentRealRowNumeber) {
        case 1:
            cell.mineTextLabel.text = @"about~";
            cell.iconImageView.backgroundColor = [UIColor redColor];
            break;
        case 2:
            cell.mineTextLabel.text = @"My videos";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.badgeString = @"2";
            cell.badge.radius = 8.75;
//            cell.badgeLeftOffset = 8;
            cell.badgeRightOffset = 40;
            cell.badgeColor = [UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
            break;
        case 3:
            cell.mineTextLabel.text = @"3rd setting";
            break;
        case 4:
            cell.mineTextLabel.text = @"4th setting";
            break;
        case 5:
            cell.mineTextLabel.text = @"5th setting";
            break;
    }
    
    return cell;
}

// cell中每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger rowNumber = 0;
//    for (NSInteger i = 0; i < indexPath.section; ++i) {
//        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
//    }
//    rowNumber += indexPath.row;
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 计算当下是第几行
    NSInteger currentRealRowNumeber = (indexPath.section > 0 ? [self tableView:tableView numberOfRowsInSection:indexPath.section - 1] : 0) + indexPath.row + 1;

    NSLog(@"%ld %ld currentrow:%ld", (long)indexPath.section, (long)indexPath.row, (long)currentRealRowNumeber);
    
    switch (currentRealRowNumeber) {
        case 1:
            [self performSegueWithIdentifier:aboutSegue sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:myVideosSegue sender:self];
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
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
