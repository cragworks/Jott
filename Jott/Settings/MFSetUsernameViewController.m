//
//  MFSetUsernameViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/29/14.
//
//

#import "MFSetUsernameViewController.h"
#import "MFViewController.h"

@interface MFSetUsernameViewController ()

@end

@implementation MFSetUsernameViewController

@synthesize textValue, editedFieldKey, textControl, keychainWrapper;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initialSetup];
    
}

- (void)initialSetup {
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *enterUserLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 115, 200, 40)];
    [enterUserLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [enterUserLabel setText:@"Enter Username:"];
    
    textControl = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 125, 150, 250, 40)];
    [textControl setBackgroundColor:[UIColor whiteColor]];
    [textControl setBorderStyle:UITextBorderStyleLine];
    [textControl setTextAlignment:NSTextAlignmentCenter];
    textControl.placeholder = nil;
    textControl.delegate = self;
    textControl.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textControl.autocorrectionType = UITextAutocorrectionTypeNo;
    textControl.secureTextEntry = NO;
    
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
    [keychainWrapper setObject:[textControl text] forKey:editedFieldKey];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [textControl becomeFirstResponder];
    [textControl setText:textValue];
}

@end
