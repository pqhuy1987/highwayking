//
//  TGLineLayer.h
//  TGDriving
//
//  Created by Charles Magahern on 10/23/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGTruck.h"

typedef enum _drawingMode {
	TGLineLayerDrawingModeDrivingPath,
	TGLineLayerDrawingModeRawPath
} TGLineLayerDrawingMode;

@interface TGLineLayer : CCColorLayer {
	TGLineLayerDrawingMode drawingMode;
	NSArray *trucks;
}

@property (assign) TGLineLayerDrawingMode drawingMode;
@property (nonatomic, retain) NSArray *trucks;

-(id) initWithTrucksArray:(NSArray *)_trucks;

@end
