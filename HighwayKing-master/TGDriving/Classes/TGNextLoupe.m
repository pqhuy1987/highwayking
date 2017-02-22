//
//  TGNextLoupe.m
//  TGDriving
//
//  Created by James Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGNextLoupe.h"
#import "SimpleAudioEngine.h"

@implementation TGNextLoupe

- (id)initWithTruckType:(TGTruckGoalType)type direction:(TGNextLoupeDirection)_direction {
	self = [super init];
	
	direction = _direction;
	
	NSString *truckPath;
	switch (type) {
		case TGTruckGoalTypeBlue:
			truckPath = @"truck_blue.png";
			break;
		case TGTruckGoalTypeOrange:
			truckPath = @"truck_orange.png";
			break;
		default:
			truckPath = @"red_truck.png";
			break;
	}
	
	truck = [[CCSprite alloc] initWithFile:truckPath];
	[truck setScale:0.65];
	[truck setPosition:ccp(-4,-2)];
	
	NSString *loupePath;
	switch (direction) {
		case TGNextLoupeDirectionUp:
			loupePath = @"nextloupe_up.png";
			break;
		case TGNextLoupeDirectionDown:
			loupePath = @"nextloupe_down.png";
			break;
		case TGNextLoupeDirectionLeft:
			loupePath = @"nextloupe_left.png";
			break;
		case TGNextLoupeDirectionRight:
			loupePath = @"nextloupe_right.png";
			break;
		default:
			break;
	}
	
	bg = [[CCSprite alloc] initWithFile:loupePath];
	
	bg.opacity = 0;
	truck.opacity = 0;
	
	[self addChild:bg];
	[self addChild:truck];
	
	[self beginAnimating];
	
	[self performSelector:@selector(destroy) withObject:nil afterDelay:3.0];
	
	return self;
}

- (void)beginAnimating {
	[[SimpleAudioEngine sharedEngine] playEffect:@"beepbeep.aif"];
	
	[bg runAction:[CCFadeIn actionWithDuration:0.2]];
	[truck runAction:[CCFadeIn actionWithDuration:0.2]];
	
	int xDisplacement;
	int yDisplacement;
	
	if (direction == TGNextLoupeDirectionDown || direction == TGNextLoupeDirectionUp) {
		yDisplacement = 10;
		xDisplacement = 0;
	}
	
	if (direction == TGNextLoupeDirectionLeft || direction == TGNextLoupeDirectionRight) {
		yDisplacement = 0;
		xDisplacement = 10;
	}
	
	id bounce = [CCMoveBy actionWithDuration:0.3 position:ccp(xDisplacement, yDisplacement)];
	id bounceDown = [CCMoveBy actionWithDuration:0.5 position:ccp(-xDisplacement, -yDisplacement)];
	
	[self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCEaseSineOut actionWithAction:bounce], [CCEaseSineIn actionWithAction:bounceDown], nil]]];
}

- (void)removeSelf {
	[self removeFromParentAndCleanup:YES];
}

- (void)destroy {
	[bg runAction:[CCFadeOut actionWithDuration:0.5]];
	[truck runAction:[CCFadeOut actionWithDuration:0.5]];
	[self performSelector:@selector(removeSelf) withObject:nil afterDelay:0.55];
}

@end
