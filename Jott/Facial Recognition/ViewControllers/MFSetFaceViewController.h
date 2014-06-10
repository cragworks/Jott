//
//  MFSetFaceViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/24/14.
//
//

#import <UIKit/UIKit.h>
#import "FaceDetector.h"
#import "CustomFaceRecognizer.h"

@interface MFSetFaceViewController : UIViewController <CvVideoCameraDelegate>

@property (strong, nonatomic) UIButton *switchCameraButton;
@property (nonatomic, strong) UIImageView *previewImage;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSNumber *personID;
@property (nonatomic, strong) FaceDetector *faceDetector;
@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) int numPicsTaken;
@property (nonatomic) float totalConfidence;
@property (nonatomic, retain) UILabel *picsLabel;

- (void)switchCameraButtonClicked;

@end
