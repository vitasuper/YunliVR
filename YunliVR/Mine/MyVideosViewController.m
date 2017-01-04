//
//  MyVideosViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/13.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "MyVideosViewController.h"
#import "MyVideosTableViewCell.h"
#import "HSDownloadManager.h"
#import "NSString+Hash.h"
#import "Video360ViewController.h"
#import <YYWebImage/YYWebImage.h>

// 缓存主目录
#define HSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HSCache"]
// 保存文件名
#define HSFileName(url) [url lastPathComponent]
// 文件的存放路径（caches）
#define HSFileFullpath(url) [HSCachesDirectory stringByAppendingPathComponent:HSFileName(url)]
// 文件的已下载长度
#define HSDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:HSFileFullpath(url) error:nil][NSFileSize] integerValue]

NSString * const qiniuURL = @"http://ogme3pxax.bkt.clouddn.com/";

// Timer
dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer) {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}


@interface MyVideosViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *downloadedVideoArray;
@property (nonatomic, strong) NSMutableArray *downloadingVideoArray;

@property (nonatomic, strong) NSMutableArray *tasksUrls;
@property (nonatomic, strong) NSMutableArray *taskCoverImgUrls;

@end


@implementation MyVideosViewController {
    dispatch_source_t _timer;
}

- (NSMutableArray *)downloadingVideoArray {
    if (!_downloadingVideoArray) {
        _downloadingVideoArray = [[NSMutableArray alloc] init];
    }
    return _downloadingVideoArray;
}


- (NSMutableArray *)downloadedVideoArray {
    if (!_downloadedVideoArray) {
        _downloadedVideoArray = [[NSMutableArray alloc] init];
    }
    return _downloadedVideoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的视频";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated {
    // 每次进来都得更新一下数据模型
    [self.downloadedVideoArray removeAllObjects];
    NSArray *arr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:HSCachesDirectory error:nil]];
    for (NSString *item in arr) {
        if ([item hasSuffix:@".mp4"] && [[HSDownloadManager sharedInstance] isCompletion:[HSCachesDirectory stringByAppendingPathComponent:item]]) {
            [self.downloadedVideoArray addObject:item];
        }
    }
    
    [self.downloadingVideoArray removeAllObjects];
    for (NSString *item in arr) {
        if ([item hasSuffix:@".mp4"] && ![[HSDownloadManager sharedInstance] isCompletion:[HSCachesDirectory stringByAppendingPathComponent:item]]) {
            [self.downloadingVideoArray addObject:item];
        }
    }
    [self.tableView reloadData];
    
    [self startTimer];
    NSLog(@"appear!!");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"disappear!!");
    [self cancelTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 刷新两个tableView section的方法

- (void)refreshDownloadingSectionData {
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshData {
    // 准备已下载的数据
    NSInteger downloadedOldCnt = [self.downloadedVideoArray count];
    [self.downloadedVideoArray removeAllObjects];
    NSArray *arr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:HSCachesDirectory error:nil]];
    for (NSString *item in arr) {
        if ([item hasSuffix:@".mp4"] && [[HSDownloadManager sharedInstance] isCompletion:[HSCachesDirectory stringByAppendingPathComponent:item]]) {
            [self.downloadedVideoArray addObject:item];
        }
    }
    NSInteger downloadedNewCnt = [self.downloadedVideoArray count];
    
    // 准备正在下载的数据
    NSInteger downloadingOldCnt = [self.downloadingVideoArray count];
    [self.downloadingVideoArray removeAllObjects];
    for (NSString *item in arr) {
        if ([item hasSuffix:@".mp4"] && ![[HSDownloadManager sharedInstance] isCompletion:[HSCachesDirectory stringByAppendingPathComponent:item]]) {
            [self.downloadingVideoArray addObject:item];
        }
    }
    
    NSInteger downloadingNewCnt = [self.downloadingVideoArray count];
    
    if (downloadingOldCnt == downloadingNewCnt && downloadingNewCnt != 0) {
        [self updateCellComponent];
    }
    
    if (downloadedOldCnt != downloadedNewCnt) {
        [self.tableView reloadData];
    }
}

- (void)updateCellComponent {
    [self.tableView beginUpdates];
    
    
    // select visible cells only which we will update
    NSArray *visibleIndices = [self.tableView indexPathsForVisibleRows];
    
    // iterate through visible cells
    for (NSIndexPath *visibleIndex in visibleIndices) {
        if (visibleIndex.section == 0) {
            MyVideosTableViewCell *cell = (MyVideosTableViewCell *)[self.tableView cellForRowAtIndexPath:visibleIndex];
            cell.videoTitleLabel.text = [self.downloadingVideoArray objectAtIndex:visibleIndex.row];
            cell.downloadingProgressView.progress = [[HSDownloadManager sharedInstance] progress:[self.downloadingVideoArray objectAtIndex:visibleIndex.row]];
        
            cell.currentCellUrl = [qiniuURL stringByAppendingPathComponent:[self.downloadingVideoArray objectAtIndex:visibleIndex.row]];
        
            if ([[HSDownloadManager sharedInstance] isRunning:cell.currentCellUrl]) {
                cell.currentStatusLabel.text = @"正在下载...";
            } else {
                cell.currentStatusLabel.text = @"暂停";
            }
        
            cell.downloadingProgressTextLabel.text = [NSString stringWithFormat:@"%.2fMB", [[HSDownloadManager sharedInstance] fileLocalTotalLength:[self.downloadingVideoArray objectAtIndex:visibleIndex.row]] / 1024.0 / 1024.0];
            cell.currentDownloadingSpeedLabel.hidden = TRUE;
            cell.coverImageView.yy_imageURL = [NSURL URLWithString:[cell.currentCellUrl stringByAppendingString:@".jpg"]];
            cell.currentStatusLabel.hidden = FALSE;
            cell.downloadingProgressView.hidden = FALSE;
            cell.currentDownloadingSpeedLabel.hidden = TRUE;
        }
    }
    
    [self.tableView endUpdates];
}

