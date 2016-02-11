//
//  MusicInfoCell.h
//  UI_QQMuisc_Demo_01
//
//  Created by ZC on 15/5/27.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicInfo.h"

@interface MusicInfoCell : UITableViewCell

@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *singerLabel;


- (void)configureCellWithMusic:(MusicInfo *)aMusic;


@end
