//
//  CCMenu+CorrectPadding.m
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "CCMenu+CorrectPadding.h"


@implementation CCMenu (CorrectPadding)

-(void) alignItemsVerticallyWithPadding:(float)padding
{
	CCMenuItem *item;
	float y = 0;
	
	CCARRAY_FOREACH(children_, item) {
		CGSize itemSize = item.contentSize;
	    [item setPosition:ccp(0, y - itemSize.height * item.scaleY / 1.0f)];
	    y -= itemSize.height * item.scaleY + padding;
	}
}

-(id) initWithItemsArray:(NSArray*)items
{
	if( (self=[super init]) ) {
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		
		// menu in the center of the screen
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		self.isRelativeAnchorPoint = NO;
		anchorPoint_ = ccp(0.5f, 0.5f);
		[self setContentSize:s];
		
		// XXX: in v0.7, winSize should return the visible size
		// XXX: so the bar calculation should be done there
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		CGRect r = [[UIApplication sharedApplication] statusBarFrame];
		ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
		if( orientation == CCDeviceOrientationLandscapeLeft || orientation == CCDeviceOrientationLandscapeRight )
			s.height -= r.size.width;
		else
			s.height -= r.size.height;
#endif
		self.position = ccp(s.width/2, s.height/2);
		
		int z=0;
		
		
		for (CCMenuItem *item in items) {
			[self addChild:item z:z];
			z++;
		}
		
			 /*
		if (item) {
			[self addChild: item z:z];
			CCMenuItem *i = va_arg(args, CCMenuItem*);
			while(i) {
				z++;
				[self addChild: i z:z];
				i = va_arg(args, CCMenuItem*);
			}
		}*/
			 
		//	[self alignItemsVertically];
		
		selectedItem = nil;
		state = kCCMenuStateWaiting;
	}
	
	return self;
}

@end
