//
//  GLRenderer.h
//  simpleEAGL
//
//  Created by 城市　博史 on 2014/11/20.
//  Copyright (c) 2014年 城市　博史. All rights reserved.
//

#ifndef __simpleEAGL__GLRenderer__
#define __simpleEAGL__GLRenderer__

#include <OpenGLES/EAGL.h>
#include <OpenGLES/EAGLDrawable.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

class GLRenderer
{
public:
	GLRenderer();
	~GLRenderer();
	
	void init(CAEAGLLayer* layer);
	void createFramebuffer(CAEAGLLayer* layer);
	void destroyFramebuffer();
	void setCurrentContext();
	
public:
	EAGLContext* _context;
	GLuint _uiViewRenderBuffer;
	GLuint _uiViewFrameBuffer;
	GLuint _uiDepthRenderBuffer;
	GLint _width;
	GLint _height;
};

#endif /* defined(__simpleEAGL__GLRenderer__) */
