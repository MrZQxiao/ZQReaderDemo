//
//  ZQAVSpeechTool.h
//  ShuWangTongBu
//
//  Created by 肖兆强 on 2018/5/11.
//  Copyright © 2018年 JWZT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZQAVSpeechTool : NSObject

+(instancetype)shareSpeechTool;

//开始朗读
- (void)speechTextWith:(NSString *)text;
//暂停朗读
- (void)pauseSpeech;
//继续朗读
- (void)continueSpeech;
//结束朗读
- (void)StopSpeech;
//切换语速
- (void)changeRate:(CGFloat)rate;


@end
