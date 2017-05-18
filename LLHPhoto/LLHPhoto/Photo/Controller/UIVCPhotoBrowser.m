#import "UIVCPhotoBrowser.h"
#import "PhotoScrollView.h"
#import "TapImageView.h"
#import "UIVCPhoto.h"


@interface UIVCPhotoBrowser () <UIScrollViewDelegate, PhotoScrollViewDelegate, TapImageViewDelegate,PhotoScrollViewSaveDelegate>
{
    UIScrollView *myScrollView;
    NSInteger currentIndex;
    
    UIView *markView;
    UIView *scrollPanel;
}

@end

@implementation UIVCPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    /*self view*/
    scrollPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollPanel.backgroundColor = [UIColor blackColor];
    scrollPanel.alpha = 0.0;
    [self.view addSubview:scrollPanel];
    
    markView = [[UIView alloc] initWithFrame:scrollPanel.bounds];
    markView.backgroundColor = [UIColor blackColor];
    markView.alpha = 0.0;
    [scrollPanel addSubview:markView];
    
    myScrollView = [[UIScrollView alloc] initWithFrame:scrollPanel.bounds];
    myScrollView.backgroundColor = [UIColor whiteColor];
    [scrollPanel addSubview:myScrollView];
    myScrollView.pagingEnabled = YES;
    myScrollView.delegate = self;
    CGSize contentSize = myScrollView.contentSize;
//    contentSize.height = sfh;
    contentSize.width = SCREEN_WIDTH * self.imageArray.count;
    myScrollView.contentSize = contentSize;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewComeIn];
}

- (void)viewComeIn
{
    NSLog(@"currIndex=%ld, count= %ld", (long)self.currIndex, (long)self.imageArray.count);
    CGSize contentSize = myScrollView.contentSize;
    contentSize.height = SCREEN_HEIGHT;
    contentSize.width = SCREEN_WIDTH * self.imageArray.count;
    myScrollView.contentSize = contentSize;
    
    
    NSString *fileName = @"";
    NSString *imgName = self.imageArray[self.currIndex];
    if ([imgName hasSuffix:@".jpg"]) {
        fileName = [NSString stringWithFormat:@"%@/%@", [DOCUMENTPATH stringByAppendingPathComponent:@"chatPicture"],imgName];
    } else if ([imgName hasSuffix:@".jpeg"]){
        fileName = [NSString stringWithFormat:@"%@/%@", [DOCUMENTPATH stringByAppendingPathComponent:@"screenPrint"],imgName];
    }
    
    TapImageView *tmpView = [[TapImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:fileName]];
    [self tappedWithObject:tmpView];
}

#pragma mark - custom delegate
- (void)tappedWithObject:(id)sender
{
    [self.view bringSubviewToFront:scrollPanel];
    scrollPanel.alpha = 1.0;
    
    TapImageView *tmpView = sender;
    currentIndex = self.currIndex;
    
    //转换后的rect
    CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
    
    CGPoint contentOffset = myScrollView.contentOffset;
    contentOffset.x = currentIndex * self.view.bounds.size.width;
    myScrollView.contentOffset = contentOffset;
    
    //添加
    [self addSubImgView];
    
    PhotoScrollView *tmpImgScrollView = [[PhotoScrollView alloc] initWithFrame:(CGRect){contentOffset,myScrollView.bounds.size}];
    [tmpImgScrollView setContentWithFrame:convertRect];
    [tmpImgScrollView setImage:tmpView.image];
    [myScrollView addSubview:tmpImgScrollView];
    tmpImgScrollView.i_delegate = self;
    tmpImgScrollView.s_delegate = self;
    
    [self performSelector:@selector(setOriginFrame:) withObject:tmpImgScrollView afterDelay:0.1];
}

- (void) addSubImgView
{
    for (UIView *view in myScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i=0; i<self.imageArray.count; i++) {
        if (i==currentIndex)
            continue;
        
        NSString *fileName = @"";
        NSString *imgName = self.imageArray[i];
        if ([imgName hasSuffix:@".jpg"]) {
            fileName = [NSString stringWithFormat:@"%@/%@", [DOCUMENTPATH stringByAppendingPathComponent:@"chatPicture"],imgName];
        }else if ([imgName hasSuffix:@".jpeg"]){
            fileName = [NSString stringWithFormat:@"%@/%@", [DOCUMENTPATH stringByAppendingPathComponent:@"screenPrint"],imgName];
        }
        
        TapImageView *tmpView = [[TapImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:fileName]];
        
        //转换后的rect
        CGRect convertRect = [[tmpView superview] convertRect:tmpView.frame toView:self.view];
        
        PhotoScrollView *tmpImgScrollView = [[PhotoScrollView alloc] initWithFrame:(CGRect){i*myScrollView.bounds.size.width,0,myScrollView.bounds.size}];
        [tmpImgScrollView setContentWithFrame:convertRect];
        [tmpImgScrollView setImage:tmpView.image];
        [myScrollView addSubview:tmpImgScrollView];
        tmpImgScrollView.i_delegate = self;
        tmpImgScrollView.s_delegate = self;
        
        [tmpImgScrollView setAnimationRect];
    }
}

- (void)setOriginFrame:(PhotoScrollView *) pScrollView
{
//    [UIView animateWithDuration:0.3 animations:^{
        [pScrollView setAnimationRect];
        markView.alpha = 1.0;
//    }];
}

- (void)tapImageViewTappedWithObject:(id) sender
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if (self.navigationController.navigationBar.alpha == 0.0f) {
        self.navigationController.navigationBar.alpha = 1.0f;
        myScrollView.backgroundColor = [UIColor whiteColor];
        statusBar.alpha = 1.0f;
    } else {
        self.navigationController.navigationBar.alpha = 0.0f;
        myScrollView.backgroundColor = [UIColor blackColor];
        statusBar.alpha = 0.0f;
    }
}

- (void) saveImageToPhotographAlbum
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *imgName = self.imageArray[currentIndex];
        NSString *imgPath = [NSString stringWithFormat:@"%@/%@", [DOCUMENTPATH stringByAppendingPathComponent:@"screenPrint"],imgName];
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);//图片保存到相册
    }];
    [controller addAction:otherAction];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) image:(UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo
{
    NSLog(@"成功");
//    NSString *prompt = LoadString(@"NC_SUCCESS");
//    showMessageInView(prompt);
}

#pragma mark - scroll delegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

@end
