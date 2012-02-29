#import "OutstretchView.h"

@implementation OutstretchView {
    CALayer *_slices[3][3];
    BOOL _imageDidChange : 1;
    BOOL _hasSlices : 1;
}

@synthesize image = _image;
@synthesize fixedRect = _fixedRect;
@synthesize fixedCenter = _fixedCenter;

- (void)commonInit {
    _fixedRect = CGRectNull;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self commonInit];
    
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageDidChange = YES;
    [self setNeedsLayout];
}

- (void)setFixedRect:(CGRect)fixedRect {
    _fixedRect = CGRectStandardize(fixedRect);
    [self setNeedsLayout];
}

- (void)setFixedCenter:(CGPoint)fixedCenter {
    _fixedCenter = fixedCenter;
    [self setNeedsLayout];
}

- (void)hideSlices {
    if (!_hasSlices)
        return;
    for (int y = 0; y < 3; ++y) {
        for (int x = 0; x < 3; ++x) {
            _slices[y][x].hidden = YES;
        }
    }
}

- (void)makeSlices {
    if (_hasSlices)
        return;
    CALayer *myLayer = self.layer;
    for (int y = 0; y < 3; ++y) {
        for (int x = 0; x < 3; ++x) {
            _slices[y][x] = [CALayer layer];
            [myLayer addSublayer:_slices[y][x]];
        }
    }
    _hasSlices = YES;
}

static CGRect rect(CGFloat *xs, CGFloat *ys) {
    return CGRectMake(xs[0], ys[0], xs[1] - xs[0], ys[1] - ys[0]);
}

- (void)setSliceImages {
    UIImage *image = self.image;
    CGImageRef cgImage = image.CGImage;
    CGFloat scale = image.scale;
    CGRect fixedRect = self.fixedRect;
    fixedRect.origin.x *= scale;
    fixedRect.origin.y *= scale;
    fixedRect.size.width *= scale;
    fixedRect.size.height *= scale;
    CGFloat xs[4] = { 0, fixedRect.origin.x, CGRectGetMaxX(fixedRect), CGImageGetWidth(cgImage) };
    CGFloat ys[4] = { 0, fixedRect.origin.y, CGRectGetMaxY(fixedRect), CGImageGetHeight(cgImage) };
    
    for (int y = 0; y < 3; ++y) {
        for (int x = 0; x < 3; ++x) {
            CGImageRef imageSlice = CGImageCreateWithImageInRect(cgImage, rect(xs + x, ys + y));
            _slices[y][x].contents = (__bridge id)imageSlice;
            CGImageRelease(imageSlice);
        }
    }
}

- (void)setSliceFrames {
    CGRect bounds = self.bounds;
    CGRect fixedRect = self.fixedRect;
    CGPoint fixedCenter = self.fixedCenter;
    fixedRect = CGRectOffset(fixedRect, fixedCenter.x - fixedRect.size.width / 2, fixedCenter.y - fixedRect.size.height / 2);
    CGFloat xs[4] = { bounds.origin.x, fixedRect.origin.x, CGRectGetMaxX(fixedRect), CGRectGetMaxX(bounds) };
    CGFloat ys[4] = { bounds.origin.y, fixedRect.origin.y, CGRectGetMaxY(fixedRect), CGRectGetMaxY(bounds) };
    
    for (int y = 0; y < 3; ++y) {
        for (int x = 0; x < 3; ++x) {
            _slices[y][x].frame = rect(xs + x, ys + y);
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.image) {
        [self hideSlices];
        self.layer.contents = nil;
        return;
    }
    
    if (CGRectIsNull(self.fixedRect)) {
        [self hideSlices];
        self.layer.contents = (__bridge id)self.image.CGImage;
        return;
    }
    
    if (!_hasSlices)
        [self makeSlices];
    
    if (_imageDidChange) {
        [self setSliceImages];
        _imageDidChange = NO;
    }
    
    [self setSliceFrames];
}

@end
