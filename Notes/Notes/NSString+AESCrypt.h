//
//  NSString+AESCrypt.h
//  Notes
//
//  Created by Mohssen Fathi on 5/6/14.
//
//

#import <Foundation/Foundation.h>
#import "NSData+AESCrypt.h"

@interface NSString (AESCrypt)

- (NSString *)AES256EncryptWithKey:(NSString *)key;
- (NSString *)AES256DecryptWithKey:(NSString *)key;

@end