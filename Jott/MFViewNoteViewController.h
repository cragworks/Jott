//
//  MFViewNoteViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/21/14.
//
//

#import <UIKit/UIKit.h>
#import "MFNote.h"
#import "MFKeychainWrapper.h"

@interface MFViewNoteViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextField *noteField;
@property (nonatomic, retain) NSString *password;

- (void)changeTextEncryption;

@end
