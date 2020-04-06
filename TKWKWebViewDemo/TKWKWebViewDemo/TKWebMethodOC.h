//
//  TKJSMethodManagerOC.h
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/4/3.
//  Copyright © 2020 王同科. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
/// web交互事件
@interface TKWebMethodOC : NSObject
@property(nonatomic, weak)WKWebView *webView;

-(NSString *)getUserPhone:(int) aaa;
-(bool)showToast:(NSString *)msg duration:(CGFloat )duration;
-(CGFloat)showShare:(NSString *)param callback:(NSString *)callback;
-(void)debuglog:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
