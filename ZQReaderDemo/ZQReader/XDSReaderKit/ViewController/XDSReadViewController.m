//
//  XDSReadViewController.m
//  XDSReader
//
//  Created by dusheng.xu on 07/07/2017.
//  Copyright © 2017 macos. All rights reserved.
//

#import "XDSReadViewController.h"
#import "XDSReadView.h"
@interface XDSReadViewController ()

@property (strong, nonatomic) XDSChapterModel *chapterModel;

@end

@implementation XDSReadViewController
- (instancetype)initWithChapterNumber:(NSInteger)chapterNum pageNumber:(NSInteger)pageNum {
    if (self = [super init]) {
        self.chapterNum = chapterNum;
        self.pageNum = pageNum;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetView:) name:@"speechParagraph" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speechDidStop) name:@"speechDidStop" object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [XDSReadConfig shareInstance].currentTheme?[XDSReadConfig shareInstance].currentTheme:[XDSReadConfig shareInstance].cacheTheme;

    CGRect frame = [XDSReadManager readViewBounds];
    self.readView = [[XDSReadView alloc] initWithFrame:frame chapterNum:self.chapterNum pageNum:self.pageNum];
    self.readView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.readView];
    
}

- (void)speechDidStop
{
    [self.readView removeAttributed];
}


- (void)resetView:(NSNotification *)notification
{
    [self.readView highlightTextWith:notification.object];
}
- (void)dealloc{
    NSLog(@"XDSReadViewController dealloc");
}

@end
