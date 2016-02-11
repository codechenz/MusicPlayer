//
//  LOAudioStreamer.m
//  LOAudioStreamer
//
//  Created by ZC on 15/6/3.
//  Copyright (c) 2015年 843949490@qq.com. All rights reserved.
//

#import "LOAudioStreamer.h"
#import <AVFoundation/AVFoundation.h>

@interface LOAudioStreamer ()
{
    BOOL _isPlaying;//标记是否正在播放
    BOOL _isPrepared;//标记播放器是否准备完成
}
@property (nonatomic, retain) AVPlayer *audioPlayer;//音乐播放器
@property (nonatomic, retain) NSTimer *timer;
@end

@implementation LOAudioStreamer

- (AVPlayer *)audioPlayer {
    if (!_audioPlayer) {
        self.audioPlayer = [[[AVPlayer alloc] init] autorelease];
    }
    return _audioPlayer;
}

- (void)setAudioMetadataWithURL:(NSString *)urlString {
    if (self.audioPlayer.currentItem) {
        [self.audioPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    /**
     *  根据指定的url创建AVPlayerItem对象
     */
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString]];
//    NSLog(@"%@", [(AVURLAsset *)currentItem.asset URL].absoluteString);
    
    [currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    /**
     *  根据给定的item对象替换音频播放器当前的item
     */
    [self.audioPlayer replaceCurrentItemWithPlayerItem:currentItem];
}

+ (instancetype)sharedStreamer {
    static LOAudioStreamer *streamer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        streamer = [[self alloc] init];
    });
    return streamer;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}


#pragma mark - Audio Control -

- (void)play {
    _isPlaying = YES;
    [self.audioPlayer play];
    if (self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimerAction:) userInfo:nil repeats:YES];
}

- (void)pause {
    _isPlaying = NO;
    [self.audioPlayer pause];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stop {
    [self pause];
    //设置播放器跳转回0秒，完成播放器的停止功能
    [self.audioPlayer seekToTime:CMTimeMake(0, self.audioPlayer.currentTime.timescale)];
}

- (void)setVolume:(float)volume {
    self.audioPlayer.volume = volume;
}

- (float)volume {
    return self.audioPlayer.volume;
}

- (void)seekToTime:(float)time {
    [self pause];
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(time, self.audioPlayer.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            [self play];  
        }
    }];
}

- (void)handleTimerAction:(NSTimer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioStreamer:didPlayingWithProgress:)]) {
        float progress = self.audioPlayer.currentTime.value / self.audioPlayer.currentTime.timescale;
        [self.delegate audioStreamer:self didPlayingWithProgress:progress];
    }
}

- (void)handleEndTimeNotification:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector( audioStreamerDidFinishPlaying:)]) {
        [self.delegate audioStreamerDidFinishPlaying:self];
    }
//    [self.audioPlayer replaceCurrentItemWithPlayerItem:nil];
}

- (BOOL)isPlaying {
    return _isPlaying;
}


- (BOOL)isPrepared {
    return _isPrepared;
}

- (BOOL)isPlayingCurrentAudioWithURL:(NSString *)urlString {
    NSString *currentURLString = [(AVURLAsset *)self.audioPlayer.currentItem.asset URL].absoluteString;
    return [currentURLString isEqualToString:urlString];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch ([change[@"new"] intValue]) {
        case AVPlayerItemStatusFailed:
            break;
        case AVPlayerItemStatusReadyToPlay:
            _isPrepared = YES;
            break;
        case AVPlayerItemStatusUnknown:
            break;
        default:
            break;
    }
}




@end
