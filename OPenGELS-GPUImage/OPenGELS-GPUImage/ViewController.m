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
    [self setupShader];
    [self drawTrangle];
}


#pragma mark - 设置 Open GL ES

// STEP1 - 创建OpenGL上下文, 并且设置为当前上下文
- (void)setupOpenGLESContext {
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; // openGLES 2.0
    [EAGLContext setCurrentContext:_eaglContext];  // 设置为当前上下文
}

// STEP2 - 设置 EAGLLayer
/**
 作用主要有两个:
         1. 为renderbuffer分配共享存储
         2. 将渲染缓冲区呈现给Core Animation, 用renderbuffer中的数据替换了以前的内容
 */
- (void)setupCAEAGLLayer:(CGRect)frame {
    _eaglLayer = [CAEAGLLayer layer];
    _eaglLayer.frame = frame;
    _eaglLayer.backgroundColor = [UIColor cyanColor].CGColor;
    _eaglLayer.opaque = YES;
    
    // kEAGLDrawablePropertyRetainedBacking - 表示不想保存已经显示的内容，因此在下一次显示时，应用程序必须完全重绘一次
    // kEAGLDrawablePropertyColorFormat - 主要规定显示的颜色格式
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
//      目的: 显示 OpenGL 的绘制结果
/**
 两种显示方式:
         1. 简单点: GLKView - 本质上是基于 CAEAGLLayer 的封装
         2. 难点的: CAEAGLLayer
 */
- (void)setupBuffers {
    // 帧缓冲区
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 渲染缓冲区
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    // 把颜色渲染缓存 添加到 帧缓存的GL_COLOR_ATTACHMENT0上,就会自动把渲染缓存的内容填充到帧缓存, 在由帧缓存渲染到屏幕
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
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
    glClearColor(1.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    // 设置窗口尺寸
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

// STEP6 - 设置着色器
- (void)setupShader {
    _shaderCompiler = [[TXKShaderCompiler alloc] initWithVertexShader:@"vertexShader.vsh"
                                                       fragmentShader:@"fragmentShader.fsh"];
    [_shaderCompiler prepareToDraw];
    
    // 获取全局参数,注意 一定要在连接完成后才行，否则拿不到
    _positionSlot = [_shaderCompiler attributeIndex:@"a_Position"];
//    _textureSlot = [_shaderCompiler uniformIndex:@"u_Texture"];
//    _textureCoordSlot = [_shaderCompiler attributeIndex:@"a_TexCoordIn"];
//    _colorSlot = [_shaderCompiler attributeIndex:@"a_Color"];
}

// STEP7 - 绘制图形
- (void)drawTrangle {
    static const GLfloat vertices[] = {
        -1, -1, 0,   // 左下
        1,  -1, 0,   // 右下
        -1, 1,  0,   // 左上
        
//        -1, 1, 0,    // 左上
//        1, 1, 0,     // 右上
//        1, -1, 0     // 右下
    };
    
    /**
     赋值步骤:
         1. 启动这个变量: _positionSlot
         2. 赋值
     */
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    // GLsizei count - 传点数
    glDrawArrays(GL_TRIANGLES, 0, 3);
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
