//
//  ICGVideoTrimmerView.h
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ICGVideoTrimmerDelegate;
@class AVAsset;

@interface ICGVideoTrimmerView : UIView

// Video to be trimmed
@property (strong, nonatomic) AVAsset *asset;

// Theme color for the trimmer view
@property (strong, nonatomic) UIColor *themeColor;

// Theme color for the borders
@property (strong, nonatomic) UIColor *borderColor;

// Theme color for the playback pointer
@property (strong, nonatomic) UIColor *pointerColor;

// Maximum length for the trimmed video
@property (assign, nonatomic) CGFloat maxLength;

// Minimum length for the trimmed video
@property (assign, nonatomic) CGFloat minLength;

// Show ruler view on the trimmer view or not
@property (assign, nonatomic) BOOL showsRulerView;

// Custom image for the left thumb
@property (strong, nonatomic) UIImage *leftThumbImage;

// Custom image for the right thumb
@property (strong, nonatomic) UIImage *rightThumbImage;

// Custom width for the top and bottom borders
@property (assign, nonatomic) CGFloat borderWidth;

// Custom width for thumb
@property (assign, nonatomic) CGFloat thumbWidth;

// Custom width for playback pointer
@property (assign, nonatomic) CGFloat pointerWidth;

// Left trimmer position
@property (readonly, nonatomic) NSTimeInterval startTime;

// Right trimmer position
@property (readonly, nonatomic) NSTimeInterval endTime;

@property (weak, nonatomic) IBOutlet id<ICGVideoTrimmerDelegate> delegate;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;

- (void)resetSubviews;

@end

@interface ICGVideoTrimmerView (ICGPlaybackTime)

- (void)runPlaybackPointerAtTime:(NSTimeInterval)timeInterval;
- (void)stopPlaybackPointerAtTime:(NSTimeInterval)timeInterval;

@end

@protocol ICGVideoTrimmerDelegate <NSObject>

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(NSTimeInterval)startTime rightPosition:(NSTimeInterval)endTime;


@optional
- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didMovePointerAtTime:(NSTimeInterval)time;

@optional
- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didStopAnyMoveAtLeftPosition:(NSTimeInterval)startTime rightPosition:(NSTimeInterval)endTime;

@end
