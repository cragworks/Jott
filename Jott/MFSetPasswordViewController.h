//
//  MFSetPasswordViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/24/14.
//
//

#import <UIKit/UIKit.h>

@class MFKeychainWrapper;

@interface MFSetPasswordViewController : UIViewController {
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
