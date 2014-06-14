//
//  MFViewNoteViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/21/14.
//
//

#import "MFViewNoteViewController.h"
#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFNote.h"
#import "MFViewController.h"
#import "MFAppDelegate.h"
#import "NSString+AESCrypt.h"
#import "MFKeychainWrapper.h"
#import "MFAppDelegate.h"
#import "OpenCVData.h"
#import "SWRevealViewController.h"
#import "UIImage+ImageEffects.h"

#define CAPTURE_FPS 30
#define CONFIDENCE_THRESHHOLD 65

@interface MFViewNoteViewController () {
    BOOL shouldBeEncrypted;
    BOOL isBeingEdited;
    BOOL isEncrypted;
    BOOL usingVision;
    int totalSeconds;
    UIBarButtonItem *back;
    UIBarButtonItem *edit;
    UIButton *cryptButton;
    MFViewController *presentingViewController;
    UIAlertView *enterPasswordAlert;
    UIAlertView *wrongPasswordAlert;
    NSString *password;
    UIButton *timedDecryptButton;
    NSInteger confidenceThreshhold;
    BOOL isLockDecrypted;
    UIDeviceOrientation currentDeviceOrientation;
}
@end

@implementation MFViewNoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
    [self setupFacialRecognition];
}

- (void)initialSetup {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHeight:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    UIImage *background = [[UIImage imageNamed:@"bg6.jpg"] applyLightEffect];
    UIImage *background = [UIImage imageNamed:@"paper2.png"];
    background = [UIImage imageWithCGImage:[background CGImage]
                                         scale:(background.scale * 2.0)
                                   orientation:(background.imageOrientation)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    
    UIImage *lineImage = [UIImage imageNamed:@"line.png"];
    UIImageView *line = [[UIImageView alloc] initWithImage:lineImage];
    line.frame = CGRectMake(self.view.frame.size.width/2 - 135, 50, 270, 1);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    confidenceThreshhold = [defaults integerForKey:@"sensitivity"];
    
    MFAppDelegate *ad = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    presentingViewController = ad.root;
    MFKeychainWrapper *wrapper = ad.wrapper;
    password = [wrapper objectForKey:(__bridge id)(kSecValueData)];                   // Safe ?
    
    enterPasswordAlert = [[UIAlertView alloc] initWithTitle:@"Enter Password"
                                                        message:@"Enter the key to decrypt text:"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Enter", nil];
    enterPasswordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    enterPasswordAlert.tag = 0;
    
    wrongPasswordAlert = [[UIAlertView alloc]initWithTitle:@"Incorrect Password"
                                                   message:@"The password you entered is incorrect."
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Retry", nil];
    wrongPasswordAlert.tag = 1;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _decryptButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_decryptButton setBackgroundImage:[UIImage imageNamed:@"lock-50.png"] forState:UIControlStateNormal];
    _decryptButton.frame = CGRectMake(270, 455, 35, 35);
    [_decryptButton addTarget:self action:@selector(decryptButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    edit = [[UIBarButtonItem alloc]initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTitle)];
    
    _titleView = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width - 20, 35)];
    _titleView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    _titleView.userInteractionEnabled = NO;
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    _titleView.text = presentingViewController.currentNote.title;
    
    _noteView = [[UITextView alloc] initWithFrame:CGRectMake(10, 55, self.view.frame.size.width - 20, 363)];
    _noteView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    _noteView.editable = NO;
    _noteView.delegate = self;
    
//    if ([defaults integerForKey:@"textEncryption"] == 0) {
//        _noteView.text = presentingViewController.currentNote.text;
//    }
//    else if ([defaults integerForKey:@"textEncryption"] == 1) {
//        _noteView.text = presentingViewController.currentNote.text;   // Change later
//    }
//    else if ([defaults integerForKey:@"textEncryption"] == 2) {
//        _noteView.text = @"";
//    }
    
    _noteView.text = presentingViewController.currentNote.text;
    _noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    _noteView.alwaysBounceVertical = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    self.navigationItem.rightBarButtonItem = edit;
    
    
    [self.view addSubview:_titleView];
    [self.view addSubview:_noteView];
    [self.view addSubview:_decryptButton];
    [self.view addSubview:line];
    
    NSTimer *encryptionCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                                     target: self
                                                                   selector:@selector(checkIfEncrypted:)
                                                                   userInfo: nil repeats:YES];
    [self checkIfEncrypted:encryptionCheckTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    isLockDecrypted = NO;
    isEncrypted = YES;
    shouldBeEncrypted = YES;
    usingVision = YES;
}

#pragma mark - Timed Decryption

- (void)decryptButtonTapped {
    if (isLockDecrypted) {
        [self lockDecrypt];
    }
    else {
        UIAlertView *lockAlert = [[UIAlertView alloc] init];
        lockAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        lockAlert.title = @"Enter Password";
        [lockAlert textFieldAtIndex:0].textAlignment = NSTextAlignmentCenter;
        [lockAlert textFieldAtIndex:0].placeholder = @"Password";
        lockAlert.delegate = self;
        lockAlert.tag = 3;
        [lockAlert addButtonWithTitle:@"Unlock"];
        [lockAlert show];
    }
}

- (void)lockDecrypt {
    if (isLockDecrypted) {
        [self startCamera];
        isLockDecrypted = NO;
        [_decryptButton setBackgroundImage:[UIImage imageNamed:@"lock-50.png"] forState:UIControlStateNormal];
    }
    else {
        [self stopCamera];
        isLockDecrypted = YES;
        [_decryptButton setBackgroundImage:[UIImage imageNamed:@"unlock-50.png"] forState:UIControlStateNormal];
    }
}

- (void)timerButtonTapped {
    if (usingVision) {
        totalSeconds = 10;
        [timedDecryptButton setImage:[UIImage imageNamed:@"close-32.png"] forState:UIControlStateNormal];
        [self stopCamera];
        [self.imageView setHidden:YES];
        usingVision = NO;
    }
    else {
        [self startCamera];
        [self encryptText];
        [self.imageView setHidden:NO];
        [timedDecryptButton setImage:[UIImage imageNamed:@"stopwatch-32.png"] forState:UIControlStateNormal];
    }
}

- (void)checkIfEncrypted:(NSTimer *)timer {
    if (isLockDecrypted) {
        [self decryptText];
    }
    else {
        if (!shouldBeEncrypted) {
            [self decryptText];
        }
        else {
            [self encryptText];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 0 && buttonIndex == 1) {  // Enter button of password alert view
        if ([[alertView textFieldAtIndex:0].text isEqualToString:password]) {
            [self changeTextEncryption];
        }
        else {
            [wrongPasswordAlert show];
        }
    }
    else if (alertView.tag == 1 && buttonIndex == 1) {  // Retry button of incorrect password alert view
        [enterPasswordAlert show];
    }
    if (alertView.tag == 3) {
        MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([[alertView textFieldAtIndex:0].text isEqualToString: appDelegate.password]) {
            [self lockDecrypt];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Password"
                                                                         message:nil
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}


#pragma mark - Encrypt/Decrypt

- (void)changeTextEncryption {
    if (!isBeingEdited) {
        if (isEncrypted) {
            [cryptButton setTitle:@"Encrypt" forState:UIControlStateNormal];
            [self decryptText];
            presentingViewController.currentNote.isEncrypted = NO;
        }
        else {
            [cryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
            [self encryptText];
            presentingViewController.currentNote.isEncrypted = YES;
        }
    }
}

- (void)decryptText {
    if (isEncrypted) {
        presentingViewController.currentNote.text = [presentingViewController.currentNote.text AES256DecryptWithKey:password];
        _noteView.text = presentingViewController.currentNote.text;
        isEncrypted = NO;
    }
}

- (void)encryptText {
    if (!isEncrypted) {
        presentingViewController.currentNote.text = [presentingViewController.currentNote.text AES256EncryptWithKey:password];
        _noteView.text = presentingViewController.currentNote.text;
        isEncrypted = YES;
        isLockDecrypted = NO;
    }
}

- (NSString *)encryptText:(NSString *)text {
    MFAppDelegate *ad = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    MFKeychainWrapper *wrapper = ad.wrapper;
    NSString *encryptedText = [text AES256EncryptWithKey:[wrapper objectForKey:(__bridge id)(kSecValueData)]];
    
    return encryptedText;
}


#pragma mark - Edit Notes

- (void)didRecognizeTapGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];

    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        
        if (CGRectContainsPoint(_titleView.frame, point)) [self editTitle];
        else if (CGRectContainsPoint(_noteView.frame, point)) [self editText];
    }
}

- (void)cancel {
    shouldBeEncrypted = YES;
    isLockDecrypted = NO;
    [self encryptText];
    presentingViewController.currentNote.isEncrypted = YES;
    [_noteView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editTitle {
    [self editStartingAtTitle:YES];
}

- (void)editText {
    [self editStartingAtTitle:NO];
}

- (void)editStartingAtTitle: (BOOL)startAtTitle {
    
    if (!isEncrypted) {
        if(isBeingEdited) {
            if (!isLockDecrypted) [self startCamera];
            edit.title = @"Edit";
            back.title = @"Done";
            _titleView.userInteractionEnabled = NO;
            _noteView.editable = NO;
            [_noteView resignFirstResponder];
            isBeingEdited = NO;
            [self save];
        }
        else {
            [self stopCamera];
            edit.title = @"Save";
            back.title = @"Cancel";
            _titleView.userInteractionEnabled = YES;
            _noteView.editable = YES;
            if (startAtTitle) [_titleView becomeFirstResponder];
            else [_noteView becomeFirstResponder];
            isBeingEdited = YES;
        }
    }
}

- (void)keyboardHeight:(NSNotification*)notification
{
    int h;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    if (keyboardFrameBeginRect.size.height > 225.0) {
        h = 223;
    }
    else if (keyboardFrameBeginRect.size.height < 225.0) {
        h = 193;
    };
    _noteView.frame = CGRectMake(10, 55, self.view.frame.size.width - 20, h);
    NSLog(@"%f", keyboardFrameBeginRect.size.height);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [_noteView becomeFirstResponder];
    return NO;
}

- (void)keyboardWillHide:(id)sender {
    _noteView.frame = CGRectMake(10, 70, self.view.frame.size.width - 20, 350);
}

- (void)save {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"text=%@",presentingViewController.currentNote.text]];
    
    MFNote *mfnote = [[presentingViewController.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    mfnote.title = _titleView.text;
    mfnote.text = _noteView.text;
    
    if (!isLockDecrypted) [self encryptText];
    
    NSError *error = nil;
    
    [presentingViewController.managedObjectContext save:&error];
    shouldBeEncrypted = YES;
}

#pragma mark - Facial Recognition

- (void)setupFacialRecognition {
    _frameNum = 0;
    _totalConfidence = 0.0;
    
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] initWithLBPHFaceRecognizer];
    [self setupCamera];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.modelAvailable = [self.faceRecognizer trainModel];
        });
    });
    
    [self startCamera];
}

