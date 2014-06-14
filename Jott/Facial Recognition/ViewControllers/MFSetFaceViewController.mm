//
//  MFSetFaceViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/24/14.
//
//

#import "MFSetFaceViewController.h"
#import "OpenCVData.h"

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
    [self initialSetup];
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
    [self setupCamera];
    
//    _nameInput = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 150, 10, 300, 40)];
//    _nameInput.placeholder = @"ex. Glasses, Dark, ...";
//    _nameInput.textAlignment = NSTextAlignmentCenter;
//    _nameInput.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:0.1];
//    _nameInput.delegate = self;
    
    _picsLabel = [[UILabel alloc] init];
    _picsLabel.frame = CGRectMake(0, 441, self.view.frame.size.width, 50);
    _picsLabel.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    _picsLabel.textColor = [UIColor whiteColor];
    _picsLabel.text = @"10 more pictures remaining.";
    _picsLabel.textAlignment = NSTextAlignmentCenter;
    _picsLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:18.0];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
                                                    message:@"When the camera starts, move it around to show different angles of your face."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.view addSubview:_picsLabel];
//    [self.view addSubview:_nameInput];

}

- (void)setupCamera
{
    
    UIImage *switchCameraImage = [UIImage imageNamed:@"switch_camera-32.png"];
    UIBarButtonItem *switchCameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:switchCameraImage style:UIBarButtonItemStylePlain target:self action:@selector(switchCameraButtonClicked)];
    self.navigationItem.rightBarButtonItem = switchCameraBarButtonItem;
    
    self.previewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 415)];
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.previewImage];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.imageHeight = 430;
    self.videoCamera.imageWidth = 300;
    
    self.numPicsTaken = 0;
    self.totalConfidence = 0;
    [self.videoCamera start];
    
    [self.view addSubview:self.previewImage];
    [self.view sendSubviewToBack:self.previewImage];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        [self savePerson:[alertView textFieldAtIndex:0].text];
        [self.navigationController popViewControllerAnimated:YES];
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
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_picsLabel setText:[NSString stringWithFormat:@"%d more pictures remaining.", 10 - _numPicsTaken]];
        [self highlightFace:[OpenCVData faceToCGRect:faces[0]]];
        
        if (self.numPicsTaken == 10) {
            self.featureLayer.hidden = YES;
            [self.videoCamera stop];
            
//            UIAlertView *finishedAlert = [[UIAlertView alloc] initWithTitle:@"Finished" message:@"10 Imaged have been taken" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
            
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:100 forKey:@"sensitivity"];
    [defaults synchronize];
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

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:YES];
//    [self.videoCamera stop];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
