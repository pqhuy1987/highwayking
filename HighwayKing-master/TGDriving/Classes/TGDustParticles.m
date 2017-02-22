//
//  TGDustParticles.m
//  TGDriving
//
//  Created by James Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGDustParticles.h"


@implementation TGDustParticles
-(id) init
{
	return [self initWithTotalParticles:5];
}

-(id) initWithTotalParticles:(int) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
		
		// duration
		duration = kCCParticleDurationInfinity;
		
		// Emitter mode: Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
		
		// Gravity Mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity Mode: speed of particles
		self.speed = 15;
		self.speedVar = 10;
		
		// angle
		angle = 270;
		angleVar = 5;
		
		// emitter position
		//CGSize winSize = [[CCDirector sharedDirector] winSize];
		//self.position = ccp(winSize.width/2, 0);
		self.position = ccp(14, 0);
		posVar = ccp(5, 0);
		
		// life of particles
		life = 1;
		lifeVar = 1;
		
		// size, in pixels
		startSize = 17.0f;
		startSizeVar = 3.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
		
		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 0.52f;
		startColor.g = 0.43f;
		startColor.b = 0.282f;
		startColor.a = 1.0f;
		startColorVar.r = 0.002f;
		startColorVar.g = 0.002f;
		startColorVar.b = 0.002f;
		startColorVar.a = 0.0f;
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 0.0f;
		endColor.a = 0.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"dirtParticle.png"];
		
		// additive
		self.blendAdditive = NO;
	}
	
	return self;
}
@end