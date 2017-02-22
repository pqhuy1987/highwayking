//
//  TGBackgroundLayer.m
//  TGDriving
//
//  Created by Charles Magahern on 10/23/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGBackgroundLayer.h"


@implementation TGBackgroundLayer
@synthesize background;

-(id) initWithFile:(NSString *)filename {
	self = [super init];
	
	[self setAnchorPoint:ccp(0,0)];
	[self setPosition:ccp(0,0)];
	
	self.background = [[CCSprite alloc] initWithFile:filename];
	self.background.position = ccp(0,0);
	self.background.anchorPoint = ccp(0,0);
	[self addChild:self.background];
	
	return self;
}

-(id) initWithImage:(UIImage*)image {
	self = [super init];
	
	[self setAnchorPoint:ccp(0,0)];
	[self setPosition:ccp(0,0)];
	
	self.background = [[CCSprite alloc] initWithCGImage:[image CGImage]];
	self.background.position = ccp(0,0);
	self.background.anchorPoint = ccp(0,0);
	[self addChild:self.background];
	
	return self;
}

-(void) dealloc {
	[background release];
	[super dealloc];
}

@end
