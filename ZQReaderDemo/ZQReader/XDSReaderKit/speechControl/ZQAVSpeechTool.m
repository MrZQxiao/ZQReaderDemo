//
//  ZQAVSpeechTool.m
//  ShuWangTongBu
//
//  Created by 肖兆强 on 2018/5/11.
//  Copyright © 2018年 JWZT. All rights reserved.
//

#import "ZQAVSpeechTool.h"
#import <AVFoundation/AVFoundation.h>

@interface ZQAVSpeechTool ()<AVSpeechSynthesizerDelegate>

@property (nonatomic ,strong)AVSpeechSynthesizer *avSpeaker;

@property (nonatomic ,strong)NSArray *paragraphs;

@property (nonatomic ,assign)NSInteger currentParagraphs;


@property (nonatomic ,assign)CGFloat rate;


@end

@implementation ZQAVSpeechTool

// 单例
+(instancetype)shareSpeechTool {
    static ZQAVSpeechTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZQAVSpeechTool alloc]init];
        
    });
    return instance;
}

- (void)speechTextWith:(NSString *)text
{
    if (!(text.length>0)) {
        return;
    }
    if (_avSpeaker) {
        //把每一页文字拆分成段
        _paragraphs =[text componentsSeparatedByString:@"\n"];
        _currentParagraphs = 0;
        [self speechParagraphWith:_paragraphs[_currentParagraphs]];
    }else
    {
        //初次阅读
        NSUserDefaults *useDef = [NSUserDefaults standardUserDefaults];
        _rate = [useDef floatForKey:@"speechRate"];
        if (!_rate) {
            _rate = 0.5;
        }
        _paragraphs =[text componentsSeparatedByString:@"\n"];
        _currentParagraphs = 0;
         [[NSNotificationCenter defaultCenter] postNotificationName:@"speechParagraph" object:_paragraphs[_currentParagraphs]];
        //初始化语音合成器
        _avSpeaker = [[AVSpeechSynthesizer alloc] init];
        _avSpeaker.delegate = self;
        //初始化要说出的内容
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:_paragraphs[_currentParagraphs]];
        //设置语速,语速介于AVSpeechUtteranceMaximumSpeechRate和AVSpeechUtteranceMinimumSpeechRate之间
        //AVSpeechUtteranceMaximumSpeechRate
        //AVSpeechUtteranceMinimumSpeechRate
        //AVSpeechUtteranceDefaultSpeechRate
        utterance.rate = _rate;
        
        //设置音高,[0.5 - 2] 默认 = 1
        //AVSpeechUtteranceMaximumSpeechRate
        //AVSpeechUtteranceMinimumSpeechRate
        //AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1;
        
        //设置音量,[0-1] 默认 = 1
        utterance.volume = 1;
        
        //读一段前的停顿时间
        utterance.preUtteranceDelay = 0.5;
        //读完一段后的停顿时间
        utterance.postUtteranceDelay = 0;
        
        //设置声音,是AVSpeechSynthesisVoice对象
        //AVSpeechSynthesisVoice定义了一系列的声音, 主要是不同的语言和地区.
        //voiceWithLanguage: 根据制定的语言, 获得一个声音.
        //speechVoices: 获得当前设备支持的声音
        //currentLanguageCode: 获得当前声音的语言字符串, 比如”ZH-cn”
        //language: 获得当前的语言
        //通过特定的语言获得声音
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
        //通过voicce标示获得声音
        //AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithIdentifier:AVSpeechSynthesisVoiceIdentifierAlex];
        utterance.voice = voice;
        //开始朗读
        [_avSpeaker speakUtterance:utterance];
    }
                                    
}

- (void)speechParagraphWith:(NSString *)Paragraph
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"speechParagraph" object:Paragraph];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:Paragraph];
    utterance.rate = _rate;
    [_avSpeaker speakUtterance:utterance];
}
//切换语速
- (void)changeRate:(CGFloat)rate
{
    _rate = rate;
    //
    [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];    //初始化语音合成器
//    _avSpeaker = [[AVSpeechSynthesizer alloc] init];
//    _avSpeaker.delegate = self;
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:_paragraphs[_currentParagraphs]];
    utterance.rate = rate;
    utterance.pitchMultiplier = 1;
    utterance.volume = 1;
    utterance.preUtteranceDelay = 0.5;
    utterance.postUtteranceDelay = 0;
    
    
    [_avSpeaker speakUtterance:utterance];
    NSUserDefaults *useDef = [NSUserDefaults standardUserDefaults];
    [useDef setFloat:rate forKey:@"speechRate"];
    [useDef synchronize];
    
}

- (void)pauseSpeech
{
    //暂停朗读
    //AVSpeechBoundaryImmediate 立即停止
    //AVSpeechBoundaryWord    当前词结束后停止
    [_avSpeaker pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)continueSpeech
{
    [_avSpeaker continueSpeaking];
    
}

- (void)StopSpeech
{
    //AVSpeechBoundaryImmediate 立即停止
    //AVSpeechBoundaryWord    当前词结束后停止
    [_avSpeaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    _avSpeaker = nil;
    [XDSReadManager sharedManager].speeching = NO;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"speechDidStop" object:nil];

}

#pragma mark -
#pragma mark - AVSpeechSynthesizerDelegate
//已经开始
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
   
    
}
//已经说完
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    
   
    _currentParagraphs+=1;
    if (_currentParagraphs<_paragraphs.count) {
         //读下一段
        [self speechParagraphWith:_paragraphs[_currentParagraphs]];
    }else{
    
    
    NSInteger currentPage = CURRENT_RECORD.currentPage;
    NSInteger currentChapter = CURRENT_RECORD.currentChapter;
    if (currentPage < CURRENT_RECORD.totalPage - 1) {
        //下一页
        currentPage += 1;
    }else
    {
        if (currentChapter < CURRENT_RECORD.totalChapters - 1) {
            //下一章
            currentChapter += 1;
            currentPage = 0;
        }else
        {
            //全书读完
            [self StopSpeech];
            return;
        }
        
    }
    
    [[XDSReadManager sharedManager] readViewJumpToChapter:currentChapter page:currentPage];
     NSString *content = CURRENT_RECORD.chapterModel.pageStrings[currentPage];
    [self speechTextWith:content];
    
    }
    
}



//已经暂停
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    
}
//已经继续说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    
}
//已经取消说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    
}
//将要说某段话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    
//    DebugLog(@"%@",utterance.speechString);
    
}

@end
