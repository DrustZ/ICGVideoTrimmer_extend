//
//  ICGVideoTrimmerLeftOverlay.h
//  ICGVideoTrimmer
//
//  Created by 张明瑞 on 7/15/15.
//  Copyright (c) 2015 . All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ICGThumbView : UIView

@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color right:(BOOL)flag;

- (instancetype)initWithFrame:(CGRect)frame thumbImage:(UIImage *)image;

@end
