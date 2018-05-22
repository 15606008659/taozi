//
//  UserTaozi.m
//

#import "UserTaozi.h"
#import "Wrapper.h"
#import "UserWrapper.h"
#import "TaoziWrapper.h"
#import "PluginHelper.h"

#define OUTPUT_LOG(...)     [PluginHelper logDebug:__VA_ARGS__]

@implementation UserTaozi

- (id)init {
    if ([super init]) {
        [TaoziWrapper purge];
        [self configDeveloperInfo:[PluginHelper getParamsInfo]];
    }
    return self;
}

- (void)configDeveloperInfo:(NSMutableDictionary *)devInfo {
    [[TaoziWrapper getInstance] initSDK:self info:devInfo];
}

- (void)login {
    OUTPUT_LOG(@"login invoked!\n");
    if (![[TaoziWrapper getInstance] isInited]) {
        [self onActionResult:ACTION_RET_INIT_FAIL msg:@"init failed"];
        return;
    }
    [[TaoziWrapper getInstance] login:self sel:@selector(onLoginResult:msg:)];
}

- (BOOL)isLogined {
    OUTPUT_LOG(@"isLogined invoked!\n");
    return [[TaoziWrapper getInstance] isLogined];
}

- (BOOL)isFunctionSupported:(NSString *)functionName {
    OUTPUT_LOG(@"isFunctionSupported invoked!");
    NSString *temp  = [functionName stringByAppendingString:@":"];
    SEL sel = NSSelectorFromString(functionName);
    SEL sel_param = NSSelectorFromString(temp);
    BOOL ret = [self respondsToSelector:sel] || [self respondsToSelector:sel_param];
    return ret;
}

- (NSString *)getUserID {
    OUTPUT_LOG(@"getUserID invoked!\n");
    return [[TaoziWrapper getInstance] userID];
}

- (NSString *)getSDKVersion {
    OUTPUT_LOG(@"getSDKVersion invoked!\n");
    return kSDKVersion;
}

- (NSString *)getPluginVersion {
    OUTPUT_LOG(@"getPluginVersion invoked!\n");
    return kPluginVersion;
}

- (NSString *)getPluginId {
    OUTPUT_LOG(@"getPluginId invoked!\n");
    return kPluginID;
}

- (void)onInitResult:(NSString *)status msg:(NSString *)message {
    OUTPUT_LOG(@"onInitResult,status:%@, message:%@\n", status, message);
    if ([status isEqualToString:@"SUCCEED"]) {
        [self onActionResult:ACTION_RET_INIT_SUCCESS msg:message];
    } else if ([status isEqualToString:@"FAIL"]){
        [self onActionResult:ACTION_RET_INIT_FAIL msg:message];
    }
}

- (void)onLoginResult:(NSString *)status msg:(NSString *)message {
    OUTPUT_LOG(@"onLoginResult,status:%@, message:%@\n",status,message);
    if ([status isEqualToString:@"SUCCEED"]) {
        [self onActionResult:ACTION_RET_LOGIN_SUCCESS msg:message];
    } else if ([status isEqualToString:@"FAIL"]){
        [self onActionResult:ACTION_RET_LOGIN_FAIL msg:message];
    } else {
        [self onActionResult:ACTION_RET_LOGIN_CANCEL msg:message];
    }
}

- (void)onActionResult:(int)status msg:(NSString *)message {
    OUTPUT_LOG(@"onActionResult,status:%@, message:%@\n",[NSNumber numberWithInt:status],message);
    [UserWrapper onActionResult:self retCode:status retMsg:message];
}

@end


