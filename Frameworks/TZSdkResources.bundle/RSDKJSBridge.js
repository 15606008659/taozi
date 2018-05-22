 (function() {
      if (window.WebViewJavascriptBridge) { return; }
  
      RSDKJSBridge = {
      __RETURN_VALUE__: undefined,
          getAccessToken:function() {
//              alert("helloworld");
         },
          isAppAliPay:function(orderNO, token) {
              window.webkit.messageHandlers.isAppAliPay.postMessage([orderNO, token]);
         },
          isAppWeChat:function(orderNO, token) {
              window.webkit.messageHandlers.isAppWeChat.postMessage([orderNO, token]);
          },
          isAppUniPay:function(orderNO, token) {
              window.webkit.messageHandlers.isAppUniPay.postMessage([orderNO, token]);
          },
          aliPay:function(jsonStr) {
              window.webkit.messageHandlers.aliPay.postMessage(jsonStr);
          },
          weChatPay:function(jsonStr) {
              window.webkit.messageHandlers.weChatPay.postMessage(jsonStr);
          },
          iUniPay:function(jsonStr) {
              window.webkit.messageHandlers.iUniPay.postMessage(jsonStr);
          },
          copyToCliboard:function(jsonStr) {
              window.webkit.messageHandlers.copyToCliboard.postMessage(jsonStr);
          },
          toast:function(msg, durationType) {
              window.webkit.messageHandlers.toast.postMessage([msg, durationType]);
          },
          verifyPayPwd:function(jsonStr) {
              window.webkit.messageHandlers.verifyPayPwd.postMessage(jsonStr);
          },
          close:function() {
              window.webkit.messageHandlers.close.postMessage(null);
          },
          closeSuccess:function() {
              window.webkit.messageHandlers.closeSuccess.postMessage(null);
          },
          connectCustomerService:function() {
              window.webkit.messageHandlers.connectCustomerService.postMessage(null);
          },
          getUserID:function() {
  
          },
          getChildUserID:function() {
  
          },
          getUsername:function() {
  
          },
          getGameName:function() {
  
          },
          getGameID:function() {
  
          },
          getplatform:function() {
  
          },
          getdeviceID:function() {
  
          },
          getchannelID:function() {
  
          },
          getbundleID:function() {
  
          },
      }
      window.WebViewJavascriptBridge = {
          __RETURN_VALUE__: undefined,
      }
})();
