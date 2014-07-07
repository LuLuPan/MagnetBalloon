//
//  Ore.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Ore.h"

@implementation Ore

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"ore";
    self.physicsBody.sensor = YES;
}

@end
