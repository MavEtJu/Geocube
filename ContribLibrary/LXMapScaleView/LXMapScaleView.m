//
//  LXMapScaleView.m
//
//  Created by Tamas Lustyik on 2012.01.09..
//  Copyright (c) 2012 LKXF. All rights reserved.
//

#import "LXMapScaleView.h"
#import "ToolsLibrary/Coordinates.h"
#import "ManagersLibrary/LocalizationManager.h"


static const CGRect kDefaultViewRect = {{0,0},{160,30}};
static const CGFloat kMinimumWidth = 100.0f;
static const UIEdgeInsets kDefaultPadding = {10,10,10,10};

static const double kFeetPerMeter = 1.0/0.3048;
static const double kFeetPerMile = 5280.0;



@interface LXMapScaleView ()
{
    MapTemplate *mapTemplate;
	UILabel* zeroLabel;
	UILabel* maxLabel;
	UILabel* unitLabel;
	CGFloat scaleWidth;
    CGFloat kMaximumWidth;
}

- (void)constructLabels;

@end



@implementation LXMapScaleView

@synthesize style;
@synthesize metric;
@synthesize position;
@synthesize padding;
@synthesize maxWidth;


// -----------------------------------------------------------------------------
// LXMapScaleView::mapScaleForAMSMapView:
// -----------------------------------------------------------------------------
+ (LXMapScaleView*)mapScaleForGC:(MapTemplate *)mt;
{
	if (mt == nil) {
		return nil;
	}
    return [[LXMapScaleView alloc] initWithMapTemplate:mt];
}

// -----------------------------------------------------------------------------
// LXMapScaleView::initWithMapView:
// -----------------------------------------------------------------------------
- (id)initWithMapTemplate:(MapTemplate*)mt
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    kMaximumWidth = MAX(applicationFrame.size.width, applicationFrame.size.height);

	if ( (self = [super initWithFrame:kDefaultViewRect]) )
	{
		self.opaque = NO;
		self.clipsToBounds = YES;
		self.userInteractionEnabled = NO;
		
        mapTemplate = mt;
		metric = YES;
		style = kLXMapScaleStyleBar;
		position = kLXMapScalePositionBottomLeft;
		padding = kDefaultPadding;
		maxWidth = kDefaultViewRect.size.width;

		[self constructLabels];
	}
	
	return self;
}

// -----------------------------------------------------------------------------
// LXMapScaleView::constructLabels
// -----------------------------------------------------------------------------
- (void)constructLabels
{
	UIFont* font = [UIFont systemFontOfSize:12.0f];
	zeroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 8, 10)];
	zeroLabel.backgroundColor = [UIColor clearColor];
	zeroLabel.textColor = [UIColor whiteColor];
	zeroLabel.shadowColor = [UIColor blackColor];
	zeroLabel.shadowOffset = CGSizeMake(1, 1);
	zeroLabel.text = @"0";
	zeroLabel.font = font;
	[self addSubview:zeroLabel];

	maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 10, 10)];
	maxLabel.backgroundColor = [UIColor clearColor];
	maxLabel.textColor = [UIColor whiteColor];
	maxLabel.shadowColor = [UIColor blackColor];
	maxLabel.shadowOffset = CGSizeMake(1, 1);
	maxLabel.text = @"1";
	maxLabel.font = font;
	maxLabel.textAlignment = NSTextAlignmentRight;
	[self addSubview:maxLabel];

	unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 18, 10)];
	unitLabel.backgroundColor = [UIColor clearColor];
	unitLabel.textColor = [UIColor whiteColor];
	unitLabel.shadowColor = [UIColor blackColor];
	unitLabel.shadowOffset = CGSizeMake(1, 1);
	unitLabel.text = @"m";
	unitLabel.font = font;
	[self addSubview:unitLabel];
}


