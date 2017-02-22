//
//  TGPenaltyDot.m
//  TGDriving
//
//  Created by James Magahern on 12/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGPenaltyDot.h"


@implementation TGPenaltyDot

-(id) init {
	if ((self = [super init])) {
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"penaltydot.png"];
		if( texture ) {
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			
			self.texture = texture;
			self.textureRect = rect;
		}
		
		penaltyLabel = [[CCLabelTTF alloc] initWithString:@"-0" fontName:@"Helvetica-Bold" fontSize:18];
		penaltyLabel.position = ccp(23, 23);
		[self addChild:penaltyLabel];
	}
	
	return self;
}

-(id) initWithPenaltyAmount:(int)penaltyAmount truckLocation:(CGPoint)_truckLocation {
	self = [self init];
	[penaltyLabel setString:[NSString stringWithFormat:@"%d", -penaltyAmount]];
	
	[self animateInFrom:_truckLocation];
	
	[self performSelector:@selector(animateOut) withObject:nil afterDelay:2.0];
	
	return self;
}

-(void) animateInFrom:(CGPoint)from {
	self.position = from;
	self.opacity = 0;
	self.scale = 0.2;
	
	CGPoint animationDirection = ccp(0,0);
	int moveDistance = 60;
	
	if (self.position.x < 0) {
		self.position = ccp(0, self.position.y);
		self.anchorPoint = ccp(0, self.anchorPoint.y);
		animationDirection.x = -1;
	}
	
	if (self.position.x > 320) {
		self.position = ccp(320, self.position.y);
		self.anchorPoint = ccp(1, self.anchorPoint.y);
		animationDirection.x = 1;
	}
	
	if (self.position.y < 0) {
		self.position = ccp(self.position.x, 0);
		self.anchorPoint = ccp(self.anchorPoint.x, 0);
		animationDirection.y = -1;
	}
	
	if (self.position.y > 480) {
		self.position = ccp(self.position.x, 480);
		self.anchorPoint = ccp(self.anchorPoint.x, 1);
		animationDirection.y = 1;
	}
	
	[self runAction:[CCFadeIn actionWithDuration:0.5]];
	[self runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
	
	self.position = ccp(self.position.x + moveDistance * animationDirection.x, self.position.y + moveDistance * animationDirection.y);
	[self runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(-moveDistance * animationDirection.x, -moveDistance * animationDirection.y)]];
}

-(void) animateOut {
	
	id fade = [CCSpawn actions:[CCFadeOut actionWithDuration:0.5], [CCScaleTo actionWithDuration:0.5 scale:1.5], nil];
	id seq = [CCSequence actions:fade, [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)], nil];
	
	[self runAction:seq];
}

-(void) removeSelf {
	[self removeFromParentAndCleanup:YES];
}

@end
