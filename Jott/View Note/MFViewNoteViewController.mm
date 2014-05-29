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
    self.view.backgroundColor = [UIColor whiteColor];
    
    back = [[UIBarButtonItem alloc]initWithTitle: @"Done" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    edit = [[UIBarButtonItem alloc]initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTitle)];
    
    _titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width - 20, 50)];
    _titleField.layer.borderWidth = 1.0;
    _titleField.userInteractionEnabled = NO;
    _titleField.text = presentingViewController.currentNote.title;
    [_titleField addTarget:self action:@selector(editTitle) forControlEvents:UIControlEventTouchUpInside];
    [_titleField becomeFirstResponder];
    
    _noteField = [[UITextField alloc] initWithFrame:CGRectMake(10, 75, self.view.frame.size.width - 20, 400)];
    _noteField.userInteractionEnabled = NO;
    _noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_noteField addTarget:self action:@selector(editText) forControlEvents:UIControlEventTouchUpInside];
    _noteField.text = presentingViewController.currentNote.text;
    
    timedDecryptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timedDecryptButton.frame = CGRectMake(self.view.frame.size.width - 40, self.view.frame.size.height - 103, 30, 30);
    UIImage *timerImage = [UIImage imageNamed:@"stopwatch-32.png"];
    [timedDecryptButton setImage:timerImage forState:UIControlStateNormal];
    [timedDecryptButton addTarget:self action:@selector(timerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.rightBarButtonItem = edit;
    //self.navigationItem.titleView = cryptView;
    [self.view addSubview:_titleField];
    [self.view addSubview:_noteField];
    [self.view addSubview:timedDecryptButton];
    
    NSTimer *encryptionCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25
                                                                     target: self
                                                                   selector:@selector(checkIfEncrypted:)
                                                                   userInfo: nil repeats:YES];
    [self checkIfEncrypted:encryptionCheckTimer];
    
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
        [self.videoCamera stop];
        [self.imageView setHidden:YES];
        usingVision = NO;
        [self timedDecrypt:decryptTimer];
    }
    else {
        [self encryptText];
        [self.videoCamera start];
        [self.imageView setHidden:NO];

        usingVision = YES;
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
        presentingViewController.currentNote.title = [presentingViewController.currentNote.title AES256DecryptWithKey:password];
        presentingViewController.currentNote.text = [presentingViewController.currentNote.text AES256DecryptWithKey:password];
        _titleField.text = presentingViewController.currentNote.title;
        _noteField.text = presentingViewController.currentNote.text;
        isEncrypted = NO;
    }
}

- (void)encryptText {
    if (!isEncrypted) {
        presentingViewController.currentNote.title = [presentingViewController.currentNote.title AES256EncryptWithKey:password];
        presentingViewController.currentNote.text = [presentingViewController.currentNote.text AES256EncryptWithKey:password];
        _titleField.text = presentingViewController.currentNote.title;
        _noteField.text = presentingViewController.currentNote.text;
        isEncrypted = YES;
    }
}


#pragma mark - Edit Notes

- (void)cancel {
    shouldBeEncrypted = YES;
    [self encryptText];
    presentingViewController.currentNote.isEncrypted = YES;
    [presentingViewController dismissPresentedViewController];
}

- (void)editTitle {
    [self editStartingAtTitle:YES];
}

- (void)editText {
    [self editStartingAtTitle:NO];
}

- (void)editStartingAtTitle: (BOOL)startAtTitle {
    if (!isEncrypted) {
        if (isBeingEdited) {
            [self.videoCamera start];
            edit.title = @"Edit";
            back.title = @"Done";
            _titleField.userInteractionEnabled = NO;
            _noteField.userInteractionEnabled = NO;
            isBeingEdited = NO;
            [self save];
        }
        else {
            [self.videoCamera stop];
            edit.title = @"Save";
            back.title = @"Cancel";
            _titleField.userInteractionEnabled = YES;
            _noteField.userInteractionEnabled = YES;
            if (startAtTitle) [_titleField becomeFirstResponder];
            else [_noteField becomeFirstResponder];
            isBeingEdited = YES;
        }
    }
}

- (void)save {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"text=%@",presentingViewController.currentNote.text]];

    MFNote *mfnote = [[presentingViewController.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    mfnote.title = _titleField.text;
    mfnote.text = _noteField.text;
    
    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    shouldBeEncrypted = YES;
    [self encryptText];
    [presentingViewController dismissPresentedViewController];
}


#pragma mark - Facial Recognition

- (void)setupFacialRecognition {
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] initWithLBPHFaceRecognizer];
    [self setupCamera];
    
    self.modelAvailable = [self.faceRecognizer trainModel];
    
    if (!self.modelAvailable) {
        self.instructionLabel.text = @"Add people in the database first";
    }
    
    [self.videoCamera start];
}

- (void)setupCamera
{
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height - 143, 75, 75)];
    
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
    NSString *confidence = @"";
    
    if (self.modelAvailable) {
        NSDictionary *match = [self.faceRecognizer recognizeFace:face inImage:image];
        
        if ([match objectForKey:@"personID"] != [NSNumber numberWithInt:-1]) {
            message = [match objectForKey:@"personName"];
            highlightColor = [[UIColor greenColor] CGColor];
            
            NSNumberFormatter *confidenceFormatter = [[NSNumberFormatter alloc] init];
            [confidenceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            confidenceFormatter.maximumFractionDigits = 2;
            
            confidence = [NSString stringWithFormat:@"Confidence: %@",
                          [confidenceFormatter stringFromNumber:[match objectForKey:@"confidence"]]];
            if ([confidence doubleValue] < CONFIDENCE_THRESHHOLD) {
                shouldBeEncrypted = NO;
            }
            else {
                shouldBeEncrypted = YES;
            }
        }
        
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.instructionLabel.text = message;
        self.confidenceLabel.text = confidence;
        [self highlightFace:[OpenCVData faceToCGRect:face] withColor:highlightColor];
    });
}

- (void)noFaceToDisplay
{
    shouldBeEncrypted = YES;
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.instructionLabel.text = @"No face in image";
        self.confidenceLabel.text = @"";
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
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self.videoCamera start];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.videoCamera stop];
}

@end
