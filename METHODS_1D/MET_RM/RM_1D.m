% SHORTHAND

[SCALAR_FLUX, ANGULAR_FLUX, ITER, TIME] = MET_1D_RM(N, ZON, DOM, BC, TOL);

[AV_SCALAR_FLUX, AV_ANGULAR_FLUX, ABS_R, LEAK, X] = ...
         POST(N, ZON, DOM, BC, SCALAR_FLUX, ANGULAR_FLUX);