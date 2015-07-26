//
//  ICGVideoPlayerView.m
//  ICGVideoTrimmer
//
//  Created by 明瑞 on 15/7/25.
//  Copyright (c) 2015年 ichigo. All rights reserved.
//
#import "ICGVideoPlayerView.h"
#import "ViewUtils.h"
#import "AVAsset+VideoOrientation.h"

@interface ICGVideoPlayerView()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (assign, nonatomic) CMTime Starttime;
@property (assign, nonatomic) CMTime Endtime;
@property (strong, nonatomic) UIView *videoview;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, assign) float movieAspectRatio;
@property (nonatomic, assign) LBVideoOrientation orientation;
@end
@implementation ICGVideoPlayerView
@synthesize player;
@synthesize playerLayer;
@synthesize timer;

- (void)play{
    [self.player play];
}

- (void)pause{
    [self.player pause];
}

- (void)refreshTimePeriod:(CGFloat)startTime end:(CGFloat)endTime{
    int32_t timeScale = player.currentItem.asset.duration.timescale;
    self.Starttime = CMTimeMakeWithSeconds(startTime, timeScale);
    self.Endtime = CMTimeMakeWithSeconds(endTime, timeScale);
    [self.player seekToTime:self.Starttime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if(timer.isValid){
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:endTime - startTime target:self selector:@selector(replayMovie:) userInfo:nil repeats:YES];
    }
    _range = CMTimeRangeFromTimeToTime(self.Starttime, self.Endtime);
}

-(void)replayMovie:(NSTimer *)timer
{
    [self.playerLayer.player seekToTime:self.Starttime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.playerLayer.player play];
}

- (void)slidevideo:(UIPanGestureRecognizer*)recognizer{
    CGPoint translation = [recognizer translationInView:self];
    CGFloat leftp = recognizer.view.left + translation.x;
    if (leftp > 0){
        leftp = 0;
        NSLog(@"zuobian");
    } else if (leftp + recognizer.view.width < self.bounds.size.width){
        leftp = self.bounds.size.width - recognizer.view.width;
        NSLog(@"youbian");
    }
    recognizer.view.left = leftp;
    self.xrate = (0 - leftp) / recognizer.view.width;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:self];
        CGFloat leftp = recognizer.view.left + (velocity.x * 0.2);
        if (leftp > 0){
            leftp = 0;
        } else if (leftp + recognizer.view.width < self.bounds.size.width){
            leftp = self.bounds.size.width - recognizer.view.width;
        }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.left = leftp;
        } completion:nil];
        self.xrate = (0 - leftp) / recognizer.view.width;
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
}

- (void)setVideoAsset:(AVAsset *)asset{
    self.orientation = asset.videoOrientation;
    self.player = [[AVPlayer alloc] initWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:asset]];
    self.playerLayer =[AVPlayerLayer playerLayerWithPlayer:player];
    
    if (self.videoview){
        [self.videoview removeFromSuperview];
    }
    self.videoview = [[UIView alloc] init];
    [self.videoview setHeight:self.height];
    CGSize theNaturalSize = ([[asset tracksWithMediaType:AVMediaTypeVideo][0] naturalSize]);
    self.movieAspectRatio = theNaturalSize.width/theNaturalSize.height;
    [self.videoview setWidth:self.width];
    if (self.orientation == LBVideoOrientationLeft || self.orientation == LBVideoOrientationRight){
        self.videoview.frame = CGRectMake(0, 0, self.height*self.movieAspectRatio, self.height);
        [self.videoview setBackgroundColor:[UIColor whiteColor]];
    }
    self.videoview.center = self.center;

    if (self.orientation == LBVideoOrientationLeft || self.orientation == LBVideoOrientationRight){
        UIPanGestureRecognizer *pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slidevideo:)];
        [self.videoview addGestureRecognizer:pangesture];
        self.playerLayer.contentsGravity = kCAGravityResizeAspect;
        self.xrate = (0 - self.videoview.left) / self.videoview.width;
    } else {
        self.xrate = -1;
    }
    [self.playerLayer setFrame:self.videoview.bounds];
    [self.playerLayer setBounds:self.videoview.bounds];
    [self.videoview.layer addSublayer:self.playerLayer];
    self.playerLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self addSubview:self.videoview];
    
    
    if(self.playerLayer.player.status == AVPlayerStatusReadyToPlay) {
        [self.playerLayer.player play];
    }
    _range = [self.playerLayer.player.currentItem.loadedTimeRanges[0] CMTimeRangeValue];
    self.Starttime = _range.start;
    NSTimeInterval duration = CMTimeGetSeconds(_range.start) + CMTimeGetSeconds(player.currentItem.duration);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(replayMovie:) userInfo:nil repeats:YES];

}
@end
