//
//  AVAsset+VideoOrientation.m
//  ICGVideoTrimmer
//
//  Created by 明瑞 on 15/7/25.
//  Copyright (c) 2015年 ichigo. All rights reserved.
//

#import "AVAsset+VideoOrientation.h"


static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};

@implementation AVAsset (VideoOrientation)
@dynamic videoOrientation;

- (LBVideoOrientation)videoOrientation
{
    NSArray *videoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] == 0) {
        return LBVideoOrientationNotFound;
    }
    
    AVAssetTrack* videoTrack    = [videoTracks objectAtIndex:0];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    CGFloat videoAngleInDegree  = RadiansToDegrees(atan2(txf.b, txf.a));
    
    LBVideoOrientation orientation = 0;
    switch ((int)videoAngleInDegree) {
        case 0:
            orientation = LBVideoOrientationRight;
            break;
        case 90:
            orientation = LBVideoOrientationUp;
            break;
        case 180:
            orientation = LBVideoOrientationLeft;
            break;
        case -90:
            orientation	= LBVideoOrientationDown;
            break;
        default:
            orientation = LBVideoOrientationNotFound;
            break;
    }
    
    return orientation;
}

@end