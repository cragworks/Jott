//
//  MFSettingsViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/22/14.
//
//

#import <UIKit/UIKit.h>
#import "MFKeychainWrapper.h"
#import "MFSetPasswordViewController.h"
#import "MFSetUsernameViewController.h"

@class MFSetUsernameViewController;
@class MFSetPasswordViewController;
@class MFKeychainWrapper;

@interface MFSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    UITableView *tableView;
    MFSetPasswordViewController *textFieldController;
    MFKeychainWrapper *passwordItem;
    MFKeychainWrapper *accountNumberItem;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) MFSetPasswordViewController *setPasswordViewController;
@property (nonatomic, retain) MFSetUsernameViewController *setUsernameViewController;
@property (nonatomic, retain) MFKeychainWrapper *passwordItem;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, assign) BOOL firstTime;

+ (NSString *)titleForSection:(NSInteger)section;
+ (id)secAttrForSection:(NSInteger)section;

@end
