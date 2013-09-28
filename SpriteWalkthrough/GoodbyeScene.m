//
//  GoodbyeScene.m
//  SpriteWalkthrough
//
//  Created by Nicholas Barr on 9/27/13.
//  Copyright (c) 2013 Nicholas Barr. All rights reserved.
//

#import "GoodbyeScene.h"
#import "SpaceshipScene.h"


@interface GoodbyeScene ()
@property BOOL contentCreated;
@end


@implementation GoodbyeScene

- (void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newGoodbyeNode]];
    [self addChild: [self newPlayAgain]];
}

- (SKLabelNode *)newGoodbyeNode
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    helloNode.name = @"gameover";
    helloNode.text = @"Game Over :(";
    helloNode.fontSize = 42;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    return helloNode;
    
}

- (SKLabelNode *)newPlayAgain
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    helloNode.name = @"playagain";
    helloNode.text = @"Play Again?";
    helloNode.fontSize = 42;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - 50);
    return helloNode;
    
}

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    SKNode *helloNode = [self childNodeWithName:@"playagain"];
    UITouch *touch = [touches anyObject];
    
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if ((helloNode != nil) && (node == helloNode))
        {
            helloNode.name = nil;
            SKNode *gameover = [self childNodeWithName:@"gameover"];
            [gameover removeFromParent];
            SKAction *moveUp = [SKAction moveByX: 0 y: 100.0 duration: 0.5];
            SKAction *zoom = [SKAction scaleTo: 2.0 duration: 0.25];
            SKAction *pause = [SKAction waitForDuration: 0.5];
            SKAction *fadeAway = [SKAction fadeOutWithDuration: 0.25];
            SKAction *remove = [SKAction removeFromParent];
            SKAction *moveSequence = [SKAction sequence:@[moveUp, zoom, pause, fadeAway, remove]];
            [helloNode runAction: moveSequence completion:^{
                SKScene *spaceshipScene  = [[SpaceshipScene alloc] initWithSize:self.size];
                SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
                [self.view presentScene:spaceshipScene transition:doors];
            }];    }
    }
}


@end
