//
//  VertexFormat.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jun 26 2004.
//  Copyright (c) 2004 __Kelvin_NishikawaName__. All rights reserved.
//

#ifndef __VertexFormat_h_
#define __VertexFormat_h_

#ifndef __VertexTypes_h_
	#include <CocoaGranite/VertexTypes.h>
#endif

#define CBIndex				GLuint
#define CBIndexFormat		GL_UNSIGNED_INT

#define CBVertex			Vertex_TCubV3
#define CBVertex_T			GL_FLOAT
#define CBVertex_C			GL_UNSIGNED_BYTE


//define the pointer format based on CBVertex
#if (CBVertex == Vertex_V2)
	#define CBVertex_Format		GL_V2F
#elif(CBVertex == Vertex_V3)
	#define CBVertex_Format		GL_V3F
#elif (CBVertex == Vertex_CubV2)
	#define CBVertex_Format     GL_C4UB_V2F
#elif (CBVertex == Vertex_CubV3)
	#define CBVertex_Format     GL_C4UB_V3F
#elif (CBVertex == Vertex_CV3)
	#define CBVertex_Format		GL_C3F_V3F
#elif (CBVertex == Vertex_NV3)
	#define CBVertex_Format		GL_N3F_V3F
#elif (CBVertex == Vertex_CNV3)
	#define CBVertex_Format		GL_C4F_N3F_V3F
#elif (CBVertex == Vertex_TV3)
	#define CBVertex_Format		GL_T2F_V3F
#elif (CBVertex == Vertex_TV4)
	#define CBVertex_Format		GL_T4F_V4F
#elif (CBVertex == Vertex_TCubV3)
	#define CBVertex_Format		GL_T2F_C4UB_V3F
#elif (CBVertex == Vertex_TCV3)
	#define CBVertex_Format		GL_T2F_C3F_V3F
#elif (CBVertex == Vertex_TNV3)
	#define CBVertex_Format		GL_T2F_N3F_V3F
#elif (CBVertex == Vertex_TCNV3)
	#define CBVertex_Format		GL_T2F_C4F_N3F_V3F
#elif (CBVertex == Vertex_TCNV4)
	#define CBVertex_Format		GL_T4F_C4F_N3F_V4F
#endif


#endif /* __VertexFormat_h_ */