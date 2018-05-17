//
//  XDSReadPageViewController.m
//  XDSReader
//
//  Created by dusheng.xu on 11/07/2017.
//  Copyright © 2017 macos. All rights reserved.
//

#import "XDSReadPageViewController.h"
#import "XDSReadMenu.h"
#import "ZQSpeechMenuView.h"
@interface XDSReadPageViewController ()
<UIPageViewControllerDelegate,
UIPageViewControllerDataSource,
UIGestureRecognizerDelegate,
XDSReadManagerDelegate
>
{
    
    
    
    
}

@property (nonatomic,assign)NSInteger chapter;    //当前显示的章节
@property (nonatomic,assign)NSInteger page;       //当前显示的页数

@property (nonatomic,assign)NSInteger chapterChange;  //将要变化的章节
@property (nonatomic,assign)NSInteger pageChange;     //将要变化的页数

@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (strong, nonatomic) XDSReadMenu *readMenuView;//菜单

@property (nonatomic ,strong)ZQSpeechMenuView *SpeechMenuView;//朗读菜单

@end

@implementation XDSReadPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self readPageViewControllerDataInit];
    [self createReadPageViewControllerUI];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _pageViewController.view.frame = self.view.frame;
}


- (void)dealloc
{
    
}



//MARK: - ABOUT UI
- (void)createReadPageViewControllerUI{
    [self addChildViewController:self.pageViewController];
    
    _chapter = CURRENT_RECORD.currentChapter;
    _page = CURRENT_RECORD.currentPage;
  
    XDSReadViewController *readVC = [[XDSReadManager sharedManager] readViewWithChapter:&_chapter
                                                                                   page:&_page
                                                                                pageUrl:nil];

    [_pageViewController setViewControllers:@[readVC]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished) {
//                                     if (finished) {
//                                         NSInteger i = wself.chapter;
//                                         NSInteger j = wself.page;
//                                         [wself.pageViewController setViewControllers:@[[[XDSReadManager sharedManager] readViewWithChapter:&i
//                                                                                                                                       page:&j
//                                                                                                                                    pageUrl:nil]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//                                     }
                                 }];
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu)];
        tap.delegate = self;
        tap;
    })];
    

}

#pragma mark - init
-(UIPageViewController *)pageViewController{
    if (!_pageViewController) {
//        NSInteger effect = [XDSReadConfig shareInstance].currentEffect>0?[XDSReadConfig shareInstance].currentEffect:[XDSReadConfig shareInstance].cacheEffect;
//        effect>0?UIPageViewControllerTransitionStyleScroll:UIPageViewControllerTransitionStylePageCurl
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self.view addSubview:_pageViewController.view];
    }
    return _pageViewController;
}

//MARK: - DELEGATE METHODS
//TODO: XDSReadManagerDelegate
- (void)readViewDidClickCloseButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)readViewFontDidChanged {
    _chapter = CURRENT_RECORD.currentChapter;
    _page = CURRENT_RECORD.currentPage;
    XDSReadViewController *readVC = [[XDSReadManager sharedManager] readViewWithChapter:&_chapter
                                                                                   page:&_page
                                                                                pageUrl:nil];
    __weak typeof(self) wself = self;

    [_pageViewController setViewControllers:@[readVC]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:^(BOOL finished) {
//                                     if (finished) {
//                                         NSInteger i = wself.chapter;
//                                         NSInteger j = wself.page;
//                                         [wself.pageViewController setViewControllers:@[[[XDSReadManager sharedManager] readViewWithChapter:&i
//                                                                                                                                       page:&j
//                                                                                                                                    pageUrl:nil]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//                                     }
                                 }];
}
- (void)readViewThemeDidChanged{
    XDSReadViewController *readView = _pageViewController.viewControllers.firstObject;
    UIColor *theme = [XDSReadConfig shareInstance].currentTheme?[XDSReadConfig shareInstance].currentTheme:[XDSReadConfig shareInstance].cacheTheme;
    readView.view.backgroundColor = theme;
    readView.readView.backgroundColor = theme;
}
- (void)readViewEffectDidChanged{
    
    
    
    
    
}
- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page{
    if (chapter<0) {
        return;
    }
    XDSReadViewController *readVC = [[XDSReadManager sharedManager] readViewWithChapter:&chapter
                                                                                   page:&page
                                                                                pageUrl:nil];
    [_pageViewController setViewControllers:@[readVC]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}
- (void)readViewDidUpdateReadRecord{
    [self.readMenuView updateReadRecord];
    _chapter = CURRENT_RECORD.currentChapter;
    _page = CURRENT_RECORD.currentPage;
}

- (void)readViewDidAddNoteSuccess {
    [XDSReaderUtil showAlertWithTitle:nil message:@"保存笔记成功"];
    [self readViewFontDidChanged];
}

//TODO: UIGestureRecognizerDelegate
//解决TabView与Tap手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[DTAttributedTextContentView class]] ||
        [touch.view isKindOfClass:[DTAttributedTextView class]] ||
        [touch.view isKindOfClass:[XDSReadView class]]) {
        return YES;
    }
    return  NO;
}

