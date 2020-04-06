//
//  TKJSMethodManager.h
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/4/1.
//  Copyright © 2020 王同科. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TKJSMethodManager : NSObject


/// 创建一个userScript
/// @param obj 实现交互事件的对象
/// @param key 在js里面对象的name
- (WKUserScript *)createUserScript: (id)obj forKeyedSubscript:(NSString *)key;


/// 执行收到的H5事件 在wkwebview UIDelegate方法runJavaScriptTextInputPanelWithPrompt里面调用此方法
/// @param prompt <#prompt description#>
/// @param defaultText <#defaultText description#>
/// @param completionHandler <#completionHandler description#>
- (void)exeMethodWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText completionHandler:(void (^)(NSString * _Nullable result))completionHandler;
@end

@interface WKWebView (tk)

/// 添加一个userScropt
/// @param obj 实现交互事件的对象
/// @param key 在js里面对象的name
- (TKJSMethodManager *)tk_addUserScript:(id)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
