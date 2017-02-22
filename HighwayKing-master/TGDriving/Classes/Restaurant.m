//
//  Restaurant.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Restaurant.h"
#import "CCDrawingPrimitives.h"

@implementation Restaurant

-(id) init {
	if ((self = [super init])) {
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"restaurant.png"];
        
        CGRect rect = CGRectZero;
        rect.size = texture.contentSize;
        
        [self setTexture:texture];
        [self setTextureRect:rect rotated:NO];
        
        
		TGParkingSpot *parkingSpot1 = [[TGParkingSpot alloc] initWithPosition:ccp(37.0, 72.0) highlight:[[CCSprite alloc] initWithFile:@"parking_spot_highlight.png"] taskType:TGTaskFood];
		[self addParkingSpot:parkingSpot1];
		
		TGParkingSpot *parkingSpot2 = [[TGParkingSpot alloc] initWithPosition:ccp(74.0, 72.0) highlight:[[CCSprite alloc] initWithFile:@"parking_spot_highlight.png"] taskType:TGTaskFood];
		[self addParkingSpot:parkingSpot2];
	}
	
	return self;
}


@end
