 (function() {
  if (window.WebViewJavascriptBridge) { return; }
  
  TZSDKJSBridge = {
  __RETURN_VALUE__: undefined,
  
  //****** web -> client ******
  
  /**
   * Helper: invoke
   * @url: func:接口名
   */
  invoke:function(func) {
      TZSDKJSBridge.invoke(func, func, null);
  },
  /**
   * Helper: invoke
   * @url: module:模块名
   *		func:接口名
   */
  invoke:function(module, func) {
      TZSDKJSBridge.invoke(module, func, null);
  },
  
  /**
   * Helper: invoke
   * @url: module:模块名
   *		func:接口名
   *		params:参数
   */
  invoke:function(module, func, param) {
      var url = 'tz://' + module + '/' + func + '/' + '?params=' + encodeURIComponent(param || '');
  
      var result = TZSDKJSBridge._openURL(url);
      return result ? result : null;
  },
  
  /**
   * Helper: invoke
   * @url: module:模块名
   *		func:接口名
   *		params:参数
   *		callback:回调
   */
  invoke:function(module, func, param, callback) {
      var url = 'tz://' + module + '/' + func + '/' + '?params=' + encodeURIComponent(param || '') + '&callback=' + callback;
  
      var result = TZSDKJSBridge._openURL(url);
      return result ? result : null;
  },
  
  //****** client -> web ******
  
  invokeWebMethod:function(callback, returnValue) {
      WebViewJavascriptBridge._invokeCallbackWithArgs(callback, returnValue);
  },
  
  //****** private ******
  
  _openURL:function(url) {
  //create an iframe to send the request
      var i = document.createElement('iframe');
      i.style.display = 'none';
      i.src = url;
      document.body.appendChild(i);
  
  //read return value
      var returnValue = RSDKJSBridge.__RETURN_VALUE__;
      TZSDKJSBridge.__RETURN_VALUE__ = undefined;
  
  //destory the iframe
      i.parentNode.removeChild(i);
  
      return returnValue;
  },
  
  _invokeCallbackWithArgs:function(callback, args) {
      if (callback) {
          setTimeout(function() {
                     callback.apply(null, args);
                     }, 0);
          }
      }
  };
  
  window.WebViewJavascriptBridge = {
      call:function(url) {
          return TZSDKJSBridge.invoke('operate', 'jump', url);
      }
  };
  RSDKJSBridge = {
  getAccessToken:function() {
      return TZSDKJSBridge.invoke('pay', 'getAccessToken');
  },
  isAppAliPay:function(orderNO, token) {
      TZSDKJSBridge.invoke('pay', 'isAppAliPay', [orderNO, token]);
  },
  isAppWeChat:function(orderNO, token) {
      TZSDKJSBridge.invoke('pay', 'isAppWeChat', [orderNO, token]);
  },
  isAppUniPay:function(orderNO, token) {
      TZSDKJSBridge.invoke('pay', 'isAppUniPay', [orderNO, token]);
  },
  aliPay:function(data) {
      TZSDKJSBridge.invoke('pay', 'aliPay', data);
  },
  weChatPay:function(data) {
      TZSDKJSBridge.invoke('pay', 'weChatPay', data);
  },
  iUniPay:function(data) {
      TZSDKJSBridge.invoke('pay', 'iUniPay', data);
  },
  verifyPayPwd:function(funcName) {
      TZSDKJSBridge.invoke('pay', 'verifyPayPwd', funcName);
  },
  close:function() {
      TZSDKJSBridge.invoke('operate', 'close');
  },
  closeSuccess:function() {
      TZSDKJSBridge.invoke('operate', 'closeSuccess');
  },
  connectCustomerService:function() {
      TZSDKJSBridge.invoke('operate', 'connectCustomerService');
  },
  toast:function(msg, durationType) {
      TZSDKJSBridge.invoke('operate', 'toast', [msg, durationType]);
  },
  getUserID:function() {
      TZSDKJSBridge.invoke('data', 'getUserID');
  },
  getChildUserID:function() {
      TZSDKJSBridge.invoke('data', 'getChildUserID');
  },
  getUsername:function() {
      TZSDKJSBridge.invoke('data', 'getUsername');
  },
  getGameName:function() {
      TZSDKJSBridge.invoke('data', 'getGameName');
  },
  getGameID:function() {
      TZSDKJSBridge.invoke('data', 'getGameID');
  },
  getplatform:function() {
      TZSDKJSBridge.invoke('data', 'getplatform');
  },
  getdeviceID:function() {
      TZSDKJSBridge.invoke('data', 'getdeviceID');
  },
  getchannelID:function() {
      TZSDKJSBridge.invoke('data', 'getchannelID');
  },
  getbundleID:function() {
      TZSDKJSBridge.invoke('data', 'getbundleID');
  },
  }
  })();
