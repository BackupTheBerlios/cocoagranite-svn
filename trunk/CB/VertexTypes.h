/*
 *  VertexTypes.h
 *  CocoaGranite
 *
 *  Created by Kelvin Nishikawa on Tue Apr 06 2004.
 *  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
 *
 */

#ifndef __VertexTypes_h_
#define __VertexTypes_h_

#include <OpenGL/gl.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Vertex Types
 *  Basic Vector and Color types defined in this file are non-destructive unions of compatible
 *  OpenGL vector data. When using the VectorTypes you can use whatever symbol names are most
 *  comfortable for you. Intermixing names should not destroy your data integrity.
 *
 *  All names in this file follow the following pattern.
 *  Basic Types:
 *   x,y,z,w		Standard 4D basis coords in all vector types.
 *   r,g,b,a		Color3/4f's are interchangeable with their Vector3/4f counterparts.
 *   u,v			Texture coordinates are named for Vector2f.
 *   c[0],...c[n]   Vector components can be accessed address-wise, array style.
 *   i				Color4ub can be accessed as a whole unsigned integer.
 *
 *  VertexTypes have the following naming style and order for all types defined here.
 *  Type names include which values are accessable. e.g. Vertex_TNV3 has t,n, and v(no c).
 *  Vertex Types:
 *   t				The texture vertex value.
 *   c				The vertex color value.
 *   n				The vertex normal.
 *   v				The positional vertex value.
 */
		
//Basic Types
	
// 8 bytes
	typedef union {
		struct { GLfloat	x,y; };
		struct { GLfloat	u,v; };
		GLfloat				c[2];
	} Vector2f;

// 12 bytes
	typedef union {
		struct { GLfloat	x,y,z; };
		struct { GLfloat	r,g,b; };
		GLfloat				c[3];
	} Vector3f;

// 16 bytes
	typedef union {
		struct { GLfloat    x,y,z,w; };
		struct { GLfloat    r,g,b,a; };
		GLfloat				c[4];
	} Vector4f;

	typedef Vector3f Color3f;
	typedef Vector4f Color4f;

// 4 bytes
	typedef union {
		struct { GLubyte    r,g,b,a; };
		GLubyte				c[4];
		GLuint				i;
	} Color4ub;

#pragma mark -

/* OpenGL Interleaved Vertex formats
 *  Interleaved formats are defined here for readability convenience.
 *  e.g.
 *    Vertex_TCubV3 *verts;
 *    glInterleavedArrays ( Vertex_TCubV3_Format , sizeof(Vertex_TCubV3) , &verts[0] );
 */

#define Vertex_V2_Format		GL_V2F
#define Vertex_V3_Format		GL_V3F
#define Vertex_CubV2_Format     GL_C4UB_V2F
#define Vertex_CubV3_Format     GL_C4UB_V3F
#define Vertex_CV3_Format       GL_C3F_V3F
#define Vertex_NV3_Format       GL_N3F_V3F
#define Vertex_CNV3_Format      GL_C4F_N3F_V3F
#define Vertex_TV3_Format       GL_T2F_V3F
#define Vertex_TV4_Format       GL_T4F_V4F
#define Vertex_TCubV3_Format    GL_T2F_C4UB_V3F
#define Vertex_TCV3_Format      GL_T2F_C3F_V3F
#define Vertex_TNV3_Format      GL_T2F_N3F_V3F
#define Vertex_TCNV3_Format     GL_T2F_C4F_N3F_V3F
#define Vertex_TCNV4_Format     GL_T4F_C4F_N3F_V4F

#pragma mark -

/* Interleaved Vertex Structures
 *   Mac OS X's small alloc granularity is 16 bytes.
 *   VM page granularity is 4096 bytes. (16 x 256)
 *   Just something to keep in mind when allocating memory.
 */


// GL_V2F				(8 bytes*)
	typedef struct {
		Vector2f	    v; //location
	} Vertex_V2;

// GL_V3F				(12 bytes*)
	typedef struct {
		Vector3f	    v; //location
	} Vertex_V3;

// GL_C4UB_V2F			(12 bytes*)
	typedef struct {
		Color4ub	    c; //color
		Vector2f	    v; //location
	} Vertex_CubV2;

// GL_C4UB_V3F			(16 bytes)
	typedef struct {
		Color4ub	    c; //color
		Vector3f	    v; //location
	} Vertex_CubV3;

// GL_C3F_V3F			(24 bytes*)
	typedef struct {
		Color3f			c; //color
		Vector3f	    v; //location
	} Vertex_CV3;

// GL_N3F_V3F			(24 bytes*)
	typedef struct {
		Vector3f	    n; //normal
		Vector3f	    v; //location
	} Vertex_NV3;

// GL_C4F_N3F_V3F		(40 bytes*)
	typedef struct {
		Color4f			c; //color
		Vector3f	    n; //normal
		Vector3f	    v; //location
	} Vertex_CNV3;

// GL_T2F_V3F			(20 bytes*)
	typedef struct {
		Vector2f	    t; //texture coord
		Vector3f	    v; //location
	} Vertex_TV3;

// GL_T4F_V4F			(32 bytes)
	typedef struct {
		Vector4f	    t; //texture coord
		Vector4f	    v; //location
	} Vertex_TV4;

// GL_T2F_C4UB_V3F		(24 bytes*)
	typedef struct {
		Vector2f	    t; //texture coord
		Color4ub	    c; //color
		Vector3f	    v; //location
	} Vertex_TCubV3;

// GL_T2F_C3F_V3F		(32 bytes)
	typedef struct {
		Vector2f	    t; //texture coord
		Color3f			c; //color
		Vector3f	    v; //location
	} Vertex_TCV3;


// GL_T2F_N3F_V3F		(32 bytes)
	typedef struct {
		Vector2f	    t; //texture coord
		Vector3f	    n; //normal
		Vector3f	    v; //location
	} Vertex_TNV3;

// GL_T2F_C4F_N3F_V3F   (48 bytes)
	typedef struct {
		Vector2f	    t; //texture coord
		Color4f         c; //color
		Vector3f        n; //normal
		Vector3f        v; //location
	} Vertex_TCNV3;

// GL_T4F_C4F_N3F_V4F   (60 bytes*)
	typedef struct {
		Vector4f	    t; //texture coord
		Color4f			c; //color
		Vector3f	    n; //normal
		Vector4f	    v; //location
	} Vertex_TCNV4;


#ifdef __cplusplus
}
#endif

#endif /* __VertexTypes_h_ */