//
//  TZGameSdk.h
//  TZSdk
//
//  Created by wjc on 2017/8/30.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 支付结果
 */
typedef NS_ENUM(NSInteger, TZGameSdkPayResult) {
    TZGameSdkPayResultFail = 0, // 失败
    TZGameSdkPayResultSuccess,  // 成功
    TZGameSdkPayResultCancel,   // 取消
    TZGameSdkPayResultRepeat,   // 重复支付
    TZGameSdkPayResultNetError, // 网络连接错误
    TZGameSdkPayResultUnknown,  // 未知
};

/**
 * 支付类型 目前只支持支付宝和微信支付第三方支付
 */
typedef NS_ENUM(NSInteger, TZGameSdkPaymentType) {
    TZGameSdkPaymentTypeAlipay      = 0,        // 支付宝
    TZGameSdkPaymentTypeWeChatPay   = 1,        // 微信支付
    TZGameSdkPaymentTypeUniPay      = 2,        // 银联支付
    TZGameSdkPaymentTypeRCoin       = 3,        // 平台币支付
    TZGameSdkPaymentTypeNative      = 4,        // 苹果内购支付
    TZGameSdkPaymentTypeClose       = 254,      // 关闭支付
    TZGameSdkPaymentTypeUnknow      = 255,      // 未知
};

/**
 * 货币类型
 */
typedef NS_ENUM(NSInteger, TZGameSdkPayCurrencyType) {
    TZGameSdkPayCurrencyTypeRMB = 0,    // 人民币
    TZGameSdkPayCurrencyTypeUSD,        // 美元
    TZGameSdkPayCurrencyTypeHKD,        // 港币
};

/**
 登录回调
 @param error         错误代码
 @param uid           用户唯一标识
 @param token         用户会话token
 */
typedef void(^LoginGameSdkResultBlock)(NSError * _Nullable error, NSString *_Nullable uid,  NSString *_Nullable token);

/**
 * 支付完成回调
 * 参数 result        :支付结果 see TZGameSdkPayResult
 * 参数 paymentType   :支付类型 see TZGameSdkPaymentType
 * 参数 currencyType  :货币类型 see TZGameSdkPayCurrencyType(目前统一返回"人民币")
 */
typedef void(^PayGameSdkCompleteBlock)(TZGameSdkPayResult result, TZGameSdkPaymentType paymentType , TZGameSdkPayCurrencyType currencyType);

/**
 * 游戏方订单参数
 */
static NSString * const kKeyCpOrderId        = @"cpOrderID";     // cp订单号,必选
static NSString * const kKeyCpFee            = @"cpFee";         // cp订单金额，单位为元 必选
static NSString * const kKeyProductId        = @"productId";     // 商品id
static NSString * const kKeySubject          = @"subject";       // 商品名称
static NSString * const kKeyBody             = @"body";          // 商品描述
static NSString * const kKeyExInfo           = @"exInfo";        // 扩展信息
static NSString * const kKeyServerId         = @"serverId";      // 游戏服务器id
static NSString * const kKeyRoleName         = @"roleName";      // 角色名
static NSString * const kRespKeyCpCallbackUrl= @"cpCallbackUrl"; // 支付回调地址

@protocol TZGameSdkDelegate <NSObject>

@optional
/**
 * 切换账号、注销时调用
 * 参数 uid:用户唯一标识
 */
- (void)didLogoutSuccessfullyWithUid:(UInt32)uid;

@end

@interface TZGameSdk : NSObject

@property(nonatomic, assign, readonly, getter=getGameID) UInt32 gameID;

@property(nonatomic, copy) NSString *gameKey;

@property(nonatomic, weak) id<TZGameSdkDelegate> delegate;

/**
 单例

 @return 实例对象
 */
+ (TZGameSdk *)sharedInstance;

/**
 * 登录
 * 参数 topViewController :最上层的ViewController,用于部分页面跳转
 * 参数 gameID            :后台分配给游戏的ID
 * 参数 gameKey           :后台分配给游戏的gameKey
 * 参数 urlScheme         :用于执行应用间跳转,建议定义的复杂些,以免和其他APP重复
 * 参数 block             :登录成功的回调see LoginGameSdkResultBlock
 */
- (void)loginGameSdkWithTopViewController:(UIViewController *)topViewController gameID:(UInt32)gameID gameKey:(NSString *)gameKey urlScheme:(NSString *)urlScheme result:(LoginGameSdkResultBlock)block;

/**
 * 支付接口
 * 参数 price     :价格
 * 参数 ordInfo   :订单参数,详见上方定义的"订单参数"字段
 * 参数 controller:跳转至支付界面之前的控制器,用于执行支付完成后跳回动作
 * 参数 urlScheme :用于执行应用间跳转,建议定义的复杂些,以免和其他APP重复
 * 参数 block     :支付完成回调 see PayGameSdkCompleteBlock
 */
- (void)payForGood:(float)price
          orderInfo:(NSDictionary *)ordInfo
        controller:(UIViewController *)controller
         urlScheme:(NSString *)urlScheme
     completeBlock:(PayGameSdkCompleteBlock)block;

/**
 * appDelegate - 用户支付宝支付
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication
         annotation:(id _Nonnull )annotation;
// 9.0以后使用新API接口
- (BOOL)application:(UIApplication *_Nullable)app openURL:(NSURL *_Nullable)url options:(NSDictionary<NSString*, id> *_Nonnull)options;

/**
 * appDelegate - 用户微信支付
 */
- (void)willEnterForeground;

/**
 * appDelegate - 参数 trackKey 热云track key (若无热云trackKey,请传nil)
 */
- (BOOL)applicationDidFinishLaunchingWithTrackKey:(NSString *_Nullable)trackKey;

/**
 * 改变最上层的ViewController(发生变化时调用,一般情况无需调用)
 * 参数 topViewController : 最上层的ViewController
 */
- (void)changeTopViewController:(UIViewController *)topViewController;

/**
 * 注销
 */
- (void)logout;

/**
 * 显示悬浮窗
 */
+ (void)showSuspensionView;

/**
 * 隐藏悬浮窗
 */
+ (void)hideSuspensionView;

@end

NS_ASSUME_NONNULL_END
