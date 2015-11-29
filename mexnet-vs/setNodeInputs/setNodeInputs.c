// setNodeInputs.c : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include <math.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	if (nrhs == 3) {
		int netid = (int)roundl(mxGetScalar(prhs[0]));
		size_t nodeid = (size_t)roundl(mxGetScalar(prhs[1]));
		sqSetNodeInputs(netid, nodeid, prhs[2]);
	}
	else {
		mexErrMsgIdAndTxt("sq:notEnoughArgs", "Not enough input arguments");
	}
}