//
//  Ore.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Ore.h"

@implementation Ore {
    CCNode *_bar;
}

- (id)initOre {
    self = [super initWithImageNamed:@"Background/element_red_polygon_glossy_4x.png"];
    
    if (self) {
        self.pole_n = TRUE;
    }
    
    return self;
}

- (void)didLoadFromCCB {
    _bar.physicsBody.collisionType = @"ore";
    _bar.physicsBody.sensor = YES;
}

@end
