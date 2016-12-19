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
#import "NSString+Hash.h"
#import <YYWebImage/YYWebImage.h>

// 缓存主目录
#define HSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HSCache"]

// 保存文件名
#define HSFileName(url) [url lastPathComponent]

// 文件的存放路径（caches）
#define HSFileFullpath(url) [HSCachesDirectory stringByAppendingPathComponent:HSFileName(url)]


@interface VRVideoIntroViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end

@implementation VRVideoIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.coverImageView.clipsToBounds = YES;
    [self loadVRVideoIntroData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playVRVideo:(id)sender {
    
    NSURL *url;
    
    if ([[HSDownloadManager sharedInstance] isDownloaded:self.videoURL]) {
        url = [NSURL fileURLWithPath:HSFileFullpath(self.videoURL)];
        NSLog(@"已下载啦！可以直接播放！");
    } else {
        url = [NSURL URLWithString:self.videoURL];
        NSLog(@"还没下好，播的是网络版。。");
    }
    
    Video360ViewController *videoController = [[Video360ViewController alloc] initWithNibName:@"HTY360PlayerVC" bundle:nil url:url];
    
    if (![[self presentedViewController] isBeingDismissed]) {
        [self presentViewController:videoController animated:YES completion:nil];
    }
}

- (IBAction)downloadVRVideo:(id)sender {
    
    //创建一个UIAlertController对象
    UIAlertController *alert;
    if ([[HSDownloadManager sharedInstance] isDownloading:self.videoURL] || [[HSDownloadManager sharedInstance] isInCache:self.videoURL]) {
        alert = [UIAlertController alertControllerWithTitle:@"已存在下载任务" message:@"请到 我的 -> 我的下载 查看相关下载进度" preferredStyle:UIAlertControllerStyleAlert];
//        if ([[HSDownloadManager sharedInstance] isDownloaded:self.videoURL]) NSLog(@"DEBUG5: 已经下载了")
    } else {
        NSLog(@"DEBUG1: %@", self.coverImgURL);
        [[HSDownloadManager sharedInstance] download:self.videoURL coverImgUrl:self.coverImgURL progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
            // do something...
        } state:^(DownloadState state) {
            // do something...
        }];
        alert = [UIAlertController alertControllerWithTitle:@"开始下载" message:@"请到 我的 -> 我的下载 查看相关下载进度" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    //创建一个确定按钮及其点击触发事件
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    //创建一个取消按钮
//    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //将创建的两个按钮添加到UIAlertController对象中
    [alert addAction:submit];
//    [alert addAction:cancle];
    
    //显示弹窗
    [self presentViewController:alert animated:YES completion:nil];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开始下载" message:@"请到 Mine -> 我的下载 查看相关下载进度" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
}


#pragma mark - 加载传过来的数据
- (void)loadVRVideoIntroData {
    _coverImageView.yy_imageURL = [NSURL URLWithString:_coverImgURL];
    _videoNameLabel.text = _videoName;
    _introTextView.text = _videoIntro;
}


//#pragma mark -  播放
//- (IBAction)playAction:(id)sender {
//    [self performSegueWithIdentifier:@"playSegue" sender:self];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
