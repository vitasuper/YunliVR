//
//  ExploreTableViewCell.h
//  YunliVR
//
//  Created by 韩龙粤 on 2016/11/16.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExploreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundShadowView;
@property (weak, nonatomic) IBOutlet UIView *infoBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoIntroLabel;

@end
