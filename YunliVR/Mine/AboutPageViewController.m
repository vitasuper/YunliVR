//
//  AboutPageViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/20.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "AboutPageViewController.h"

@interface AboutPageViewController ()

@end

@implementation AboutPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.introLabel.numberOfLines = 0;
    self.introLabel.text = @"云粒-虚拟现实移动广告平台成立于2014年7月，为广告主提供VR广告程序化购买、精准投放、实时竞价、数据 监测以及用户分析，为VR开发者提供兼容性SDK以及流量变现。云粒总部位于深圳CBD，核心团队均来自腾讯、百度等，曾经服务于万科家装、大族激光、震有科技、华诺（诺基亚中国）、小米耳机等大客户。";
    [self.introLabel sizeToFit];
    
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
