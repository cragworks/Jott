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

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHeight:) name:UIKeyboardDidShowNotification object:nil];

    UIImage *background = [UIImage imageNamed:@"paper2.png"];
    background = [UIImage imageWithCGImage:[background CGImage]
                                     scale:(background.scale * 2.0)
                               orientation:(background.imageOrientation)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    
    UIImage *lineImage = [UIImage imageNamed:@"line.png"];
    UIImageView *line = [[UIImageView alloc] initWithImage:lineImage];
    line.frame = CGRectMake(self.view.frame.size.width/2 - 135, 50, 270, 1);
    
    MFAppDelegate *appDelegate = (MFAppDelegate *)[[UIApplication sharedApplication] delegate];
    password = appDelegate.password;
    presentingViewController = appDelegate.root;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:appDelegate.root.background];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithTitle: @"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    
    titleView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 35)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.placeholder = @"Title";
    titleView.delegate = self;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26.0];
    [titleView becomeFirstResponder];
    
    noteView = [[UITextView alloc] initWithFrame:CGRectMake(10, 55, self.view.frame.size.width - 20, 363)];
    noteView.backgroundColor = [UIColor clearColor];
    noteView.delegate = self;
    noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    
    self.navigationItem.rightBarButtonItem = done;
    [self.view addSubview:titleView];
    [self.view addSubview:noteView];
    [self.view addSubview:line];
}


#pragma mark - Manage Keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [noteView becomeFirstResponder];
    return NO;
}

- (void)keyboardHeight:(NSNotification*)notification
{
    int h;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    if (keyboardFrameBeginRect.size.height > 225.0) {
        if(IS_IPHONE_5) h = self.view.frame.size.height*0.4; //223;
        else h = self.view.frame.size.height*0.37;
    }
    else if (keyboardFrameBeginRect.size.height < 225.0) {
        if(IS_IPHONE_5) h = self.view.frame.size.height*0.35; //193;
        else h = self.view.frame.size.height*0.35;
    };
    noteView.frame = CGRectMake(10, 50, self.view.frame.size.width - 20, h);
}

- (void)done {
    if (noteView.isFirstResponder) [noteView resignFirstResponder];
    if (titleView.isFirstResponder) [titleView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveNote {
    MFNote *mfnote = [NSEntityDescription insertNewObjectForEntityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext];
    
    if ([titleView.text isEqualToString:@""]) {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"MMM dd, yyyy - hh:mm a"];
        NSString *dateString = [dateFormat stringFromDate:date];
        mfnote.title = dateString;
    }
    else mfnote.title = titleView.text;
    mfnote.text = [self encryptText:noteView.text];
    mfnote.isEncrypted = YES;

    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    [[MFNotesModel sharedModel] addNote:mfnote];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    if (![noteView.text isEqualToString:@""] || ![titleView.text isEqualToString:@""]) {
        [self saveNote];
    }
}


@end
