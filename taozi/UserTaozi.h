//
//  UserTaozi.h
//

#import <Foundation/Foundation.h>
#import "InterfaceUser.h"

@interface UserTaozi : NSObject <InterfaceUser>

/**
 *  user login
 */
- (void)login;

/**
 *  get the status of login
 *
 *  @return  status of login
 */
- (BOOL)isLogined;

/**
 *  get user identifier
 *
 *  @return user identifier
 */
- (NSString *)getUserID;

/**
 *  get the version of SDK
 *
 *  @return the version of SDK
 */
- (NSString *)getSDKVersion;

/**
 *  get the version of plugin
 *
 *  @return the version of plugin
 */
- (NSString *)getPluginVersion;

/**
 *  get the identifier of plugin
 *
 *  @return the identifier of plugin
 */
- (NSString *)getPluginId;

/**
 *  whether function is supported
 *
 *  @param functionName the name of function
 *
 *  @return return If the function is supported, return true
 or if the function is  not supported, return false
 */
- (BOOL)isFunctionSupported:(NSString *)functionName;

/**
 *  init SDK
 *
 *  @param cpInfo the parameters of SDK
 */
- (void)configDeveloperInfo:(NSMutableDictionary *)cpInfo;

/********* self need *********/
/**
 *  user callback function
 *
 *  @param status  other status about the user
 *  @param message other message
 */
- (void)onActionResult:(int)status msg:(NSString*)message;

/**
 *  init callback function
 *
 *  @param status  status about the initialization
 *  @param message other message
 */
- (void)onInitResult:(NSString *)status msg:(NSString *)message;

/**
 *  login callback function
 *
 *  @param status  status about the login process
 *  @param message other message
 */
- (void)onLoginResult:(NSString *)status msg:(NSString *)message;

@end


