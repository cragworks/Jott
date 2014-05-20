//
//  MFViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import <UIKit/UIKit.h>
#import "MFMainView.h"

@interface MFViewController : UIViewController <UITableViewDelegate>

@property (nonatomic, strong) MFMainView *mainView;

- (void)addNote;
- (void)reloadTableView;
+ (MFViewController *)sharedController;

@end
