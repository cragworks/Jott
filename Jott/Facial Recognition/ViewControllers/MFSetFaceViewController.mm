//
//  MFSetFaceViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/24/14.
//
//

#import "MFSetFaceViewController.h"
#import "OpenCVData.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MFCamera.h"
#import "MFAppDelegate.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MFSetFaceViewController ()

@end

@implementation MFSetFaceViewController

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
    [[MFCamera sharedCamera].videoCamera stop];
    [self initialSetup];
}

- (void)initialSetup {

    self.view.backgroundColor = [UIColor whiteColor];
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
    [self setupCamera];
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"HasLaunchedOnce"]) {
        [self.navigationItem setHidesBackButton:YES];
        
        NSString *string = [NSString stringWithFormat:@"Welcome %@",[appDelegate.passwordItem objectForKey:(__bridge id)kSecAttrAccount]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                        message:@"The camera will now take 10 pictures of your face. Look at the camera how you normally would to view a note."
                                                       delegate:nil
                                              cancelButtonTitle:@"Start"
                                              otherButtonTitles:nil];
        alert.delegate = self;
        alert.tag = 0;
        [alert show];
    }
    
    _picsLabel = [[UILabel alloc] init];
    _picsLabel.frame = CGRectMake(0, self.view.frame.size.height - 130, self.view.frame.size.width, 50);
    _picsLabel.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    _picsLabel.textColor = [UIColor whiteColor];
    _picsLabel.text = @"10 more pictures remaining.";
    _picsLabel.textAlignment = NSTextAlignmentCenter;
    _picsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    
    [self.view addSubview:_picsLabel];

}

- (void)setupCamera
{
    
    UIImage *switchCameraImage = [UIImage imageNamed:@"switch_camera-32.png"];
    UIBarButtonItem *switchCameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:switchCameraImage style:UIBarButtonItemStylePlain target:self action:@selector(switchCameraButtonClicked)];
    self.navigationItem.rightBarButtonItem = switchCameraBarButtonItem;
    
    if (IS_IPHONE_5) self.previewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 16, self.view.frame.size.width, 407)];
    else self.previewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 18, self.view.frame.size.width, 315)];
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.previewImage];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    if (IS_IPHONE_5) self.videoCamera.imageHeight = 430;
    else self.videoCamera.imageHeight = 380;
    self.videoCamera.imageWidth = 300;
    self.numPicsTaken = 0;
    self.totalConfidence = 0;
    
    [self.view addSubview:self.previewImage];
    [self.view sendSubviewToBack:self.previewImage];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"HasLaunchedOnce"]) [self.videoCamera start];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        [self.videoCamera start];
    }
    if (alertView.tag == 1) {
        [self savePerson:[alertView textFieldAtIndex:0].text];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults boolForKey:@"HasLaunchedOnce"]) {
            [defaults setBool:YES forKey:@"HasLaunchedOnce"];
            [defaults synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.videoCamera stop];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.videoCamera start];
}

- (void)processImage:(cv::Mat&)image
{
    // Only process every 60th frame (every 2s)
    if (self.frameNum == 60) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 1;
    }
    else {
        self.frameNum++;
    }
}

- (void)savePerson:(id)sender
{
    CustomFaceRecognizer *faceRecognizer = [[CustomFaceRecognizer alloc] init];
    [faceRecognizer newPersonWithName:sender];
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (![self learnFace:faces forImage:image]) {
        return;
    };
    self.numPicsTaken++;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_picsLabel setText:[NSString stringWithFormat:@"%d more pictures remaining.", 10 - _numPicsTaken]];
        [self highlightFace:[OpenCVData faceToCGRect:faces[0]]];
        
        if (self.numPicsTaken == 10) {
            self.featureLayer.hidden = YES;
            [self.videoCamera stop];
            
            UIAlertView *finishedAlert = [[UIAlertView alloc] init];
            finishedAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            finishedAlert.title = @"Name";
            finishedAlert.message = @"Enter a name for this face";
            [finishedAlert addButtonWithTitle:@"Done"];
            [finishedAlert textFieldAtIndex:0].placeholder = @"ex. Glasses, Dark, ...";
            [finishedAlert textFieldAtIndex:0].textAlignment = NSTextAlignmentCenter;
            finishedAlert.tag = 1;
            finishedAlert.delegate = self;
            [finishedAlert show];
            
            [self learnFace:faces forImage:image];
        }
    });
}



- (bool)learnFace:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return NO;
    }
    
    cv::Rect face = faces[0]; 
    [self.faceRecognizer learnFace:face ofPersonID:[self.personID intValue] fromImage:image];
    
    return YES;
}

- (void)noFaceToDisplay
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect
{
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderColor = [[UIColor redColor] CGColor];
        self.featureLayer.borderWidth = 4.0;
        [self.previewImage.layer addSublayer:self.featureLayer];
    }
    
    self.featureLayer.hidden = NO;
    self.featureLayer.frame = faceRect;
}

- (void)switchCameraButtonClicked
{
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self.videoCamera start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.videoCamera stop];
    [[MFCamera sharedCamera] trainModel];
    [[MFCamera sharedCamera].videoCamera start];
    [[MFCamera sharedCamera] pause];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:120 forKey:@"confidenceThreshold"];
    [defaults synchronize];
    [MFCamera sharedCamera].confidenceThreshhold = 120;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