- (void)setupCamera
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(deviceOrientationDidChange:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, self.view.frame.size.height - 147, 75, 75)];
    
    [self.imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCameraTapped)];
    [self.imageView addGestureRecognizer:singleTap];
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.opacity = 0.8;
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
   
    //[self updateCameraOrientation];
    

    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = CAPTURE_FPS;
    self.videoCamera.grayscaleMode = NO;
    
    [self.view addSubview:self.imageView];
}


//- (void)deviceOrientationDidChange:(NSNotification*)notification
//{
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    
//    switch (orientation)
//    {
//        case UIDeviceOrientationPortrait:
//        case UIDeviceOrientationPortraitUpsideDown:
//        case UIDeviceOrientationLandscapeLeft:
//        case UIDeviceOrientationLandscapeRight:
//            currentDeviceOrientation = orientation;
//            break;
//            
//        case UIDeviceOrientationFaceUp:
//        case UIDeviceOrientationFaceDown:
//        default:
//            break;
//    }
//    //NSLog(@"Orientation: %d", orientation);
//    
//    [self updateCameraOrientation];
//}
//
//- (void)updateCameraOrientation {
//
//    if (currentDeviceOrientation == 4) {
//        NSLog(@"LANDSCAPE RIGHT\n\n\n");
//        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, -M_PI_2);
//    }
//    if (currentDeviceOrientation == 3) {
//        NSLog(@"LANDSCAPE LEFT\n\n\n");
//        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_2);
//    }
//    
//    //    if (currentDeviceOrientation == 4) {
////        self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
////    }
////    if (currentDeviceOrientation == 3) {
////        self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
////    }
////    if (currentDeviceOrientation == 1) {
////        self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
////    }
//}