// -----------------------------------------------------------------------------
// LXMapScaleView::update
// -----------------------------------------------------------------------------
- (void)update
{

    float metersPerPixel = 0;

    // Meters per pixel = 156543.03392 * Math.cos(latLng.lat() * Math.PI / 180) / Math.pow(2, zoom)
    // 'latLng.lat()' = map.getCenter.lat()
    // 'zoom' = map.getZoom()

    double zoom = [mapTemplate currentZoom];
    CLLocationCoordinate2D coord = [mapTemplate currentCenter];
    metersPerPixel = 156543.03392 * cos(coord.latitude * M_PI / 180.0) / pow(2, zoom);

	CGFloat maxScaleWidth = maxWidth-40;
	
	NSUInteger maxValue = 0;
	NSString* unit = @"";
	
	if ( metric )
	{
		float meters = maxScaleWidth*metersPerPixel;
		
		if ( meters > 2000.0f )
		{
			// use kilometer scale
			unit = _(@"distance-km");
			static const NSUInteger kKilometerScale[] = {1,2,5,10,20,50,100,200,500,1000,2000,5000,10000,20000,50000};
			float kilometers = meters / 1000.0f;
			
			for ( int i = 0; i < 15; ++i )
			{
				if ( kilometers < kKilometerScale[i] )
				{
					scaleWidth = maxScaleWidth * kKilometerScale[i-1]/kilometers;
					maxValue = kKilometerScale[i-1];
					break;
				}
			}
		}
		else
		{
			// use meter scale
			unit = _(@"distance-m");
			static const NSUInteger kMeterScale[11] = {1,2,5,10,20,50,100,200,500,1000,2000};

			for ( int i = 0; i < 11; ++i )
			{
				if ( meters < kMeterScale[i] )
				{
					scaleWidth = maxScaleWidth * kMeterScale[i-1]/meters;
					maxValue = kMeterScale[i-1];
					break;
				}
			}
		}
	}
	else
	{
		float feet = maxScaleWidth*metersPerPixel*kFeetPerMeter;
		
		if ( feet > kFeetPerMile )
		{
			// user mile scale
			unit = _(@"distance-mi");
			static const double kMileScale[] = {1,2,5,10,20,50,100,200,500,1000,2000,5000,10000,20000,50000};
			float miles = feet / kFeetPerMile;
			
			for ( int i = 0; i < 15; ++i )
			{
				if ( miles < kMileScale[i] )
				{
					scaleWidth = maxScaleWidth * kMileScale[i-1]/miles;
					maxValue = kMileScale[i-1];
					break;
				}
			}
		}
		else
		{
			// use foot scale
			unit = _(@"distance-ft");
			static const double kFootScale[] = {1,2,5,10,20,50,100,200,500,1000,2000,5000,10000};

			for ( int i = 0; i < 13; ++i )
			{
				if ( feet < kFootScale[i] )
				{
					scaleWidth = maxScaleWidth * kFootScale[i-1]/feet;
					maxValue = kFootScale[i-1];
					break;
				}
			}
		}
	}
	
	maxLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)maxValue];
	unitLabel.text = unit;
	
	[self layoutSubviews];
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setFrame:
// -----------------------------------------------------------------------------
- (void)setFrame:(CGRect)aFrame
{
	[self setMaxWidth:aFrame.size.width];
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setBounds:
// -----------------------------------------------------------------------------
- (void)setBounds:(CGRect)aBounds
{
	[self setMaxWidth:aBounds.size.width];
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setMaxWidth:
// -----------------------------------------------------------------------------
- (void)setMaxWidth:(CGFloat)aMaxWidth
{
    // Already there.
	if (maxWidth == aMaxWidth)
        return;

    // Don't go overboard
    if (aMaxWidth >= kMinimumWidth && aMaxWidth < kMaximumWidth) {
		maxWidth = aMaxWidth;
		[self setNeedsLayout];
    } else {
        NSLog(@"Silly aMaxWidth: %f (expected > %f and < %f", aMaxWidth, kMinimumWidth, kMaximumWidth);
    }
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setAlpha:
// -----------------------------------------------------------------------------
- (void)setAlpha:(CGFloat)aAlpha
{
	[super setAlpha:aAlpha];
	zeroLabel.alpha = aAlpha;
	maxLabel.alpha = aAlpha;
	unitLabel.alpha = aAlpha;
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setStyle:
// -----------------------------------------------------------------------------
- (void)setStyle:(LXMapScaleStyle)aStyle
{
	if ( style != aStyle )
	{
		style = aStyle;
		
		[self setNeedsDisplay];
	}
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setPosition:
// -----------------------------------------------------------------------------
- (void)setPosition:(LXMapScalePosition)aPosition
{
	if ( position != aPosition )
	{
		position = aPosition;

		[self setNeedsLayout];
	}
}


// -----------------------------------------------------------------------------
// LXMapScaleView::setMetric:
// -----------------------------------------------------------------------------
- (void)setMetric:(BOOL)aIsMetric
{
	if ( metric != aIsMetric )
	{
		metric = aIsMetric;
		
		[self update];
	}
}


// -----------------------------------------------------------------------------
// LXMapScaleView::layoutSubviews
// -----------------------------------------------------------------------------
- (void)layoutSubviews
{
    CGSize size = [maxLabel.text sizeWithAttributes: @{NSFontAttributeName:maxLabel.font}];
    CGSize maxLabelSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
	// Original: CGSize maxLabelSize = [maxLabel.text sizeWithFont:maxLabel.font];

	maxLabel.frame = CGRectMake(zeroLabel.frame.size.width/2.0f+1+scaleWidth+1 - (maxLabelSize.width+1)/2.0f,
								0, 
								maxLabelSize.width+1,
								maxLabel.frame.size.height);
	
	CGSize unitLabelSize = unitLabel.frame.size;
	unitLabel.frame = CGRectMake(CGRectGetMaxX(maxLabel.frame),
								 0,
								 unitLabelSize.width,
								 unitLabelSize.height);
	
    CGSize mapSize = CGSizeMake(0, 0);
    mapSize = mapTemplate.mapvc.view.bounds.size;
	CGRect frame = self.bounds;
	frame.size.width = CGRectGetMaxX(unitLabel.frame) - CGRectGetMinX(zeroLabel.frame);
	
	switch (position)
	{
		case kLXMapScalePositionTopLeft:
		{
			frame.origin = CGPointMake(padding.left,
									   padding.top);
			self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
			break;
		}
			
		case kLXMapScalePositionTop:
		{
			frame.origin = CGPointMake((mapSize.width - frame.size.width) / 2.0f,
									   padding.top);
			self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
			break;
		}
			
		case kLXMapScalePositionTopRight:
		{
			frame.origin = CGPointMake(mapSize.width - padding.right - frame.size.width,
									   padding.top);
			self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
			break;
		}
			
		default:
		case kLXMapScalePositionBottomLeft:
		{
			frame.origin = CGPointMake(padding.left,
									   mapSize.height - padding.bottom - frame.size.height);
			self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
			break;
		}
			
		case kLXMapScalePositionBottom:
		{
			frame.origin = CGPointMake((mapSize.width - frame.size.width) / 2.0f,
									   mapSize.height - padding.bottom - frame.size.height);
			self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
			break;
		}
			
		case kLXMapScalePositionBottomRight:
		{
			frame.origin = CGPointMake(mapSize.width - padding.right - frame.size.width,
									   mapSize.height - padding.bottom - frame.size.height);
			self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
			break;
		}
	}
	
	super.frame = frame;

	[self setNeedsDisplay];
}


// -----------------------------------------------------------------------------
// LXMapScaleView::drawRect:
// -----------------------------------------------------------------------------
- (void)drawRect:(CGRect)aRect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	if ( style == kLXMapScaleStyleTapeMeasure )
	{
		CGRect baseRect = CGRectZero;
		UIColor* strokeColor = [UIColor whiteColor];
		UIColor* fillColor = [UIColor blackColor];
		
		baseRect = CGRectMake(3, 24, scaleWidth+2, 3);
		[strokeColor setFill];
		CGContextFillRect(ctx, baseRect);
		
		baseRect = CGRectInset(baseRect, 1, 1);
		[fillColor setFill];
		CGContextFillRect(ctx, baseRect);

		baseRect = CGRectMake(3, 12, 3, 12);
		for ( int i = 0; i <= 5; ++i )
		{
			CGRect rodRect = baseRect;
			rodRect.origin.x += i*(scaleWidth-1)/5.0f;
			[strokeColor setFill];
			CGContextFillRect(ctx, rodRect);
			
			rodRect = CGRectInset(rodRect, 1, 1);
			rodRect.size.height += 2;
			[fillColor setFill];
			CGContextFillRect(ctx, rodRect);
		}
		
		baseRect = CGRectMake(3+(scaleWidth-1)/10.0f, 16, 3, 8);
		for ( int i = 0; i < 5; ++i )
		{
			CGRect rodRect = baseRect;
			rodRect.origin.x += i*(scaleWidth-1)/5.0f;
			[strokeColor setFill];
			CGContextFillRect(ctx, rodRect);

			rodRect = CGRectInset(rodRect, 1, 1);
			rodRect.size.height += 2;
			[fillColor setFill];
			CGContextFillRect(ctx, rodRect);
		}
	}
	else if ( style == kLXMapScaleStyleBar )
	{
		CGRect scaleRect = CGRectMake(4, 12, scaleWidth, 3);
		
		[[UIColor blackColor] setFill];
		CGContextFillRect(ctx, CGRectInset(scaleRect, -1, -1));
		
		[[UIColor whiteColor] setFill];
		CGRect unitRect = scaleRect;
		unitRect.size.width = scaleWidth/5.0f;
		
		for ( int i = 0; i < 5; i+=2 )
		{
			unitRect.origin.x = scaleRect.origin.x + unitRect.size.width*i;
			CGContextFillRect(ctx, unitRect);
		}
	}
	else if ( style == kLXMapScaleStyleAlternatingBar )
	{
		CGRect scaleRect = CGRectMake(4, 12, scaleWidth, 6);
		
		[[UIColor blackColor] setFill];
		CGContextFillRect(ctx, CGRectInset(scaleRect, -1, -1));
		
		[[UIColor whiteColor] setFill];
		CGRect unitRect = scaleRect;
		unitRect.size.width = scaleWidth/5.0f;
		unitRect.size.height = scaleRect.size.height/2.0f;
		
		for ( int i = 0; i < 5; ++i )
		{
			unitRect.origin.x = scaleRect.origin.x + unitRect.size.width*i;
			unitRect.origin.y = scaleRect.origin.y + unitRect.size.height*(i%2);
			CGContextFillRect(ctx, unitRect);
		}
	}
}


@end

