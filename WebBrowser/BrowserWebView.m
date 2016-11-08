//
//  BrowserWebView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserWebView.h"
#import "WebViewHeader.h"

#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@interface BrowserWebView ()

@end

@implementation BrowserWebView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeWebView];
    }
    
    return self;
}

- (void)initializeWebView{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.delegate = self;
    
    [self setScalesPageToFit:YES];
    
    [self setDrawInWebThread];
    
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
        
        if (completionHandler) {
            completionHandler(result,nil);
        }
    });
}

- (void)setDrawInWebThread{
    if([self respondsToSelector:NSSelectorFromString(DRAW_IN_WEB_THREAD)])
        (DRAW_IN_WEB_THREAD__PROTO objc_msgSend)(self,NSSelectorFromString(DRAW_IN_WEB_THREAD),YES);
    if([self respondsToSelector:NSSelectorFromString(DRAW_CHECKERED_PATTERN)])
        (DRAW_CHECKERED_PATTERN__PROTO objc_msgSend)(self, NSSelectorFromString(DRAW_CHECKERED_PATTERN),YES);
}

- (NSString *)mainFURL{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)])
        webDocumentView = (DOCUMENT_VIEW__PROTO objc_msgSend)(selfid,NSSelectorFromString(DOCUMENT_VIEW));
    else
        return nil;
    
    if(webDocumentView)
    {
        //也可以使用valueForKey来获取,object_getInstanceVariable方法只能在MRC下执行
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
    }
    else
        return nil;
    
    if(webView)
    {
        if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME_URL)])
            return [(MAIN_FRAME_URL__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_URL)) autorelease];
        else
            return nil;
    }
    else
        return nil;
}

- (NSString *)mainFTitle
{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)])
        webDocumentView = (DOCUMENT_VIEW__PROTO objc_msgSend)(selfid, NSSelectorFromString(DOCUMENT_VIEW));
    else
        return nil;
    
    if(webDocumentView)
    {
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
    }
    else
        return nil;
    
    if(webView)
    {
        if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME_TITLE)])
            return [(MAIN_FRAME_TITLE__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_TITLE)) autorelease];
        else
            return nil;
    }
    else
        return nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(BrowserWebView *)webView{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.webViewDelegate webViewDidStartLoad:webView];
    }
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    if ([self.webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.webViewDelegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    return YES;
}

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    
    if ([self.webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.webViewDelegate webViewDidFinishLoad:webView];
    }
}

#pragma mark - private method

//得到title回调
- (void)zwWebView:(id)sender didReceiveTitle:(id)title forFrame:(id)frame{
    if(![title isKindOfClass:[NSString class]])
        return;

    if ([self respondsToSelector:@selector(zwWebView:didReceiveTitle:forFrame:)]) {
        ((void(*)(id, SEL, id, id, id)) objc_msgSend)(self, @selector(zwWebView:didReceiveTitle:forFrame:), sender, title, frame);
    }
    
    
    if([sender respondsToSelector:NSSelectorFromString(MAIN_FRAME)])
    {
        id mainFrame = (MAIN_FRAME__PROTO objc_msgSend)(sender,NSSelectorFromString(MAIN_FRAME));
        if(mainFrame == frame)
        {
            [self webViewGotTitle:title];
        }
    }
    else
    {
        [self webViewGotTitle:title];
    }
}

#pragma mark - decidePolicy method

//new window 回调
- (void)zwWebView:(id)webView decidePolicyForNewWindowAction:(id)actionInformation request:(id)request newFrameName:(id)frameName decisionListener:(id)listener{
    if ([self respondsToSelector:@selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)]) {
        ((void(*)(id, SEL, id, id, id, id, id)) objc_msgSend)(self, @selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:), webView, actionInformation, request, frameName, listener);
    }
    
    if(![request isKindOfClass:[NSURLRequest class]])
        return;
    
    if(![frameName isKindOfClass:[NSString class]])
        return;
    
}

//navigation 回调
- (void)zwWebView:(id)webView decidePolicyForNavigationAction:(id)actionInformation request:(id)request frame:(id)frame decisionListener:(id)listener{
    if(![request isKindOfClass:[NSURLRequest class]])
        return;
    
    NSInteger intNaviType = 0;
    if ([actionInformation isKindOfClass:[NSDictionary class]]) {
        id naviType = [((NSDictionary*)actionInformation) objectForKey:WEB_ACTION_NAVI_TYPE_KEY];
        if([naviType isKindOfClass:[NSNumber class]])
        {
            intNaviType = [(NSNumber*)naviType integerValue];
        }
    }
    
    if([self respondsToSelector:@selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:)])
        ((void(*)(id, SEL, id, id, id, id, id)) objc_msgSend)(self, @selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:), webView, actionInformation, request, frame, listener);
}

#pragma mark - main frame load functions
//webViewMainFrameDidCommitLoad:
-(void)zwMainFrameCommitLoad:(id)arg1
{
    if([self respondsToSelector:@selector(zwMainFrameCommitLoad:)])
    {
        ((void(*)(id, SEL, id)) objc_msgSend)(self, @selector(zwMainFrameCommitLoad:),arg1);
    }
    
    if([self respondsToSelector:@selector(mainFrameCommitLoad)])
    {
        ((void(*)(id, SEL)) objc_msgSend)(self, @selector(mainFrameCommitLoad));
    }
}

-(void)mainFrameCommitLoad
{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewMainFrameDidCommitLoad:)]) {
        [self.webViewDelegate webViewMainFrameDidCommitLoad:self];
    }
}

//webViewMainFrameDidFinishLoad:
-(void)zwMainFrameFinishLoad:(id)arg1
{
    if([self respondsToSelector:@selector(zwMainFrameFinishLoad:)])
    {
        ((void(*)(id, SEL, id)) objc_msgSend)(self, @selector(zwMainFrameFinishLoad:),arg1);
    }
    
    if([self respondsToSelector:@selector(mainFrameFinishLoad)])
    {
        ((void(*)(id, SEL)) objc_msgSend)(self, @selector(mainFrameFinishLoad));
    }
}

-(void)mainFrameFinishLoad
{
    if ([self.webViewDelegate respondsToSelector:@selector(webViewMainFrameDidFinishLoad:)]) {
        [self.webViewDelegate webViewMainFrameDidFinishLoad:self];
    }
}

#pragma mark - replaced method calling

-(void)webViewGotTitle:(NSString*)titleName
{
    if([self.webViewDelegate respondsToSelector:@selector(webView:gotTitleName:)])
    {
        [self.webViewDelegate webView:self gotTitleName:titleName];
    }
}

@end

__attribute__((__constructor__)) static void $(){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_GOT_TITLE), @selector(zwWebView:didReceiveTitle:forFrame:));
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_NEW_WINDOW), @selector(zwWebView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:));
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(WEB_ACTION_NAVIGATION), @selector(zwWebView:decidePolicyForNavigationAction:request:frame:decisionListener:));

    MethodSwizzle([BrowserWebView class], NSSelectorFromString(MAIN_FRAME_COMMIT_LOAD), @selector(zwMainFrameCommitLoad:));
    
    MethodSwizzle([BrowserWebView class], NSSelectorFromString(MAIN_FRAME_FINISIH_LOAD), @selector(zwMainFrameFinishLoad:));
    
    [pool drain];
}


