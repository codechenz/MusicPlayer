//
//  LyricItem.m
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "LyricItem.h"

@implementation LyricItem

- (void)dealloc
{
    [_string release];
    [super dealloc];
}

- (instancetype)initWithCurrentTime:(NSTimeInterval)currentTime string:(NSString *)string
{
    self = [super init];
    if (self) {
        _currentTime = currentTime;
        _string = [string copy];
    }
    return self;
}

+ (instancetype)lyricItemWithCurrentTime:(NSTimeInterval)currentTime string:(NSString *)string
{
    return [[[LyricItem alloc] initWithCurrentTime:currentTime string:string] autorelease];
}

@end
