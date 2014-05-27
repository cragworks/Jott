//
//  MFKeychainWrapper.h
//  Jott
//
//  Created by Mohssen Fathi on 5/23/14.
//
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface MFKeychainWrapper : NSObject {
    NSMutableDictionary *keychainItemData;		// The actual keychain item data backing store.
    NSMutableDictionary *genericPasswordQuery;	// A placeholder for the generic keychain item query used to locate the item.
}

@property (nonatomic, retain) NSMutableDictionary *keychainItemData;
@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;

- (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup;
- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;
//- (NSString*)sha1:(NSString*)input;

- (void)resetKeychainItem;

@end
