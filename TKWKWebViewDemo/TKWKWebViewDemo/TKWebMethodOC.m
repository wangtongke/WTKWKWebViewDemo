//
//  TKJSMethodManagerOC.m
//  TKWKWebViewDemo
//
//  Created by 王同科 on 2020/4/3.
//  Copyright © 2020 王同科. All rights reserved.
//

#import "TKWebMethodOC.h"

@implementation TKWebMethodOC
-(NSString *)getUserPhone:(int) aaa {
    NSLog(@"%d", aaa);
    return @"wangtongke";
}
-(bool)showToast:(NSString *)msg duration:(CGFloat )duration {
    NSLog(@"%@, %f", msg, duration);
    return true;
}
-(CGFloat)showShare:(NSString *)param callback:(NSString *)callback {
    NSLog(@"%@, %@", param, callback);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.webView != nil) {
            [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@(true)", callback] completionHandler:nil];
        }
    });
    return 0.119;
}
-(void)debuglog:(NSString *)msg {
    NSLog(@"%@", msg);
}
@end
