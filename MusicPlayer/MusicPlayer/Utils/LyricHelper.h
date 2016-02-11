//
//  LyricHelper.h
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LyricItem.h"

@interface LyricHelper : NSObject

//获取 歌词处理 对象
+ (instancetype)sharedLyricHelper;

//传入歌词,完成解析.
- (void)setLyricString:(NSString *)lyricString;


//获取全部 LyricItem
- (NSArray *)allLyricItems;

//根据给定的时间,返回对应的歌词
- (NSString *)lyricAtTime:(NSTimeInterval)time;


//根据给定的时间,返回歌词的下标
- (NSUInteger)lyricIndexAtTime:(NSTimeInterval)time;


@end
