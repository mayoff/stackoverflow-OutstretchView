#import "OutstretchView.h"

@implementation OutstretchView

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
    [self setNeedsDisplay];
}

- (void)setFixedRect:(CGRect)fixedRect {
    _fixedRect = CGRectStandardize(fixedRect);
    [self setNeedsDisplay];
}

- (void)setFixedCenter:(CGPoint)fixedCenter {
    _fixedCenter = fixedCenter;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)imageRect ofImage:(UIImage *)image inRect:(CGRect)viewRect {
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGContextSaveGState(gc); {
        CGContextClipToRect(gc, viewRect);
        CGContextTranslateCTM(gc, viewRect.origin.x, viewRect.origin.y);
        CGContextScaleCTM(gc, viewRect.size.width / imageRect.size.width, viewRect.size.height / imageRect.size.height);
        CGContextTranslateCTM(gc, -imageRect.origin.x, -imageRect.origin.y);
        [image drawAtPoint:CGPointZero];
    } CGContextRestoreGState(gc);
}

static CGRect rect(CGFloat *xs, CGFloat *ys) {
    return CGRectMake(xs[0], ys[0], xs[1] - xs[0], ys[1] - ys[0]);
}

- (void)drawRect:(CGRect)dirtyRect {
    UIImage *image = self.image;
    if (!image)
        return;

    CGRect imageBounds = (CGRect){ CGPointZero, image.size };
    CGRect viewBounds = self.bounds;

    CGRect imageFixedRect = self.fixedRect;
    if (CGRectIsNull(imageFixedRect)) {
        [image drawInRect:viewBounds];
        return;
    }

    CGPoint imageFixedCenter = self.fixedCenter;
    CGRect viewFixedRect = CGRectOffset(imageFixedRect, imageFixedCenter.x - imageFixedRect.size.width / 2, imageFixedCenter.y - imageFixedRect.size.height / 2);
    
    CGFloat viewSlicesX[4] = { viewBounds.origin.x, viewFixedRect.origin.x, CGRectGetMaxX(viewFixedRect), CGRectGetMaxX(viewBounds) };
    CGFloat viewSlicesY[4] = { viewBounds.origin.y, viewFixedRect.origin.y, CGRectGetMaxY(viewFixedRect), CGRectGetMaxY(viewBounds) };
    CGFloat imageSlicesX[4] = { imageBounds.origin.x, imageFixedRect.origin.x, CGRectGetMaxX(imageFixedRect), CGRectGetMaxX(imageBounds) };
    CGFloat imageSlicesY[4] = { imageBounds.origin.y, imageFixedRect.origin.y, CGRectGetMaxY(imageFixedRect), CGRectGetMaxY(imageBounds) };
    
    for (int y = 0; y < 3; ++y) {
        for (int x = 0; x < 3; ++x) {
            [self drawRect:rect(imageSlicesX + x, imageSlicesY + y) ofImage:image inRect:rect(viewSlicesX + x, viewSlicesY + y)];
        }
    }
}

@end
