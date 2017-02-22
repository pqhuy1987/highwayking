//
//  TGBackgroundLayer.h
//  TGDriving
//
//  Created by Charles Magahern on 10/23/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TGBackgroundLayer : CCLayer {
	CCSprite *background;
}

@property (nonatomic, retain) CCSprite *background;

-(id) initWithFile:(NSString *)filename;
-(id) initWithImage:(UIImage *)image;

@end
