//
//  XDSMenuTopView.h
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/20.
//  Copyright © 2017年 macos. All rights reserved.
//

#import "XDSReadRootView.h"

@protocol XDSMenuTopViewDelegate <NSObject>

- (void)startSpeech;

@end

@interface XDSMenuTopView : XDSReadRootView

- (void)updateMarkButtonState;

@property (nonatomic ,weak)id<XDSMenuTopViewDelegate>delegate;

@end
