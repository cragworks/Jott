//
//  MFInfoChildViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/28/14.
//
//

#import "MFInfoChildViewController.h"

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
//    _screenNumber = [[UILabel alloc]initWithFrame:CGRectMake(120, 200, 200, 50)];
//    _screenNumber.text = [NSString stringWithFormat:@"Screen #%ld", (long)self.index];
//    self.view.backgroundColor = [UIColor clearColor];
//    
//    [self.view addSubview:_screenNumber];
}

- (void)loadBackground {
    switch (self.index) {
        case 0:
        {
            UIImage *backgroundImage = [UIImage imageNamed:@"info1.png"];
            backgroundImage = [UIImage imageWithCGImage:[backgroundImage CGImage]
                                                   scale:(backgroundImage.scale * 2.0)
                                             orientation:(backgroundImage.imageOrientation)];
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            [self.view addSubview:backgroundImageView];
            
            break;
        }
            
        default:
            break;
    }
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
