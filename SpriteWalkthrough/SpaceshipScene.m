//
//  SpaceshipScene.m
//  SpriteWalkthrough
//
//  Created by Nicholas Barr on 9/8/13.
//  Copyright (c) 2013 Nicholas Barr. All rights reserved.
//

#import "SpaceshipScene.h"

@interface SpaceshipScene ()
@property BOOL contentCreated;
@property BOOL amiDone;
@property BOOL isShieldEnabled;
@end

CGFloat _shieldpercentage = 100.00f;

@implementation SpaceshipScene
- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        _isShieldEnabled = FALSE;
        self.contentCreated = YES;
    }
    
}


//Introduce the nodes


- (SKSpriteNode *)outerSpace
{
    SKSpriteNode *space = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(4000,4000)];
    space.name = @"space";
    return space;
}


- (SKSpriteNode *)newShield
{
 SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Shield.png"];
    shield.name = @"shield";
    shield.size = CGSizeMake(264,264);
    shield.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shield.size.width/2];
    shield.physicsBody.dynamic = NO;
    return shield;
}


- (SKLabelNode *)newEnergyMeter
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.name = @"energymeter";
    scoreLabel.fontSize = 40;
    scoreLabel.position = CGPointMake(50,50);
    scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.3];
    scoreLabel.text = [NSString stringWithFormat:@"%02.0f", _shieldpercentage];
    return scoreLabel;
    
}



- (SKSpriteNode *)newSpaceship
{
    SKSpriteNode *hull = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    hull.name = @"spaceship";
    hull.size = CGSizeMake(64,64);
    hull.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:hull.size.width/2];
    hull.physicsBody.dynamic = NO;
    return hull;
}


//Define touch behavior

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
    UITouch *touch = [touches anyObject];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    
    if (![nodes containsObject:spaceship]) {
        CGPoint pointToMove = [touch locationInNode: space];
        SKAction *teleport = [SKAction sequence:@[
                                                      [SKAction waitForDuration:0],
                                                      [SKAction moveTo:pointToMove duration:1.0]]];
            [spaceship runAction: [SKAction repeatAction: teleport count:(1)]];
    }
    else if (_shieldpercentage > 0) {
        SKNode *shield = [self childNodeWithName:@"shield"];
        shield = [self newShield];
        shield.position = CGPointMake(0, 0);
        [spaceship addChild:shield];
        spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:132];
        spaceship.physicsBody.dynamic = NO;
        SKAction *fadeOut = [SKAction fadeOutWithDuration: 0.2];
        SKAction *fadeIn = [SKAction fadeInWithDuration: 0.2];
        SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
        SKAction *pulseForever = [SKAction repeatActionForever:pulse];
        [shield runAction: pulseForever];
        _isShieldEnabled = TRUE;
    }
    else {
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
    UITouch *touch = [touches anyObject];
    CGPoint pointToMove = [touch locationInNode: space];
    
    SKAction *teleport = [SKAction sequence:@[
                                              [SKAction waitForDuration:0],
                                              [SKAction moveTo:pointToMove duration:1.0]]];
    [spaceship runAction: [SKAction repeatAction: teleport count:(1)]];
    
    if(_shieldpercentage <= 0){
          [spaceship removeAllChildren];
    }
}

- (void)touchesEnded:(NSSet *) touches withEvent:(UIEvent *)event {
    _isShieldEnabled = FALSE;
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:32];
    spaceship.physicsBody.dynamic = NO;
    [spaceship removeAllChildren];
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isShieldEnabled = FALSE;
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:32];
    spaceship.physicsBody.dynamic = NO;
    [spaceship removeAllChildren];
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}


- (void)addRock
{
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid.png"];
    rock.size = CGSizeMake(8,8);
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height-50);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:rock];
    if (_isShieldEnabled){
        _shieldpercentage = _shieldpercentage - 1;
        if(_shieldpercentage < 0){
            _shieldpercentage = 0;
        }
    }
}


- (void)didBeginContact:(SKPhysicsContact *)contact {
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    SKSpriteNode *spaceship = [self newSpaceship];
    SKSpriteNode *space = [self outerSpace];
    SKLabelNode *scoreLabel = [self newEnergyMeter];
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150);
    [self addChild:space];
    [self addChild:spaceship];
    [self addChild:scoreLabel];
    
    SKAction *makeRocks = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addRock) onTarget:self],
                                                [SKAction waitForDuration:0.10 withRange:0.15]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeRocks]];
}

-(void)update:(CFTimeInterval)currentTime
{
    [self enumerateChildNodesWithName:@"energymeter" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
    }];

}
-(void)didSimulatePhysics
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.text = [NSString stringWithFormat:@"%f", _shieldpercentage];
    [self addChild:self.newEnergyMeter];


    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}
@end