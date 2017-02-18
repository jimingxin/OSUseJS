//
//  ViewController.m
//  OSUserJS
//
//  Created by 嵇明新 on 2017/2/18.
//  Copyright © 2017年 lanhe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //加载 Web 本地的一个Html文件
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Index" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 自定义的一些方法
//不同参数的测试方法

- (void) ceshi {

    NSLog(@"%s----无参数",__func__);
}

- (void) ceshi:(NSString *)number1{
   
    NSLog(@"%s----%@---", __func__,number1);
}
- (void) ceshi:(NSString *)number1 number2:(NSString *)number2{
    
    NSLog(@"%s----%@---%@--", __func__,number1,number2);
}
- (void) ceshi:(NSString *)number1 number2:(NSString *)number2 number3:(NSString *)number3{
   
    NSLog(@"%s----%@---%@---%@---", __func__,number1,number2,number3);
}

#pragma mark - UiWebViewDelegate
//捕获location.herf的跳转
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    //获取跳转的URL
    NSString *url = request.URL.absoluteString;
    //自定义的协议
    NSString *scheme = @"heihei://";
    
    //如果url中是我们自定义的协议，实现OC方法
    if ([url containsString:scheme]) {
        //截取自定义协议后面的字符串
        NSString *path = [url substringFromIndex:scheme.length];
        NSString *method = nil;
        NSArray *params = nil;
        //字符串是否包含？，判断是否有参数
        if ([path containsString:@"?"]) {
            //有参数
            //通过？分割
            NSArray *info = [path componentsSeparatedByString:@"?"];
            //数组第一个眼熟就是方法名，将JS中的_转化为：转换为OC中的方法名
            method = [[info firstObject] stringByReplacingOccurrencesOfString:@"_" withString:@":"];
            
            //数组第二个元素就为参数字符串
            NSString *param = [info lastObject];
            //将参数以&f分割变为参数数组
            params = [param componentsSeparatedByString:@"&"];
            
        }else{
        
            //无参数
            //方法名
            method = path;
            //参数数组
            params = @[];
            
        }
         NSLog(@"method:%@------params:%@",method,params);
        //通过方法签名来调用方法，因为参数的个数未知，所以我们封装一个比较通用的方法
        [self performSelect:NSSelectorFromString(method) withObjects:params];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{

    //oc调用js
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    [webView stringByEvaluatingJavaScriptFromString:@"test()"];
}


#pragma mark - 根据方法签名调用方法

- (id) performSelect:(SEL) selector withObjects:(NSArray *) objects{

    //方法签名（方法描述）
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (signature == nil) {
        //找不到该方法跑出异常
        @throw [NSException exceptionWithName:@"牛逼的错误" reason:@"方法找不到" userInfo:nil];
        
    }
    
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //通过循环设置参数
    NSInteger paramsCount = signature.numberOfArguments;
    paramsCount = MIN(paramsCount, objects.count);
    for (NSInteger i = 0; i < paramsCount; i ++) {
        id object = objects[i];
        if ([object isKindOfClass:[NSNull class]]) {
            continue;
        }
        [invocation setArgument:&object atIndex:i+2];
    }
    
    //调用方法
    [invocation invoke];
    //获取返回值
    id returnValue = nil;
    //当返回值不是空的时候
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&returnValue];
    }
    return  returnValue;
}

@end
