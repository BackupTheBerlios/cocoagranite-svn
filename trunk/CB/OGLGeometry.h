/*
 *  OGLGeometry.h
 *  CocoaGranite
 *
 *  Created by Kelvin Nishikawa on Tue Jun 15 2004.
 *  Copyright (c) 2004 Kelvin_Nishikawa. All rights reserved.
 *
 */

#import <CocoaGranite/VertexTypes.h>

inline Vector2f		MakeVector2f(GLfloat x, GLfloat y);
inline Vector3f		MakeVector3f(GLfloat x, GLfloat y, GLfloat z);
inline Vector4f		MakeVector4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w);

inline Color3f		MakeColor3f(GLfloat r, GLfloat g, GLfloat b);
inline Color4f		MakeColor4f(GLfloat r, GLfloat g, GLfloat b, GLfloat a);
inline Color4ub		MakeColor4ub(GLubyte r, GLubyte g, GLubyte b, GLubyte a);

inline Vertex_V2		MakeVertex_V2		(												Vector2f v);
inline Vertex_V3		MakeVertex_V3		(												Vector3f v);
inline Vertex_CubV2		MakeVertex_CubV2	(				Color4ub c,						Vector2f v);
inline Vertex_CubV3		MakeVertex_CubV3	(				Color4ub c,						Vector3f v);
inline Vertex_CV3		MakeVertex_CV3		(				Color3f c,						Vector3f v);
inline Vertex_NV3		MakeVertex_NV3		(								Vector3f n,		Vector3f v);
inline Vertex_CNV3		MakeVertex_CNV3		(				Color4f c,		Vector3f n,		Vector3f v);
inline Vertex_TV3		MakeVertex_TV3		(Vector2f t,									Vector3f v);
inline Vertex_TV4		MakeVertex_TV4		(Vector4f t,									Vector4f v);
inline Vertex_TCubV3	MakeVertex_TCubV3   (Vector2f t,	Color4ub c,						Vector3f v);
inline Vertex_TCV3		MakeVertex_TCV3		(Vector2f t,	Color3f c,						Vector3f v);
inline Vertex_TNV3		MakeVertex_TNV3		(Vector2f t,					Vector3f n,		Vector3f v);
inline Vertex_TCNV3		MakeVertex_TCNV3	(Vector2f t,	Color4f c,		Vector3f n,		Vector3f v);
inline Vertex_TCNV4		MakeVertex_TCNV4	(Vector4f t,	Color4f c,		Vector3f n,		Vector4f v);

inline Vector4f AddVector4f(Vector4f v1, Vector4f v2);

Vector4f NormalizeVector4f(Vector4f v);

