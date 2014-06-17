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
#import "MFAppDelegate.h"
#import "NSString+AESCrypt.h"
#import "MFKeychainWrapper.h"
#import "MFAppDelegate.h"
#import "OpenCVData.h"
#import "SWRevealViewController.h"
#import "UIImage+ImageEffects.h"
#import "MFCamera.h"
#import "UIView+Glow.h"
#import "JCRBlurView.h"

#define CAPTURE_FPS 30
#define CONFIDENCE_THRESHHOLD 65

@interface MFViewNoteViewController () {

    BOOL isBeingEdited;
    BOOL hold;
    BOOL lock;
    BOOL paused;
    
    UIBarButtonItem *edit;
    UIBarButtonItem *save;
    UIButton *cryptButton;
    UIAlertView *enterPasswordAlert;
    UIAlertView *wrongPasswordAlert;
    UIButton *timedDecryptButton;
    NSTimer *encryptionCheckTimer;
    MFAppDelegate *appDelegate;
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
    [self setupFunctionality];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_camera unpause];
}

- (void)setupView {
    UIImage *background = [UIImage imageNamed:@"paper2.png"];
    background = [UIImage imageWithCGImage:[background CGImage]
                                     scale:(background.scale * 2.0)
                               orientation:(background.imageOrientation)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];

    _lockButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_lockButton setImage:[UIImage imageNamed:@"lock-50.png"] forState:UIControlStateNormal];
    _lockButton.backgroundColor = [UIColor clearColor];
    _lockButton.tintColor = [UIColor colorWithRed:56.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
    _lockButton.frame = CGRectMake(10, 455, 35, 35);
    [_lockButton addTarget:self action:@selector(lockButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _holdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_holdButton setImage:[UIImage imageNamed:@"hand-50.png"] forState:UIControlStateNormal];
    _holdButton.frame = CGRectMake(270, 455, 35, 35);
    _holdButton.tintColor = [UIColor colorWithRed:56.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
    [_holdButton addTarget:self action:@selector(holdButtonPressed) forControlEvents:UIControlEventTouchDown];
    [_holdButton addTarget:self action:@selector(holdButtonReleased) forControlEvents:UIControlEventTouchUpInside];
    [self activateHoldButton:NO];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButton.frame = CGRectMake(10, 5, 40, 50);
    [editButton addTarget:self action:@selector(editText) forControlEvents:UIControlEventTouchUpInside];
    editButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    edit = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(5, 5, 40, 50);
    [saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    save = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    UIImage *lineImage = [UIImage imageNamed:@"line.png"];
    UIImageView *line = [[UIImageView alloc] initWithImage:lineImage];
    line.frame = CGRectMake(self.view.frame.size.width/2 - 135, 50, 275, 1);
    
    _titleView = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 35)];
    _titleView.backgroundColor = [UIColor clearColor];
    _titleView.userInteractionEnabled = NO;
    _titleView.delegate = self;
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    _titleView.text = _currentNote.title;
    
    _noteView = [[UITextView alloc] initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 20, 360)];
    _noteView.backgroundColor = [UIColor clearColor];
    _noteView.editable = NO;
    _noteView.delegate = self;
    _noteView.text = _currentNote.text;
    _noteView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    _noteView.alwaysBounceVertical = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _redGlow = [[UIView alloc] initWithFrame:CGRectMake(160-(75/2), 421, 75, 75)];
    _redGlow.backgroundColor = [UIColor grayColor];
    _redGlow.layer.cornerRadius = 5.0;
    [self.view addSubview:_redGlow];
    _redGlow.hidden = YES;
    _greenGlow = [[UIView alloc] initWithFrame:CGRectMake(160-(75/2), 421, 75, 75)];
    _greenGlow.backgroundColor = [UIColor grayColor];
    _greenGlow.layer.cornerRadius = 5.0;
    [self.view addSubview:_greenGlow];
    _greenGlow.hidden = YES;
    
    JCRBlurView *bottomBar = [[JCRBlurView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 160, self.view.frame.size.width, 160)];
    
    self.navigationItem.rightBarButtonItem = edit;

    [self.view addSubview:bottomBar];
    [self.view addSubview:_titleView];
    [self.view addSubview:_noteView];
    [self.view addSubview:_lockButton];
    [self.view addSubview:_holdButton];
    [self.view addSubview:line];
    [self.view addSubview:[MFCamera sharedCamera]];
}

