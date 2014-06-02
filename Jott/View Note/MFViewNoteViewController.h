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

@interface MFViewNoteViewController : UIViewController <UIAlertViewDelegate,CvVideoCameraDelegate>

@property (nonatomic, strong) UITextField *titleView;
@property (nonatomic, strong) UITextView *noteView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UILabel *confidenceLabel;
@property (nonatomic, strong) FaceDetector *faceDetector;
@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) BOOL modelAvailable;

- (void)changeTextEncryption;

@end
