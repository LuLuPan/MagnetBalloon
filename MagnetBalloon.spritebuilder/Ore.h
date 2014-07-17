//
//  Ore.h
//  MagnetBalloon
//
//  Created by Luning Pan on 7/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Ore : CCSprite

@property (nonatomic, assign) BOOL pole_n;
@property (nonatomic, assign) BOOL isOre;
@property (nonatomic, assign) BOOL isProtection;

- (id)initOre;
@end
