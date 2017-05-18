#import <UIKit/UIKit.h>

@protocol TapImageViewDelegate <NSObject>

- (void) tappedWithObject:(id) sender;

@end

@interface TapImageView : UIImageView

@property (nonatomic, weak) id<TapImageViewDelegate> t_delegate;

@end
