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
#import "MFCamera.h"

@interface MFViewNoteViewController : UIViewController <UIAlertViewDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *titleView;
@property (nonatomic, strong) UITextView *noteView;
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UIButton *holdButton;
@property (nonatomic, strong) UIView *redGlow;
@property (nonatomic, strong) UIView *greenGlow;

@property (nonatomic, strong) MFCamera *camera;
@property (nonatomic, strong) MFNote *currentNote;

@end
