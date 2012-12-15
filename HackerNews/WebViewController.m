//
//  WebViewController.m
//  HackerNews
//
//  Created by Steven Spencer on 12/14/12.
//  Copyright (c) 2012 Steven Spencer. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_url) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        self.title = _url;
        NSURLRequest *httpRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [_webView loadRequest:httpRequest];
    }
 }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
