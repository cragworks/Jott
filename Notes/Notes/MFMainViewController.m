//
//  MFMainViewController.m
//  Notes
//
//  Created by Mohssen Fathi on 5/6/14.
//
//

#import "MFMainViewController.h"
#import "MFNotesList.h"
#import "NSString+AESCrypt.h"
#import "NSData+AESCrypt.h"
#import "MFSettingsViewController.h"


@interface MFMainViewController ()

@property (nonatomic, assign) CGRect window;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, strong) UITextView *textView;


@end

@implementation MFMainViewController {
    NSString *encryptedText;
    NSString *decryptedText;
    UIAlertView *keyAlert;
    BOOL isEncrypted;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _window = self.view.frame;
    isEncrypted = NO;
    
    UITextField *keyInput = [[UITextField alloc] initWithFrame:CGRectMake(_window.size.width/2 - 100, 50, 200, 40)];
    keyInput.layer.borderWidth = 1.0;
    keyInput.delegate = self;
    keyInput.textAlignment = NSTextAlignmentCenter;
    keyInput.tag = 0;
    _key = keyInput.text;
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(_window.size.width*0.1, _window.size.height*0.2, _window.size.width*0.8, _window.size.height*0.6)];
    NSString *text = [[NSString alloc] initWithFormat:@"It was November. Although it was not yet late, the sky was dark when I turned into Laundress Passage. Father had finished for the day, switched off the shop lights and closed the shutters; but so I would not come home to darkness he had left on the light over the stairs to the flat. Through the glass in the door it cast a foolscap rectangle of paleness onto the wet pavement, and it was while I was standing in that rectangle, about to turn my key in the door, that I first saw the letter. Another white rectangle, it was on the fifth step from the bottom, where I couldn't miss it."];
    _textView.text = text;
    _textView.textColor = [UIColor blackColor];
    _textView.font = [UIFont fontWithName:@"Helvetica-Light" size:16.0];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    settingsButton.frame = CGRectMake(self.view.frame.size.width/2 - 50 , 475, 100, 50);
    [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    settingsButton.layer.borderWidth = 1.0;
    settingsButton.layer.cornerRadius = 10;
    [settingsButton addTarget:self action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *decryptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    decryptButton.frame = CGRectMake(self.view.frame.size.width/2 + 55, 475, 100, 50);
    [decryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
    decryptButton.layer.borderWidth = 1.0;
    decryptButton.layer.cornerRadius = 10;
    [decryptButton addTarget:self action:@selector(decryptText) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *encryptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    encryptButton.frame = CGRectMake(self.view.frame.size.width/2 - 155, 475, 100, 50);
    [encryptButton setTitle:@"Encrypt" forState:UIControlStateNormal];
    encryptButton.layer.borderWidth = 1.0;
    encryptButton.layer.cornerRadius = 10;
    [encryptButton addTarget:self action:@selector(encryptText) forControlEvents:UIControlEventTouchUpInside];
    
    decryptedText = [encryptedText AES256DecryptWithKey:_key];
    
    [self.view addSubview:keyInput];
    [self.view addSubview:_textView];
    [self.view addSubview:encryptButton];
    [self.view addSubview:decryptButton];
    [self.view addSubview:settingsButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentSettingsViewController {
    MFSettingsViewController *svc = [[MFSettingsViewController alloc] init];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)encryptText {
    if (!isEncrypted) {
        if ([_key isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Key Given"
                                                            message:@"Enter a key phrase to encrypt the message."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            encryptedText = [_textView.text AES256EncryptWithKey:_key];
            _textView.text = encryptedText;
            isEncrypted = YES;
        }
    }
}

- (void)decryptText {
    if (isEncrypted) {
        keyAlert = [[UIAlertView alloc] initWithTitle:@"Enter Key: "
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil, nil];
        keyAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        keyAlert.tag = 0;
        [keyAlert textFieldAtIndex:0].delegate = self;
        [keyAlert textFieldAtIndex:0].tag = 1;
        [keyAlert show];

    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Decrypt "
                                                        message:@"The message has not been encrypted yet."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        _key = textField.text;
    }
    else if (textField.tag == 1) {
        [keyAlert dismissWithClickedButtonIndex:-1 animated:YES];
    }
    
    [textField resignFirstResponder];
    return NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if ([[alertView textFieldAtIndex:0].text isEqualToString:_key]) {
            decryptedText = [_textView.text AES256DecryptWithKey:_key];
            _textView.text = decryptedText;
            isEncrypted = NO;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Key"
                                                            message:@"The key you entered does not match the key used to encrypt the message"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            alert.tag = 1;
            [alert show];
        }
    }
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


