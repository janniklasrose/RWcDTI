#include <math.h>
#include "gpcmex_int.h"
#include "mex.h"
#include "gpc.h"

//TODO: revert back to original MATLAB struct structure and optional argument for type (switch case)

void mexFunction (int nargout, mxArray *varargout[], int nargin, const mxArray *varargin[])
{
    
    // help
    if (nargin == 0)
	{
        if (nargout != 0)
		{
            mexErrMsgTxt("Too many output arguments.");
        }
        mexPrintf("\n[xy_poly3] = gpcmex_int(xy_poly1, xy_poly2)\n");
        mexPrintf("\nAll polygons are 2D-arrays with its N (N>2) points layed out as such:\n");
        mexPrintf("    [x1, x2, ..., xi, ..., xN; y1, y2, ..., yi, ..., yN]\n");
        mexPrintf("\nEach polygon is assumed to be solid, i.e. contains no holes.\n");
        mexPrintf("\nThe output array may consist of multiple polygons (NaN-separated).\n");
        return;
    }
    
    // narginchk
    if (nargin < 2)
	{
        mexErrMsgTxt("Not enough input arguments.");
    } else if (nargin > 2) //%TODO: 3 for optional argument
	{
        mexErrMsgTxt("Too many input arguments.");
    }
    
    // nargoutchk
    if (nargout > 1)
	{
        mexErrMsgTxt("Too many output arguments.");
    }
    
    // initialize
    gpc_polygon poly1, poly2, poly3; // polygons (subject, clip, and result, respectively)
    
    // read
    gpcmex_read_polygon(varargin[0], &poly1);
    gpcmex_read_polygon(varargin[1], &poly2);  
    
    // clip
    gpc_polygon_clip(GPC_INT, &poly1, &poly2, &poly3); // intersection
    
    // write
    gpcmex_write_polygon(&varargout[0], &poly3);
    
}

void gpcmex_read_polygon (const mxArray *xy_poly, gpc_polygon *poly)
{
    
    // validateattributes
    if (!mxIsNumeric(xy_poly))
	{
        mexErrMsgTxt("Polygons must be numeric.");
    }
    if (mxGetNumberOfDimensions(xy_poly)!=2)
	{
        mexErrMsgTxt("Polygons must be a matrices.");
    }
    int M = mxGetM(xy_poly);
    int N = mxGetN(xy_poly);
    if (!((N==2 && M>2) || (M==2 && N>2)))
	{
        mexErrMsgTxt("Polygons must have size [2,N] or [M,2] where (M,N)>2.");
    }
    double *p_xy = mxGetPr(xy_poly);
    int i;
	for (i = 0; i < N*M; i++)
	{
		if (!mxIsFinite(p_xy[i]))
		{
			mexErrMsgTxt("Polygons must be finite.");
		}
	}
	
    // malloc and assign
    poly->num_contours = 1; // only one polygon
    poly->hole = (int*)mxMalloc(poly->num_contours * sizeof(int));
    poly->contour = (gpc_vertex_list*)mxMalloc(poly->num_contours * sizeof(gpc_vertex_list));
    poly->contour[0].num_vertices = (M>N?M:N); // [M,2] or [2,N] is ensured
    poly->contour[0].vertex = (gpc_vertex*)mxMalloc(poly->contour[0].num_vertices * sizeof(gpc_vertex));
    int v;
    for (v = 0; v < poly->contour[0].num_vertices; v++)
	{
		int id_x = (M==2)?(0+v*M):(v+0*M);
		int id_y = (M==2)?(1+v*M):(v+1*M);
        poly->contour[0].vertex[v].x = p_xy[id_x];
        poly->contour[0].vertex[v].y = p_xy[id_y];
    }
    poly->hole[0] = 0;
    
}

void gpcmex_write_polygon (mxArray **xy_poly, gpc_polygon *poly)
{
    
    if (poly->num_contours < 1) // no intersection
	{
        (*xy_poly) = mxCreateDoubleMatrix(0, 0, mxREAL); // empty array
        return;
    }
    int total_num_vertices = 0;
    int total_num_separators = poly->num_contours-1;
    int c;
    for (c = 0; c < poly->num_contours; c++)
	{
        total_num_vertices += poly->contour[c].num_vertices;
    }
    (*xy_poly) = mxCreateDoubleMatrix(2, total_num_separators+total_num_vertices, mxREAL);
	
    double *ptr = mxGetPr((*xy_poly));
    int col = 0;
    for (c = 0; c < poly->num_contours; c++)
	{
        int v;
        for (v = 0; v < poly->contour[c].num_vertices; v++,col++)
		{
            ptr[0+col*2] = poly->contour[c].vertex[v].x;
            ptr[1+col*2] = poly->contour[c].vertex[v].y;
        }
		if (poly->num_contours > 1 && c < poly->num_contours-1) // need NaN separation
		{
			ptr[0+col*2] = NAN;
			ptr[1+col*2] = NAN;
			col++;
		}
    }
    gpc_free_polygon(poly);
    
}
