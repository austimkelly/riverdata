//
//  RDHelpViewController.m
//  RiverData
//
//  Created by Tim Kelly on 8/5/14.
//  Copyright (c) 2014 Tim Kelly. All rights reserved.
//

#import "RDHelpViewController.h"

@interface RDHelpViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (assign) BOOL interceptLinks;

@end

@implementation RDHelpViewController

@synthesize interceptLinks = _interceptLinks;

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
    // Do any additional setup after loading the view.
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", [[NSBundle mainBundle] bundlePath]]];
    [self.webView loadHTMLString:htmlString baseURL:baseUrl];
    
    self.webView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (void)openBrowserWithUrl:(NSURL *)url{
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
    
}

#pragma mark UIWebViewDelegate

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //You might need to set up a interceptLinks-Bool since you don't want to intercept the initial loading of the content
    if (self.interceptLinks) {
        NSURL *url = request.URL;
        //This launches your custom ViewController, replace it with your initialization-code
        [RDHelpViewController openBrowserWithUrl:url];
        return NO;
    }
    //No need to intercept the initial request to fill the WebView
    else {
        self.interceptLinks = TRUE;
        return YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
