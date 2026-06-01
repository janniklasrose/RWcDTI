#ifndef __gpcmex_fast_h
#define __gpcmex_fast_h

#include "mex.h"
#include "gpc.h"

void gpcmex_read_polygon (const mxArray*, gpc_polygon*);

void gpcmex_write_polygon (mxArray **xy_poly, gpc_polygon *poly);

#endif
