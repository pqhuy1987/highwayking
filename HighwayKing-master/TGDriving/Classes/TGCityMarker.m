//
//  TGCityMarker.m
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "TGCityMarker.h"


@implementation TGCityMarker

-(id) init {
	if ( (self = [super init]) ) {
		marker = [CCSprite spriteWithFile:@"citymarker.png"];
		glow   = [CCSprite spriteWithFile:@"citymarker_glow.png"];
		glow.opacity = 0;
		glow.scale = 1.0;
		
		[self addChild:glow];
		[self addChild:marker];
		
		id fade = [CCFadeIn actionWithDuration:0.4];
		id callFunc = [CCCallFunc actionWithTarget:self selector:@selector(animationComplete)];
		
		marker.opacity = 0;
		[marker runAction:[CCSequence actions:fade, callFunc, nil]];
		
	}
	
	return self;
}

- (void)animationComplete {
	ccTime duration = 1.5;
	id delay = [CCDelayTime actionWithDuration:0.5];
	
	id scale = [CCScaleTo actionWithDuration:duration scale:3.0];
	id fade  = [CCFadeOut actionWithDuration:duration];
	id fadeBack = [CCFadeIn actionWithDuration:0.01];
	id scaleBack = [CCScaleTo actionWithDuration:0.01 scale:0.2];
	
	id fadeSeq = [CCSequence actions:fade, fadeBack, delay, nil];
	id scaleSeq = [CCSequence actions:scale, scaleBack, delay, nil];
	[glow runAction:[CCRepeatForever actionWithAction:fadeSeq]];
	[glow runAction:[CCRepeatForever actionWithAction:scaleSeq]];
}

- (id)initWithPosition:(CGPoint)_position completed:(BOOL)_completed {
	self = [self init];
	self.position = _position;
	
	if (_completed) {
		[marker setTexture:[[CCTextureCache sharedTextureCache] addImage:@"citymarker_completed.png"]];
	}
	
	return self;
}

+ (id)markerWithPosition:(CGPoint)location completed:(BOOL)completed {
	return [[[self alloc] initWithPosition:location completed:completed] autorelease];
}

- (void)disappear {
	id delay = [CCDelayTime actionWithDuration:0.2];
	id remove = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];
	
	[marker runAction:[CCFadeOut actionWithDuration:0.2]];
	[glow runAction:[CCFadeOut actionWithDuration:0.2]];
	[self runAction:[CCSequence actions:delay, remove, nil]];
	
}

- (void)removeSelf {
	[self removeFromParentAndCleanup:YES];
}

@end
