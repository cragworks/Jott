//
//  MFAddNoteView.h
//  Jott
//
//  Created by Mohssen Fathi on 5/20/14.
//
//

#import <UIKit/UIKit.h>

@interface MFAddNoteView : UIView <UITextFieldDelegate>

@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, weak) UIButton *saveButton;

@end
