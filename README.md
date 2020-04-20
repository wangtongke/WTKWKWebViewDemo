# WTKWKWebViewDemo

**H5一份代码同时支持两个webView,H5无须改代码！！！本文主要是为了避免前端需要适配两套交互事件，使iOS的WKWebView的交互方式与UIWebView、安卓保持一致。极大的简化了WKWebView与JS的交互步骤。**

##### 2020-04-06新增
封装了一个Web交互管理类`TKJSMethodManager`，简化了WKWebView与JS交互步骤。直接上代码
```
@interface TKJSMethodManager : NSObject
/// 创建一个userScript
/// @param obj 实现交互事件的对象
/// @param key 在js里面对象的name
- (WKUserScript *)createUserScript: (id)obj forKeyedSubscript:(NSString *)key;
/// 执行收到的H5事件 在wkwebview UIDelegate方法runJavaScriptTextInputPanelWithPrompt里面调用此方法
- (void)exeMethodWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText completionHandler:(void (^)(NSString * _Nullable result))completionHandler;
@end
@interface WKWebView (tk)
/// 添加一个userScropt
/// @param obj 实现交互事件的对象
/// @param key 在js里面对象的name
- (TKJSMethodManager *)tk_addUserScript:(id)obj forKeyedSubscript:(NSString *)key;
@end
```
**使用示例**
 ```
    //实现交互事件的对象，原UIWebView交互里面实现JSExport协议的对象
    let obj = TKWebMethodOC() 
    obj.webView = webView
    // TKJSMethodManager, 在uiDelegate需要用
    manager = webView.tk_addUserScript(obj, forKeyedSubscript: "TKApp")

// uiDelegate代理方法中调用manager的exeMethod方法
func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        manager?.exeMethod(withPrompt: prompt, defaultText: defaultText, completionHandler: completionHandler)
 }
```
**至此，UIWebView转WKWebView已经完成，H5无需改代码，之前UIWebView交互的对象方法也可以可以继续使用。**

#### 原理

`WKWebview`与`UIWebview`在原生交互方面最大差别就是交互方式差异很大。先来看一下这些差异！

 **UIWebview**是原生给H5注入了一个JS对象，比如注入一个`TKApp`对象，H5可以使用这个对象调用原生已经实现好的方法，这个调用时同步的，可以有返回值。
 
 ```
  //js代码
 var phoneNum = TKApp.getUserPhone();
 alert(phoneNum)
 ```
 **WKWebview**是H5发送一个消息给原生，原生通过这个消息的名字来执行对应的方法。类似于原生的`Notification`，可以传参，但是没有返回值。
 
 ```
 // js代码
 func getUserPhoneClick() {
 	var param = {"callback": "getUserPhoneCallback"};
 	window.webkit.messageHandlers.getUserPhoneNum.postMessage(param)
 }
 function getUserPhoneCallback(phoneNum) {
 	alert(phoneNum)
 }
 ```
****
### 通过原生代码分析一下产生差异化的原因

 看下`UIWebView`交互主要步骤代码
 
 ```
  let con = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
 
  con?.setObject(jsInstance, forKeyedSubscript: "TKApp" as NSCopying & NSObjectProtocol)
 ```
 从代码可以分析出来我们为`UIWebView`注入了一个对象`TKApp`,然后H5可以通过这个对象来调用原生的方法。
 
 而`WKWebView`是通过`userContentController.add(handler, name: "getUserPhone")`来进行交互，使原生可以处理message名字为`getUserPhone`的事件。
 
 **正是这两种注入方式的不同，使得调用方式也发生了很大的改变**
 
 ****
 
### 手动给WKWebView注入一个JS对象
`WKWebView`没有提供注入对象的方法，**但是可以为`WKWebview` 注入一段JS代码！！！在这段JS代码里实现要注入的对象**
##### WKWebview代码

```
 let configuration = WKWebViewConfiguration()
  // 添加TKApp替代方法 getJSString为js代码
 let tkapp = WKUserScript.init(source: getJSString(), injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
 // 添加js
 configuration.userContentController.addUserScript(tkapp)
 webView = WKWebView(frame: self.view.frame, configuration: configuration)
```
##### js代码 （上面getJSString()方法获取到的代码）

```
var TKApp = {
    // 获取用户手机号
    getUserPhone: function () {
       return window.prompt("getUserPhone")
    },
    showShare: function(param, callback) {
        var data = {"param": param, "callback": callback}
        window.prompt("showShare", JSON.stringify(data))
    }
}
```
`window.prompt()`是H5调用系统输入框的方法，原生会走`WKUIDelegate`的代理方法

```
func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void)
```
 **在这个代理方法中来处理H5的交互事件！**
 这个方法H5可以传过来两个字符串参数，第一个必传，第二个为可选类型。我们可以定义第一个为方法名，第二个为H5要传过来的参数。`completionHandler`回调一个`String?`类型，在H5里面相当于此方法的返回值。
 
 **需要注意的是，此方法接受的参数和返回值都是字符串，** 如果之前H5用Bool或者Int接受的，我们在注入的JS方法里面可以自己修改成相应的类型。
 [demo传送门](https://github.com/wangtongke/WTKWKWebViewDemo)