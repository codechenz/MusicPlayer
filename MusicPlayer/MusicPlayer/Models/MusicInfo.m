//
//  MusicInfo.m
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "MusicInfo.h"

@implementation MusicInfo

+ (instancetype)musicInfoWithDictionary:(NSDictionary *)dict {
    MusicInfo *music = [[MusicInfo alloc] init];
    music.album = dict[@"album"];
    music.singer = dict[@"singer"];
    music.blurPicUrl = dict[@"blurPicUrl"];
    music.mp3Url = dict[@"mp3Url"];
    music.artists = dict[@"artists_name"];
    music.identifier = dict[@"id"];
    music.duration = dict[@"duration"];
    music.lyric = dict[@"lyric"];
    music.name = dict[@"name"];
    music.thumbUrl = [dict[@"picUrl"] stringByAppendingString:@"?param=120y120"];
    music.coverUrl = [dict[@"picUrl"] stringByAppendingString:@"?param=640y640"];
    music.picUrl = dict[@"picUrl"];
    return [music autorelease];
}

- (void)dealloc {
    [_album release];
    [_mp3Url release];
    [_name release];
    [_picUrl release];
    [_singer release];
    [_thumbUrl release];
    [_coverUrl release];
    [_blurPicUrl release];
    [_duration release];
    [_identifier release];
    [_artists release];
    [super dealloc];
}




@end
