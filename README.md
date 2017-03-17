## A extend edition of [ICGVideoTrimmer](https://github.com/itsmeichigo/ICGVideoTrimmer "ICGVideoTrimmer")
### What's new?

* Add VideoPlayerView so that you can see the edit at real time!
* More comfortable with orientations! The crop mode is just like `Instagram`'s slide mode, you can pick a region of a landscape video.
* Smooth with time edit and select

some screen shots:
<h3>A landscape video may like this:
<img align="center" src="http://f8.topitme.com/8/79/40/1137883465fbb40798o.jpg" width="430" height="240" />
<h3>After being imported, you can select a vertical region like (Just slide!):</h3>
<img src="http://fe.topitme.com/e/d8/14/11378834485b214d8eo.jpg" width="240" height="430" />
<img align="right" src="http://ff.topitme.com/f/65/3e/11378834575b63e65fo.jpg" width="240" height="430" />

#### use the playerView:
```objective-C
   //with  ICGVideoTrimmerView *trimmerView
   //and ICGVideoPlayerView *playerview property
   self.playerview = [[ICGVideoPlayerView alloc] init];
   [self.playerview setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width,      self.view.frame.size.height-self.trimmerView.frame.size.height)];
   
   //after get the video
   [self.playerview setVideoAsset:self.asset];
   [self.view insertSubview:self.playerview aboveSubview:self.trimmerView];
   
   //to refresh the play period:
   - (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime{
       //blahblahblah...
       [self.playerview refreshTimePeriod:startTime end:endTime];
   }
  
  //and in the trim method:
  if (self.playerview.xrate != -1){//indicate that the video is landscape mode, need to be cropped
        [self applyCropToVideoWithAsset:self.asset AtRect:CGRectMake(naturalSize.width * self.playerview.xrate, 0,self.view.frame.size.width, self.view.frame.size.height) OnTimeRange:self.playerview.range ExportToUrl:[NSURL fileURLWithPath:self.tempVideoPath] ExistingExportSession:self.exportSession WithCompletion:nil needCrop:YES];
    } else {
        [self applyCropToVideoWithAsset:self.asset AtRect:CGRectNull OnTimeRange:self.playerview.range ExportToUrl:[NSURL fileURLWithPath:self.tempVideoPath] ExistingExportSession:self.exportSession WithCompletion:nil needCrop:NO];
    }
    
  //in the crop method:
  self.exportSession.timeRange = self.playerview.range;
```
#### To be clearer, you can see the demo project and use the ``ICGVideoPlayerView`` as it.
---
--- 
# ICGVideoTrimmer
A library for quick video trimming based on `SAVideoRangeSlider`, mimicking the behavior of Instagram's.

![Screenshot](https://raw.githubusercontent.com/itsmeichigo/ICGVideoTrimmer/master/Screenshot.png)

## Note
I've made this very quickly so here's a list of things to do for improvements (pull requests are very much appreciated!):
- ~~Make panning thumb views smoother~~
- ~~Make ruller view more customizable~~
- Bug fixes if any
- More and more, can't remember right now hahha.

## Getting started

### Manually add ICGVideoTrimmer as a library:
  Drag and drop the subfolder named `Source` in your project and you are done.

### Usage
Create an instance of `ICGVideoTrimmer` using interface builder or programmatically. Give it an asset and set the delegate. You can select theme color for the trimmer view and decide whether to show the ruler view by setting the properties. Finally, don't forget to call `resetSubviews`!
 ```objective-C
  [self.trimmerView setThemeColor:[UIColor lightGrayColor]];
  [self.trimmerView setAsset:self.asset];
  [self.trimmerView setShowsRulerView:YES];
  [self.trimmerView setDelegate:self];
  [self.trimmerView resetSubviews];
 ```
If necessary, you can also set your desired minimum and maximum length for your trimmed video by setting the properties `minLength` and `maxLength` for the trimmer view. By default, these properties are 3 and 15 (seconds) respectively.

You can also customize your thumb views by setting images for the left and right thumbs:
```objective-C
  [self.trimmerView setLeftThumbImage:[UIImage imageNamed:@"left-thumb"]];
  [self.trimmerView setRightThumbImage:[UIImage imageNamed:@"right-thumb"]];
```

## Requirements

ICGVideoTrimmer requires iOS 7 and `MobileCoreServices` and `AVFoundation` frameworks. Honestly I haven't tested it with iOS 6 and below so I can't be too sure if it's compatible.

### ARC

ICGVideoTrimmer uses ARC. If you are using ICGVideoTrimmer in a non-arc project, you
will need to set a `-fobjc-arc` compiler flag on every ICGVideoTrimmer source files. To set a
compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Then select
ICGVideoTrimmer source files, press Enter, insert -fobjc-arc and then "Done" to enable ARC
for ICGVideoTrimmer.

## Contributing

Contributions for bug fixing or improvements are welcome. Feel free to submit a pull request.