//TODO: UIPageViewControllerDelegate, UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(UIViewController *)viewController{
    if ([XDSReadManager sharedManager].speeching) {
        return nil;
    }
    

    NSLog(@"444444444444444444444===%zd count", pageViewController.viewControllers.count);
    XDSReadViewController *readVC = (XDSReadViewController *)viewController;
    _pageChange = readVC.pageNum;
    _chapterChange = readVC.chapterNum;
    
    if (_chapterChange + _pageChange == 0) {
        [self showToolMenu];//已经是第一页了，显示菜单准备返回
        return nil;
    }
    
    
    if (_pageChange == 0) {
        _chapterChange--;
    }
    _pageChange--;
    
    return [[XDSReadManager sharedManager] readViewWithChapter:&_chapterChange
                                                          page:&_pageChange
                                                       pageUrl:nil];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(UIViewController *)viewController{
    NSLog(@"333333333333333333333333===%zd count", pageViewController.viewControllers.count);

    if ([XDSReadManager sharedManager].speeching) {
        return nil;
    }
    
    
    XDSReadViewController *readVC = (XDSReadViewController *)viewController;
    _pageChange = readVC.pageNum;
    _chapterChange = readVC.chapterNum;
//        _pageChange = _page;
//        _chapterChange = _chapter;
    if (_pageChange == CURRENT_BOOK_MODEL.chapters.lastObject.pageCount-1 && _chapterChange == CURRENT_BOOK_MODEL.chapters.count-1) {
        //最后一页，这里可以处理一下，添加已读完页面。
        [self showToolMenu];//已经是最后一页了，显示菜单准备返回
        return nil;
    }
    if (_pageChange == CURRENT_RECORD.totalPage-1) {
        _chapterChange++;
        _pageChange = 0;
    }else{
        _pageChange++;
    }
    
    
    return [[XDSReadManager sharedManager] readViewWithChapter:&_chapterChange
                                                          page:&_pageChange
                                                       pageUrl:nil];
}

#pragma mark -PageViewController Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    NSLog(@"22222222222222222222222222");

    _chapter = _chapterChange;
    _page = _pageChange;
}
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed{
    NSLog(@"1111111111111111111");
    if (!completed) {
        XDSReadViewController *readView = previousViewControllers.firstObject;
        _page = readView.pageNum;
        _chapter = readView.chapterNum;
    }
    else{
        _chapter = _chapterChange;
        _page = _pageChange;
        [[XDSReadManager sharedManager] updateReadModelWithChapter:_chapter page:_page];
    }
}
//MARK: - ABOUT REQUEST
//MARK: - ABOUT EVENTS
-(void)showToolMenu{
    if ([XDSReadManager sharedManager].speeching) {
        [self.view addSubview:self.SpeechMenuView];
        return;
    }
    XDSReadViewController *readView = _pageViewController.viewControllers.firstObject;
    [readView.readView cancelSelected];
    [self.view addSubview:self.readMenuView];
}
//MARK: - OTHER PRIVATE METHODS
- (XDSReadMenu *)readMenuView{
    if (nil == _readMenuView) {
        _readMenuView = [[XDSReadMenu alloc] initWithFrame:self.view.bounds];
        _readMenuView.backgroundColor = [UIColor clearColor];
    }
    return _readMenuView;
}

- (ZQSpeechMenuView *)SpeechMenuView
{
    if (nil == _SpeechMenuView) {
        _SpeechMenuView = [[ZQSpeechMenuView alloc] initWithFrame:self.view.bounds];
        _SpeechMenuView.backgroundColor = [UIColor clearColor];
    }
    return _SpeechMenuView;
}




//MARK: - ABOUT MEMERY
- (void)readPageViewControllerDataInit{
    
}


//不自动旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
