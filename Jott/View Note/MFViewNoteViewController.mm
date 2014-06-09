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
    dispatch_queue_t cameraQueue;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UIImage *background = [[UIImage imageNamed:@"bg6.jpg"] applyLightEffect];
    background = [UIImage imageWithCGImage:[background CGImage]
                                         scale:(background.scale * 1.0)
                                   orientation:(background.imageOrientation)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    
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
    
    back = [[UIBarButtonItem alloc]initWithTitle: @"Done" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    edit = [[UIBarButtonItem alloc]initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTitle)];
    
    //self.navigationItem.title = presentingViewController.currentNote.title;
    
    _titleView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
    _titleView.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:0.1];//[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
//    _titleView.layer.cornerRadius = 5.0;
//    _titleView.layer.borderWidth = 1.0;
    _titleView.userInteractionEnabled = NO;
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26.0];
    _titleView.text = presentingViewController.currentNote.title;
    
    _noteView = [[UITextView alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 350)];
    _noteView.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:0.1];//[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
//    _noteView.layer.cornerRadius = 5.0;
//    _noteView.layer.borderWidth = 1.0;
    _noteView.editable = NO;
    //    _noteView.userInteractionEnabled = NO;
    _noteView.text = presentingViewController.currentNote.text;
    _noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    _noteView.alwaysBounceVertical = YES;
    
    timedDecryptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timedDecryptButton.frame = CGRectMake(self.view.frame.size.width - 30, self.view.frame.size.height - 3, 28, 28);
    UIImage *timerImage = [UIImage imageNamed:@"stopwatch-32.png"];
    [timedDecryptButton setImage:timerImage forState:UIControlStateNormal];
    [timedDecryptButton addTarget:self action:@selector(timerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.rightBarButtonItem = edit;
    [self.view addSubview:_titleView];
    [self.view addSubview:_noteView];
    [self.view addSubview:timedDecryptButton];
    
    NSTimer *encryptionCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25
                                                                     target: self
                                                                   selector:@selector(checkIfEncrypted:)
                                                                   userInfo: nil repeats:YES];
    [self checkIfEncrypted:encryptionCheckTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    isEncrypted = YES;
    shouldBeEncrypted = YES;
    usingVision = YES;
    
}


#pragma mark - Timed Decryption

- (void)timerButtonTapped {
    NSTimer *decryptTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timedDecrypt:) userInfo:nil repeats:YES];
    if (usingVision) {
        totalSeconds = 10;
        [timedDecryptButton setImage:[UIImage imageNamed:@"close-32.png"] forState:UIControlStateNormal];
        [self stopCamera];
        [self.imageView setHidden:YES];
        usingVision = NO;
        [self timedDecrypt:decryptTimer];
    }
    else {
        [self startCamera];
        [self encryptText];
        [self.imageView setHidden:NO];
        //usingVision = YES;
        [timedDecryptButton setImage:[UIImage imageNamed:@"stopwatch-32.png"] forState:UIControlStateNormal];
    }
}

- (void)timedDecrypt:(NSTimer *)timer {
    NSLog(@"%d",totalSeconds);
    if (!totalSeconds) {
        [self changeTextEncryption];
        [self timerButtonTapped];
        [timer invalidate];
        return;
    }
    totalSeconds--;
}

- (void)checkIfEncrypted:(NSTimer *)timer {
    if (!shouldBeEncrypted) {
        [self decryptText];
    }
    else {
        [self encryptText];
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
    }
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
    [self encryptText];
    presentingViewController.currentNote.isEncrypted = YES;
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
            [self startCamera];
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
            //[self save];
        }
    }
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
    
    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    shouldBeEncrypted = YES;
    [self encryptText];
    [presentingViewController dismissPresentedViewController];
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
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 142, 75, 75)];

    [self.imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCameraClicked)];
    [self.imageView addGestureRecognizer:singleTap];
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.opacity = 0.65;
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = CAPTURE_FPS;
    self.videoCamera.grayscaleMode = NO;
    
    [self.view addSubview:self.imageView];
    [self.view bringSubviewToFront:self.imageView];
}

- (void)processImage:(cv::Mat&)image
{
    // Only process every CAPTURE_FPS'th frame (every 1s)
    if (self.frameNum == CAPTURE_FPS) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 0;
    }
    
    self.frameNum++;
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    
    // Too many faces found
    if (faces.size() > 1) {
        NSLog(@"A Spy!");
    }
    else if (faces.size() < 1) { // No faces found
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
            NSLog(@"Confidence = %f  -  Threshold = %ld",confidence,(long)confidenceThreshhold);
            
            if (confidence  < confidenceThreshhold || (confidence - confidenceThreshhold) < 3) {
                shouldBeEncrypted = NO;
                
                _numPics++;
                _totalConfidence += confidence;
                _averageConfidence = _totalConfidence/_numPics;
                
//                NSLog(@"Average = %f",_averageConfidence);
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

- (void)switchCameraClicked {
    [self stopCamera];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self startCamera];
}

- (void)adjustThreshold {
    if (abs(confidenceThreshhold - _averageConfidence) > 10) {
        _averageConfidence += 5;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(NSUInteger)_averageConfidence forKey:@"sensitivity"];
        NSLog(@"1: Reset Threshold to: %d",(NSUInteger)_averageConfidence);
    }
    else if ((confidenceThreshhold - _averageConfidence) > 5) {
        confidenceThreshhold += 5;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(NSUInteger)confidenceThreshhold forKey:@"sensitivity"];
        NSLog(@"2: Reset Threshold to: %d",(NSUInteger)confidenceThreshhold);
    }
    else if (confidenceThreshhold < _averageConfidence) {
        confidenceThreshhold = _averageConfidence + 5;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:(NSUInteger)confidenceThreshhold forKey:@"sensitivity"];
        NSLog(@"3: Reset Threshold to: %d",(NSUInteger)confidenceThreshhold);

    }
}

- (void)startCamera {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoCamera start];
        });
    });
}

- (void)stopCamera {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoCamera stop];
        });
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // Your server calls
    NSLog(@"applicationDidEnterBackground - start");
    [self stopCamera];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    // Your server calls
    NSLog(@"applicationDidBecomeActive - start");
    [self startCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_numPics) [self adjustThreshold];
    [self.videoCamera stop];
}

@end
