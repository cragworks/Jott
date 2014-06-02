//
//  MFSetUsernameViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/29/14.
//
//

#import <UIKit/UIKit.h>
#import "MFKeychainWrapper.h"

@interface MFSetUsernameViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    NSString *textValue;
    NSString *editedFieldKey;
    UITextField *textControl;
    MFKeychainWrapper *keychainWrapper;
}

@property (nonatomic, retain) NSString *textValue;
@property (nonatomic, retain) NSString *editedFieldKey;
@property (nonatomic, retain) UITextField* textControl;
@property (nonatomic, retain) MFKeychainWrapper *keychainWrapper;

- (void)cancel;
- (void)save;

@end
