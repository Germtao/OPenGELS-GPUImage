//
//  TXKShaderCompiler.m
//  OPenGELS-GPUImage
//
//  Created by TAO on 2017/10/27.
//  Copyright © 2017年 tTao. All rights reserved.
//

#import "TXKShaderCompiler.h"

@interface TXKShaderCompiler()

// 着色器程序
@property (nonatomic, assign) GLuint programShader;

// 顶点着色器
@property (nonatomic, assign) GLuint vertexShader;

// 片段着色器
@property (nonatomic, assign) GLuint fragmentShader;

@end

@implementation TXKShaderCompiler

- (instancetype)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader {
    if (self = [super init]) {
        
        [self compilerVertexShader:vertexShader fragmentShader:fragmentShader];
    }
    return self;
}

- (GLuint)uniformIndex:(NSString *)uniformName {
    return glGetUniformLocation(_programShader, [uniformName UTF8String]);
}

- (GLuint)attributeIndex:(NSString *)attributeName {
    return glGetAttribLocation(_programShader, [attributeName UTF8String]);
}

- (void)prepareToDraw {
    glUseProgram(_programShader);
}

#pragma mark - Private Method

/**
 编译顶点着色器/片段着色器

 @param vertexShaderString   顶点着色器
 @param fragmentShaderString 片段着色器
 */
- (void)compilerVertexShader:(NSString *)vertexShaderString fragmentShader:(NSString *)fragmentShaderString {
    
    // 顶点着色器
    _vertexShader = [self compilerShader:vertexShaderString withType:GL_VERTEX_SHADER];
    // 片段着色器
    _fragmentShader = [self compilerShader:fragmentShaderString withType:GL_FRAGMENT_SHADER];
    
    [self createShaderProgram];
}

/**
 创建着色器程序
 */
- (void)createShaderProgram {
    
    // 1. 创建程序
    _programShader = glCreateProgram();
    
    // 2. 绑定着色器 - 顶点/片段着色器
    glAttachShader(_programShader, _vertexShader);
    glAttachShader(_programShader, _fragmentShader);
//    3. 绑定着色器属性,方便以后获取，以后根据角标获取
//    一定要在链接程序之前绑定属性,否则拿不到
    
    glLinkProgram(_programShader);
    
    GLint linkSuccess;
    glGetProgramiv(_programShader, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_programShader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
}

/**
 编译着色器

 @param shaderName 着色器名
 @param shaderType 着色器类型
 @return 着色器
 */
- (GLuint)compilerShader:(NSString *)shaderName withType:(GLenum)shaderType {
    NSString *path = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (!shaderString) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    // 1. 加载着色器源代码
    const char *shaderStringUTF8 = [shaderString UTF8String];
    GLint shaderLength = (GLint)[shaderString length];
    // 2. 创建着色器
    GLuint shader = glCreateShader(shaderType);
    
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderLength);
    
    // 3. 编译着色器
    glCompileShader(shader);
    
    GLint compileSuccess = 0;  // 检查是否完成
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);  // 获取完整状态
    if (compileSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shader;
}

@end
