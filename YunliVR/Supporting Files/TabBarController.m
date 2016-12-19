//
//  TabBarController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/8.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置TabBaritem文字颜色
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    
    // 设置TabBaritem选中时
    UITabBarItem *exploreItem = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *mineItem = [self.tabBar.items objectAtIndex:1];
    
    [exploreItem setTitle:@"探索"];
    [mineItem setTitle:@"我的"];
    
    exploreItem.image = [[UIImage imageNamed:@"explore@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    exploreItem.selectedImage = [[UIImage imageNamed:@"explore_selected@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    mineItem.image = [[UIImage imageNamed:@"mine@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mineItem.selectedImage = [[UIImage imageNamed:@"mine_selected@1x"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
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
