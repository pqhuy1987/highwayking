//
//  TGProgressTimer.m
//  TGDriving
//
//  Created by James Magahern on 12/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGProgressTimer.h"
#import "GameLayer.h"

@implementation TGProgressTimer
@synthesize bumpOnTimeChange, shrinkWhenDone, delegate;
@dynamic progress;

- (id)init {
	if ( (self = [super init]) ) {
		bottom = [[CCSprite alloc] initWithFile:@"ProgressTimerBottom.png"];
		middle = [[CCProgressTimer alloc] initWithFile:@"ProgressTimerMiddle.png"];
		top	   = [[CCSprite alloc] initWithFile:@"ProgressTimerTop.png"];
		label  = [[CCLabelTTF alloc] initWithString:@"5" fontName:@"Helvetica-Bold" fontSize:18];
		
		label.position = ccp(0, 2);

		middle.type = kCCProgressTimerTypeRadialCW;
		
		[self addChild:bottom];
		[self addChild:middle];
		[self addChild:top];
		[self addChild:label];
		
		self.shrinkWhenDone   = YES;
		self.bumpOnTimeChange = YES;
		
		timer = currentTimer = 5;
		progress = 100;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameSpeedMultiplierDidChange:) name:TGGameSpeedMultiplierChangedNotification object:nil];
	}
	
	return self;
}

- (void)gameSpeedMultiplierDidChange:(id)sender {
    int multi = [(NSNumber *) [sender object] intValue];
    [self stopActionByTag:420];
    
    CCActionTween *tween = [CCActionTween actionWithDuration:(currentTimer / multi) key:@"progress" from:progress to:0];
    tween.tag = 420;
    [self runAction:tween];
}

- (void)startCountdown {
    int multi = [[GameLayer sharedGame] speedMultiplier];
	CCActionTween *tween = [CCActionTween actionWithDuration:(timer / multi) key:@"progress" from:100 to:0];
    tween.tag = 420;
	[self runAction:tween];
}

- (id)initWithStartingTime:(int)startTime {
	self = [self init];
	
	timer = currentTimer = startTime;
	
	[self startCountdown];
	
	return self;
}

- (void)setProgress:(int)p {
	if ((p % (100 / timer)) == 0) {
		int newTime = p / (100 / timer);
		
		if (newTime != currentTimer && bumpOnTimeChange) {
			[self runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.05 scale:1.2], [CCScaleTo actionWithDuration:0.05 scale:1.0], nil]];
		}

		currentTimer = newTime;
		
		if (newTime == 0 && shrinkWhenDone) {
			[self runAction:[CCScaleTo actionWithDuration:0.2 scale:0]];
			
			if (delegate != nil) {
				[delegate countdownEnded];
			}
		}
		
		[label setString:[NSString stringWithFormat:@"%d", newTime]];
	}
	
	if (currentTimer >= 10) {
		[label setScale:0.75];
	} else {
		[label setScale:1.0];
	}

	
	progress = p;
	[middle setPercentage:progress];
}

- (int)progress {
	return progress;
}

- (void)dealloc {
	[bottom release];
	[middle release];
	[top release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
