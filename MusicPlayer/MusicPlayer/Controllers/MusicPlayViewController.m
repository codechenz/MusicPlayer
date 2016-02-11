//
//  MusicPlayViewController.m
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "MusicPlayViewController.h"
#import "MusicInfoManager.h"
#import "LOAudioStreamer.h"
#import "UIImageView+WebCache.h"
#import "LyricHelper.h"

#define kSettingButtonBaseTag 2220

#define LOColor(r, g, b) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1.0]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kControlBarHeight 300
#define kControlBarOriginY (kScreenHeight - kControlBarHeight)

#define kTimeLabelWidth 100
#define kTimeLabelMargin 12
#define kTimeLabelHeight 20

#define kMusicInfoOriginY (kControlBarOriginY + 40)

#define kControlBarCenterX self.view.center.x
#define kControlBarCenterY (kScreenHeight - 150)
#define kButtonOffsetX 120






@interface MusicPlayViewController ()<LOAudioStreamerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) MusicInfo *currentMusic;//当前音乐播放的模型对象
@property (nonatomic, retain) UISlider *musicProgress;
@property (nonatomic, retain) UILabel *currentTimeLabel;
@property (nonatomic, retain) UILabel *remainTimeLabel;
@property (nonatomic, retain) UISlider *volumeSlider;
@property (nonatomic, retain) NSMutableArray *settings;
@property (nonatomic, retain) UIImageView *albumView;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UITableView *lyricTableView;
@property (nonatomic, retain) NSArray *lyricItemsArray;

@end

@implementation MusicPlayViewController

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        CGFloat size_width = CGRectGetWidth(self.view.bounds) - 80;
        self.pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, 60 + size_width, kScreenWidth, 20)] autorelease];
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

- (NSMutableArray *)settings {
    if (!_settings) {
        self.settings = [NSMutableArray array];
    }
    return _settings;
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        self.volumeSlider = [[[UISlider alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 40, 20)] autorelease];
        _volumeSlider.center = CGPointMake(kControlBarCenterX, kControlBarCenterY + 60);
        [_volumeSlider setThumbImage:[UIImage imageNamed:@"volumn_slider_thumb"] forState:UIControlStateNormal];
        _volumeSlider.maximumValue = 1;
        _volumeSlider.minimumValueImage = [UIImage imageNamed:@"volumelow"];
        _volumeSlider.maximumValueImage = [UIImage imageNamed:@"volumehigh"];
        _volumeSlider.minimumTrackTintColor = [UIColor blackColor];
        [_volumeSlider addTarget:self action:@selector(handleVolumeAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_volumeSlider];
    }
    return _volumeSlider;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        self.currentTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(kTimeLabelMargin, kControlBarOriginY + kTimeLabelHeight, kTimeLabelWidth, kTimeLabelHeight)] autorelease];
        _currentTimeLabel.text = @"0:00";
        _currentTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_currentTimeLabel];
    }
    return _currentTimeLabel;
}

- (UILabel *)remainTimeLabel {
    if (!_remainTimeLabel) {
        self.remainTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - kTimeLabelMargin - kTimeLabelWidth, kControlBarOriginY + kTimeLabelHeight, kTimeLabelWidth, kTimeLabelHeight)] autorelease];
        _remainTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        _remainTimeLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_remainTimeLabel];
    }
    return _remainTimeLabel;
}

- (UIImageView *)albumView {
    CGFloat size_width = CGRectGetWidth(self.view.bounds) - 80;
    if (!_albumView) {
        self.albumView = [[[UIImageView alloc] initWithFrame:CGRectMake(40, 50, size_width, size_width)] autorelease];
        _albumView.layer.cornerRadius = size_width / 2;
        _albumView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _albumView.layer.borderWidth = 2;
        _albumView.layer.masksToBounds = YES;
        [self.scrollView addSubview:_albumView];
    }
    return _albumView;
}

