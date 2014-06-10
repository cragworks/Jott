//
//  MFAppDelegate.h
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import <UIKit/UIKit.h>
#import "MFKeychainWrapper.h"
#import "MFSettingsViewController.h"
#import "MFViewNoteViewController.h"
#import "MFViewController.h"
#import "SWRevealViewController.h"
#import "MFMenuViewController.h"

@class SWRevealViewController;

@interface MFAppDelegate : UIResponder <UIApplicationDelegate, SWRevealViewControllerDelegate> {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    MFKeychainWrapper *passwordItem;
    MFKeychainWrapper *accountNumberItem;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) SWRevealViewController *viewController;
@property (nonatomic, strong) MFMenuViewController *menuViewController;
@property (nonatomic, strong) MFViewController *root;

@property (nonatomic, retain) MFSettingsViewController *settingsViewController;
@property (nonatomic, retain) MFKeychainWrapper *passwordItem;
@property (nonatomic, retain) MFKeychainWrapper *accountNumberItem;
@property (nonatomic, retain) MFKeychainWrapper *wrapper;
@property (nonatomic, strong) NSString *password;

- (void) refreshPassword;
- (void)saveContext;
- (NSString *)applicationDocumentsDirectory;

@end
