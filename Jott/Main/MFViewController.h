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
@property (nonatomic, assign) BOOL currentlyViewingNote;
@property (nonatomic, strong) UIImage *background;
@property (nonatomic, strong) SWRevealViewController *revealController;

- (void)dismissPresentedViewController;
- (void)presentHomeViewController;
- (void)presentSettingsViewController;
- (void)presentInfoViewController;
- (void)presentFacesListViewController;
- (void)presentUserSettingsViewController;
- (void)changeEncryptionFromOldPassword:(NSString *)oldPassword toNewPassword:(NSString *)newPassword;
- (void)deleteAllNotes;

@end
