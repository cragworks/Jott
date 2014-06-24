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
+ (MFCamera *)sharedCamera {
    if (sharedCamera == nil) {
        sharedCamera = [[super allocWithZone:NULL] init];
        sharedCamera.frame = CGRectMake(160-(75/2), [UIScreen mainScreen].bounds.size.height - 148, 75, 75);
        sharedCamera.defaults = [NSUserDefaults standardUserDefaults];
        [sharedCamera initialSetup];
    }
    return sharedCamera;
}

- (void)initialSetup {
    
    _frameNum = 0;
    _totalConfidence = 0.0;
    _confidenceThreshhold = [_defaults integerForKey:@"confidenceThreshold"];
    
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] initWithLBPHFaceRecognizer];
    
    [self trainModel];
    
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

- (void)trainModel {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.modelAvailable = [self.faceRecognizer trainModel];
        });
    });
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(_averageConfidence) {
        if (((_confidenceThreshhold-_averageConfidence) > 10) || ((_confidenceThreshhold - _averageConfidence) < 10)) {
            _confidenceThreshhold = _averageConfidence + [defaults integerForKey:@"sensitivity"];
            [defaults setInteger:_confidenceThreshhold forKey:@"confidenceThreshold"];
            [defaults synchronize];
        }
    }

//    NSLog(@"Average Confidence = %f \nThreshold = %ld \nSensitivity = %ld",_averageConfidence, (long)_confidenceThreshhold, (long)[defaults integerForKey:@"sensitivity"]);

    _totalConfidence = 0;
    _averageConfidence = 0;
    _numPics = 0;
}

#pragma mark - Video Camera Delegate Methods

- (void)processImage:(cv::Mat&)image
{
    if (self.frameNum == CAPTURE_FPS) {
        _faceRecognized = [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
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
             NSLog(@"Confidence = %f  -  Threshold = %ld",confidence,(long)_confidenceThreshhold);

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
    faceRect.origin.x *= 0.35;
    faceRect.origin.y *= 0.28;
    
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
    [self stopCamera];
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionBack) self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    else self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    [self startCamera];

    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:nil
                    completion:nil];
}

@end
