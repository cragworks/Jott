//
//  MFViewNoteViewController.h
//  Jott
//
//  Created by Mohssen Fathi on 5/21/14.
//
//

#import <UIKit/UIKit.h>
#import "MFNote.h"

@interface MFViewNoteViewController : UIViewController // <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextField *noteField;

- (void)changeTextEncryption;

@end
