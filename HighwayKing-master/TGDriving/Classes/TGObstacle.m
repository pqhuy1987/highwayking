//
//  TGObstacle.m
//  TGDriving
//
//  Created by Charles Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGObstacle.h"
#import "GameLayer.h"

@implementation TGObstacle
@synthesize velocity;
@dynamic collidingRect;

- (id)init {
	self = [super init];
	
	self.velocity = ccp(0,0);
	
	_collidingRect = CGRectNull;
	
	return self;
}

- (CGRect)collidingRect {
	if (!CGRectIsNull(_collidingRect)) {
		return CGRectApplyAffineTransform(_collidingRect, [self nodeToWorldTransform]);
	}
	
	int scaleFactor = 10;
    CGRect rect = CGRectMake(0.0 + (scaleFactor / 2), 0.0 + (scaleFactor / 2), self.contentSize.width - scaleFactor, self.contentSize.height - scaleFactor);
    return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

- (void)setCollidingRect:(CGRect)rect {
	_collidingRect = rect;
}

- (void)stop {
	self.velocity = ccp(0, 0);
}

- (void)draw {
     [super draw];
    
    if ([[GameLayer sharedGame] debug_showCollisionRects]) {
        glColor4ub(255, 0, 0, 255);
        glLineWidth(1.0);
        CGRect trect = [self collidingRect];
        CGPoint tpts[] = {
            [self convertToNodeSpace:trect.origin],
            [self convertToNodeSpace:ccp(trect.origin.x + trect.size.width, trect.origin.y)],
            [self convertToNodeSpace:ccp(trect.origin.x + trect.size.width, trect.origin.y + trect.size.height)],
            [self convertToNodeSpace:ccp(trect.origin.x, trect.origin.y + trect.size.height)]
        };
        
        for (int i = 0; i < 4; i++)
            ccDrawLine(tpts[i], tpts[(i != 3 ? i + 1 : 0)]);
    }
	
	if (![[GameLayer sharedGame] gameIsOver]) {
		int multiplier = [[GameLayer sharedGame] speedMultiplier];
		self.position = ccp(self.position.x + (self.velocity.x * multiplier), self.position.y + (self.velocity.y * multiplier));
	}
	
}

#pragma mark TGColliding Delegate Methods

- (void)collidedWith:(id)collidee {
    [self stop];
}

#pragma mark -

@end
