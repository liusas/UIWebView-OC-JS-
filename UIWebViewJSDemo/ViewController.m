//
//  ViewController.m
//  UIWebViewJSDemo
//
//  Created by 刘峰 on 2019/5/8.
//  Copyright © 2019年 Liufeng. All rights reserved.
//

#import "ViewController.h"
#import <objc/Message.h>

#define IPHONEXSeries           ([UIScreen mainScreen].bounds.size.height >= 810)
// 状态栏高度
#define STATUS_BAR_HEIGHT       (IPHONEXSeries ? 44.f : 20.f)
// 导航栏高度
#define NAVIGATION_BAR_HEIGHT   (IPHONEXSeries ? 88.f : 64.f)
// tabBar高度
#define TAB_BAR_HEIGHT          (IPHONEXSeries ? (49.f+34.f) : 49.f)
// home indicator
#define HOME_INDICATOR_HEIGHT   (IPHONEXSeries ? 34.f : 0.f)

@interface ViewController () <UIWebViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-HOME_INDICATOR_HEIGHT)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"UIWebView.html" withExtension:nil];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //拦截JS的回调
    if ([request.URL.scheme.lowercaseString isEqualToString:@"lfjstooc"]) {
        NSArray *arr = request.URL.pathComponents;
        SEL sel = NULL;
        if (arr.count > 2) {//表示调用js调用的方法有参数
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@:",arr[1]]);
        } else if(arr.count == 2) {//js调用OC，数组中至少得有两个元素
            sel = NSSelectorFromString(arr[1]);
        }
        objc_msgSend(self, sel, arr[2]);
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webview开始加载");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    NSLog(@"webView加载完成");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"webview加载失败:%@",error);
}

#pragma mark - Private
//第一个按钮点击事件
- (void)firstClick:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

//第二个按钮点击事件
- (void)secondClick:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

//第三个按钮点击事件
- (void)thirdClick:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

//第四个按钮点击事件，调用系统相册
- (void)forthClick:(NSString *)str {
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
    }
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark -- UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"info---%@",info);
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *imgData = UIImageJPEGRepresentation(resultImage, 0.01);
    NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *imageString = [self clearImageString:encodedImageStr];
    
    NSString *jsFunctStr = [NSString stringWithFormat:@"showImageOnDiv('%@')",imageString];
    //OC调用JS
    [self.webView stringByEvaluatingJavaScriptFromString:jsFunctStr];
}

//清除base64串里面的东西
- (NSString *)clearImageString:(NSString *)str {
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

@end
