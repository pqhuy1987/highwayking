//
//  Congratulations.m
//  TGDriving
//
//  Created by James Magahern on 11/7/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "Congratulations.h"


//
// ParticleExplosion
//
@implementation Congratulations
-(id) init
{
	return [self initWithTotalParticles:600];
}

-(id) initWithTotalParticles:(int)p
{
	if( (self=[super initWithTotalParticles:p]) ) {
		
		// duration
		duration = 0.1f;
		
		self.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
		
		// Gravity Mode: speed of particles
		self.speed = 20;
		self.speedVar = 40;
		
		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 0;
		
		// angle
		angle = -90;
		angleVar = 90;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 0.4f;
		lifeVar = 2;
		
		// size, in pixels
		startSize = 3.0f;
		startSizeVar = 4.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
		
		// emits per second
		emissionRate = totalParticles/duration;
		
		// color of particles
		startColor.r = 0.0f;
		startColor.g = 0.0f;
		startColor.b = 1.0f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.5f;
		startColorVar.b = 0.5f;
		startColorVar.a = 0.0f;
		
		
		endColor.r = 0.0f;
		endColor.g = 0.0f;
		endColor.b = 1.0f;
		endColor.a = 0.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.5f;
		endColorVar.b = 0.5f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
		
		// additive
		self.blendAdditive = NO;
	}
	
	return self;
}
@end