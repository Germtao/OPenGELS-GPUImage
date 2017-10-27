//
//  ViewController.m
//  OPenGELS-GPUImage
//
//  Created by TAO on 2017/10/27.
//  Copyright © 2017年 tTao. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <AVFoundation/AVFoundation.h>
#import "TXKShaderCompiler.h"

@interface ViewController ()
{
    EAGLContext *_eaglContext;
    CAEAGLLayer *_eaglLayer;
    
    GLuint _renderBuffer;
    GLuint _frameBuffer;
    
    // 参数
    GLuint _positionSlot;
    GLuint _textureSlot;
    GLuint _textureCoordSlot;
    GLuint _colorSlot;
    
    TXKShaderCompiler *_shaderCompiler; // 着色器编译器
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupOpenGLESContext];
    [self setupCAEAGLLayer:self.view.bounds];
//    [self clearBuffers];
//    [self setupBuffers];
//    [self setupViewPort];
//    [self setupShader];
}


#pragma mark - 设置 Open GL ES

// STEP1 - 创建OpenGL上下文, 并且设置为当前上下文
- (void)setupOpenGLESContext {
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; // openGLES 2.0
    [EAGLContext setCurrentContext:_eaglContext];  // 设置为当前上下文
}

// STEP2 - 设置 EAGLLayer
- (void)setupCAEAGLLayer:(CGRect)frame {
    _eaglLayer = [CAEAGLLayer layer];
    _eaglLayer.frame = frame;
    _eaglLayer.backgroundColor = [UIColor cyanColor].CGColor;
    _eaglLayer.opaque = YES;
    
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    [self.view.layer addSublayer:_eaglLayer];
}



@end
