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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)changeAllowWWANSwitchStatus:(id)sender {
    if (self.allowWWANSwitch.on) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN = NO;
    } else {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).allowWWAN = YES;
    }
}

@end
