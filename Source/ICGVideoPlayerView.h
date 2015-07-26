//
//  ICGVideoPlayerView.h
//  ICGVideoTrimmer
//
//  Created by 明瑞 on 15/7/25.
//  Copyright (c) 2015年 ichigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ICGVideoPlayerView;
@interface ICGVideoPlayerView : UIView

@property (nonatomic, assign) float xrate;
@property (nonatomic, assign) CMTimeRange range;


- (void)setVideoAsset:(AVAsset* )asset;
- (void)refreshTimePeriod:(CGFloat)startTime end:(CGFloat)endTime;
- (void)play;
- (void)pause;
@end
