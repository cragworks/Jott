//
//  MFAddNoteView.m
//  Jott
//
//  Created by Mohssen Fathi on 5/20/14.
//
//

#import "MFAddNoteView.h"

@implementation MFAddNoteView {
    UITextField *titleField;
    UITextField *noteField;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        _cancelButton.frame = CGRectMake(10, 25, 60, 40);
//        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//        
//        _saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        _saveButton.frame = CGRectMake(self.frame.size.width - 55, 25, 40, 40);
//        [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
        
        titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, self.frame.size.width - 20, 50)];
        titleField.delegate = self;
        titleField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
        titleField.borderStyle = UITextBorderStyleBezel;
        [titleField becomeFirstResponder];
        
        noteField = [[UITextField alloc] initWithFrame:CGRectMake(10, 125, self.frame.size.width - 20, 400)];
        noteField.delegate = self;
        noteField.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:240.0/255.0 alpha:1.0];
        noteField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        noteField.borderStyle = UITextBorderStyleBezel;
        
//        [self addSubview:_cancelButton];
//        [self addSubview:_saveButton];
        [self addSubview:titleField];
        [self addSubview:noteField];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
