//
//  MusicListViewController.m
//  MusicPlayer
//
//  Created by ZC on 15/6/1.
//  Copyright (c) 2015年 843949490@qq.com All rights reserved.
//

#import "MusicListViewController.h"
#import "MusicInfoManager.h"
#import "MusicPlayViewController.h"
#import "MusicInfoCell.h"
#import "UIImageView+WebCache.h"
@interface MusicListViewController ()
@property (nonatomic, retain) UIImageView *imageView;
//@property (nonatomic, retain) UITableView *tableView;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Favourite Songs";
    
    self.imageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    UIVisualEffectView *visualView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]] autorelease];
    visualView.frame = [UIScreen mainScreen].bounds;
    [self.imageView addSubview:visualView];
    self.tableView.backgroundView = self.imageView;
    self.tableView.separatorEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.tableView.rowHeight = 66;
    
    [self.tableView registerClass:[MusicInfoCell class] forCellReuseIdentifier:@"CELL"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"kDataDidFinishAcquire" object:nil];
    
    [[MusicInfoManager sharedManger] acquireData];
    
    UIButton *musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    musicBtn.frame = CGRectMake(0, 0, 28, 28);
    [musicBtn setImage:[UIImage imageNamed:@"music-s"] forState:UIControlStateNormal];
    [musicBtn addTarget:self action:@selector(handlePresentCurrentMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *currentMusicBtn = [[UIBarButtonItem alloc] initWithCustomView:musicBtn];
    self.navigationItem.rightBarButtonItem = currentMusicBtn;
    [currentMusicBtn release];

}
- (void)handlePresentCurrentMusicAction:(UIBarButtonItem *)sender {
    [self initalizeMusicPlayControllerWithIndex:[MusicInfoManager sharedManger].currentIndex];
}
- (void)reloadData {
    MusicInfo *music = [[MusicInfoManager sharedManger] modelAtIndex:0];
    NSLog(@"%@", [music.blurPicUrl stringByAppendingFormat:@"?param=%fy%f", [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2]);
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[music.blurPicUrl stringByAppendingFormat:@"?param=%fy%f", [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2]]];
    [self.tableView reloadData];
}

- (void)dealloc {
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView name:@"kDataDidFinishAcquire" object:nil];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [MusicInfoManager sharedManger].countOfModels;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    MusicInfo *music = [[MusicInfoManager sharedManger] modelAtIndex:indexPath.row];
    [cell configureCellWithMusic:music];
   
    // Configure the cell...
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self initalizeMusicPlayControllerWithIndex:indexPath.row];
}

- (void)initalizeMusicPlayControllerWithIndex:(NSInteger)index {
    MusicPlayViewController *musicPlayVC = [[MusicPlayViewController alloc] init];
    //属性传值
    musicPlayVC.currentIndex = index;
    
    [self.navigationController presentViewController:musicPlayVC animated:YES completion:nil];
    [musicPlayVC release];
    
    MusicInfo *music = [[MusicInfoManager sharedManger] modelAtIndex:index];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[music.blurPicUrl stringByAppendingFormat:@"?param=%fy%f", [UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height * 2]]];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
