attribute vec4 a_Position;  // 一个变量的声明

attribute vec2 a_TexCoordIn;
varying vec2 v_TexCoordOut;

void main(void) {
    gl_Position = a_Position;
    v_TexCoordOut = a_TexCoordIn;
}

/**
 shader 共有三种变量:
         - attribute
         - uniform
         - varying
 区别: http://www.jianshu.com/p/989cad48e01a
 */
