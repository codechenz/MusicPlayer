//
//  ModelManager.h
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicInfo.h"


typedef NS_ENUM(NSUInteger, MusicPlayingStatus) {
    MusicPlayingStatusLoop,
    MusicPlayingStatusRandom,
    MusicPlayingStatusRepeat,
    MusicPlayingStatusNone
};

@interface MusicInfoManager : NSObject
@property (nonatomic, assign) MusicPlayingStatus playingStatus;


+ (instancetype)sharedManger;

- (void)acquireData;

/**
 *  model对象的个数
 *
 */
- (NSInteger)countOfModels;
- (id)modelAtIndex:(NSInteger)index;
- (NSUInteger)currentIndex;

@end
