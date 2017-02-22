//
//  GameOverDialog.m
//  TGDriving
//
//  Created by Charles Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "GameOverDialog.h"


@implementation GameOverDialog
@synthesize opacity, color;
@synthesize target, playAgainAction;

-(id) init {
	if ((self = [super init])) {
		CCSprite *bgSprt = [CCSprite spriteWithFile:@"game_over_bg.png"];
		[self addChild:bgSprt];
		
		CCMenuItemImage *playAgain = [CCMenuItemImage itemFromNormalImage:@"play_again_btn.png"
															selectedImage:@"play_again_btn.png"
																   target:self
																 selector:@selector(playAgain:)];
		
		CCMenu *menu = [CCMenu menuWithItems:playAgain, nil];
		[menu alignItemsVertically];
		menu.position = ccp(0.0, -[bgSprt boundingBox].size.height / 2 + 45.0);
		
		[self addChild:menu];
		
		self.opacity = 0;
	}
	return self;
}

- (void)onEnter {
	[super onEnter];
	
	self.position = ccp(self.position.x, self.position.y - 20.0);
	CCSpawn *enterSpawn = [CCSpawn actions:
						   [CCMoveBy actionWithDuration:0.15 position:ccp(0.0, 20.0)],
						   [CCFadeIn actionWithDuration:0.15],
						   nil];
	[self runAction:enterSpawn];
}

- (void)playAgain:(CCMenuItem *)sender {
	[self dismiss];
	if (target != nil && playAgainAction != NULL) {
		if ([target respondsToSelector:playAgainAction]) {
			[target performSelector:playAgainAction];
		}
	}
}

- (void)setOpacity:(GLubyte)o {
	for (id child in [self children]) {
		if ([child conformsToProtocol:@protocol(CCRGBAProtocol)]) {
			CCNode<CCRGBAProtocol> *n = (CCNode<CCRGBAProtocol> *) child;
			[n setOpacity:o];
		}
	}
	opacity = o;
}

- (void)setColor:(ccColor3B)c {
	for (id child in [self children]) {
		if ([child conformsToProtocol:@protocol(CCRGBAProtocol)]) {
			CCNode<CCRGBAProtocol> *n = (CCNode<CCRGBAProtocol> *) child;
			[n setColor:c];
		}
	}
	
	color = c;
}

- (void)remove {
	[self removeFromParentAndCleanup:YES];
}

- (void)dismiss {
	CCSpawn *exitSpawn = [CCSpawn actions:
						   [CCMoveBy actionWithDuration:0.15 position:ccp(0.0, -20.0)],
						   [CCFadeOut actionWithDuration:0.15],
						   nil];
	[self runAction:[CCSequence actions:
					 exitSpawn,
					 [CCCallFunc actionWithTarget:self selector:@selector(remove)],
					 nil]];
}

- (void)dealloc {
	[super dealloc];
}

@end
