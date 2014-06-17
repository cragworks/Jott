//
//  MFCamera.m
//  Jott
//
//  Created by Mohssen Fathi on 6/15/14.
//
//

#import "MFCamera.h"
#import "OpenCVData.h"

#define CAPTURE_FPS 30

@implementation MFCamera {
    BOOL isBeingEdited;
    BOOL isEncrypted;
    BOOL usingVision;
    BOOL isLockDecrypted;
    BOOL paused;
    BOOL shouldBeEncrypted;
    
}

static MFCamera *sharedCamera = nil;
+ (MFCamera *)sharedCamera {   ///////////////// If problem, look here /////////////////////
    if (sharedCamera == nil) {
        sharedCamera = [[super allocWithZone:NULL] init];
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        sharedCamera.confidenceThreshhold = [defaults integerForKey:@"sensitivity"];
        
        sharedCamera.frame = CGRectMake(160-(75/2), 421, 75, 75);
        sharedCamera.defaults = [NSUserDefaults standardUserDefaults];
        [sharedCamera initialSetup];
    }
    return sharedCamera;
}

- (void)initialSetup {
    
    _frameNum = 0;
    _totalConfidence = 0.0;
    _confidenceThreshhold = [_defaults integerForKey:@"sensitivity"];
    
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] initWithLBPHFaceRecognizer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.modelAvailable = [self.faceRecognizer trainModel];
        });
    });
    
    [self startCamera];
    
    [self setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCameraTapped)];
    [self addGestureRecognizer:singleTap];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 5;
    self.layer.opacity = 1.0;//0.8;
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = CAPTURE_FPS;
    self.videoCamera.grayscaleMode = NO;
}

- (void)startCamera {
    self.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoCamera start];
        });
    });
}

- (void)stopCamera {
    self.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoCamera stop];
        });
    });
}

- (void)pause {
//    NSLog(@"Camera Paused");
    [self.videoCamera pause];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:nil];
    
    [self refreshConfidenceThreshold];
}

- (void)unpause {
//    NSLog(@"Camera Unpaused");
    [self.videoCamera unpause];

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.alpha = 1.0;
                     }
                     completion:nil];
    
}

- (void)refreshConfidenceThreshold {
//    NSLog(@"Refreshing");
    if(_averageConfidence) {
        if (abs(_confidenceThreshhold - _averageConfidence) > 10) {
            _averageConfidence += 5;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:(NSUInteger)_averageConfidence forKey:@"sensitivity"];
            //        NSLog(@"1: Reset Threshold to: %lu",(unsigned long)_averageConfidence);
        }
        else if ((_confidenceThreshhold - _averageConfidence) > 5) {
            _confidenceThreshhold += 5;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:(NSUInteger)_confidenceThreshhold forKey:@"sensitivity"];
            //        NSLog(@"2: Reset Threshold to: %lu",(unsigned long)confidenceThreshhold);
        }
        else if (_confidenceThreshhold < _averageConfidence) {
            _confidenceThreshhold = _averageConfidence + 5;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:(NSUInteger)_confidenceThreshhold forKey:@"sensitivity"];
            //        NSLog(@"3: Reset Threshold to: %lu",(unsigned long)confidenceThreshhold);
            
        }
        _confidenceThreshhold = [_defaults integerForKey:@"sensitivity"];
    }
}

#pragma mark - Video Camera Delegate Methods

- (void)processImage:(cv::Mat&)image
{
    if (self.frameNum == CAPTURE_FPS) {
        _faceRecognized = [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
//        NSLog(@"Face Recognized = %d",_faceRecognized);
        self.frameNum = 0;
    }
    self.frameNum++;
}

- (BOOL)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    BOOL recognized = NO;
    
    if (faces.size() < 1) { // No faces found
        [self noFaceToDisplay];
        return NO;
    }
    
    cv::Rect face = faces[0];
    
    CGColor *highlightColor = [[UIColor redColor] CGColor];
    NSString *message = @"No match found";
    
    if (self.modelAvailable) {
        NSDictionary *match = [self.faceRecognizer recognizeFace:face inImage:image];

        if ([match objectForKey:@"personID"] != [NSNumber numberWithInt:-1]) {
            message = [match objectForKey:@"personName"];
            highlightColor = [[UIColor greenColor] CGColor];
            
            NSNumberFormatter *confidenceFormatter = [[NSNumberFormatter alloc] init];
            [confidenceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            confidenceFormatter.maximumFractionDigits = 2;
            
            float confidence = [[match objectForKey:@"confidence"] floatValue];
//             NSLog(@"Confidence = %f  -  Threshold = %ld",confidence,(long)_confidenceThreshhold);

            
            if (confidence < _confidenceThreshhold || (confidence - _confidenceThreshhold) < 3) {
                shouldBeEncrypted = NO;
                _numPics++;
                _totalConfidence += confidence;
                _averageConfidence = _totalConfidence/_numPics;
                
                recognized = YES;
                
            }
            else {
                shouldBeEncrypted = YES;
                recognized = NO;
            }
        }
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self highlightFace:[OpenCVData faceToCGRect:face] withColor:highlightColor];
    });
    
    return recognized;
}

- (void)noFaceToDisplay
{
    shouldBeEncrypted = YES;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect withColor:(CGColor *)color
{
    
    faceRect.size.width *= 0.2;
    faceRect.size.height *= 0.2;
    faceRect.origin.x *= 0.25;
    faceRect.origin.y *= 0.25;
    
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderWidth = 2.0;
    }
    
    [self.layer addSublayer:self.featureLayer];
    
    self.featureLayer.hidden = NO;
    self.featureLayer.borderColor = color;
    self.featureLayer.frame = faceRect;
}

- (void)switchCameraTapped {
    // Temporary//
    
    if (self.alpha == 1.0)  self.alpha = 0.5;
    else self.alpha = 1.0;
    
    
//    [self stopCamera];
//    
//    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
//        [UIView transitionWithView:self.imageView
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionFlipFromLeft
//                        animations:^(void){
//                            [self.imageView removeFromSuperview];
//                            [self addSubview:self.imageView];
//                        }
//                        completion:nil];
//        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
//        
//        
//    } else {
//        [UIView transitionWithView:self.imageView
//                          duration:0.3
//                           options:UIViewAnimationOptionTransitionFlipFromRight
//                        animations:^(void){
//                            [self.imageView removeFromSuperview];
//                            [self addSubview:self.imageView];
//                        }
//                        completion:nil];
//        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
//        
//    }
//    
//    [self startCamera];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
