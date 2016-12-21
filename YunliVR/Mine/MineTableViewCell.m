//
//  MineTableViewCell.m
//  YunliVR
//
//  Created by 韩龙粤 on 2016/12/8.
//  Copyright © 2016年 vitasuper. All rights reserved.
//

#import "MineTableViewCell.h"
#import "AppDelegate.h"

@implementation MineTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)changeAllowWWANSwitchStatus:(id)sender {
    if (self.allowWWANSwitch.on) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN = NO;
        
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN) {
            NSLog(@"仅Wi-Fi关闭，可以用WWAN！");
        } else {
            NSLog(@"仅Wi-Fi开启，不能用WWAN！");
            
        }
    } else {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN = YES;
        
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN) {
            NSLog(@"仅Wi-Fi关闭，可以用WWAN！");
        } else {
            NSLog(@"仅Wi-Fi开启，不能用WWAN！");
            
        }
        
    }
}

@end
