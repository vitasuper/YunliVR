//
//  GuidePagesViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/11/9.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "GuidePagesViewController.h"
#import "GVRPanoramaView.h"


@interface GuidePagesViewController () <UIScrollViewDelegate> {
    CGFloat width;
    CGFloat height;
}

@property (weak, nonatomic) IBOutlet GVRPanoramaView *backgroundVRView;
@property (weak, nonatomic) IBOutlet UIScrollView *guideScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation GuidePagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_backgroundVRView loadImage:[UIImage imageNamed:@"grand_canyon.jpg"] ofType:kGVRPanoramaImageTypeMono];
    
    // 隐藏(i)按钮
    for (UIView *v in self.backgroundVRView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [v removeFromSuperview];
        }
    }
    
    // 设置引导页以及Page Control控件
    width = [[UIScreen mainScreen] bounds].size.width;
    height = [[UIScreen mainScreen] bounds].size.height;
    
    [self setGuidePages];
    
    _guideScrollView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return false;
}

#pragma mark -

//#pragma mark 隐藏引导页上方Navigation Bar
//- (void)viewWillAppear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [super viewWillAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//    [super viewWillDisappear:animated];
//}

#pragma mark 设置首页引导轮播
- (void)setGuidePages {
    // 设置scrollView内容大小
    _guideScrollView.contentSize = CGSizeMake(width * 3, height);
    
    // 将引导页图片添加到scrollView中
    for (int i = 0; i < 3; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        if (i == 0) [imageView setBackgroundColor:[UIColor redColor]];
        if (i == 1) [imageView setBackgroundColor:[UIColor greenColor]];
        if (i == 2) [imageView setBackgroundColor:[UIColor blueColor]];
        
        [imageView setAlpha:0.05];
        [_guideScrollView addSubview:imageView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int pageNum = scrollView.contentOffset.x / width;
    _pageControl.currentPage = pageNum;
}

#pragma mark 进入的"Go"按钮
- (IBAction)goAction:(id)sender {
    [self performSegueWithIdentifier:@"goSegue" sender:self];
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
