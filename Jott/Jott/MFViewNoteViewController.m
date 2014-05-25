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

@interface MFViewNoteViewController () {
    BOOL isBeingEdited;
    BOOL isEncrypted;
    UIBarButtonItem *back;
    UIBarButtonItem *edit;
    UIButton *cryptButton;
    MFViewController *presentingViewController;
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
}

- (void)initialSetup {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    presentingViewController = (MFViewController *)self.presentingViewController;
    isEncrypted = presentingViewController.currentNote.isEncrypted;
    
    back = [[UIBarButtonItem alloc]initWithTitle: @"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    edit = [[UIBarButtonItem alloc]initWithTitle: @"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    UIView *cryptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    cryptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cryptButton.frame = CGRectMake(0, 0, 100, 50);
    [cryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
    [cryptButton addTarget:self action:@selector(changeTextEncryption) forControlEvents:UIControlEventTouchUpInside];
    [cryptView addSubview:cryptButton];
    
    _titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 50)];
    _titleField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    _titleField.userInteractionEnabled = NO;
    _titleField.text = presentingViewController.currentNote.encryptedTitle;

    [_titleField becomeFirstResponder];
    
    _noteField = [[UITextField alloc] initWithFrame:CGRectMake(10, 125, self.view.frame.size.width - 20, 400)];
    _noteField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
    _noteField.userInteractionEnabled = NO;
    _noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _noteField.text = presentingViewController.currentNote.encryptedText;
    
    self.navigationItem.leftBarButtonItem = back;
    self.navigationItem.rightBarButtonItem = edit;
    self.navigationItem.titleView = cryptView;
    [self.view addSubview:_titleField];
    [self.view addSubview:_noteField];
}

- (void)changeTextEncryption {
    if (isEncrypted) {
        [cryptButton setTitle:@"Encrypt" forState:UIControlStateNormal];
        _titleField.text = presentingViewController.currentNote.title;
        _noteField.text = presentingViewController.currentNote.text;
        isEncrypted = NO;
        presentingViewController.currentNote.isEncrypted = NO;
    }
    else {
        [cryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
        _titleField.text = presentingViewController.currentNote.encryptedTitle;
        _noteField.text = presentingViewController.currentNote.encryptedText;
        isEncrypted = YES;
        presentingViewController.currentNote.isEncrypted = YES;
    }
}

- (void)back {
    [(MFViewController *)self.presentingViewController dismissPresentedViewController];
}

- (void)edit {
    if (isBeingEdited) {
        edit.title = @"Edit";
        _titleField.userInteractionEnabled = NO;
        _noteField.userInteractionEnabled = NO;
        isBeingEdited = NO;
       // [self save];
    }
    else {
        edit.title = @"Done";
        _titleField.userInteractionEnabled = YES;
        _noteField.userInteractionEnabled = YES;
        [_titleField becomeFirstResponder];
        isBeingEdited = YES;
        
    }
}

- (void)save {
    presentingViewController = (MFViewController *)self.presentingViewController;
    MFNote *mfnote = [NSEntityDescription insertNewObjectForEntityForName:@"MFNote" inManagedObjectContext:presentingViewController.managedObjectContext];
    mfnote.title = _titleField.text;
    mfnote.text = _noteField.text;
    NSError *error = nil;
    [presentingViewController.managedObjectContext save:&error];
    
    [[MFNotesModel sharedModel] addNote:mfnote];
    [presentingViewController dismissPresentedViewController];
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
