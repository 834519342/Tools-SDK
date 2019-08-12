

#import <Foundation/Foundation.h>

@interface TJKeychain : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (BOOL)setValue:(id)value forKey:(NSString *)key;
+ (BOOL)setValue:(id)value forKey:(NSString *)key forAccessGroup:(nullable NSString *)group;

+ (id)valueForKey:(NSString *)key;
+ (id)valueForKey:(NSString *)key forAccessGroup:(nullable NSString *)group;

+ (BOOL)deleteValueForKey:(NSString *)key;
+ (BOOL)deleteValueForKey:(NSString *)key forAccessGroup:(nullable NSString *)group;

+ (NSString *)getBundleSeedIdentifier;

@end
NS_ASSUME_NONNULL_END
