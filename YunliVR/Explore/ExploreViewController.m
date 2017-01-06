//
//  ExploreViewController.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/11/7.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "ExploreViewController.h"
#import "ExploreTableViewCell.h"
#import "VRVideoIntroViewController.h"
#import "GVRPanoramaView.h"
#import <BmobSDK/Bmob.h>
#import <YYWebImage/YYWebImage.h>
#import <MJRefresh.h>

@interface ExploreViewController () <GVRWidgetViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *videoNameArray;
@property (nonatomic, strong) NSMutableArray *coverImgURLArray;
@property (nonatomic, strong) NSMutableArray *videoIntroArray;
@property (nonatomic, strong) NSMutableArray *videoURLArray;

@property (nonatomic, copy) NSString *videoName;
@property (nonatomic, copy) NSString *coverImgURL;
@property (nonatomic, copy) NSString *videoIntro;
@property (nonatomic, copy) NSString *videoURL;

@property (nonatomic, assign) BOOL refreshing;

@end


@implementation ExploreViewController

- (NSMutableArray *)videoNameArray {
    if (!_videoNameArray) {
        _videoNameArray = [[NSMutableArray alloc] init];
    }
    return _videoNameArray;
}

- (NSMutableArray *)coverImgURLArray {
    if (!_coverImgURLArray) {
        _coverImgURLArray = [[NSMutableArray alloc] init];
    }
    return _coverImgURLArray;
}

- (NSMutableArray *)videoIntroArray {
    if (!_videoIntroArray) {
        _videoIntroArray = [[NSMutableArray alloc] init];
    }
    return _videoIntroArray;
}

- (NSMutableArray *)videoURLArray {
    if (!_videoURLArray) {
        _videoURLArray = [[NSMutableArray alloc] init];
    }
    return _videoURLArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"YUNLI VR";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self getVRVideoInfo];
    self.tableView.separatorStyle = NO;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.refreshing = YES;
        [self getVRVideoInfo];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 读取后端数据表

- (void)getVRVideoInfo {
    [self.videoNameArray removeAllObjects];
    [self.coverImgURLArray removeAllObjects];
    [self.videoIntroArray removeAllObjects];
    [self.videoURLArray removeAllObjects];
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"BasicInfo"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            [self.videoNameArray addObject:[obj objectForKey:@"videoName"]];
            [self.coverImgURLArray addObject:[obj objectForKey:@"coverImgURL"]];
            [self.videoIntroArray addObject:[obj objectForKey:@"videoIntro"]];
            [self.videoURLArray addObject:[obj objectForKey:@"videoURL"]];;
        }
        
        if (self.refreshing) {
            self.refreshing = NO;
            [self.tableView.mj_header endRefreshing];
        }
        
        [self.tableView reloadData];
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        [self.tableView reloadData];
    }];
}


#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coverImgURLArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExploreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ExploreTableViewCell"];
    [cell coverImageView].yy_imageURL = [NSURL URLWithString:[self.coverImgURLArray objectAtIndex:indexPath.row]];
    
    cell.videoTitleLabel.text = [self.videoNameArray objectAtIndex:indexPath.row];
    cell.videoIntroLabel.text = [self.videoIntroArray objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat cornerRadius = 3.0f;
    // 给图片加圆角
    [cell coverImageView].clipsToBounds = YES;
    cell.coverImageView.layer.cornerRadius = cornerRadius;
    cell.coverImageView.layer.masksToBounds = YES;
    
    // 图片阴影：给图片下面加一层view，然后让view产生阴影
    // 这样可以避免图片不能同时出现圆角和阴影的问题
    // 参考：http://stackoverflow.com/questions/11724517/add-round-corner-to-uiimageview-and-display-shadow-effect
    cell.backgroundShadowView.layer.cornerRadius = cornerRadius;
    cell.backgroundShadowView.layer.masksToBounds = NO;
    
    cell.backgroundShadowView.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    cell.backgroundShadowView.layer.shadowOpacity = 0.7;
    cell.backgroundShadowView.layer.shadowRadius = 2.0f;
    cell.backgroundShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    cell.infoBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    
    // 给下方的信息label加两个圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.infoBackgroundView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    cell.infoBackgroundView.layer.mask = maskLayer;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.videoName = [self.videoNameArray objectAtIndex:indexPath.row];
    self.coverImgURL = [self.coverImgURLArray objectAtIndex:indexPath.row];
    self.videoIntro = [self.videoIntroArray objectAtIndex:indexPath.row];
    self.videoURL = [self.videoURLArray objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"toVRVideoIntroSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVRVideoIntroSegue"]) {
        VRVideoIntroViewController *dest = segue.destinationViewController;
        dest.coverImgURL = self.coverImgURL;
        dest.videoIntro = self.videoIntro;
        dest.videoName = self.videoName;
        dest.videoURL = self.videoURL;
    }
}

@end