- (UITableView *)lyricTableView
{
    if (_lyricTableView == nil) {
        _lyricTableView = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth, 100, kScreenWidth, kScreenWidth - 160) style:UITableViewStylePlain];
        _lyricTableView.contentInset = UIEdgeInsetsMake(200, 0, 200, 0);
        [_lyricTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _lyricTableView.dataSource = self;
        _lyricTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _lyricTableView.backgroundView = nil;
        _lyricTableView.backgroundColor = [UIColor clearColor];
        _lyricTableView.showsVerticalScrollIndicator = NO;
        _lyricTableView.delegate = self;
    }
    return _lyricTableView;
}

- (void)loadView {
    self.view = [[[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.view.userInteractionEnabled = YES;
    
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    visualEffectView.frame = self.view.frame;
    [self.view addSubview:visualEffectView.autorelease];
    
    
    self.scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 300)] autorelease];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * 2, CGRectGetHeight(self.scrollView.bounds));
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.lyricTableView];
    
    [self.view addSubview:self.pageControl];
    
    UIVisualEffectView *background = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    background.frame = CGRectMake(0, kControlBarOriginY, kScreenWidth, kControlBarHeight);
    [self.view addSubview:background];
    [background release];
}

- (NSString *)timeWithInterval:(float)interval {
    int minute = interval / 60;
    int second = (int)interval % 60;
    return [NSString stringWithFormat:@"%d:%02d", minute, second];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(16, 24, 20, 20);
    [backButton setImage:[UIImage imageNamed:@"arrowdown"] forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    backButton.layer.cornerRadius = 10;
    backButton.layer.masksToBounds = YES;
    [backButton addTarget:self action:@selector(handleDismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
   
    
//    //获取背景图片的地址
//    NSString *blurImagURLStr = [self.currentMusic.blurPicUrl stringByAppendingFormat:@"?param=%fy%f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height];
//    [(UIImageView *)self.view sd_setImageWithURL:[NSURL URLWithString:blurImagURLStr]];
    
    self.musicProgress = [[[UISlider alloc] initWithFrame:CGRectMake(0, kControlBarOriginY - 20, kScreenWidth, 40)] autorelease];
    self.musicProgress.minimumTrackTintColor = LOColor(244, 0, 89);
    self.musicProgress.maximumTrackTintColor = [UIColor grayColor];
    [self.musicProgress setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
//    self.musicProgress.maximumValue = self.currentMusic.duration.floatValue / 1000;//设置进度条的最大值为音乐总时长
//    self.musicProgress.value = defaultStreamer
    [self.musicProgress addTarget:self action:@selector(handleProgressChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.musicProgress];
    
//    self.currentTimeLabel.text = @"0:00";
//    self.remainTimeLabel.text = [NSString stringWithFormat:@"- %@", [self timeWithInterval:self.musicProgress.maximumValue]];
    [self setupMusicInfo];
    [self setupControlButton];
    [self setupSettingsButton];
    [self updateMusicState];
}

- (void)setupControlButton {
    UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *playPauseImgN = [UIImage imageNamed:@"pause"];
    UIImage *playPauseImgH = [UIImage imageNamed:@"pause_h"];
    playPauseButton.frame = CGRectMake(0, 0, playPauseImgN.size.width * 0.36, playPauseImgN.size.height * 0.36);
    [playPauseButton setImage:playPauseImgN forState:UIControlStateNormal];
    [playPauseButton setImage:playPauseImgH forState:UIControlStateHighlighted];
    [playPauseButton addTarget:self action:@selector(handlePlayPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    playPauseButton.center = CGPointMake(kControlBarCenterX, kControlBarCenterY);
    [self.view addSubview:playPauseButton];
    
    UIButton *rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rewindImgN = [UIImage imageNamed:@"rewind"];
    UIImage *rewindImgH = [UIImage imageNamed:@"rewind_h"];
    rewindButton.frame = CGRectMake(0, 0, rewindImgN.size.width * 0.36, rewindImgN.size.height * 0.36);
    rewindButton.center = CGPointMake(kControlBarCenterX - kButtonOffsetX, kControlBarCenterY);
    [rewindButton setImage:rewindImgN forState:UIControlStateNormal];
    [rewindButton setImage:rewindImgH forState:UIControlStateHighlighted];
    [rewindButton addTarget:self action:@selector(handleRewindAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rewindButton];
    
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *forwardImgN = [UIImage imageNamed:@"forward"];
    UIImage *forwardImgH = [UIImage imageNamed:@"forward_h"];
    forwardButton.frame = CGRectMake(0, 0, forwardImgN.size.width * 0.36, forwardImgN.size.height * 0.36);
    forwardButton.center = CGPointMake(kControlBarCenterX + kButtonOffsetX, kControlBarCenterY);
    [forwardButton addTarget:self action:@selector(handleForwardAction:) forControlEvents:UIControlEventTouchUpInside];
    [forwardButton setImage:forwardImgN forState:UIControlStateNormal];
    [forwardButton setImage:forwardImgH forState:UIControlStateHighlighted];
    [self.view addSubview:forwardButton];
    
}

- (void)setupSettingsButton {
    NSArray *titles = @[@"loop", @"shuffle", @"singleloop", @"music"];
    for (int i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonInteritemSpacing = (kScreenWidth - 25 * 4 - 24) / 3;
        CGRect frame = CGRectMake(12 + (25 + buttonInteritemSpacing) * i, kScreenHeight - 25 - 18, 25, 25);
        button.frame = frame;
        button.tag = kSettingButtonBaseTag + i;
        [button setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[titles[i] stringByAppendingString:@"-s"]] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(handleSettingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [self.settings addObject:button];
    }
    [self.settings[[MusicInfoManager sharedManger].playingStatus] setSelected:YES];
}

- (void)setupMusicInfo {
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kMusicInfoOriginY, kScreenWidth, 30)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.tag = 1111;
    nameLabel.font = [UIFont systemFontOfSize:22];
    nameLabel.text = self.currentMusic.name;
    [self.view addSubview:nameLabel];
    [nameLabel release];
    
    UILabel *albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kMusicInfoOriginY + 35, kScreenWidth, 16)];
    albumLabel.textAlignment = NSTextAlignmentCenter;
    albumLabel.tag = 1112;
    albumLabel.textColor = [UIColor darkGrayColor];
    albumLabel.font = [UIFont fontWithName:@"HelveticaNeue-bold" size:12];
    albumLabel.text = [NSString stringWithFormat:@"%@ - %@", self.currentMusic.singer, self.currentMusic.album];
    [self.view addSubview:albumLabel];
    [albumLabel release];
}


- (void)handleProgressChangedAction:(UISlider *)sender {
    [[LOAudioStreamer sharedStreamer] seekToTime:sender.value];
}

- (void)handleDismissAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)audioStreamer:(LOAudioStreamer *)streamer didPlayingWithProgress:(float)progress {
    NSUInteger index = [[LyricHelper sharedLyricHelper] lyricIndexAtTime:progress];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_lyricTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    self.musicProgress.value = progress;
    NSString *currentTime = [self timeWithInterval:progress];
    NSString *remainTime = [NSString stringWithFormat:@"- %@", [self timeWithInterval:self.musicProgress.maximumValue - progress]];
    self.currentTimeLabel.text = currentTime;
    self.remainTimeLabel.text = remainTime;
    
    
    self.albumView.transform = CGAffineTransformRotate(self.albumView.transform, 0.01);
    
    self.albumView.transform = CGAffineTransformRotate(self.albumView.transform, 0.01);
}

- (void)dealloc {
    [LOAudioStreamer sharedStreamer].delegate = nil;
    _lyricTableView.delegate = nil;
    _lyricTableView.dataSource = nil;
    [_lyricTableView release];
    [_lyricItemsArray release];
    [super dealloc];
}

- (void)handlePlayPauseAction:(UIButton *)sender {
    LOAudioStreamer *streamer = [LOAudioStreamer sharedStreamer];
    if ([streamer isPlaying]) {
        [streamer pause];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"play_h"] forState:UIControlStateHighlighted];
    } else {
        [streamer play];
        [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"pause_h"] forState:UIControlStateHighlighted];
    }
}

- (void)handleRewindAction:(UIButton *)sender {
    //让currentIndex自减
    self.currentIndex--;
    if (self.currentIndex < 0) {
        self.currentIndex = [[MusicInfoManager sharedManger] countOfModels] - 1;
    }
  
    [self updateMusicState];
}

- (void)handleForwardAction:(UIButton *)sender {
    self.currentIndex++;
    self.currentIndex = self.currentIndex % [MusicInfoManager sharedManger].countOfModels;
    [self updateMusicState];
}

- (void)updateMusicState {
    self.currentMusic = [[MusicInfoManager sharedManger] modelAtIndex:self.currentIndex];//获取指定下表的音乐模型对象
    LyricHelper *helper = [LyricHelper sharedLyricHelper];
    [helper setLyricString:self.currentMusic.lyric];
    self.lyricItemsArray = helper.allLyricItems;
    
    [self.albumView sd_setImageWithURL:[NSURL URLWithString:self.currentMusic.coverUrl] placeholderImage:[UIImage imageNamed:@"place_holder"]];
    self.musicProgress.maximumValue = self.currentMusic.duration.floatValue / 1000;
    [(UIImageView *)self.view sd_setImageWithURL:[NSURL URLWithString:[self.currentMusic.picUrl stringByAppendingFormat:@"?param=%fy%f", kScreenWidth * 2, kScreenHeight * 2]]];
    self.currentTimeLabel.text = @"0:00";
    self.remainTimeLabel.text = [self timeWithInterval:self.musicProgress.maximumValue];
    [(UILabel *)[self.view viewWithTag:1111] setText:self.currentMusic.name];
    [(UILabel *)[self.view viewWithTag:1112] setText:[NSString stringWithFormat:@"%@ - %@", self.currentMusic.singer, self.currentMusic.album]];
    LOAudioStreamer *defaultStreamer = [LOAudioStreamer sharedStreamer];
    defaultStreamer.delegate = self;
    if (![defaultStreamer isPlayingCurrentAudioWithURL:self.currentMusic.mp3Url]) {
        [defaultStreamer setAudioMetadataWithURL:self.currentMusic.mp3Url];
    }
    //播放音乐
    [defaultStreamer play];
    self.volumeSlider.value = defaultStreamer.volume;
    [self.lyricTableView reloadData];
}

- (void)handleSettingsButtonAction:(UIButton *)sender {
    for (UIButton *aButton in self.settings) {
        aButton.selected = NO;
    }
    sender.selected = !sender.selected;
    [MusicInfoManager sharedManger].playingStatus = [self.settings indexOfObject:sender];
}

- (void)handleVolumeAction:(UISlider *)sender {
    [[LOAudioStreamer sharedStreamer] setVolume:sender.value];
}

- (void)audioStreamerDidFinishPlaying:(LOAudioStreamer *)streamer {
    switch ([MusicInfoManager sharedManger].playingStatus) {
        case MusicPlayingStatusLoop:
            [self handleForwardAction:nil];
            break;
        case MusicPlayingStatusRandom:
            self.currentIndex = arc4random() % [MusicInfoManager sharedManger].countOfModels;
            [self updateMusicState];
            break;
        case MusicPlayingStatusRepeat:
            [[LOAudioStreamer sharedStreamer] setAudioMetadataWithURL:nil];
            [self updateMusicState];
            break;
        case MusicPlayingStatusNone:
        default:
            break;
    }
    [self.lyricTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lyricItemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    LyricItem *lyricItem = _lyricItemsArray[indexPath.row];
    cell.textLabel.text = lyricItem.string;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.highlightedTextColor = LOColor(244, 0, 89);
//    cell.textLabel.shadowColor = [UIColor lightGrayColor];
//    cell.textLabel.shadowOffset = CGSizeMake(.5, .5);
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    UIView *backgroundView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
    backgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = backgroundView;
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



@end
