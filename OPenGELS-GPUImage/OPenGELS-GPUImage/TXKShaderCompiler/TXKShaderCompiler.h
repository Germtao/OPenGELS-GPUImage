//
//  TXKShaderCompiler.h
//  OPenGELS-GPUImage
//
//  Created by TAO on 2017/10/27.
//  Copyright © 2017年 tTao. All rights reserved.
//
/**
 什么是着色器?
     - 通常用来处理纹理对象, 并且把处理好的纹理对象渲染到帧缓存上, 从而显示到屏幕上
     - 提取纹理信息, 可以处理顶点坐标空间转换, 纹理色彩度调整(滤镜效果)等操作
     - 着色器分为 '顶点着色器' / '片段着色器':
                 1. 顶点着色器 - 确定图形形状
                 2. 片段着色器 - 确定图形渲染颜色
     - 步骤: 1.编辑着色器代码 2.创建着色器 3.编译着色器
 */

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface TXKShaderCompiler : NSObject

- (instancetype)initWithVertexShader:(NSString *)vertexShader fragmentShader:(NSString *)fragmentShader;

/**
 启动程序
 */
- (void)prepareToDraw;

/**
 获取全局参数
 🐽注意: 一定要在连接完成后才行, 否则拿不到

 @param uniformName uniform
 @return 全局参数
 */
- (GLuint)uniformIndex:(NSString *)uniformName;

/**
 获取全局属性

 @param attributeName attribute
 @return 属性
 */
- (GLuint)attributeIndex:(NSString *)attributeName;

@end
