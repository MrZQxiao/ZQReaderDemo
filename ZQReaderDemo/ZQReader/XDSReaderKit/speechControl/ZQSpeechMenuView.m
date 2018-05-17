//
//  ZQSpeechMenuView.m
//  ShuWangTongBu
//
//  Created by 肖兆强 on 2018/5/12.
//  Copyright © 2018年 JWZT. All rights reserved.
//

#import "ZQSpeechMenuView.h"
#import "ZQAVSpeechTool.h"

@interface ZQSpeechMenuView ()

@property (nonatomic ,strong)UIView *coverView;

@property (nonatomic, strong) UILabel *titleLabel;//标题

@property (nonatomic, strong) UISlider *slider;//进度条

@property (nonatomic ,strong) UIButton *pauseBtn;

@property (nonatomic ,strong) UIButton *stopBtn;



@end

@implementation ZQSpeechMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    [self addGestureRecognizer:tap];
    
    
    _coverView = [UIView new];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.85;
    UITapGestureRecognizer *coverTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverTouchBegin)];
    [_coverView addGestureRecognizer:coverTap];
    
    
    
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textAlignment = NSTextAlignmentRight;
    _titleLabel.text = @"语速";
    
    _slider = [UISlider new];
    _slider.minimumValue = 0.2;
    _slider.maximumValue = 0.8;
    _slider.tintColor = RGB(253, 85, 103);
    [_slider setThumbImage:[UIImage imageNamed:@"RM_3"] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSUserDefaults *useDef = [NSUserDefaults standardUserDefaults];
    if ([useDef floatForKey:@"speechRate"]) {
        _slider.value = [useDef floatForKey:@"speechRate"];
    }else
    {
        _slider.value = 0.5;
    }
    
    
    _pauseBtn = [UIButton new];
    [_pauseBtn setImage:[UIImage imageNamed:@"speech_pause"] forState:UIControlStateNormal];
    [_pauseBtn setImage:[UIImage imageNamed:@"speech_continue"] forState:UIControlStateSelected];
    [_pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [_pauseBtn setTitle:@"继续" forState:UIControlStateSelected];
    _pauseBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _pauseBtn.layer.borderWidth = 1.0;
    _pauseBtn.sd_cornerRadius = @5;
    _pauseBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_pauseBtn addTarget:self action:@selector(pauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _stopBtn = [UIButton new];
    [_stopBtn setImage:[UIImage imageNamed:@"speech_stop"] forState:UIControlStateNormal];
    [_stopBtn setTitle:@"退出朗读" forState:UIControlStateNormal];
    _stopBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _stopBtn.layer.borderWidth = 1.0;
    _stopBtn.sd_cornerRadius = @5;
    _stopBtn.titleLabel.font = [UIFont systemFontOfSize:12];

    [_stopBtn addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self sd_addSubviews:@[_coverView,_titleLabel,_slider,_stopBtn,_pauseBtn]];
    
    _coverView.sd_layout
    .leftEqualToView(self)
    .rightEqualToView(self)
    .bottomEqualToView(self)
    .heightIs(150);
    
    
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width *0.5 - 60;
    _stopBtn.sd_layout
    .leftSpaceToView(self, 30)
    .bottomSpaceToView(self, 30)
    .heightIs(30)
    .widthIs(btnW);
    
    _pauseBtn.sd_layout
    .rightSpaceToView(self, 30)
    .bottomSpaceToView(self, 30)
    .heightIs(30)
    .widthIs(btnW);
    
    
    _titleLabel.sd_layout
    .leftSpaceToView(self, 15)
    .bottomSpaceToView(_stopBtn, 40)
    .heightIs(20);
    [_titleLabel setSingleLineAutoResizeWithMaxWidth:CGFLOAT_MAX];
    
    _slider.sd_layout
    .centerYEqualToView(_titleLabel)
    .leftSpaceToView(_titleLabel, 15)
    .rightSpaceToView(self, 30)
    .heightIs(20);
    
}

- (void)coverTouchBegin
{
    
}


//暂停/播放
- (void)pauseBtnClick:(UIButton *)sender
{
    if (_pauseBtn.selected) {
        [[ZQAVSpeechTool shareSpeechTool] continueSpeech];
    }else{
        [[ZQAVSpeechTool shareSpeechTool] pauseSpeech];
    }
    _pauseBtn.selected = !_pauseBtn.selected;
}

//退出
- (void)stopBtnClick
{
    _pauseBtn.selected = NO;
    [[ZQAVSpeechTool shareSpeechTool] StopSpeech];
    [self removeFromSuperview];
}

//切换语速
- (void)sliderValueChanged:(UISlider *)slider{
    
    [[ZQAVSpeechTool shareSpeechTool] changeRate:slider.value];
    _pauseBtn.selected = NO;
}

@end
