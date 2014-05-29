//
//  MFViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MFNote.h"
#import "SWRevealViewController.h"

@interface MFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) MFNote *currentNote;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UITableView *tableView;

- (void)addNote;
- (void)dismissPresentedViewController;
- (void)presentSettingsViewController;
- (void)presentInfoViewController;
- (void)presentUserSettingsViewController;
- (void)changeEncryptionFromOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword;

@end
