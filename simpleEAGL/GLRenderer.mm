//
//  GLRenderer.cpp
//  simpleEAGL
//
//  Created by 城市　博史 on 2014/11/20.
//  Copyright (c) 2014年 城市　博史. All rights reserved.
//

#include "GLRenderer.h"

#define USE_DEPTH_BUFFER 1

GLRenderer::GLRenderer()
: _context(nullptr)
, _uiViewRenderBuffer(0)
, _uiViewFrameBuffer(0)
, _uiDepthRenderBuffer(0)
, _width(0)
, _height(0)
{
}

GLRenderer::~GLRenderer()
{
	destroyFramebuffer();
	
	if ([EAGLContext currentContext] == _context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[_context release];
	_context = nullptr;
}

void GLRenderer::init(CAEAGLLayer* layer)
{
	_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if (!_context) {
		printf("Create context failed");
	}
	[EAGLContext setCurrentContext:_context];

	createFramebuffer(layer);
}

void GLRenderer::createFramebuffer(CAEAGLLayer* layer)
{
	glGenFramebuffers(1, &_uiViewFrameBuffer);
	glGenRenderbuffers(1, &_uiViewRenderBuffer);
	
	glBindFramebuffer(GL_FRAMEBUFFER, _uiViewFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _uiViewRenderBuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _uiViewRenderBuffer);
	[_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
	//	_uiDepthRenderBuffer = depthBuffer;
	
	if (USE_DEPTH_BUFFER) {
		glGenRenderbuffers(1, &_uiDepthRenderBuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, _uiDepthRenderBuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _uiDepthRenderBuffer);
	}
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Create framebuffer failed: %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
	}
}

void GLRenderer::destroyFramebuffer()
{
	if (_uiViewFrameBuffer) {
		glDeleteFramebuffers(1, &_uiViewFrameBuffer);
		_uiViewFrameBuffer = 0;
	}
	
	if (_uiViewRenderBuffer) {
		glDeleteRenderbuffers(1, &_uiViewRenderBuffer);
		_uiViewRenderBuffer = 0;
	}
	
	if (_uiDepthRenderBuffer) {
		glDeleteRenderbuffers(1, &_uiDepthRenderBuffer);
		_uiDepthRenderBuffer = 0;
	}
}

void GLRenderer::setCurrentContext()
{
	[EAGLContext setCurrentContext: _context];
}