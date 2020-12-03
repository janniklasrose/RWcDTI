#include "mex.h"
#include <math.h>

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    if (nrhs!=3) {
        mexErrMsgTxt("Three inputs needed");
    } else if(nlhs>1) {
        mexErrMsgTxt("Only one output allowed");
    }
    
    double *position_iP = mxGetPr(prhs[0]); // [x, y, z]
    double *dxdydz = mxGetPr(prhs[1]); // [x, y, z]
    double *boundingbox = mxGetPr(prhs[2]); // [[xmin, xmax, ymin, ymax, zmin, zmax]_1, [xmin, xmax, ymin, ymax, zmin, zmax]_2, ...]
    
    int N = mxGetN(prhs[2]);
    int M = mxGetM(prhs[2]);
    if (N==1 && M>1)
    {
        N = M;
    }
    else if (N>1 && M!=1)
    {
        mexErrMsgTxt("3rd argument must be 1D array");
    }
    if (N%6 != 0)
    {
        mexErrMsgTxt("3rd argument must be have Nx6 elements");
    }
    N = N/6; // is Nx6 array
    plhs[0] = mxCreateLogicalMatrix(1, N);
    mxLogical *out = mxGetLogicals(plhs[0]); 
    int i;
    for (i = 0; i < N; i++)
    {
        double absdist_step = 1.01*sqrt(dxdydz[0]*dxdydz[0]+dxdydz[1]*dxdydz[1]+dxdydz[2]*dxdydz[2]);
        double posx = position_iP[0];
        double posy = position_iP[1];
        double posz = position_iP[2];
        // we will use a bigger box, whose size depends on the step (one where being inside means a step could potentially hit the body)
        double bb_xmin = boundingbox[0+i*6]-absdist_step;
        double bb_xmax = boundingbox[1+i*6]+absdist_step;
        double bb_ymin = boundingbox[2+i*6]-absdist_step;
        double bb_ymax = boundingbox[3+i*6]+absdist_step;
        double bb_zmin = boundingbox[4+i*6]-absdist_step;
        double bb_zmax = boundingbox[5+i*6]+absdist_step;
        mxLogical isInside = (posx > bb_xmin && posx < bb_xmax)  // inside in x, and
                          && (posy > bb_ymin && posy < bb_ymax)  // inside in y, and
                          && (posz > bb_zmin && posz < bb_zmax); // inside in z
        out[i] = isInside;
    }
    
}
