//
//  MFViewNoteViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/21/14.
//
//

#import <UIKit/UIKit.h>
#import "MFNote.h"
#import "MFKeychainWrapper.h"
#import "CustomFaceRecognizer.h"
#import "FaceDetector.h"

@interface MFViewNoteViewController : UIViewController <UIAlertViewDelegate,CvVideoCameraDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextField *titleView;
@property (nonatomic, strong) UITextView *noteView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FaceDetector *faceDetector;
@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic, strong) UIButton *decryptButton;
@property (nonatomic) float totalConfidence;
@property (nonatomic) float averageConfidence;
@property (nonatomic) int numPics;

@property (nonatomic) BOOL modelAvailable;

- (void)changeTextEncryption;

@end
