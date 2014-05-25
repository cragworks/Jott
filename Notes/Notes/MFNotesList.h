//
//  MFNotesList.h
//  Notes
//
//  Created by Mohssen Fathi on 5/5/14.
//
//

#import <UIKit/UIKit.h>
#import "MFListItem.h"

@interface MFNotesList : UITableViewController

@property (nonatomic, strong) UITableView *notesList;
@property (nonatomic, strong) NSMutableArray *notes;

@end
