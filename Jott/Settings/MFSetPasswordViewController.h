//
//  MFSetPasswordViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/24/14.
//
//

#import <UIKit/UIKit.h>

@class MFKeychainWrapper;

@interface MFSetPasswordViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    NSString *textValue;
    NSString *editedFieldKey;
    UITextField *textControl;
    UITextField* confirmTextControl;
    MFKeychainWrapper *keychainWrapper;
    BOOL setPassword;
    BOOL setUser;
}

@property (nonatomic, retain) NSString *textValue;
@property (nonatomic, retain) NSString *editedFieldKey;
@property (nonatomic, retain) UITextField* textControl;
@property (nonatomic, retain) UITextField* confirmTextControl;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) MFKeychainWrapper *keychainWrapper;
@property (nonatomic, assign) BOOL setPassword;

- (void)cancel;
- (void)save;

@end
