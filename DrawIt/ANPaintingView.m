//
//  ANPaintingView.m
//  DrawIt
//
//  Created by Andrew Zhuk on 23.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANPaintingView.h"
#import "ANVectorGeometry.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"

//CONSTANTS:

#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		2
#define kBrushScale			2


// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
	UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
	NUM_UNIFORMS
};

enum {
	ATTRIB_VERTEX,
	NUM_ATTRIBS
};

typedef struct {
	char *vert, *frag;
	GLint uniform[NUM_UNIFORMS];
	GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};


// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;

@interface ANPaintingView()
{
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *mainContext;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
	
	textureInfo_t brushTexture;     // brush texture
    textureInfo_t wholeImageTexture;
    CGFloat brushColor[4];          // brush color
    
	Boolean	firstTouch;
	Boolean needsErase;
    
    // Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;   
    
    // Buffer Objects
    GLuint vboId;
    
    BOOL initialized;
}

@property (nonatomic, strong) NSMutableArray * layersArray;
@property (nonatomic, strong) NSMutableArray * contextsArray;
@property (nonatomic, strong) NSMutableArray * viewFrameBuffersArray;
@property (nonatomic, strong) NSMutableArray * viewRenderBuffersArrayArray;

@property (nonatomic, assign) NSInteger currentViewFrameBuffer;
@property (nonatomic, assign) NSInteger currentViewRenderBuffer;

@property (nonatomic, weak) EAGLContext * currentContex;
@property (nonatomic, assign) GLubyte* pixelData;

@end

@implementation ANPaintingView

@synthesize  location;
@synthesize  previousLocation;

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass {
	return [CAEAGLLayer class];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super initWithCoder:coder])) {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
		eaglLayer.opaque = YES;
		// In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		mainContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		self.currentContex = mainContext;
//        self.currentLayer = (CAEAGLLayer *)eaglLayer;
		if (!mainContext || ![EAGLContext setCurrentContext:mainContext]) {
			return nil;
		}
        
        // Set the view's scale factor as you wish
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
		// Make sure to start with a cleared buffer
		needsErase = YES;
        _scaleFactor = 1.0f;
        
        self.contextsArray = [NSMutableArray arrayWithObject:mainContext];
        self.layersArray = [NSMutableArray arrayWithObject: self.layer];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame {
     if ((self = [super initWithFrame:frame])) {
         CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
         
         eaglLayer.opaque = YES;
         // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
         eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
         
         mainContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
         self.currentContex = mainContext;
         //        self.currentLayer = (CAEAGLLayer *)eaglLayer;
         if (!mainContext || ![EAGLContext setCurrentContext:mainContext]) {
             return nil;
         }
         
         // Set the view's scale factor as you wish
         self.contentScaleFactor = [[UIScreen mainScreen] scale];
         
         // Make sure to start with a cleared buffer
         needsErase = YES;
         _scaleFactor = 1.0f;
         
     }
    return self;
}

- (void) addLayer {
    CAEAGLLayer * newLayer = [CAEAGLLayer layer];
    newLayer.bounds = self.bounds;
    newLayer.backgroundColor = [[UIColor clearColor] CGColor];
    [self.layer setSublayers:@[newLayer]];
    
//    [self.layer addSublayer:newLayer];
    
    newLayer.opaque = YES;
    newLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    EAGLContext * newContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:newContext];
    
    self.currentContex = newContext;
//    self.currentLayer = newLayer;
    
    [self.layersArray addObject:newLayer];
    [self.contextsArray addObject:newContext];
    
    GLuint viewFramebuffer1;
    GLuint viewRenderbuffer1;
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glBindRenderbuffer(GL_RENDERBUFFER, 0);
    
    glGenFramebuffers(1, &viewFramebuffer1);
	glGenRenderbuffers(1, &viewRenderbuffer1);
	
    
    
	glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer1);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer1);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[newContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)newLayer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer1);

    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return;
	}
    self.currentViewFrameBuffer = viewFramebuffer1;
    self.currentViewRenderBuffer = viewRenderbuffer1;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    float red;
    float green;
    float blue;
    float alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [self setBrushColorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)setBrushWidth:(NSInteger)brushWidth {
    _brushWidth = brushWidth;
    glUseProgram(program[PROGRAM_POINT].id);
    glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushWidth);
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
	[EAGLContext setCurrentContext:mainContext];
    
    if (!initialized) {
        initialized = [self initGL];
    }
    else {
//        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
        [self zoom];
    }
	
	// Clear the framebuffer the first time it is allocated
	if (needsErase) {
		[self erase];
		needsErase = NO;
	}
}

