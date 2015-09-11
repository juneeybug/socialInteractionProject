#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mex.h> 
#include <mat.h>
// to compile: mex -L/usr/lib/ resample_discont.cpp
void mexFunction(int nlhs, mxArray*plhs[], int nrhs, const mxArray*prhs[]) {
	// xout = resample_discont(xint, tin, tout, interpolate=1);
	// output is SINGLE resolution. 
	// this is for resampling a discontinuously-sampled signal. 
	// only works with doubles and only works on Nx1 vectors
	// for convenience, row vectors are forced to be column vectors
	// the interpolate parameter (defaults to true)
	// determines if (linear) interpolation is used
	if ( (nlhs == 1 || nlhs == 0) && (nrhs == 3 || nrhs == 4) ) {
		double interp = 1.f;
		double * interpolate;
		if (nrhs == 4)
			interpolate = (double*)mxGetData(prhs[3]);
		else
			interpolate = & interp;
		int pres = 0; 
		int next = 1; 
		int m, n;
		int dims[2];
		dims[0] = mxGetM(prhs[2]); 
		dims[1] = mxGetN(prhs[2]); 
		if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2]) ) {
			mexPrintf("resample_discont: Inputs must be doubles, or things will break badly\n");
			return;
		}
		plhs[0] = mxCreateNumericArray(2, (const int*)dims, mxSINGLE_CLASS, mxREAL); 
		if (plhs[0]==0) {
			mexPrintf("resample_discont: Not enough memory to allocate output\n");
			return;
		}

		float* xout = (float*)mxGetData(plhs[0]); 
		double* x =  (double*)mxGetData(prhs[0]); 
		double* t =  (double*)mxGetData(prhs[1]); 
		double* tout =  (double*)mxGetData(prhs[2]);
		m = mxGetM(prhs[0]); 
		n = mxGetN(prhs[0]); 
		int rowsIn = m > n ? m : n; 
		m = mxGetM(prhs[2]); 
		n = mxGetN(prhs[2]); 
		int rowsOut = m > n ? m : n; 
		//mexPrintf("input rows: %d output rows %d \n", rowsIn, rowsOut); 
		for(int k=0; k < rowsOut; k++) {
			while( t[next] < tout[k] && pres < rowsIn -1) {
				pres = pres + 1; 
				if(pres < rowsIn-1) {
					next = pres + 1; 
				}
			}			
			double lerp;
			if (interpolate[0] != 0) {
				if (k<0 || k>=rowsOut || pres < 0 || pres>=rowsIn || next < 0 || next>=rowsIn)
					mexPrintf("resample_discont: error at k %d  pres %d  next %d\n",k,pres,next);
				lerp = (tout[k] - t[pres]) / (t[next] - t[pres]); 
				if(next == pres) lerp = 1;
				if(lerp <0) lerp = 0; 
				if(lerp > 1) lerp = 1; 
			} else
				lerp = 0;
			xout[k] = (float)((1-lerp)*x[pres] + lerp*x[next]); 
		}
	}
    else
        mexPrintf("argument error\n");
}