- (void)setupFunctionality {
    
    _camera = [MFCamera sharedCamera];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHeight:) name:UIKeyboardDidShowNotification object:nil];
    
    appDelegate = (MFAppDelegate *)[UIApplication sharedApplication].delegate;
    
    enterPasswordAlert = [[UIAlertView alloc] initWithTitle:@"Enter Password"
                                                        message:@"Enter the key to decrypt text:"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Enter", nil];
    enterPasswordAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    enterPasswordAlert.tag = 0;
    
    wrongPasswordAlert = [[UIAlertView alloc]initWithTitle:@"Incorrect Password"
                                                   message:@"The password you entered is incorrect."
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Retry", nil];
    wrongPasswordAlert.tag = 1;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    encryptionCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                                     target: self
                                                                   selector:@selector(checkIfEncrypted:)
                                                                   userInfo: nil repeats:YES];
    [self checkIfEncrypted:encryptionCheckTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Encryption
- (void)checkIfEncrypted:(NSTimer *)timer {
    
    if (hold || lock) {
        [self decryptText];
    }
    else {
        if (_camera.faceRecognized) {
            
            [_redGlow stopGlowing];
            _redGlow.hidden = YES;
            _greenGlow.hidden = NO;
            [_greenGlow startGlowingWithColor:[UIColor greenColor] intensity:1.0];
            
            if (_currentNote.isEncrypted) {
                [self decryptText];
                return;
            }
        }
        
        if (!_camera.faceRecognized) {
            
            [_greenGlow stopGlowing];
            _greenGlow.hidden = YES;
            _redGlow.hidden = NO;
            [_redGlow startGlowingWithColor:[UIColor redColor] intensity:1.0];
            
            if (!_currentNote.isEncrypted) {
                [self encryptText];
                return;
            }
        }
    }
}


#pragma mark - Edit Notes
- (void)encryptText {
    if (!_currentNote.isEncrypted) {
        [self activateHoldButton:NO];
        
        _currentNote.text = [_currentNote.text AES256EncryptWithKey:appDelegate.password];
        _currentNote.isEncrypted = YES;
        _noteView.text = _currentNote.text;
        
    }
}

- (void)decryptText {
    if (_currentNote.isEncrypted) {
        [self activateHoldButton:YES];
        
        _currentNote.text = [_currentNote.text AES256DecryptWithKey:appDelegate.password];
        _currentNote.isEncrypted = NO;
        _noteView.text = _currentNote.text;
    }
}


#pragma mark - Hold
- (void)holdButtonPressed {
    hold = YES;
    [_camera pause];
    
    [_greenGlow stopGlowing];
    _greenGlow.hidden = YES;
    [_redGlow stopGlowing];
    _redGlow.hidden = YES;
}

- (void)holdButtonReleased {
    hold = NO;
    [_camera unpause];
}

- (void)activateHoldButton:(BOOL)active {
    if (!active) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _holdButton.alpha = 0.4;
                         }
                         completion:^(BOOL finished) {
                             _holdButton.userInteractionEnabled = NO;
                         }];
    }
    else {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _holdButton.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             _holdButton.userInteractionEnabled = YES;
                         }];
    }
}


