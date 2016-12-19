//
//  MyVideosTableViewCell.h
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/14.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVideosTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadingProgressTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDownloadingSpeedLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadingProgressView;
@property (nonatomic, strong) NSString *currentCellUrl;


@end
