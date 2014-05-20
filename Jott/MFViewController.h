//
//  MFViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/16/14.
//
//

#import <UIKit/UIKit.h>

@interface MFViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UITableView *tableView;

- (void)addNote;
- (void)reloadTableView;
+ (MFViewController *)sharedController;

@end
