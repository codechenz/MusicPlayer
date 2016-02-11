//
//  MusicInfoCell.m
//  UI_QQMuisc_Demo_01
//
//  Created by ZC on 15/5/27.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "MusicInfoCell.h"
#import "UIImageView+WebCache.h"

@implementation MusicInfoCell

- (UIImageView *)avatar {
    if (!_avatar) {
        self.avatar = [[[UIImageView alloc] initWithFrame:CGRectMake(20, 6, 54, 54)] autorelease];
        _avatar.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _avatar.layer.borderWidth = .5;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(84, 16, CGRectGetWidth([UIScreen mainScreen].bounds) - 100, 16)] autorelease];
//        _nameLabel.backgroundColor = [UIColor redColor];
        _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.highlightedTextColor = [UIColor colorWithRed:244 / 255.0 green:0 blue:89 / 255.0 alpha:1];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)singerLabel {
    if (!_singerLabel) {
        self.singerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(84, 32, 220, 14)] autorelease];
//        _singerLabel.backgroundColor = [UIColor greenColor];
        _singerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        _singerLabel.textColor = [UIColor lightGrayColor];
        _singerLabel.highlightedTextColor = [UIColor orangeColor];
        [self.contentView addSubview:_singerLabel];
    }
    return _singerLabel;
}

- (void)configureCellWithMusic:(MusicInfo *)aMusic {
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:aMusic.thumbUrl]];
    self.nameLabel.text = aMusic.name;
    self.singerLabel.text = aMusic.singer;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [_avatar release];
    [_nameLabel release];
    [_singerLabel release];
    [super dealloc];
}

@end
