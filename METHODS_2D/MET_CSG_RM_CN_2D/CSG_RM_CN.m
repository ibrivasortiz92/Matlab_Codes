% SHORTHAND CSG_RM_CN

% METHOD CALL
[SCALAR_FLUX, ... % SCALAR FLUX IN EACH COLUMN FOR X
ANGULAR_FLUX, ... % ANGULAR FLUX IN EACH COLUMN FOR X
X_ANG_FLUX, ...   % ANGULAR FLUX AT X EDGES
Y_ANG_FLUX, ...   % ANGULAR FLUX AT Y EDGES
ITER, ...         % NUMBER OF ITERATIONS
TIME ...          % CPU TIME
] = MET_CSG_RM_CN_2D(N, ZON, XDOM, YDOM, ZMAP, QMAP, BC, TOL);

% POST-PROCESSING
POST_2D(N, ZON, XDOM, YDOM, ZMAP, BC, SCALAR_FLUX, X_ANG_FLUX, Y_ANG_FLUX)