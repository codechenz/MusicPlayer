//
//  LyricItem.h
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricItem : NSObject

//单句歌词时间
@property (nonatomic, assign) NSTimeInterval currentTime;

//单句歌词内容
@property (nonatomic, copy) NSString *string;


- (instancetype)initWithCurrentTime:(NSTimeInterval)currentTime string:(NSString *)string;

+ (instancetype)lyricItemWithCurrentTime:(NSTimeInterval)currentTime string:(NSString *)string;


@end