#pragma mark - tableView delegate

#pragma mark tableView样式
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// 设置两个section之间的距离
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0;
}

// cell中每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"下载中";
    } else if (section == 1) {
        return @"已下载完成";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.downloadingVideoArray.count;
    } else {
        return self.downloadedVideoArray.count;
    }
}

#pragma mark 显示内容 & 点击事件
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyVideosTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyVideosTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.videoTitleLabel.text = [self.downloadingVideoArray objectAtIndex:indexPath.row];
        cell.downloadingProgressView.progress = [[HSDownloadManager sharedInstance] progress:[self.downloadingVideoArray objectAtIndex:indexPath.row]];
        
        cell.currentCellUrl = [qiniuURL stringByAppendingPathComponent:[self.downloadingVideoArray objectAtIndex:indexPath.row]];
        
        if ([[HSDownloadManager sharedInstance] isRunning:cell.currentCellUrl]) {
            cell.currentStatusLabel.text = @"正在下载...";
        } else {
            cell.currentStatusLabel.text = @"暂停";
        }
        
        cell.downloadingProgressTextLabel.text = [NSString stringWithFormat:@"%.2fMB", [[HSDownloadManager sharedInstance] fileLocalTotalLength:[self.downloadingVideoArray objectAtIndex:indexPath.row]] / 1024.0 / 1024.0];
        cell.currentDownloadingSpeedLabel.hidden = TRUE;
        cell.coverImageView.yy_imageURL = [NSURL URLWithString:[cell.currentCellUrl stringByAppendingString:@".jpg"]];
        cell.currentStatusLabel.hidden = FALSE;
        cell.downloadingProgressView.hidden = FALSE;
        cell.currentDownloadingSpeedLabel.hidden = TRUE;
        
    } else if (indexPath.section == 1) {
        cell.videoTitleLabel.text = [[self.downloadedVideoArray objectAtIndex:indexPath.row] lastPathComponent];
        cell.coverImageView.yy_imageURL = [NSURL URLWithString:[[qiniuURL stringByAppendingPathComponent:[self.downloadedVideoArray objectAtIndex:indexPath.row]] stringByAppendingString:@".jpg"]];
        cell.currentStatusLabel.hidden = TRUE;
        cell.downloadingProgressView.hidden = TRUE;
        cell.downloadingProgressTextLabel.text = @"已完成";
        cell.currentDownloadingSpeedLabel.hidden = TRUE;
    }
    
    [cell coverImageView].clipsToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [[HSDownloadManager sharedInstance] download:[qiniuURL stringByAppendingPathComponent:[self.downloadingVideoArray objectAtIndex:indexPath.row]] coverImgUrl:@"" progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // ...
            });
        } state:^(DownloadState state) {
            // ...
        }];
        [self startTimer];
        
    } else if (indexPath.section == 1) {
        NSURL *url = [NSURL fileURLWithPath:[HSCachesDirectory stringByAppendingPathComponent:[self.downloadedVideoArray objectAtIndex:indexPath.row]]];
        
        Video360ViewController *videoController = [[Video360ViewController alloc] initWithNibName:@"HTY360PlayerVC" bundle:nil url:url];
        
        if (![[self presentedViewController] isBeingDismissed]) {
            [self presentViewController:videoController animated:YES completion:nil];
        }
    }
}

#pragma mark 左划删除
// 开启编辑模式
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 编辑风格（删除）
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 定义删除按钮名称
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

// 设置删除事件
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            // 正在下载的
            [[HSDownloadManager sharedInstance] deleteFile:[qiniuURL stringByAppendingPathComponent:[self.downloadingVideoArray objectAtIndex:indexPath.row]]];
            [self.downloadingVideoArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self refreshData];
             
        } else if (indexPath.section == 1) {
            // 已下好的
            [[HSDownloadManager sharedInstance] deleteLocalFile:[self.downloadedVideoArray objectAtIndex:indexPath.row]];
            [self.downloadedVideoArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self refreshData];
        }
    }
}

#pragma mark - GCD Timer

- (void)startTimer {
    dispatch_queue_t queue = dispatch_get_main_queue();
    double secondsToFire = 0.500f;
    _timer = CreateDispatchTimer(secondsToFire, queue, ^{
        [self refreshData];
        NSLog(@"LY");
        if ([[[HSDownloadManager sharedInstance] getTasks] count] == 0) {
            [self cancelTimer];
        }
    });
}

- (void)cancelTimer {
    if (_timer) {
        dispatch_source_cancel(_timer);
        
        NSLog(@"停下来Timer啦！");
        _timer = nil;
    }
}

@end
