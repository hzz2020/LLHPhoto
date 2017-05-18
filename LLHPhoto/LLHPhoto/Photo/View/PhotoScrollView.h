#import <UIKit/UIKit.h>

@protocol PhotoScrollViewDelegate <NSObject>

- (void) tapImageViewTappedWithObject:(id) sender;

@end

@protocol PhotoScrollViewSaveDelegate <NSObject>

- (void) saveImageToPhotographAlbum;

@end


@interface PhotoScrollView : UIScrollView

@property (nonatomic, weak) id<PhotoScrollViewDelegate>     i_delegate;
@property (nonatomic, weak) id<PhotoScrollViewSaveDelegate> s_delegate;

- (void) setContentWithFrame:(CGRect) rect;
- (void) setImage:(UIImage *) image;
- (void) setAnimationRect;
- (void) rechangeInitRdct;

@end
