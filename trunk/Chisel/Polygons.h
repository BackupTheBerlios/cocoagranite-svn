//
//  Polygons.h
//  CocoaGranite
//
//  Created by Kelvin Nishikawa on Sat Jul 17 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#include <CocoaGranite/VertexFormat.h>


#ifdef __cplusplus
extern "C" {
#endif
	

	typedef union {
		CBVertex		c[3];
		struct { CBVertex   a,b,c; };
	} CBTri;
	
	typedef union {
		CBVertex			c[4];
		struct { CBVertex   a,b,c,d; };
	} CBQuad;





#ifdef __cplusplus
}
#endif