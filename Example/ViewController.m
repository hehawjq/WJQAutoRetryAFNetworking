//
//  ViewController.m
//  Example
//
//  Created by 云睿 on 2021/1/19.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <WJQAutoRetryAFNetworking/WJQAutoRetryAFNetworking.h>

#define TestURL @"https://www.baidu.com"

@interface ViewController () {
    UIButton *btnGet1;
    UIButton *btnGet2;
    UIButton *btnPost1;
    UIButton *btnPost2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    btnGet1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btnGet1.layer.borderWidth = 1;
    btnGet1.layer.borderColor = UIColor.grayColor.CGColor;
    btnGet1.frame = CGRectMake(self.view.center.x - 50, 200, 100, 40);
    [btnGet1 setTitle:@"Get 1" forState:UIControlStateNormal];
    [btnGet1 addTarget:self action:@selector(requestWithGet1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnGet1];
    
    btnPost1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btnPost1.layer.borderWidth = 1;
    btnPost1.layer.borderColor = UIColor.grayColor.CGColor;
    btnPost1.frame = CGRectMake(btnGet1.frame.origin.x, CGRectGetMaxY(btnGet1.frame) + 20, CGRectGetWidth(btnGet1.frame), CGRectGetHeight(btnGet1.frame));
    [btnPost1 setTitle:@"Post 1" forState:UIControlStateNormal];
    [btnPost1 addTarget:self action:@selector(requestWithPost1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPost1];
    
    btnGet2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btnGet2.layer.borderWidth = 1;
    btnGet2.layer.borderColor = UIColor.grayColor.CGColor;
    btnGet2.frame = CGRectMake(btnGet1.frame.origin.x, CGRectGetMaxY(btnPost1.frame) + 20, CGRectGetWidth(btnGet1.frame), CGRectGetHeight(btnGet1.frame));
    [btnGet2 setTitle:@"Get 2" forState:UIControlStateNormal];
    [btnGet2 addTarget:self action:@selector(requestWithGet2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnGet2];
    
    btnPost2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btnPost2.layer.borderWidth = 1;
    btnPost2.layer.borderColor = UIColor.grayColor.CGColor;
    btnPost2.frame = CGRectMake(btnGet1.frame.origin.x, CGRectGetMaxY(btnGet2.frame) + 20, CGRectGetWidth(btnGet1.frame), CGRectGetHeight(btnGet1.frame));
    [btnPost2 setTitle:@"Post 2" forState:UIControlStateNormal];
    [btnPost2 addTarget:self action:@selector(requestWithPost2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPost2];
 
}

- (void)requestWithGet1 {
    
    NSSet *set = [NSSet setWithObjects:@"text/json", @"text/javascript", @"text/html", nil];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = set;
    
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = responseSerializer;
    
    [httpManager GET:TestURL parameters:nil headers:nil progress:^(NSProgress * _Nonnull progress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable response) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    } autoRetry:3 retryInterval:5];
}

- (void)requestWithPost1 {
    NSSet *set = [NSSet setWithObjects:@"text/json", @"text/javascript", @"text/html", nil];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = set;
    
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = responseSerializer;
    
    [httpManager POST:TestURL parameters:nil headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    } autoRetry:3 retryInterval:0];
}

- (void)requestWithGet2 {
    NSSet *set = [NSSet setWithObjects:@"text/json", @"text/javascript", @"text/html", nil];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = set;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    urlManager.responseSerializer = responseSerializer;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:TestURL parameters:nil error:nil];

    NSURLSessionDataTask *dataTask = [urlManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress");
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress");
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"success");
        } else {
            NSLog(@"failed");
        }
    } autoRetry:3 retryInterval:5];
    
    [dataTask resume];
}

- (void)requestWithPost2 {
    NSSet *set =  [NSSet setWithObjects:@"text/json", @"text/javascript", @"text/html", nil];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = set;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    urlManager.responseSerializer = responseSerializer;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:TestURL parameters:nil error:nil];
    
    NSURLSessionDataTask *dataTask = [urlManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress");
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress");
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"success");
        } else {
            NSLog(@"failed");
        }
    } autoRetry:3 retryInterval:0];
    
    [dataTask resume];
}

@end
