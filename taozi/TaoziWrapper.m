//
//  TaoziWrapper.m
//

#import "TaoziWrapper.h"

#import "UserWrapper.h"
#import "IAPWrapper.h"
#import "UserTaozi.h"
#import "IAPOnlineTaozi.h"
#import "InterfaceUser.h"
#import "InterfaceIAP.h"
#import "PluginHelper.h"

#define OUTPUT_LOG(...)     [PluginHelper logDebug:__VA_ARGS__]

@interface TaoziWrapper ()

@property (assign, nonatomic) id initTarget;
@property (assign, nonatomic) id loginTarget;
@property (assign, nonatomic) SEL loginSEL;
@property (assign, nonatomic) id userTarget;
@property (assign, nonatomic) id payTarget;

@property (nonatomic, assign) UInt32 gameID;
@property (nonatomic, copy) NSString *gameKey;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *uid;

@end

@implementation TaoziWrapper

+ (TaoziWrapper *)getInstance {
    static TaoziWrapper *instance = nil;
    
    if (!instance) {
        instance = [[TaoziWrapper alloc] init];
    }
    return instance;
}

+ (void)purge {
    TaoziWrapper *channelWrapper = [TaoziWrapper getInstance];
    channelWrapper = nil;
}

- (void)initSDK:(id)target info:(NSMutableDictionary *)cpInfo {
    @try {
        OUTPUT_LOG(@"config params:%@",cpInfo);
        
        if ([target conformsToProtocol:@protocol(InterfaceUser)]){
            _userTarget = target;
            
        } else if ([target conformsToProtocol:@protocol(InterfaceIAP)]){
            _payTarget = target;
        }
        if (_isInited) {
            return;
        }
        _initTarget = target;
        _isInited = YES;//We believe that the initialization is successful，Before the initialization failed
        
        self.bDebug = [PluginHelper getDebugModeStatus];
        _userID = @"";
        // TODO init SDK
        
        NSNumber *appID = [[NSNumber alloc]initWithFloat:[[cpInfo valueForKey:@"TZgameID"] floatValue]];
        _gameID = (UInt32)appID.unsignedLongLongValue;
        _gameKey = [cpInfo valueForKey:@"TZgameKey"];
        _urlSchemes = [@"taozi" stringByAppendingString:[cpInfo valueForKey:@"TZgameID"]];
        
        [UserWrapper onActionResult:target retCode:ACTION_RET_INIT_SUCCESS retMsg:@"init success"];
    }
    @catch (NSException *exception) {
        // 捕获到的异常exception
        _isInited = NO;
        NSLog(@"%@",exception);
        [_loginTarget performSelector:_loginSEL withObject:@"FAIL" withObject:@"init failed!"];
    }
}

- (void)login:(id)target sel:(SEL)sel {
    _loginTarget = target;
    _loginSEL = sel;
    
    // TODO call login function
    [TZGameSdk sharedInstance].delegate = self;
    NSLog(@"_gameID:%i, _gameKey:%@", _gameID, _gameKey);
    [[TZGameSdk sharedInstance] loginGameSdkWithTopViewController:[PluginHelper getCurrentRootViewController] gameID:_gameID gameKey:_gameKey urlScheme:_urlSchemes result:^(NSError * _Nullable error, NSString * _Nullable uid, NSString * _Nullable token) {
        if (error) {
            if(-1 == error.code){
                NSLog(@"login cancel:%@", error);
                [UserWrapper onActionResult:_userTarget retCode:ACTION_RET_LOGIN_CANCEL retMsg:@"login cancel!"];
            }
            else{
                NSLog(@"error:%@", error);
                [UserWrapper onActionResult:_userTarget retCode:ACTION_RET_LOGIN_FAIL retMsg:@"login fail!"];
            }
        }
        else {
            NSLog(@"===============>>>>uid:%@, token:%@", uid, token);
            _uid = uid;
            _token = token;
            [self getAccessToken];
        }
    }];
}

/********************/
- (void)getAccessToken {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:kPluginID forKey:@"plugin_id"];
    [data setObject:kLoginCnl forKey:@"channel"];
    // TODO other params
    [data setObject:_uid forKey:@"uid"];
    [data setObject:_token forKey:@"token"];
    OUTPUT_LOG(@"getAccessTokenParams: %@",data);
    [UserWrapper getAccessToken:data target:self sel:@selector(onGetAccessToken:)];
}

- (void)onGetAccessToken:(id)data {
    @try {
        NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        OUTPUT_LOG(@"onGetAccessToken %@",message);
        if ([message isEqualToString:@"ERROR" ]) {
            [_loginTarget performSelector:_loginSEL withObject:@"FAIL" withObject:@"onGetAccessToken error! message: ERROR"];
            return ;
        }
        
        NSError *error = nil;
        NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (!jsonObject) {
            [_loginTarget performSelector:_loginSEL withObject:@"FAIL" withObject:@"parse jsondata failed!"];
            return ;
        }
        
        NSString *status = [jsonObject objectForKey:@"status"];
        if (status && [status isEqualToString:@"ok"]) {
            _isLogined  = YES;
            
            NSMutableDictionary *commonData = [jsonObject objectForKey:@"common"];
            if (commonData) {
                if ([[commonData objectForKey:@"uid"] isKindOfClass:[NSString class]]) {
                    self.userID = [commonData objectForKey:@"uid"];
                } else if ([[commonData objectForKey:@"uid"] isKindOfClass:[NSString class]]) {
                    self.userID = [[commonData objectForKey:@"uid"] stringValue];
                } else {
                    [_loginTarget performSelector:_loginSEL withObject:@"FAIL" withObject:@"uid is null!"];
                    return;
                }
            } else {
                [_loginTarget performSelector:_loginSEL withObject:@"FAIL" withObject:@"uid is null!"];
                return;
            }
            
            NSString *ext = [jsonObject objectForKey:@"ext"];
            if ([NSJSONSerialization isValidJSONObject:ext]) {
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:&error];
                ext =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            [_loginTarget performSelector:_loginSEL withObject:@"SUCCEED" withObject:ext ? ext : @""];
        } else {
            [_loginTarget performSelector:_loginSEL withObject:@"FAIL" withObject:@"onGetAccessToken status error"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

#pragma mark - TZGameSdkDelegate
- (void)didLogoutSuccessfullyWithUid:(UInt32)uid {
    _isLogined = NO;
    _userID = @"";
    NSLog(@"退出成功，切换账号了,上一个账号的uid是 %u", (unsigned int)uid);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@", [NSString stringWithFormat:@"%@\n登出\nuid:%d", strDate, (unsigned int)uid]);
    [UserWrapper onActionResult:_userTarget retCode:ACTION_RET_LOGOUT_SUCCESS retMsg:@"logout success"];
}

+ (void)showSuspensionView:(id)sender {
    [TZGameSdk showSuspensionView];
}

+ (void)hideSuspensionView:(id)sender {
    [TZGameSdk hideSuspensionView];
}

- (void)logout {
    [[TZGameSdk sharedInstance] logout];
    _isLogined = NO;
    _userID = @"";
    [UserWrapper onActionResult:_userTarget retCode:ACTION_RET_LOGOUT_SUCCESS retMsg:@"logout success"];
}


@end
