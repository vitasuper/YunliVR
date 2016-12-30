//
//  MineTableViewCell.h
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/8.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"

@interface MineTableViewCell : TDBadgedCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *mineTextLabel;
@property (weak, nonatomic) IBOutlet UISwitch *allowWWANSwitch;

@end
