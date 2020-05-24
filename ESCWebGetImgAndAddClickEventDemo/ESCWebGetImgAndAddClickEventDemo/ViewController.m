//
//  ViewController.m
//  ESCWebGetImgAndAddClickEventDemo
//
//  Created by xiang on 2020/5/24.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, WKUIDelegate>

@property(nonatomic,weak)WKWebView* webView;

/// 图片资源数组
@property(nonatomic, strong) NSArray* imgSrcArray;

@end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    WKWebView *webView = [[WKWebView alloc] init];
    [self.view addSubview:webView];
    self.webView = webView;
    
    NSURL *url = [NSURL URLWithString:@"https://x0.ifengimg.com/ucms/2020_21/C8D719291130E4446C4338778C00E236B5AC10FE_w1200_h800.jpg"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

#pragma mark - WKNavigationDelegate, WKUIDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([webView.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* paths = [webView.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        //计算index
        NSInteger index = [self.imgSrcArray indexOfObject:paths];
        
        NSLog(@"imageurl==%@",[self.imgSrcArray objectAtIndex:index]);
        
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self getImageArrayAndSetImageeventWithWebView:webView];
}

- (void)getImageArrayAndSetImageeventWithWebView:(WKWebView *)webView {
    //获取img标签
    NSString *jsGetImages =@"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    [webView evaluateJavaScript:jsGetImages completionHandler:nil];
    
    [webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable urlResurlt, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //获取图片数组
            NSMutableArray* mUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
            if ([mUrlArray.lastObject isEqualToString:@""]) {
                [mUrlArray removeLastObject];
            }
            
            self.imgSrcArray = mUrlArray;
        });
    }];
    //    添加点击事件
    NSString* string = @"function registerImageClickAction(){\
    var imgs=document.getElementsByTagName('img');\
    var length=imgs.length;\
    for(var i=0;i<length;i++){\
    var img=imgs[i];\
    img.onclick=function(){\
    window.location.href='image-preview:'+this.src}\
    }\
    }";
    [webView evaluateJavaScript:string completionHandler:nil];
    [webView evaluateJavaScript:@"registerImageClickAction();" completionHandler:nil];
}

@end
