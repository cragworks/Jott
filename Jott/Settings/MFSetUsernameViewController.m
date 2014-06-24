//
//  MFSetUsernameViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/29/14.
//
//

#import "MFSetUsernameViewController.h"
#import "MFViewController.h"

@interface MFSetUsernameViewController () {
    UILabel *enterUserLabel;
}

@end

@implementation MFSetUsernameViewController

@synthesize textValue, editedFieldKey, textControl, keychainWrapper;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initialSetup];
    
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    
    textControl = [[UITextField alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.2, self.view.frame.size.width, 50)];
    [textControl setBackgroundColor:[UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]];
    [textControl setTextAlignment:NSTextAlignmentCenter];
    textControl.placeholder = nil;
    textControl.delegate = self;
    textControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textControl.autocorrectionType = UITextAutocorrectionTypeNo;
    textControl.secureTextEntry = NO;
    textControl.textColor = [UIColor whiteColor];
    textControl.tintColor = [UIColor whiteColor];
    [textControl setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0]];
    
    enterUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, textControl.frame.origin.y - 40, 200, 40)];
    enterUserLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0];
    [enterUserLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [enterUserLabel setText:@"Enter New Username:"];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:textControl];
    [self.view addSubview:enterUserLabel];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [textControl setFont:[UIFont boldSystemFontOfSize:16]];
}

- (void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else if (buttonIndex == 1) {
//        [textControl setText:@""];
//        [textControl becomeFirstResponder];
//    }
//}

- (void)save
{
    [keychainWrapper setObject:[textControl text] forKey:(__bridge id)kSecAttrAccount];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [textControl becomeFirstResponder];
    [textControl setText:textValue];
}

@end
