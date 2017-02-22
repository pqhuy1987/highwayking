//
//  GameOverDialog.h
//  TGDriving
//
//  Created by Charles Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverDialog : CCNode<CCRGBAProtocol> {
	GLubyte		opacity;
	ccColor3B	color;
	
	id target;
	SEL playAgainAction;
}

@property (assign) GLubyte opacity;
@property (assign) ccColor3B color;
@property (nonatomic, retain) id target;
@property (assign) SEL playAgainAction;

- (void)dismiss;

@end
