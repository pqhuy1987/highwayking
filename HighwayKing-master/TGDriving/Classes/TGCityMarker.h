//
//  TGCityMarker.h
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TGCityMarker : CCSprite {
	CCSprite *marker;
	CCSprite *glow;
}

- (id)initWithPosition:(CGPoint)_position completed:(BOOL)_c;
+ (id)markerWithPosition:(CGPoint)location completed:(BOOL)_c;

- (void)disappear;

@end
