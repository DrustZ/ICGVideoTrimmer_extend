//
//  ViewController.m
//  ICGVideoTrimmer
//
//  Created by 张明瑞 on 7/15/15.
//  Copyright (c) 2015 . All rights reserved.
//


#import "ViewController.h"
#import "ICGVideoTrimmerView.h"
#import "ICGVideoPlayerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ICGVideoTrimmerDelegate>

@property (weak, nonatomic) IBOutlet ICGVideoTrimmerView *trimmerView;
@property (weak, nonatomic) IBOutlet UIButton *trimButton;

@property (strong, nonatomic) ICGVideoPlayerView *playerview;
@property (strong, nonatomic) NSString *tempVideoPath;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];
    self.playerview = [[ICGVideoPlayerView alloc] init];
    [self.playerview setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-self.trimmerView.frame.size.height)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ICGVideoTrimmerDelegate

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    self.startTime = startTime;
    self.stopTime = endTime;
    [self.playerview refreshTimePeriod:startTime end:endTime];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    self.asset = [AVAsset assetWithURL:url];
    
    // set properties for trimmer view
    [self.trimmerView setThemeColor:[UIColor lightGrayColor]];
    [self.trimmerView setAsset:self.asset];
    [self.trimmerView setShowsRulerView:YES];
    [self.trimmerView setDelegate:self];
    [self.trimmerView setThumbWidth:15];
    
    // important: reset subviews
    [self.trimmerView resetSubviews];
    
    [self.trimButton setHidden:NO];
    
    [self.playerview setVideoAsset:self.asset];
    [self.view insertSubview:self.playerview aboveSubview:self.trimmerView];
}


#pragma mark - Actions

- (void)deleteTempFile
{
    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}

- (IBAction)selectAsset:(id)sender
{
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = NO;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
}

- (IBAction)trimVideo:(id)sender
{
    CGSize naturalSize = [[self.asset tracksWithMediaType:AVMediaTypeVideo][0] naturalSize];
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.asset presetName:AVAssetExportPreset640x480] ;
    self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    if (self.playerview.xrate != -1){
        [self applyCropToVideoWithAsset:self.asset AtRect:CGRectMake(naturalSize.width * self.playerview.xrate, 0,self.view.frame.size.width, self.view.frame.size.height) OnTimeRange:self.playerview.range ExportToUrl:[NSURL fileURLWithPath:self.tempVideoPath] ExistingExportSession:self.exportSession WithCompletion:nil needCrop:YES];
    } else {
        [self applyCropToVideoWithAsset:self.asset AtRect:CGRectNull OnTimeRange:self.playerview.range ExportToUrl:[NSURL fileURLWithPath:self.tempVideoPath] ExistingExportSession:self.exportSession WithCompletion:nil needCrop:NO];
    }
}

- (AVAssetExportSession*)applyCropToVideoWithAsset:(AVAsset*)asset AtRect:(CGRect)cropRect OnTimeRange:(CMTimeRange)cropTimeRange ExportToUrl:(NSURL*)outputUrl ExistingExportSession:(AVAssetExportSession*)exporter WithCompletion:(void(^)(BOOL success, NSError* error, NSURL* videoUrl))completion needCrop:(BOOL)needOrNot
{
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager]  removeItemAtURL:outputUrl error:nil];
    
    if (needOrNot){
        //create an avassetrack with our asset
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        //create a video composition and preset some settings
        AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        CGFloat cropOffX = cropRect.origin.x;
        CGFloat cropOffY = cropRect.origin.y;
        CGFloat cropWidth = cropRect.size.width;
        CGFloat cropHeight = cropRect.size.height;
        
        videoComposition.renderSize = CGSizeMake(cropWidth, cropHeight);
        
        //create a video instruction
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = cropTimeRange;
        
        AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
        
        UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
        
        CGAffineTransform t1 = CGAffineTransformIdentity;
        CGAffineTransform t2 = CGAffineTransformIdentity;
        
        switch (videoOrientation) {
    /*        case UIImageOrientationUp:
                t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height - cropOffX, 0 - cropOffY );
                t2 = CGAffineTransformRotate(t1, M_PI_2 );
                break;
            case UIImageOrientationDown:
                t1 = CGAffineTransformMakeTranslation(0 - cropOffX, clipVideoTrack.naturalSize.width - cropOffY ); // not fixed width is the real height in upside down
                t2 = CGAffineTransformRotate(t1, - M_PI_2 );
                break;
     */
            case UIImageOrientationRight:
                t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
                t2 = CGAffineTransformRotate(t1, 0 );
                break;
            case UIImageOrientationLeft:
                t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.width - cropOffX, clipVideoTrack.naturalSize.height - cropOffY );
                t2 = CGAffineTransformRotate(t1, M_PI  );
                break;
            default:
                NSLog(@"no need to crop");
                break;
        }
        
        CGAffineTransform finalTransform = t2;
        [transformer setTransform:finalTransform atTime:kCMTimeZero];
        
        //add the transformer layer instructions, then add to video composition
        instruction.layerInstructions = [NSArray arrayWithObject:transformer];
        videoComposition.instructions = [NSArray arrayWithObject: instruction];

        // assign all instruction for the video processing (in this case the transformation for cropping the video
        exporter.videoComposition = videoComposition;
    }
    
    self.exportSession.timeRange = self.playerview.range;

    if (outputUrl){
        exporter.outputURL = outputUrl;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exporter status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"crop Export failed: %@", [[exporter error] localizedDescription]);
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,[exporter error],nil);
                        });
                        return;
                    }
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"crop Export canceled");
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO,nil,nil);
                        });
                        return;
                    }
                    break;
                default:
                    NSLog(@"seccessfully complete");
                    break;
            }
            
            if (completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES,nil,outputUrl);
                });
            }
            
        }];
    }
    
    return exporter;
}

- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}

@end
