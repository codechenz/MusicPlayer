//
//  LOAudioStreamer.h
//  LOAudioStreamer
//
//  Created by ZC on 15/6/3.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import <Foundation/Foundation.h>
@class LOAudioStreamer;
@protocol LOAudioStreamerDelegate <NSObject>

@optional
- (void)audioStreamer:(LOAudioStreamer *)streamer
didPlayingWithProgress:(float)progress;

- (void)audioStreamerDidFinishPlaying:(LOAudioStreamer *)streamer;

@end


@interface LOAudioStreamer : NSObject

@property (nonatomic, assign) float volume;//播放器的音量
@property (nonatomic, assign) id<LOAudioStreamerDelegate> delegate;

/**
 *  单利方法
 *
 *  @return 返回音频流对象
 */
+ (instancetype)sharedStreamer;

- (void)play;
- (void)pause;
- (void)stop;
/**
 *  设置音频播放的url
 *
 *  @param urlString url的字符串形式
 */
- (void)setAudioMetadataWithURL:(NSString *)urlString;

- (void)seekToTime:(float)time;//跳转到指定时间播放

- (BOOL)isPlaying;//判断是否正在播放
- (BOOL)isPrepared;//判断是否准备完成
- (BOOL)isPlayingCurrentAudioWithURL:(NSString *)urlString;//是否正在播放指定的URL


@end
