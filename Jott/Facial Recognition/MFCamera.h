//
//  MFCamera.h
//  Jott
//
//  Created by Mohssen Fathi on 6/15/14.
//
//

#import <UIKit/UIKit.h>
#import "CustomFaceRecognizer.h"
#import "FaceDetector.h"

@interface MFCamera : UIView <CvVideoCameraDelegate>


@property (nonatomic, strong) FaceDetector *faceDetector;
@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) float totalConfidence;
@property (nonatomic) float averageConfidence;
@property (nonatomic) int numPics;
@property (nonatomic) BOOL modelAvailable;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, assign) NSInteger confidenceThreshhold;


@property (nonatomic, assign) BOOL faceRecognized;

- (void)refreshConfidenceThreshold;
- (void)startCamera;
- (void)stopCamera;
- (void)pause;
- (void)unpause;
- (void)trainModel;
- (void)switchCameraTapped;
+ (MFCamera *)sharedCamera;

@end
