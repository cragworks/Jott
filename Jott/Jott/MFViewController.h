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

@interface MFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) MFNote *currentNote;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UITableView *tableView;

- (void)addNote;
- (void)dismissPresentedViewController;

@end
