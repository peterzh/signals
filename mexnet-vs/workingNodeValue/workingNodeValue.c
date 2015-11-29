// workingNodeValue.c : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include <math.h>



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	if (nrhs >= 2 && nrhs <= 3) {
		int netid = (int)mxGetScalar(prhs[0]);
		size_t nodeid = (size_t)roundl(mxGetScalar(prhs[1]));
		if (nlhs > 0 || nrhs == 2) {
			mxArray *v = sqGetNodeWorkingValue(netid, nodeid);
			bool vset = true;
			if (v) { 
				v = mxDuplicateArray(v);
			}
			else { // no value set, so return empty
				v = mxCreateDoubleMatrix(0, 0, mxREAL);
				vset = false;
			}
			plhs[0] = v;
			if (nlhs == 2) {
				plhs[1] = mxCreateLogicalScalar(vset);
			}
		}
		if (nrhs == 3) {
			mxArray *newv = mxDuplicateArray(prhs[2]);
			mexMakeArrayPersistent(newv);
			sqSetNodeWorkingValue(netid, nodeid, newv);
		}
	}
	else {
		mexErrMsgIdAndTxt("sq:notEnoughArgs", "Not enough input arguments");
	}
}