//
//  CountdownNode.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "CountdownNode.h"
#import "GameLayer.h"


@implementation CountdownNode
@synthesize count, delegate;

- (id)initWithSeconds:(NSInteger)secs {
	if ( (self = [super init]) ) {
		self.count = secs;
		
		CCSprite *bg = [[CCSprite alloc] initWithFile:@"countdown-bg.png"];
		[self addChild:bg];
		
		_countdownLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d", self.count] fontName:@"Helvetica" fontSize:18];
		[_countdownLabel setColor:ccc3(255, 255, 255)];
		[self addChild:_countdownLabel];
		
		[self setScale:0.1];
	}
	return self;
}

- (void)onEnter {
	[super onEnter];
	
	CCSpawn *addSpawn = [CCSpawn actions:
						 [CCScaleTo actionWithDuration:0.15 scale:1.0],
						 [CCFadeIn actionWithDuration:0.15],
						 nil];
	[self runAction:addSpawn];
}

- (void)startCountdown {
	_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / [[GameLayer sharedGame] speedMultiplier]) target:self selector:@selector(countdownTimerFired:) userInfo:nil repeats:YES]; 
	
	lastMultiplier = [[GameLayer sharedGame] speedMultiplier];
}

- (void)timerFinished {
	if ([self.delegate respondsToSelector:@selector(countdownEnded)])
		[self.delegate countdownEnded];
	
	CCSpawn *removeSpawn = [CCSpawn actions:
							[CCScaleBy actionWithDuration:0.15 scale:0.1],
							[CCFadeOut actionWithDuration:0.15],
							nil];
	[self runAction:[CCSequence actions:removeSpawn, [CCCallFunc actionWithTarget:self selector:@selector(removeFromParentAndCleanup:)], nil]];
}

- (void)countdownTimerFired:(id)sender {
    if ([[CCDirector sharedDirector] isPaused]) return;
    
	if ([[GameLayer sharedGame] speedMultiplier] != lastMultiplier) {
		[_timer invalidate];
		[self startCountdown];
	}
	
	[_countdownLabel setString:[NSString stringWithFormat:@"%d", --self.count]];
	if (self.count == 0) {
		[_timer invalidate];
		[self timerFinished];
	}
}

@end
