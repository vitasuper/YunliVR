//
//  VRVideoIntroViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/11/16.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "VRVideoIntroViewController.h"
#import "Video360ViewController.h"
#import "HSDownloadManager.h"
#import "AppDelegate.h"
#import "NSString+Hash.h"
#import <YYWebImage/YYWebImage.h>
#import <RealReachability.h>

// 缓存主目录
#define HSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HSCache"]

// 保存文件名
#define HSFileName(url) [url lastPathComponent]

// 文件的存放路径（caches）
#define HSFileFullpath(url) [HSCachesDirectory stringByAppendingPathComponent:HSFileName(url)]


@interface VRVideoIntroViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@end


@implementation VRVideoIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"YUNLI VR";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.coverImageView.clipsToBounds = YES;
    [self loadVRVideoIntroData];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 播放和下载事件

- (IBAction)playVRVideo:(id)sender {
    
    NSURL *url;
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    
    if ([[HSDownloadManager sharedInstance] isInCache:self.videoURL]) {
        url = [NSURL fileURLWithPath:HSFileFullpath(self.videoURL)];
        NSLog(@"已下载啦！可以直接播放！");
    } else {
        if (status == RealStatusViaWiFi) {
            url = [NSURL URLWithString:self.videoURL];
            NSLog(@"还没下好，播的是网络版。。");
        } else if (status == RealStatusViaWWAN) {
            if (((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN == YES) {
                url = [NSURL URLWithString:self.videoURL];
                NSLog(@"还没下好，播的是网络版。。");
            } else {
                UIAlertController *alert;
                alert = [UIAlertController alertControllerWithTitle:@"请检查设置" message:@"您已开启\"仅 Wi-Fi 环境下进行播放/下载\"功能，请到\"我的\"中修改相关设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *submit = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:submit];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        } else {
            UIAlertController *alert;
            alert = [UIAlertController alertControllerWithTitle:@"网络无法连接" message:@"请检查您当下的网络情况" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *submit = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:submit];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    
    Video360ViewController *videoController = [[Video360ViewController alloc] initWithNibName:@"HTY360PlayerVC" bundle:nil url:url];
    
    if (![[self presentedViewController] isBeingDismissed]) {
        [self presentViewController:videoController animated:YES completion:nil];
    }
}


- (IBAction)downloadVRVideo:(id)sender {
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    NSLog(@"Initial reachability status:%@",@(status));
    //创建一个UIAlertController对象
    UIAlertController *alert;
    if ([[HSDownloadManager sharedInstance] isDownloading:self.videoURL] || [[HSDownloadManager sharedInstance] isInCache:self.videoURL]) {
        alert = [UIAlertController alertControllerWithTitle:@"已存在下载任务" message:@"请到 我的 -> 我的视频 查看相关下载进度" preferredStyle:UIAlertControllerStyleAlert];
    } else {
        if (status == RealStatusViaWiFi) {
            [[HSDownloadManager sharedInstance] download:self.videoURL coverImgUrl:self.coverImgURL progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                // do something...
            } state:^(DownloadState state) {
                // do something...
            }];
            alert = [UIAlertController alertControllerWithTitle:@"开始下载" message:@"请到 我的 -> 我的视频 查看相关下载进度" preferredStyle:UIAlertControllerStyleAlert];
        } else if (status == RealStatusViaWWAN) {
            if (((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN == YES) {
                [[HSDownloadManager sharedInstance] download:self.videoURL coverImgUrl:self.coverImgURL progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                    // do something...
                } state:^(DownloadState state) {
                    // do something...
                }];
                alert = [UIAlertController alertControllerWithTitle:@"开始下载" message:@"请到 我的 -> 我的视频 查看相关下载进度" preferredStyle:UIAlertControllerStyleAlert];
            } else {
                alert = [UIAlertController alertControllerWithTitle:@"请检查设置" message:@"您已开启\"仅 Wi-Fi 环境下进行播放/下载\"功能，请到\"我的\"中修改相关设置" preferredStyle:UIAlertControllerStyleAlert];
            }
        } else {
            alert = [UIAlertController alertControllerWithTitle:@"网络无法连接" message:@"请检查您当下的网络情况" preferredStyle:UIAlertControllerStyleAlert];
        }
        
    }
    
    // 创建一个确定按钮及其点击触发事件
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];

    // 将创建的按钮添加到UIAlertController对象中
    [alert addAction:submit];
    
    // 显示弹窗
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 加载传过来的数据

- (void)loadVRVideoIntroData {
    self.coverImageView.yy_imageURL = [NSURL URLWithString:self.coverImgURL];
    self.videoNameLabel.text = self.videoName;
    self.introLabel.text = self.videoIntro;
}

@end