- (void)processImage:(cv::Mat&)image
{
    if (self.frameNum == CAPTURE_FPS) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 0;
    }
    self.frameNum++;
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (faces.size() < 1) { // No faces found
        [self noFaceToDisplay];
        return;
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
           // NSLog(@"Confidence = %f  -  Threshold = %ld",confidence,(long)confidenceThreshhold);
            
            if (confidence  < confidenceThreshhold || (confidence - confidenceThreshhold) < 3) {
                shouldBeEncrypted = NO;
                
                _numPics++;
                _totalConfidence += confidence;
                _averageConfidence = _totalConfidence/_numPics;
                
               // NSLog(@"Average = %f",_averageConfidence);
            }
            else {
                shouldBeEncrypted = YES;
            }
        }
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self highlightFace:[OpenCVData faceToCGRect:face] withColor:highlightColor];
    });
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
    
    [self.imageView.layer addSublayer:self.featureLayer];
    
    self.featureLayer.hidden = NO;
    self.featureLayer.borderColor = color;
    self.featureLayer.frame = faceRect;
}

- (void)switchCameraTapped {
    [self stopCamera];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        [UIView transitionWithView:self.imageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void){
                            [self.imageView removeFromSuperview];
                            [self.view addSubview:self.imageView];
                        }
                        completion:nil];
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;

        
    } else {
        [UIView transitionWithView:self.imageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^(void){
                            [self.imageView removeFromSuperview];
                            [self.view addSubview:self.imageView];
                        }
                        completion:nil];
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;

    }
    
    [self startCamera];
}

