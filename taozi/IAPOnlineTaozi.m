//
//  IAPChannel.m
//

#import "IAPOnlineTaozi.h"
#import "TaoziWrapper.h"
#import "Wrapper.h"
#import "IAPWrapper.h"
#import "JsonParser.h"
#import "PluginHelper.h"

#define OUTPUT_LOG(...)     [PluginHelper logDebug:__VA_ARGS__]

@interface IAPOnlineTaozi ()
@property int PAYRESULT_EXIT;//退出游戏

@property (strong, nonatomic) NSMutableDictionary *productInfo;
@property (strong, nonatomic) NSString *orderID;
@property (strong, nonatomic) NSString *channelProductID;//当前SDK对应的商品 ID
@property (strong, nonatomic) NSString *notifyUrl;//

@end

@implementation IAPOnlineTaozi

- (id)init {
    if ([super init]){
        _PAYRESULT_EXIT = PAYRESULT_PAYEXTENSION + 1;//退出游戏
        [self configDeveloperInfo:[PluginHelper getParamsInfo]];

        _productInfo = [[NSMutableDictionary alloc] init];
        _orderID = @"";
        _channelProductID = @"";
        //_notifyUrl = @"NOTIFY_URL_VALUE";
    }
    return self;
}

- (void)configDeveloperInfo:(NSMutableDictionary *)cpInfo {
   [[TaoziWrapper getInstance] initSDK:self info:cpInfo];
    _notifyUrl = [cpInfo valueForKey:@"callback"];
    [[TaoziWrapper getInstance] initSDK:self info:cpInfo];
}

- (void)payForProduct:(NSMutableDictionary *)productInfo {
    OUTPUT_LOG(@"payForProduct %@ invoked.\n",productInfo);
    
    if (![[TaoziWrapper getInstance] isInited]) {
        [self onPayResult:PAYRESULT_FAIL msg:@"init failed"];
        return;
    }
    
    if (![PluginHelper networkReachable]) {
        [self onPayResult:PAYRESULT_NETWORK_ERROR msg:@"network is unreachable"];
        return;
    }
    
    _productInfo = [productInfo mutableCopy];
    if (!_productInfo || [_productInfo count] < 1) {
        [self onPayResult:PAYRESULT_FAIL msg:@"product is null"];
        return;
    }
    
    if (![[TaoziWrapper getInstance] isLogined]) {
        [[TaoziWrapper getInstance] login:self sel:@selector(onLoginResult:msg:)];
    } else {
        [self getPayOrderId:productInfo];
    }
}

- (void)getPayOrderId:(NSMutableDictionary *)productInfo {
    NSMutableDictionary *orderInfo = [IAPWrapper getOrderInfo:productInfo userID:[[TaoziWrapper getInstance] userID]];
    if (orderInfo.count > 0) {
        [orderInfo setObject:[self getPluginId] forKey:@"plugin_id"];
        [IAPWrapper getPayOrderId:orderInfo target:self action:@selector(onGetPayOrderId:)];
    } else {
        [IAPWrapper onPayResult:self retCode:PAYRESULT_FAIL retMsg:@"productInfo error!"];
    }
}

- (void)onGetPayOrderId:(NSData *)data {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    OUTPUT_LOG(@"onGetPayOrderId %@",message);
    if ([message isEqualToString:@"ERROR" ]) {
        [self onPayResult:PAYRESULT_FAIL msg:@"onGetPayOrderId error! message: ERROR"];
        return ;
    }
    
    NSError *error = nil;
    NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject) {
        NSString *status = [jsonObject objectForKey:@"status"];
        if (status && [status isEqualToString:@"ok"]) {
            NSMutableDictionary *data = [jsonObject objectForKey:@"data"];
            if (data) {
                _orderID = [data objectForKey:@"order_id"];
                _channelProductID = [data objectForKey:@"channel_product_id"];
                [self payInSDK];
            } else {
                [self onPayResult:PAYRESULT_FAIL msg:@"data is nil"];
            }
        } else {
            [self onPayResult:PAYRESULT_FAIL msg:@"onGetPayOrderId status error"];
        }
    } else {
        OUTPUT_LOG(@"parse jsondata failed!！error：%@",error);
        [self onPayResult:PAYRESULT_FAIL msg:@"parse jsondata failed!"];
    }
}


