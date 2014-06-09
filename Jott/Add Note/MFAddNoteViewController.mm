//
//  MFAddNoteViewController.m
//  Jott
//
//  Created by Mohssen Fathi on 5/18/14.
//
//

#import "MFAddNoteViewController.h"
#import "MFViewController.h"
#import "MFNotesModel.h"
#import "MFNote.h"
#import "NSString+AESCrypt.h"
#import "NSData+AESCrypt.h"
#import "MFAppDelegate.h"
#import "UIImage+ImageEffects.h"

@interface MFAddNoteViewController ()

@end

@implementation MFAddNoteViewController {
    UITextField *titleView;
    UITextView *noteView;
    NSString *password;
    MFViewController *presentingViewController;
}

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
    UIImage *blurBackground = [[UIImage imageNamed:@"bg1.jpg"] applyLightEffect];
    self.view.backgroundColor = [UIColor colorWithPatternImage:blurBackground];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.translucent = YES;
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    password = appDelegate.password;
    presentingViewController = appDelegate.root;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle: @"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNote)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle: @"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote)];
    
    titleView = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 50)];
    titleView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    titleView.layer.cornerRadius = 5.0;
    titleView.delegate = self;
    titleView.layer.borderWidth = 1.0;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26.0];
    [titleView becomeFirstResponder];
    
    noteView = [[UITextView alloc] initWithFrame:CGRectMake(10, 125, self.view.frame.size.width - 20, 400)];
    noteView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
    noteView.layer.cornerRadius = 5.0;
    noteView.delegate = self;
    noteView.layer.borderWidth = 1.0;
    noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    
    
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
    [self.view addSubview:titleView];
    [self.view addSubview:noteView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [noteView becomeFirstResponder];
    return NO;
}

- (void) cancelNote {
    [presentingViewController dismissPresentedViewController];
}

- (void) saveNote {
    MFNote *mfnote = [NSEntityDescription insertNewObjectForEntityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext];
    mfnote.title = titleView.text;
    mfnote.text = [self encryptText:noteView.text];
    mfnote.isEncrypted = YES;

    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    [[MFNotesModel sharedModel] addNote:mfnote];
    [presentingViewController dismissPresentedViewController];
}

- (NSString *)encryptText:(NSString *)text {
    MFAppDelegate *ad = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    MFKeychainWrapper *wrapper = ad.wrapper;
    NSString *encryptedText = [text AES256EncryptWithKey:[wrapper objectForKey:(__bridge id)(kSecValueData)]];
    
    return encryptedText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