#pragma mark - Lock
- (void)lockButtonTapped {
    if (lock) {
        lock = NO;
        [_lockButton setImage:[UIImage imageNamed:@"lock-50.png"] forState:UIControlStateNormal];
        [self activateHoldButton:YES];
        _holdButton.hidden = NO;
        [_camera unpause];
    }
    else {
        UIAlertView *lockAlert = [[UIAlertView alloc] init];
        lockAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        lockAlert.title = @"Enter Password";
        [lockAlert textFieldAtIndex:0].textAlignment = NSTextAlignmentCenter;
        [lockAlert textFieldAtIndex:0].placeholder = @"Password";
        lockAlert.delegate = self;
        lockAlert.tag = 3;
        [lockAlert addButtonWithTitle:@"Unlock"];
        [lockAlert show];
    }
}

- (void)lock {
    lock = YES;
    [_lockButton setImage:[UIImage imageNamed:@"unlock-50.png"] forState:UIControlStateNormal];
    
    [_camera pause];
    
    [_greenGlow stopGlowing];
    _greenGlow.hidden = YES;
    [_redGlow stopGlowing];
    _redGlow.hidden = YES;
}


#pragma mark - Edit Notes
- (void)didRecognizeTapGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (!_currentNote.isEncrypted) {
            if (CGRectContainsPoint(_titleView.frame, point)) [self edit:YES];
            else if (CGRectContainsPoint(_noteView.frame, point)) [self edit:NO];
        }
    }
}

- (void)editTitle {
    [self edit:YES];
}

- (void)editText {
    [self edit:NO];
}

- (void)edit:(BOOL)startingAtTitle {
    if (!_currentNote.isEncrypted) {
        _titleView.userInteractionEnabled = YES;
        _noteView.userInteractionEnabled = YES;
        _noteView.editable = YES;
        
        hold = YES;
        self.navigationItem.rightBarButtonItem = save;
        [_camera pause];
        [_greenGlow stopGlowing];
        [_redGlow stopGlowing];
        
        _noteView.editable = YES;
        
        if (startingAtTitle) [_titleView becomeFirstResponder];
        else [_noteView becomeFirstResponder];
    }
}


#pragma mark - Save Text
- (void)save {
    _titleView.userInteractionEnabled = NO;
    _noteView.userInteractionEnabled = NO;
    _noteView.editable = NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:appDelegate.root.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"text=%@",_currentNote.text]];
    
    MFNote *mfnote = [[appDelegate.root.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    mfnote.title = _titleView.text;
    mfnote.text = _noteView.text;
    
    [self encryptText];     //Fix later, flash of encrypted text (remove this line)
    
    NSError *error = nil;
    
    [appDelegate.root.managedObjectContext save:&error];
 
    self.navigationItem.rightBarButtonItem = edit;
    hold = NO;
    [_camera unpause];
    if (_noteView.isFirstResponder) [_noteView resignFirstResponder];
    if (_titleView.isFirstResponder) [_noteView resignFirstResponder];
}


#pragma marl - AlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 3) {
        if ([[alertView textFieldAtIndex:0].text isEqualToString:appDelegate.password]) {
            [self lock];
            _holdButton.hidden = YES;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Password"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}


#pragma mark - Manage Keyboard
- (void)keyboardWillHide:(id)sender {
    _noteView.frame = CGRectMake(10, 50, self.view.frame.size.width - 20, 350);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [_noteView becomeFirstResponder];
    return NO;
}

- (void)keyboardHeight:(NSNotification*)notification
{
    int h;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    if (keyboardFrameBeginRect.size.height > 225.0) {
        h = 223;
    }
    else if (keyboardFrameBeginRect.size.height < 225.0) {
        h = 193;
    };
    _noteView.frame = CGRectMake(10, 50, self.view.frame.size.width - 20, h);
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_camera pause];
    [encryptionCheckTimer invalidate];
    
    if (_noteView.isFirstResponder) [_noteView resignFirstResponder];
    if (_titleView.isFirstResponder) [_noteView resignFirstResponder];
    
    if (!_currentNote.isEncrypted) [self encryptText];
}

@end