- (void)setupShaders
{
	for (int i = 0; i < NUM_PROGRAMS; i++)
	{
		char *vsrc = readFile(pathForResource(program[i].vert));
		char *fsrc = readFile(pathForResource(program[i].frag));
		GLsizei attribCt = 0;
		GLchar *attribUsed[NUM_ATTRIBS];
		GLint attrib[NUM_ATTRIBS];
		GLchar *attribName[NUM_ATTRIBS] = {
			"inVertex",
		};
		const GLchar *uniformName[NUM_UNIFORMS] = {
			"MVP", "pointSize", "vertexColor", "texture",
		};
		
		// auto-assign known attribs
		for (int j = 0; j < NUM_ATTRIBS; j++)
		{
			if (strstr(vsrc, attribName[j]))
			{
				attrib[attribCt] = j;
				attribUsed[attribCt++] = attribName[j];
			}
		}
		
		glueCreateProgram(vsrc, fsrc,
                          attribCt, (const GLchar **)&attribUsed[0], attrib,
                          NUM_UNIFORMS, &uniformName[0], program[i].uniform,
                          &program[i].id);
		free(vsrc);
		free(fsrc);
        
        // Set constant/initalize uniforms
        if (i == PROGRAM_POINT)
        {
            glUseProgram(program[PROGRAM_POINT].id);
            
            // the brush texture will be bound to texture unit 0
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            
            // viewing matrices
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1024, 1024);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Rotate(projectionMatrix, 0.0, 0, 0, 1);// this sample
            
            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, modelViewMatrix.m);
            
            // point size
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], 10.0);
            
            // initialize brush color
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
	}
    
    glError();
}
//- (textureInfo_t) textureFromData:(GLubyte *) data {
//    CGImageRef		brushImage;
//	CGContextRef	brushContext;
//	GLubyte			*brushData;
//	size_t			width, height;
//    GLuint          texId;
//    textureInfo_t   texture;
//    
//    // Get the width and height of the image
//    width = backingWidth;
//    height = backingHeight;
//    
//    // Make sure the image exists
//    if(data) {
//        // Use OpenGL ES to generate a name for the texture.
//        glGenTextures(1, &texId);
//        // Bind the texture name.
//        glBindTexture(GL_TEXTURE_2D, texId);
//        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        // Specify a 2D texture image, providing the a pointer to the image data in memory
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
//        // Release  the image data; it's no longer needed
//        free(data);
//        
//        texture.id = texId;
//        texture.width = width;
//        texture.height = height;
//    }
//    
//    return texture;
//}

// Create a texture from an image
- (textureInfo_t)textureFromName:(NSString *)name
{
    CGImageRef		brushImage;
	CGContextRef	brushContext;
	GLubyte			*brushData;
	size_t			width, height;
    GLuint          texId;
    textureInfo_t   texture;
    
    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;
    
    // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    // Make sure the image exists
    if(brushImage) {
        // Allocate  memory needed for the bitmap context
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage),(int)kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texId);
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D, texId);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);
        
        texture.id = texId;
        texture.width = width;
        texture.height = height;
    }
    
    return texture;
}

//- (void) setCurrentLayer:(NSUInteger)currentLayer {
//    _currentLayer = currentLayer;
//    self.currentContex = [self.contextsArray objectAtIndex:currentLayer];
//}

