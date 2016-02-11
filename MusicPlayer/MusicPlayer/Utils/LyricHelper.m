//
//  LyricHelper.m
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "LyricHelper.h"
#import "LyricItem.h"

@interface LyricHelper ()
{
    NSTimeInterval beginTime;
    NSTimeInterval endTime;
}
@property (nonatomic,retain) NSMutableArray *lyricItemsArray;
@property (nonatomic,assign) NSInteger index;

@end

@implementation LyricHelper

- (void)dealloc
{
    [_lyricItemsArray release];
    [super dealloc];
}

static LyricHelper *helper = nil;
+ (instancetype)sharedLyricHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[LyricHelper alloc] init];
    });
    return helper;
}

- (NSMutableArray *)lyricItemsArray
{
    if (_lyricItemsArray == nil) {
        _lyricItemsArray = [[NSMutableArray alloc] initWithCapacity:30];
    }
    return _lyricItemsArray;
}

- (void)setLyricString:(NSString *)lyricString
{
    //通过 \n 看一共有哪些句子
    NSArray *lyricStatementArray = [lyricString componentsSeparatedByString:@"\n"];
    self.index = -1;
    [self.lyricItemsArray removeAllObjects];
    
    for (NSString *statement in lyricStatementArray) {
        if ([statement length] == 0) {//如果最后一行歌词带\n.
            LyricItem *item = [LyricItem lyricItemWithCurrentTime:400 string:@""];
            [self.lyricItemsArray addObject:item];
            break;
        }
        NSArray *arr = [statement componentsSeparatedByString:@"]"];
        NSString *leftString = [arr[0] substringFromIndex:1];//时间部分 例如:  00:17.400
        NSString *rightString = arr[1];//歌词部分 And I'll tell you all about it when I see you again
        
        NSArray *arr2 = [leftString componentsSeparatedByString:@":"];
        NSString *minutes = arr2[0];
        NSString *seconds = arr2[1];
        NSTimeInterval time = [minutes intValue] * 60 + [seconds doubleValue];
        
        LyricItem *item = [LyricItem lyricItemWithCurrentTime:time string:rightString];
        [self.lyricItemsArray addObject:item];
    }
}

- (NSUInteger)lyricIndexAtTime:(NSTimeInterval)time
{
    
    for (int i = 0; i < [_lyricItemsArray count]; i++) {
        LyricItem *item = _lyricItemsArray[i];
        if (item.currentTime > time) {
            _index = i - 1 >= 0 ? i - 1 : 0;
            break;
        }
    }
    return _index;
    
//    if (_index == -1) {
//        for (int i = 0; i < [_lyricItemsArray count]; i++) {
//            LyricItem *item = _lyricItemsArray[i];
//            if (item.currentTime > time) {
//                _index = i - 1 >= 0 ? i - 1 : 0;
//                break;
//            }
//        }
//    }
//    if (_index >= [_lyricItemsArray count] - 1) {
//        return [_lyricItemsArray count] - 1;
//    }
//    
//    LyricItem *beginItem = _lyricItemsArray[_index];
//    LyricItem *endItem = _lyricItemsArray[_index + 1];
//    beginTime = beginItem.currentTime;
//    endTime = endItem.currentTime;
//    if (time >= beginTime && time <= endTime) {
//    
//    }else{
//        _index ++;
//    }

    return _index;
}

- (NSArray *)allLyricItems
{
    return [_lyricItemsArray copy];
}

- (NSString *)lyricAtTime:(NSTimeInterval)time
{
    //如果首次调用此方法,_index 会是-1.通过循环定位_index 的值.
    if (_index == -1) {
        for (int i = 0; i < [_lyricItemsArray count]; i++) {
            LyricItem *item = _lyricItemsArray[i];
            if (item.currentTime > time) {
                _index = i - 1 >= 0 ? i - 1 : 0;
                break;
            }
        }
    }
    
    //如果_index 已经是最后一行,返回最后一样的歌词
    if (_index >= [_lyricItemsArray count] - 1) {
        LyricItem *lastItem = _lyricItemsArray[_index];
        return lastItem.string;
    }
    
    //如果不是最后一行,返回指定歌词
    LyricItem *beginItem = _lyricItemsArray[_index];
    LyricItem *endItem = _lyricItemsArray[_index + 1];
    beginTime = beginItem.currentTime;
    endTime = endItem.currentTime;
    if (time >= beginTime && time <= endTime) {
        return beginItem.string;
    }else{
        _index ++;
        return @"";
    }
}


@end




