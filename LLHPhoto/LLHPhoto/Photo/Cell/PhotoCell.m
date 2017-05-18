#import "PhotoCell.h"

@implementation PhotoCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width-4, frame.size.height-4)];
        [self addSubview:self.imageView];
        self.checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-30, frame.size.height-30, 20, 20)];
        [self addSubview:self.checkImage];
        [self updateCheckImage];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateCheckImage];
}

- (void)updateCheckImage {
    self.checkImage.hidden = !self.selected;
}


@end