#pragma mark - init GL
- (BOOL)initGL
{
    // Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffers(1, &viewFramebuffer);
	glGenRenderbuffers(1, &viewRenderbuffer);
	
    self.currentViewFrameBuffer = viewFramebuffer;
    self.currentViewRenderBuffer = viewRenderbuffer;
    
	glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[mainContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
		
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return NO;
	}
    
    // Setup the view port in Pixels
    glViewport(0, 0, backingWidth, backingHeight);
    
    // Create a Vertex Buffer Object to hold our data
    glGenBuffers(1, &vboId);
    
    // Load the brush texture
    brushTexture = [self textureFromName:@"Particle.png"];
    
    // Load shaders
    [self setupShaders];
    
    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    return YES;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [mainContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // Update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);
	
    [self erase];
    return YES;
}

- (void) zoom {
    [EAGLContext setCurrentContext:mainContext];
    backingHeight = self.layer.frame.size.height;
    backingWidth = self.layer.frame.size.width;

    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);
}


// Releases resources when they are not longer needed.
- (void)dealloc
{
    // Destroy framebuffers and renderbuffers
	if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
	if (depthRenderbuffer)
	{
		glDeleteRenderbuffers(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
    // texture
    if (brushTexture.id) {
		glDeleteTextures(1, &brushTexture.id);
		brushTexture.id = 0;
	}
    // vbo
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    
    // tear down context
	if ([EAGLContext currentContext] == mainContext)
        [EAGLContext setCurrentContext:nil];
}
- (void)eraseForLayers
{
	[EAGLContext setCurrentContext:self.currentContex];
	
	// Clear the buffer
    
	glBindFramebuffer(GL_FRAMEBUFFER, self.currentViewFrameBuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Display the buffer
	glBindRenderbuffer(GL_RENDERBUFFER, self.currentViewRenderBuffer);
	[self.currentContex presentRenderbuffer:GL_RENDERBUFFER];
}
// Erases the screen
- (void)erase
{
	[EAGLContext setCurrentContext:self.currentContex];
	
	// Clear the buffer
    
	glBindFramebuffer(GL_FRAMEBUFFER, self.currentViewFrameBuffer);
    if ([self.contextsArray indexOfObject:self.currentContex] == 1){
        glClearColor(0.0, 0.0, 0.0, 1.0);
    } else
        glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	// Display the buffer
	glBindRenderbuffer(GL_RENDERBUFFER, self.currentViewRenderBuffer);
	[self.currentContex presentRenderbuffer:GL_RENDERBUFFER];
}

//- (void) drawSavedPixels {
//    glUseProgram(program[PROGRAM_POINT].id);
//    
//    // the brush texture will be bound to texture unit 0
//    glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 1);
//    
//    [EAGLContext setCurrentContext:self.currentContex];
//	glBindFramebuffer(GL_FRAMEBUFFER, self.currentViewFrameBuffer);
//    GLfloat*		vertexBuffer = malloc(1 * 2 * sizeof(GLfloat));
//
//    glBindBuffer(GL_ARRAY_BUFFER, vboId);
//	glBufferData(GL_ARRAY_BUFFER, 1 * 2 * sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
//    
//    vertexBuffer[ 0] = 0;
//    vertexBuffer[1] = 0;
//	
//    glEnableVertexAttribArray(ATTRIB_VERTEX);
//    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, NULL);
//	
//	// Draw
//    glUseProgram(program[PROGRAM_POINT].id);
//	glDrawArrays(GL_POINTS, 0, 1);
//	
//	// Display the buffer
//	glBindRenderbuffer(GL_RENDERBUFFER, self.currentViewRenderBuffer);
//	[self.currentContex presentRenderbuffer:GL_RENDERBUFFER];
//}

//- (void) savePixelData {
//    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
//    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
//    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
//    NSInteger dataLength = width * height * 4;
//    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
//    // Read pixel data from the framebuffer
//    glPixelStorei(GL_PACK_ALIGNMENT, 4);
//    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
//    wholeImageTexture = [self textureFromData:data];
//}
// Drawings a line onscreen based on where the user touches
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0;
    NSUInteger          count;
    NSUInteger          i;
	 
    start.x /= self.scaleFactor;
	start.y /= self.scaleFactor;
	end.x /= self.scaleFactor;
	end.y /= self.scaleFactor;
    
    start.y = _imageSize.height - start.y;
    end.y = _imageSize.height - end.y;
    
	[EAGLContext setCurrentContext:self.currentContex];
	glBindFramebuffer(GL_FRAMEBUFFER, self.currentViewFrameBuffer);
	
	// Convert locations from Points to Pixels
	CGFloat scale = self.contentScaleFactor;
	start.x /= scale;
	start.y /= scale;
	end.x /= scale;
	end.y /= scale;
	
	// Allocate vertex array buffer
	if(vertexBuffer == NULL){
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
	}
    
	// Add points to the buffer so there are drawing points every X pixels
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
	for(i = 0; i < count; ++i) {
		if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
    
	// Load data to the Vertex Buffer Object
	glBindBuffer(GL_ARRAY_BUFFER, vboId);
	glBufferData(GL_ARRAY_BUFFER, vertexCount * 2 * sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
	
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, NULL);
	
	// Draw
    glUseProgram(program[PROGRAM_POINT].id);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
	// Display the buffer
	glBindRenderbuffer(GL_RENDERBUFFER, self.currentViewRenderBuffer);
	[self.currentContex presentRenderbuffer:GL_RENDERBUFFER];
    glError();
}

// Reads previously recorded points and draws them onscreen. This is the Shake Me message that appears when the application launches.
- (void)playback:(NSMutableArray*)recordedPaths
{
	NSData*				data = [recordedPaths objectAtIndex:0];
	CGPoint*			point = (CGPoint*)[data bytes];
	NSUInteger			count = [data length] / sizeof(CGPoint),
    i;
	
	// Render the current path
	for(i = 0; i < count - 1; ++i, ++point) {
		[self renderLineFromPoint:*point toPoint:*(point + 1)];
	}
	// Render the next path after a short delay
	[recordedPaths removeObjectAtIndex:0];
	if([recordedPaths count])
		[self performSelector:@selector(playback:) withObject:recordedPaths afterDelay:0.01];
}

#pragma mark - color setting

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat) alpha
{
	// Update the brush color
    brushColor[0] = red;// * kBrushOpacity;
    brushColor[1] = green;// * kBrushOpacity;
    brushColor[2] = blue ;//* kBrushOpacity;
    brushColor[3] = alpha;
    
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
}

#pragma mark - zoom handling
- (void) setScaleFactor:(float)scaleFactor {
    if (scaleFactor >= 10) {
        scaleFactor = 10;
    }
    _scaleFactor = scaleFactor;
    
    CGSize newSize = self.imageSize;
    newSize.width *= scaleFactor;
    newSize.height *= scaleFactor;
    
    CGRect frame = self.frame;
    frame.size = newSize;
    self.frame = frame;
    
    glViewport(0, 0, newSize.width, newSize.height);
}

- (void)drawCircleWithRadius:(CGFloat)radius {
    NSInteger pointsNumber;
    CGPoint *array = pointsArrayForCicle(self.center, radius, &pointsNumber);
    self.circlePointsNumber = pointsNumber;
    for (int i = 1; i < pointsNumber; i++){
        [self renderLineFromPoint:array[i - 1] toPoint:array[i]];
    }
    [self renderLineFromPoint:array[pointsNumber - 1] toPoint:array[0]];
    self.circlePoints = array;
}

- (void)setCirclePoints:(CGPoint *)circlePoints{
    if (_circlePoints){
        free(_circlePoints);
    }
    _circlePoints = circlePoints;
}

@end
