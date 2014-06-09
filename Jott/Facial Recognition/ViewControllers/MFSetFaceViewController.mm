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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instructions"
                                                    message:@"When the camera starts, move it around to show different angles of your face."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)setupCamera
{
    UIImage *switchCameraImage = [UIImage imageNamed:@"switch_camera-32.png"];
    UIBarButtonItem *switchCameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:switchCameraImage style:UIBarButtonItemStylePlain target:self action:@selector(switchCameraButtonClicked)];
    self.navigationItem.rightBarButtonItem = switchCameraBarButtonItem;
    
    self.previewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 400)];
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.previewImage];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.imageHeight = 300;
    self.videoCamera.imageWidth = 300;

    _picsLabel = [[UILabel alloc] init];
    _picsLabel.frame = CGRectMake(self.view.frame.size.width/2 - 125, 530, 250, 50);
    _picsLabel.text = @"10 more pictures remaining.";
    _picsLabel.textAlignment = NSTextAlignmentCenter;
    
    self.numPicsTaken = 0;
    self.totalConfidence = 0;
    [self.videoCamera start];
    
    [self.view addSubview:_picsLabel];
    [self.view addSubview:self.previewImage];

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
            [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