- (void)adjustThreshold {
    if (abs(confidenceThreshhold - _averageConfidence) > 10) {
        _averageConfidence += 5;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(NSUInteger)_averageConfidence forKey:@"sensitivity"];
//        NSLog(@"1: Reset Threshold to: %lu",(unsigned long)_averageConfidence);
    }
    else if ((confidenceThreshhold - _averageConfidence) > 5) {
        confidenceThreshhold += 5;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(NSUInteger)confidenceThreshhold forKey:@"sensitivity"];
//        NSLog(@"2: Reset Threshold to: %lu",(unsigned long)confidenceThreshhold);
    }
    else if (confidenceThreshhold < _averageConfidence) {
        confidenceThreshhold = _averageConfidence + 5;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(NSUInteger)confidenceThreshhold forKey:@"sensitivity"];
//        NSLog(@"3: Reset Threshold to: %lu",(unsigned long)confidenceThreshhold);

    }
}

- (void)startCamera {
    self.imageView.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoCamera start];
        });
    });
}

- (void)stopCamera {
    self.imageView.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoCamera stop];
        });
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self stopCamera];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self startCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        if (!isEncrypted) {
            if (isBeingEdited) [_noteView resignFirstResponder];
            shouldBeEncrypted = YES;
            [self encryptText];
            [self save];
            presentingViewController.currentNote.isEncrypted = YES;
        }
   // }
    
    if (_numPics) [self adjustThreshold];
    if(self.videoCamera.running) [self.videoCamera stop];
}

@end
