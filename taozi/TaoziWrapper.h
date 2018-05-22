//
//  TaoziWrapper.h
//  TaoziWrapper
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TZSdk/TZSdk.h>

#define  kSDKVersion  @"1.0.0"
#define  kPluginVersion  @"2.0.0_1.0.0"
#define  kPluginID  @"856"
#define  kLoginCnl  @"iOS_taozi"

@interface TaoziWrapper : NSObject <TZGameSdkDelegate>

@property(nonatomic,assign) BOOL isInited;
@property(nonatomic,assign) BOOL isLogined;
@property(nonatomic,assign) BOOL bDebug;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *urlSchemes;

/**
 *  init SDK
 *
 *  @param target init target
 *  @param cpInfo information of SDK
 */
- (void)initSDK:(id)target info:(NSMutableDictionary*) cpInfo;

/**
 *  user login
 *
 *  @param target login target
 *  @param sel    selector
 */
- (void)login:(id)target sel:(SEL)sel;

/**
 *  get instance
 *
 *  @return return TaoziWrapper instance
 */
+ (TaoziWrapper *)getInstance;

+ (void)purge;

+ (void)showSuspensionView:(id)sender;

+ (void)hideSuspensionView:(id)sender;

+ (void)logout;

@end