- (NSString *)getOrderId {
    OUTPUT_LOG(@"getOrderId invoked!\n");
    return _orderID;
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

- (BOOL)isFunctionSupported:(NSString *)functionName {
    OUTPUT_LOG(@"isFunctionSupported invoked!\n");
    NSString *temp = [functionName stringByAppendingString:@":"];
    SEL sel = NSSelectorFromString(functionName);
    SEL sel_param = NSSelectorFromString(temp);
    BOOL ret = [self respondsToSelector:sel] || [self respondsToSelector:sel_param];
    return ret;
}

/*-------IAP------*/

- (void)payInSDK {
    // TODO get the params used by the SDK
    //_notifyUrl= [IAPWrapper replaceNotifyURL:[self class] url:_notifyUrl];
    NSLog(@"in_pay");
    OUTPUT_LOG(@"payInSDK params: \n");
    
    // TODO call payment function supported by the SDK
    
    NSMutableDictionary *ordInfo = ({
        ordInfo = [NSMutableDictionary dictionary];
        [ordInfo setObject:_orderID forKey:kKeyCpOrderId];
        [ordInfo setObject:[_productInfo valueForKey:@"Product_Name"] forKey:kKeySubject];
        [ordInfo setObject:[_productInfo valueForKey:@"Product_Price"] forKey:kKeyCpFee]; // 商品价格
        [ordInfo setObject:[_productInfo valueForKey:@"Product_Desc"] forKey:kKeyBody];
        [ordInfo setObject:_orderID forKey:kKeyExInfo];
        [ordInfo setObject:[_productInfo valueForKey:@"Role_Name"] forKey:kKeyRoleName];
        [ordInfo setObject:[_productInfo valueForKey:@"Server_Id"] forKey:kKeyServerId];
        [ordInfo setObject:[_productInfo valueForKey:@"Product_Id"] forKey:kKeyProductId];
        [ordInfo setObject:[IAPWrapper replaceNotifyURL:[self class] url:_notifyUrl] forKey:kRespKeyCpCallbackUrl]; // cp回调地址
        ordInfo;
    });
    float price = [[_productInfo valueForKey:@"Product_Price"] floatValue];
    NSString *urlScheme = [TaoziWrapper getInstance].urlSchemes;
    [[TZGameSdk sharedInstance] payForGood:price orderInfo:ordInfo controller:[PluginHelper getCurrentRootViewController] urlScheme:urlScheme completeBlock:^(TZGameSdkPayResult result, TZGameSdkPaymentType paymentType, TZGameSdkPayCurrencyType currencyType) {
        NSString *peyResultStr = @"";
        switch (result) {
            case TZGameSdkPayResultCancel:
                peyResultStr = @"支付取消";
                NSLog(@"支付取消");
                //TODO....
                [self onPayResult:PAYRESULT_CANCEL msg:@"pay cancel"];
                break;
            case TZGameSdkPayResultFail:
                peyResultStr = @"支付失败";
                NSLog(@"支付失败");
                //TODO...
                [self onPayResult:PAYRESULT_FAIL msg:@"pay fail"];
                break;
            case TZGameSdkPayResultSuccess:
                peyResultStr = @"支付成功";
                NSLog(@"支付成功");
                //TODO...
                [self onPayResult:PAYRESULT_SUCCESS msg:@"pay success"];
                break;
            case TZGameSdkPayResultNetError:
                peyResultStr = @"支付网络连接错误";
                NSLog(@"支付网络连接错误");
                //TODO...
                [self onPayResult:PAYRESULT_NETWORK_ERROR msg:@"pay network error"];
                break;
            case TZGameSdkPayResultUnknown:
                peyResultStr = @"支付未知";
                NSLog(@"支付未知");
                //TODO...
                [self onPayResult:PAYRESULT_FAIL msg:@"pay fail。unknown error"];
                break;
            default:
                peyResultStr = [NSString stringWithFormat:@"其他结果 - %zd",result];
                NSLog(@"其他结果 - %zd",result);
                //TODO...other
                [self onPayResult:PAYRESULT_FAIL msg:@"pay fail"];
                break;
        }
        NSString *type = @"";
        if (paymentType == TZGameSdkPaymentTypeAlipay) {
            type = @"支付宝";
        } else if (paymentType == TZGameSdkPaymentTypeWeChatPay) {
            type = @"微信";
        } else if (paymentType == TZGameSdkPaymentTypeUniPay) {
            type = @"银联";
        } else if (paymentType == TZGameSdkPaymentTypeRCoin) {
            type = @"平台币";
        } else if (paymentType == TZGameSdkPaymentTypeNative) {
            type = @"原生";
        } else if (paymentType == TZGameSdkPaymentTypeUnknow) {
            type = @"未知";
        }
        NSString *resultMsgStr = [NSString stringWithFormat:@"%@:%@", type, peyResultStr];
        OUTPUT_LOG(@"%@", resultMsgStr);
    }];
}

- (void)onInitResult:(NSString *)status msg:(NSString *)message {
    OUTPUT_LOG(@"onInitResult status:%@, msg:%@", status, message);
    if ([status isEqualToString:@"SUCCEED"]) {
        [self onPayResult:PAYRESULT_INIT_SUCCESS msg:message];
    } else if ([status isEqualToString:@"FAIL"]) {
        [self onPayResult:PAYRESULT_INIT_FAIL msg:message];
    }
}

- (void)onLoginResult:(NSString *)status msg:(NSString *)message {
    OUTPUT_LOG(@"onLoginResult status:%@, msg:%@", status, message);
    if ([status isEqualToString:@"SUCCEED"]) {
        [self getPayOrderId:_productInfo];
    } else if ([status isEqualToString:@"FAIL"]){
        [self onPayResult:PAYRESULT_FAIL msg:message];
    } else {
        [self onPayResult:PAYRESULT_CANCEL msg:message];
    }
}

- (void)onPayResult:(int)status msg:(NSString *)message {
    NSLog(@"onPayResult,status:%@, message:%@\n",[NSNumber numberWithInt:status],message);
    [IAPWrapper onPayResult:self retCode:status retMsg:message];
}

@end
