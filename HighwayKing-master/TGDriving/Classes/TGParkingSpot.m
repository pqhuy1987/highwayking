//
//  TGParkingSpot.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGParkingSpot.h"


@implementation TGParkingSpot
@synthesize highlightSprite, taskType;

- (id)initWithPosition:(CGPoint)_pos highlight:(CCSprite *)_sprite taskType:(TGTaskType)_type {
	if ( (self = [super init]) ) {
		self.highlightSprite = _sprite;
		self.highlightSprite.position = _pos;
		
		self.taskType = _type;
		
		[self.highlightSprite setAnchorPoint:ccp(0,0)];
		self.highlightSprite.opacity = 0;
	}
	return self;
}

- (CGRect)collidingRect {
	CGPoint p = [[self.highlightSprite parent] convertToWorldSpace:self.highlightSprite.position];
	//p.x += 15;
	//p.y += 15; // Padding for glow
	
    CGSize hilSize = [self.highlightSprite contentSize];
	return CGRectMake(p.x, p.y, hilSize.width, hilSize.height);
}

- (CGPoint)position {
    CGPoint hilPoint = [[self.highlightSprite parent] convertToWorldSpace:self.highlightSprite.position];
    return hilPoint; // Glow padding accounted for
}

- (void)setPosition:(CGPoint)p {
    self.highlightSprite.position = p;
}

- (void)highlight {
	[self.highlightSprite runAction:[CCFadeIn actionWithDuration:0.3]];
	[self performSelector:@selector(unHighlight) withObject:nil afterDelay:1.0];
}

- (void)unHighlight {
	[self.highlightSprite runAction:[CCFadeOut actionWithDuration:0.2]];
}


#pragma mark TGColliding Delegate Methods

- (void)collidedWith:(id)collidee {
    
}

#pragma mark -

- (void)dealloc {
	[highlightSprite release];
	
	[super dealloc];
}

@end
