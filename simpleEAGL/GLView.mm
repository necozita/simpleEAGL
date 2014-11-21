//
//  GLView.m
//  simpleEAGL
//
//  Created by necozita on 2014/11/20.
//  Copyright (c) 2014年 necozita. All rights reserved.
//

#import "GLView.h"
#import "QuartzCore/CADisplayLink.h"
#import "OpenGLES/ES2/gl.h"
#import "OpenGLES/ES2/glext.h"

GLuint CreateShader(const GLchar* vertexShader, const GLchar* fragmentShader)
{
	char logBuffer[1024];
	
	GLuint shader, prog;
	int status = 0;
	
	prog = glCreateProgram();
	NSLog(@"prog: %d", prog);

	// vertex shader
	shader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(shader, 1, &vertexShader, nullptr);
	glCompileShader(shader);
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	
	if (status == GL_FALSE) {
		int logLength = 0;
		glGetShaderInfoLog(shader, sizeof(logBuffer), &logLength, logBuffer);
		NSLog(@"Vertex shader failed: %s\n", logBuffer);
		glDeleteShader(shader);
		glDeleteProgram(prog);
		return 0;
	}
	
	glAttachShader(prog, shader);
	glDeleteShader(shader);
	
	// fragment shader
	shader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(shader, 1, &fragmentShader, nullptr);
	glCompileShader(shader);
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (status == GL_FALSE) {
		int logLength = 0;
		glGetShaderInfoLog(shader, sizeof(logBuffer), &logLength, logBuffer);
		printf("Fragment shader failed: %s\n", logBuffer);
		glDeleteShader(shader);
		glDeleteProgram(prog);
		return 0;
	}
	
	glAttachShader(prog, shader);
	glDeleteShader(shader);
	
	// Link
	glLinkProgram(prog);
	
	// Validate
	glValidateProgram(prog);
	
	int logLength = 0;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		glGetProgramInfoLog(prog, logLength, &logLength, logBuffer);
		printf("Shader link error %s\n", logBuffer);
		glDeleteProgram(prog);
		return 0;
	}
	
	return prog;
}





@interface GLView() {
	CADisplayLink* displayLink;
	GLuint shaderProgram;
	GLint shaderAttribVertexPosition;
}

- (void)setupGL;
- (void)update:(CADisplayLink*)sender;
@end


@implementation GLView

+ (id)viewWithFrame:(CGRect)frame
{
	return [[[self alloc] initWithFrame:frame] autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		NSLog(@"initWithFrame");
        // Initialization code
		[self setupGL];
	}
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// OpenGL描画
+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

- (void)setupGL
{
	CAEAGLLayer* glLayer = (CAEAGLLayer*)self.layer;
	
	glLayer.opaque = YES;
	glLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithBool:NO],
								  kEAGLDrawablePropertyRetainedBacking,
								  kEAGLColorFormatRGBA8,
								  kEAGLDrawablePropertyColorFormat,
								  nil
								  ];
	
	// コンテキスト生成ほか
	_renderer = new GLRenderer();
	_renderer->init(glLayer);
	
	// Create shader
	const GLchar* vertexShader =
	"attribute vec4 vertexPosition;\n"
	"void main()\n"
	"{                           \n"
	"    gl_Position = vertexPosition; \n"
	"}                           \n";
	
	const GLchar* fragmentShader =
	"precision mediump float;                  \n"
	"void main()                               \n"
	"{                                         \n"
	"    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0); \n"
	"}                                         \n";

	shaderProgram = CreateShader(vertexShader, fragmentShader);
	if (shaderProgram == 0) {
		return;
	}

	shaderAttribVertexPosition = glGetAttribLocation(shaderProgram, "vertexPosition");

	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
}

- (void)startMainLoop
{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopMainLoop
{
	if (displayLink) {
		[displayLink invalidate];
		displayLink = nil;
	}
}

- (void)update:(CADisplayLink*)sender
{
    const GLfloat squareVertices[] = {
		-0.5f, -0.5f, 0.2f,
		0.5f,  -0.5f, 0.2f,
		-0.5f,  0.5f, 0.2f,
		0.5f,   0.5f, 0.2f,
	};
	_renderer->setCurrentContext();
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glBindFramebuffer(GL_FRAMEBUFFER, _renderer->_uiViewFrameBuffer);
	glViewport(0, 0, _renderer->_width, _renderer->_height);

	// Setup shader
	glUseProgram(shaderProgram);
	glEnableVertexAttribArray(shaderAttribVertexPosition);
	glVertexAttribPointer(shaderAttribVertexPosition, 3, GL_FLOAT, GL_FALSE, 0, squareVertices);
	
	// Draw
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableVertexAttribArray(shaderAttribVertexPosition);
	glUseProgram(0);
	
	glBindRenderbuffer(GL_RENDERBUFFER, _renderer->_uiViewRenderBuffer);
	[_renderer->_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)layoutSubviews
{
	NSLog(@"layoutSubviews!");
	[EAGLContext setCurrentContext:_renderer->_context];
	_renderer->destroyFramebuffer();
	_renderer->createFramebuffer((CAEAGLLayer*)self.layer);
	[self update:nil];
}

- (void)dealloc
{
	[self stopMainLoop];
	
	if (shaderProgram) {
		glDeleteProgram(shaderProgram);
	}
	
	if (_renderer) {
		delete _renderer;
		_renderer = nullptr;
	}
	[super dealloc];
}

@end
