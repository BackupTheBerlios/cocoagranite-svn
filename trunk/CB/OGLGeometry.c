/*
 *  OGLGeometry.c
 *  HotMouseX
 *
 *  Created by Kelvin Nishikawa on Tue Jun 15 2004.
 *  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
 *
 */

#import <CocoaGranite/OGLGeometry.h>

inline Vector2f MakeVector2f(GLfloat x, GLfloat y) { Vector2f v = {{x,y}}; return v;}
inline Vector3f MakeVector3f(GLfloat x, GLfloat y, GLfloat z) { Vector3f v = {{x,y,z}}; return v;}
inline Vector4f MakeVector4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) { Vector4f v = {{x,y,z,w}}; return v;}
inline Color3f MakeColor3f(GLfloat r, GLfloat g, GLfloat b) { Color3f c = {{r,g,b}}; return c;}
inline Color4f MakeColor4f(GLfloat r, GLfloat g, GLfloat b, GLfloat a) { Color4f c = {{r,g,b,a}}; return c;}
inline Color4ub MakeColor4ub(GLubyte r, GLubyte g, GLubyte b, GLubyte a) { Color4ub c = {{r,g,b,a}}; return c;}


inline Vertex_V2		MakeVertex_V2		(												Vector2f v){ Vertex_V2 e = {v}; return e;}
inline Vertex_V3		MakeVertex_V3		(												Vector3f v){ Vertex_V3 e = {v}; return e;}
inline Vertex_CubV2		MakeVertex_CubV2	(				Color4ub c,						Vector2f v){ Vertex_CubV2 e = {c,v}; return e;}
inline Vertex_CubV3		MakeVertex_CubV3	(				Color4ub c,						Vector3f v){ Vertex_CubV3 e = {c,v}; return e;}
inline Vertex_CV3		MakeVertex_CV3		(				Color3f c,						Vector3f v){ Vertex_CV3 e = {c,v}; return e;}
inline Vertex_NV3		MakeVertex_NV3		(								Vector3f n,		Vector3f v){ Vertex_NV3 e = {n,v}; return e;}
inline Vertex_CNV3		MakeVertex_CNV3		(				Color4f c,		Vector3f n,		Vector3f v){ Vertex_CNV3 e = {c,n,v}; return e;}
inline Vertex_TV3		MakeVertex_TV3		(Vector2f t,									Vector3f v){ Vertex_TV3 e = {t,v}; return e;}
inline Vertex_TV4		MakeVertex_TV4		(Vector4f t,									Vector4f v){ Vertex_TV4 e = {t,v}; return e;}
inline Vertex_TCubV3	MakeVertex_TCubV3   (Vector2f t,	Color4ub c,						Vector3f v){ Vertex_TCubV3 e = {t,c,v}; return e;}
inline Vertex_TCV3		MakeVertex_TCV3		(Vector2f t,	Color3f c,						Vector3f v){ Vertex_TCV3 e = {t,c,v}; return e;}
inline Vertex_TNV3		MakeVertex_TNV3		(Vector2f t,					Vector3f n,		Vector3f v){ Vertex_TNV3 e = {t,n,v}; return e;}
inline Vertex_TCNV3		MakeVertex_TCNV3	(Vector2f t,	Color4f c,		Vector3f n,		Vector3f v){ Vertex_TCNV3 e = {t,c,n,v}; return e;}
inline Vertex_TCNV4		MakeVertex_TCNV4	(Vector4f t,	Color4f c,		Vector3f n,		Vector4f v){ Vertex_TCNV4 e = {t,c,n,v}; return e;}




