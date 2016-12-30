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
@property (weak, nonatomic) IBOutlet UIButton *goButton;

@end

@implementation GuidePagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    @autoreleasepool {
        [self.backgroundVRView loadImage:[UIImage imageNamed:@"grand_canyon.jpg"] ofType:kGVRPanoramaImageTypeMono];
        
        // 隐藏(i)按钮
        for (UIView *v in self.backgroundVRView.subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                [v removeFromSuperview];
            }
        }
        
        // 设置GO按钮相关样式
        [self setGoButtonStyle];
        
        // 设置引导页以及Page Control控件
        width = [[UIScreen mainScreen] bounds].size.width;
        height = [[UIScreen mainScreen] bounds].size.height;
        
        [self setGuidePages];
        self.guideScrollView.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return false;
}

#pragma mark - 设置首页引导轮播
- (void)setGuidePages {
    // 设置scrollView内容大小
    self.guideScrollView.contentSize = CGSizeMake(width * 3, height);
    
    // 将引导页图片添加到scrollView中
    for (int i = 0; i < 3; ++i) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        
        if (i == 0) imageView.image = [UIImage imageNamed:@"GuidePage1"];
        if (i == 1) imageView.image = [UIImage imageNamed:@"GuidePage2"];
        if (i == 2) imageView.image = [UIImage imageNamed:@"GuidePage3"];
        
        [self.guideScrollView addSubview:imageView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int pageNum = scrollView.contentOffset.x / width;
    self.pageControl.currentPage = pageNum;
}

#pragma mark - 进入的"Go"按钮样式及跳转

- (void)setGoButtonStyle {
    self.goButton.layer.borderWidth = 1.0f;
    self.goButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [self.goButton addTarget:self action:@selector(highlightBorder) forControlEvents:UIControlEventTouchDown];
    [self.goButton addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchUpInside];
    [self.goButton addTarget:self action:@selector(unhighlightBorder) forControlEvents:UIControlEventTouchDragExit];
    
    self.goButton.layer.cornerRadius = 5.0f;
    self.goButton.layer.masksToBounds = YES;
}

- (void)highlightBorder {
    self.goButton.layer.borderColor = [[UIColor colorWithWhite:1.0f alpha:0.3f] CGColor];
}

- (void)unhighlightBorder {
    self.goButton.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (IBAction)goAction:(id)sender {
    [self.guideScrollView removeFromSuperview];
    [self.backgroundVRView removeFromSuperview];
    [self.pageControl removeFromSuperview];
    [self.goButton removeFromSuperview];
    
    self.guideScrollView.delegate = nil;
    self.backgroundVRView = nil;
    self.guideScrollView = nil;
    self.pageControl = nil;
    self.goButton = nil;
    
    [self performSegueWithIdentifier:@"goSegue" sender:self];
}

@end
