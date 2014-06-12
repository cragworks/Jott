//
//  MFFacesListTableViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 6/10/14.
//
//

#import <UIKit/UIKit.h>
#import "CustomFaceRecognizer.h"

@interface MFFacesListTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) NSMutableArray *faces;
@property (nonatomic, strong) NSDictionary *selectedFace;
@property (nonatomic, strong) UIAlertView *addFaceAlertView;
@property (nonatomic, strong) UIAlertView *deleteFaceAlertView;

- (void)removeAllFacesFromFaceRecognizer:(CustomFaceRecognizer *)faceRecognizer;

@end
