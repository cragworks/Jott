//
//  MFAppDelegate.m
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import "MFAppDelegate.h"
#import "MFViewController.h"
#import "MFNote.h"
#import "MFKeychainWrapper.h"
#import "MFSettingsViewController.h"
#import "MFViewNoteViewController.h"
#import "MFMenuViewController.h"
#import "MFNote.h"
#import "MFNotesModel.h"
#import "NSString+AESCrypt.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

@implementation MFAppDelegate {
    UIView *launchAnimationView;
    UIImageView *jImageView;
}

@synthesize passwordItem, accountNumberItem, settingsViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    _wrapper = [[MFKeychainWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
	self.passwordItem = _wrapper;
    
    settingsViewController = [[MFSettingsViewController alloc] init];
    settingsViewController.passwordItem = _wrapper;
    
    [self refreshPassword];
    
    NSManagedObjectContext *context = [self managedObjectContext];

    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    _menuViewController = [[MFMenuViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _root = [[MFViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_root];
    //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundVerticalPositionAdjustment:-4 forBarMetrics:UIBarMetricsDefault];
    
    SWRevealViewController *revealViewController = [[SWRevealViewController alloc] initWithRearViewController:_menuViewController frontViewController:navController];
    revealViewController.delegate = self;

    self.viewController = revealViewController;
    self.window.rootViewController = self.viewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window.layer setCornerRadius:5.0];
    [self.window.layer setMasksToBounds:YES];
    self.window.layer.opaque = NO;
    [self.window.layer setShouldRasterize:YES];
    [self.window.layer setRasterizationScale:[UIScreen mainScreen].scale];
    
    [self.window makeKeyAndVisible];
    //UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    [self launchAnimationPortrait];
//    if (orientation == UIInterfaceOrientationPortrait) {
//        
//    }
//    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
//        [self launchAnimationLandscape];
//    }
    
    return YES;
}

- (void) refreshPassword {
    _password = [_wrapper objectForKey:(__bridge id)kSecValueData];
}

- (void)launchAnimationPortrait {
    launchAnimationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width,  self.window.frame.size.height)];
    launchAnimationView.backgroundColor = [UIColor whiteColor];
    
    jImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jImage.png"]];
    jImageView.frame = CGRectMake(222, 257, 55, 55);
    [launchAnimationView addSubview:jImageView];
    
    UIImageView *ottImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ottImage.png"]];
    ottImage.frame = CGRectMake(133, 259, 100, 50);
    [launchAnimationView addSubview:ottImage];
    ottImage.alpha = 0.0;
    
    [self runSpinAnimationOnView:jImageView duration:2.5 rotations:2.0 repeat:1.0];
    

    [UIView animateWithDuration:3.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         jImageView.frame = CGRectMake(95, 257, 55, 55);
                     }
                     completion:^(BOOL finished) {
//                         [self runSpinAnimationOnView:jImageView duration:0.5 rotations:-0.1 repeat:2.0];
                     }];
    
//    [UIView animateWithDuration:3.0
//                          delay:0.0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:-30
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                        // jImageView.transform = CGAffineTransformRotate(jImageView.transform, M_PI_2);
//                         jImageView.frame = CGRectMake(95, 257, 55, 55); //CGRectMake(95, 257, 55, 55);
//                     }
//                     completion:nil];

    
    [UIView animateWithDuration:1.0
                          delay: 2.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         ottImage.alpha = 1.0;
                     }
                     completion:nil];
    
    ottImage.alpha = 1.0;
    [self performSelector:@selector(animationDidFinish) withObject:nil afterDelay:3.0];
    [self.window addSubview:launchAnimationView];
}

/* - (void)launchAnimationLandscape {
    launchAnimationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width,  self.window.frame.size.height)];
    launchAnimationView.backgroundColor = [UIColor whiteColor];
    
    jImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jImage.png"]];
    jImageView.frame = CGRectMake(112, 77, 95, 95);
    [launchAnimationView addSubview:jImageView];
    jImageView.transform = CGAffineTransformRotate(jImageView.transform, -M_PI_2);
    
    UIImageView *ottImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ottImage.png"]];
    ottImage.frame = CGRectMake(60, 205, 200, 100);
    [launchAnimationView addSubview:ottImage];
    ottImage.transform = CGAffineTransformRotate(ottImage.transform, -M_PI_2);
    ottImage.alpha = 0.0;
    
    for(int i = 0; i < 13; i++) {
        [self rotateImage];
    }
    [UIView animateWithDuration:3.0
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:100
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         jImageView.transform = CGAffineTransformRotate(jImageView.transform, M_PI_2);
                         jImageView.frame = CGRectMake(113, 325, 95, 95);
                     }
                     completion:nil];
    
//    [UIView animateWithDuration:3.0
//                          delay: 0.0
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         //jImageView.transform = CGAffineTransformRotate(jImageView.transform, M_PI_2);
//                         jImageView.frame = CGRectMake(113, 325, 95, 95);
//                     }
//                     completion:nil];
    
    [UIView animateWithDuration:1.0
                          delay: 1.95
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         ottImage.alpha = 1.0;
                     }
                     completion:nil];
 
    ottImage.alpha = 1.0;
    [self performSelector:@selector(animationDidFinish) withObject:nil afterDelay:3.0];
    [self.window addSubview:launchAnimationView];
} */

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidFinish {
    [UIView animateWithDuration:0.25
                          delay: 0.75
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         launchAnimationView.alpha = 0.0;
                     }
                     completion: ^(BOOL finished){
                         [launchAnimationView removeFromSuperview];
                     }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void) encryptCurrentNote {
    if (!_root.currentNote.isEncrypted) {
        _root.currentNote.text = [_root.currentNote.text AES256EncryptWithKey:_password];
    
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:[self managedObjectContext]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"text=%@",_root.currentNote.text]];
        
        MFNote *mfnote = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] lastObject];
        mfnote.text = _root.currentNote.text;
        _root.currentNote.isEncrypted = YES;
    }
}

- (void) encryptAllNotes {
    for (MFNote *note in [[MFNotesModel sharedModel] notesList]) {
        if (!note.isEncrypted) {
            note.text = [note.text AES256EncryptWithKey:_password];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"MFNote" inManagedObjectContext:[self managedObjectContext]]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"text=%@",note.text]];
            
            MFNote *mfnote = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] lastObject];
            mfnote.text = note.text;
            note.isEncrypted = YES;
        }
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext1 = self.managedObjectContext;
    if (managedObjectContext1 != nil) {
        if ([managedObjectContext1 hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Jott.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



@end
