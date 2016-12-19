//
//  ViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/11/7.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "ViewController.h"
#import "VRVideoIntroTableViewCell.h"
#import "VRVideoIntroViewController.h"
#import "GVRPanoramaView.h"
#import "GVRVideoView.h"
#import <BmobSDK/Bmob.h>
#import <YYWebImage/YYWebImage.h>

@interface ViewController () <GVRWidgetViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *photoArray;
    
    NSMutableArray *videoNameArray;
    NSMutableArray *coverImgURLArray;
    NSMutableArray *videoIntroArray;
    NSMutableArray *videoURLArray;
    
    NSString *videoName;
    NSString *coverImgURL;
    NSString *videoIntro;
    NSString *videoURL;
    
//    NSURL *videoURL;
    UIView *currentView;
    GVRWidgetDisplayMode currentDisplayMode;
    BOOL isPaused;
}

//@property (weak, nonatomic) IBOutlet GVRPanoramaView *imageVRView;
//@property (weak, nonatomic) IBOutlet GVRVideoView *videoVRView;

//- (void)refreshVideoPlayStatus;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

//    [_imageVRView setHidden:true];
//    [_videoVRView setHidden:true];
    
//    _imageVRView.delegate = self;
//    _videoVRView.delegate = self;
    
    self.navigationItem.title = @"YunliVR";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    photoArray = [[NSMutableArray alloc] initWithObjects:@"sindhu_beach.jpg", @"grand_canyon.jpg", @"underwater.jpg", nil];
//    videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"elephant_safari" ofType:@"mp4"]];
    currentDisplayMode = kGVRWidgetDisplayModeEmbedded;
    isPaused = true;
    
    videoNameArray = [[NSMutableArray alloc] init];
    coverImgURLArray = [[NSMutableArray alloc] init];
    videoIntroArray = [[NSMutableArray alloc] init];
    videoURLArray = [[NSMutableArray alloc] init];
    
    
    
//    [_imageVRView loadImage:[UIImage imageNamed:photoArray[0]] ofType:kGVRPanoramaImageTypeMono];
//    [_videoVRView loadFromUrl:videoURL];
    
//    [_imageVRView setEnableCardboardButton:true];
//    [_imageVRView setEnableFullscreenButton:true];
    
//    [_videoVRView setEnableCardboardButton:true];
//    [_videoVRView setEnableFullscreenButton:true];
    [self getVRVideoInfo];
    
    
//    self.tabBarItem.title = @"test!!!";
    
    
    // 隐藏VRVideoIntroTableViewCell之间的横线
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
}

//- (void)refresh PlayStatus {
//    if ([currentView isEqual:_imageVRView] && currentDisplayMode != kGVRWidgetDisplayModeEmbedded) {
//        [_videoVRView resume];
//        isPaused = false;
//    } else {
//        [_videoVRView pause];
//        isPaused = true;
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 取决于你要有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return coverImgURLArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VRVideoIntroTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"VRVideoIntroTableViewCell"];
    [cell coverImageView].yy_imageURL = [NSURL URLWithString:[coverImgURLArray objectAtIndex:indexPath.row]];
    
    [cell coverImageView].clipsToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    videoName = [videoNameArray objectAtIndex:indexPath.row];
    coverImgURL = [coverImgURLArray objectAtIndex:indexPath.row];
    videoIntro = [videoIntroArray objectAtIndex:indexPath.row];
    videoURL = [videoURLArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toVRVideoIntroSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVRVideoIntroSegue"]) {
        VRVideoIntroViewController *dest = segue.destinationViewController;
        dest.coverImgURL = coverImgURL;
        dest.videoIntro = videoIntro;
        dest.videoName = videoName;
        dest.videoURL = videoURL;
    }
}

#pragma mark - 将封面的URL放进coverURLArray
- (void)getVRVideoInfo {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"BasicInfo"];
    //查找GameScore表的数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            [videoNameArray addObject:[obj objectForKey:@"videoName"]];
            NSLog(@"%@", [obj objectForKey:@"videoName"]);
            [coverImgURLArray addObject:[obj objectForKey:@"coverImgURL"]];
            [videoIntroArray addObject:[obj objectForKey:@"videoIntro"]];
            [videoURLArray addObject:[obj objectForKey:@"videoURL"]];
//            [coverURLArray addObject:[obj objectForKey:@"coverImgURL"]];
//
//            NSLog(@"videoIntro = %@", [obj objectForKey:@"videoIntro"]);
//
//            NSLog(@"coverImgURL = %@", [obj objectForKey:@"coverImgURL"]);
////            NSLog(@"obj.createdAt = %@", [obj createdAt]);
////            NSLog(@"obj.updatedAt = %@", [obj updatedAt]);
        }
//        _testImageView.yy_imageURL = [NSURL URLWithString:[array[0] objectForKey:@"coverImgURL"]];
        
        NSLog(@"%lu", (unsigned long)coverImgURLArray.count);
        [self.tableView reloadData];
    }];
    
}


//#pragma mark - 实现GVRWidgetViewDelegate的方法
///** Called when the content is successfully loaded. */
//- (void)widgetView:(GVRWidgetView *)widgetView didLoadContent:(id)content {
//    if ([content isKindOfClass:[UIImage class]]) {
//        [_imageVRView setHidden:false];
//    }
////    } else if ([content isKindOfClass:[NSURL class]]) {
////        [_videoVRView setHidden:false];
////        [self refreshVideoPlayStatus];
////    }
//}
//
///** Called when the widget view's display mode changes. See |GCSWidgetDisplayMode|. */
//- (void)widgetView:(GVRWidgetView *)widgetView didChangeDisplayMode:(GVRWidgetDisplayMode)displayMode {
//    currentView = widgetView;
//    currentDisplayMode = displayMode;
//    NSLog(@"%ld", currentDisplayMode);
//    // NSLog(@"%ld", kGCSWidgetDisplayModeEmbedded);
//    
////    [self refreshVideoPlayStatus];
//    
//    if ([currentView isEqual:_imageVRView] && currentDisplayMode == kGVRWidgetDisplayModeFullscreen) {
//        NSLog(@"???");
//        [self.view setHidden:true];
//    } else {
//        NSLog(@"!!!!");
//        [self.view setHidden:false];
//    }
//}
//
///** Called when there is an error loading content in the widget view. */
//- (void)widgetView:(GVRWidgetView *)widgetView didFailToLoadContent:(id)content withErrorMessage:(NSString *)errorMessage {
//    NSLog(@"%@, ly!", errorMessage);
//}
//
///**
// * Called when the user taps the widget view. This corresponds to the Cardboard viewer's trigger
// * event.
// */
//- (void)widgetViewDidTap:(GVRWidgetView *)widgetView {
//    if (currentDisplayMode == kGVRWidgetDisplayModeEmbedded) return;
//    currentView = widgetView;
//    if ([currentView isEqual:_imageVRView]) {
//        [photoArray addObject:[photoArray firstObject]];
//        [photoArray removeObjectAtIndex:0];
//        
//        [_imageVRView loadImage:[UIImage imageNamed:photoArray[0]] ofType:kGVRPanoramaImageTypeMono];
//    }
////    } else {
////        if (isPaused) {
////            [_videoVRView resume];
////        } else {
////            [_videoVRView pause];
////        }
////        isPaused = !isPaused;
////    }
//}








@end
