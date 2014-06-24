//
//  MFInfoChildViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/28/14.
//
//

#import "MFInfoChildViewController.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MFInfoChildViewController ()

@end

@implementation MFInfoChildViewController

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
    [self loadBackground];
}

- (void)loadBackground {
    
    switch (self.index) {
        case 0:
        {
            UIImage *backgroundImage;
            if (IS_IPHONE_5) backgroundImage = [UIImage imageNamed:@"IntroInfo-.png"];
            else backgroundImage = [UIImage imageNamed:@"IntroInfo.png"];
            
            self.navigationItem.title = @"Welcome to Jott!";

            
            backgroundImage = [UIImage imageWithCGImage:[backgroundImage CGImage]
                                                      scale:(backgroundImage.scale * 2.0)
                                                orientation:(backgroundImage.imageOrientation)];
            
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            [self.view addSubview:backgroundImageView];
            
            break;
        }
        case 1:
        {
            self.navigationItem.title = @"Creating a Note";
            
            UIImage *backgroundImage;
            if(IS_IPHONE_5) backgroundImage = [UIImage imageNamed:@"AddNoteInfo-.png"];
            else backgroundImage = [UIImage imageNamed:@"AddNoteInfo.png"];
            
            backgroundImage = [UIImage imageWithCGImage:[backgroundImage CGImage]
                                                  scale:(backgroundImage.scale * 2.0)
                                            orientation:(backgroundImage.imageOrientation)];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            [self.view addSubview:backgroundImageView];

            
            break;
        }
        case 2:
        {
            self.navigationItem.title = @"Viewing a Note";
            
            UIImage *backgroundImage;
            if(IS_IPHONE_5) backgroundImage = [UIImage imageNamed:@"ViewNoteInfo-.png"];
            else backgroundImage = [UIImage imageNamed:@"ViewNoteInfo.png"];
            
            backgroundImage = [UIImage imageWithCGImage:[backgroundImage CGImage]
                                                  scale:(backgroundImage.scale * 2.0)
                                            orientation:(backgroundImage.imageOrientation)];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            [self.view addSubview:backgroundImageView];
            
            break;
        }
        case 3:
        {
            self.navigationItem.title = @"Facial Recognition";

            UIImage *backgroundImage;
            if(IS_IPHONE_5) backgroundImage = [UIImage imageNamed:@"FacialRecognitionInfo-.png"];
            else backgroundImage = [UIImage imageNamed:@"FacialRecognitionInfo.png"];
            
            backgroundImage = [UIImage imageWithCGImage:[backgroundImage CGImage]
                                                  scale:(backgroundImage.scale * 2.0)
                                            orientation:(backgroundImage.imageOrientation)];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            [self.view addSubview:backgroundImageView];
            
            break;
        }
        case 4:
        {
            self.navigationItem.title = @"More Info";
            
            UIButton *websiteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            websiteButton.tintColor = [UIColor whiteColor];
            websiteButton.layer.cornerRadius = 3.0;
            websiteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
            websiteButton.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
            [websiteButton addTarget:self action:@selector(linkToWebsite) forControlEvents:UIControlEventTouchUpInside];
            [websiteButton setTitle:@"Jott" forState:UIControlStateNormal];

            UIImage *backgroundImage;
            if(IS_IPHONE_5) {
                websiteButton.frame = CGRectMake(self.view.frame.size.width/2 - 100, 300, 200, 75);
                backgroundImage = [UIImage imageNamed:@"OutroInfo-.png"];
            }
            else {
                websiteButton.frame = CGRectMake(self.view.frame.size.width/2 - 100, 225, 200, 75);
                backgroundImage = [UIImage imageNamed:@"OutroInfo.png"];
            }
            
            backgroundImage = [UIImage imageWithCGImage:[backgroundImage CGImage]
                                                  scale:(backgroundImage.scale * 2.0)
                                            orientation:(backgroundImage.imageOrientation)];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            
           
            
            
            [self.view addSubview:backgroundImageView];
            [self.view addSubview:websiteButton];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)linkToWebsite {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ios.mohssenfathi.com/jott"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
