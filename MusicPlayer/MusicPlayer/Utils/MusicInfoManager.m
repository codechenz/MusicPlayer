//
//  ModelManager.m
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "MusicInfoManager.h"
@interface MusicInfoManager ()
{
    NSUInteger _currentIndex;
}
@property (nonatomic, retain) NSMutableArray *datasource;

/**
 *  获取远端数据
 */
- (void)_acquireData;

@end
@implementation MusicInfoManager

- (void)_acquireData {
    NSArray *contents = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:@"http://project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist"]];
    //先清空datasource
    [self.datasource removeAllObjects];
    
    for (NSDictionary *dict in contents) {
        MusicInfo *music = [MusicInfo musicInfoWithDictionary:dict];
        [self.datasource addObject:music];
    }
    
    //发起通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDataDidFinishAcquire" object:nil];
}

//lazy loading
- (NSMutableArray *)datasource {
    if (!_datasource) {
        self.datasource = [NSMutableArray array];
    }
    return _datasource;
}

+ (instancetype)sharedManger {
    static MusicInfoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MusicInfoManager alloc] init];
//        [manager _acquireData];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentIndex = 0;
    }
    return self;
}

- (void)acquireData {
    [self _acquireData];
}

- (NSInteger)countOfModels {
    return self.datasource.count;
}

- (id)modelAtIndex:(NSInteger)index {
    _currentIndex = index;
    return self.datasource[index];
}

- (NSUInteger)currentIndex {
    return _currentIndex;
}

@end
