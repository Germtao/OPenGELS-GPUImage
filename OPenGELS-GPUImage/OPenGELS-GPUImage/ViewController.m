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
    [self clearBuffers];
    [self setupBuffers];
    [self setupViewPort];
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

// STEP3 - 清除缓冲区
- (void)clearBuffers {
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

// STEP4 - 创建缓冲区, 并绑定
- (void)setupBuffers {
    // 帧缓冲区
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 把颜色渲染缓存 添加到 帧缓存的GL_COLOR_ATTACHMENT0上,就会自动把渲染缓存的内容填充到帧缓存, 在由帧缓存渲染到屏幕
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    // 渲染缓冲区
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    // 把渲染缓存绑定到渲染图层上CAEAGLLayer, 并为它分配一个共享内存.
    // 并且会设置渲染缓存的格式, 和宽度
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    GLint width = 0;
    GLint height = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    //check success
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object: %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

// STEP5 - 设置窗口
- (void)setupViewPort {
    // 清空内存
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    // 设置窗口尺寸
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}



@end
