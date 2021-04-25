% IMPLEMENTATION OF THE RESPONSE MATRIX - EXPONENTIAL NODAL (RM-EXPN) 
% METHOD FOR FIXED SOURCE, ISOTROPIC SCATTERING, ONE-GROUP OF ENERGY 
% DISCRETE-ORDINATES PROBLEMS IN X,Y - GEOMETRY. VERSION 4

function [SCALAR_FLUX, ...  % SCALAR FLUX IN EACH NODE
          ANGULAR_FLUX, ... % ANGULAR FLUX IN EACH NODE
          X_ANG_FLUX, ...   % ANGULAR FLUX AT X EDGES
          Y_ANG_FLUX, ...   % ANGULAR FLUX AT Y EDGES
          ITER, ...         % NUMBER OF ITERATIONS
          TIME ...          % CPU TIME
          ] = MET_RM_EXPN_2D(N, ZON, XDOM, YDOM, ZMAP, QMAP, BC, TOL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % VARIABLES
  M = N * (N + 2) / 2; I = sum(XDOM(2, :)); J = sum(YDOM(2, :));
  RX = length(XDOM(1, :)); RY = length(YDOM(1, :));
  [R, P, RM, LM1, LM2, PM] = response_matrix(N, ZON, XDOM, YDOM, ZMAP, QMAP);
  [QUAD, ~] = LQN_2D(N);
  
  % INITIALIZATION
  SCALAR_FLUX = zeros(J, I); ANGULAR_FLUX = zeros(M, J, I);
  X_ANG_FLUX = zeros(M, J, I + 1); Y_ANG_FLUX = zeros(M, J + 1, I);
  for j = 1: J
    for m = 1: M
      if ( m <= M / 4 && BC(1) ~= -1)
        X_ANG_FLUX(m, j, 1) = BC(1);
      elseif (m > M / 4 && m <= M / 2 && BC(3) ~= -1)
        X_ANG_FLUX(m, j, I + 1) = BC(3);
      elseif (m > M / 2 && m <= 3 * M / 4 && BC(3) ~= -1)
        X_ANG_FLUX(m, j, I + 1) = BC(3);
      elseif (m > 3 * M / 4 && m <= M && BC(1) ~= -1)
        X_ANG_FLUX(m, j, 1) = BC(1);
      end
    end
  end
  for i = 1: I
    for m = 1: M
      if ( m <= M / 4 && BC(2) ~= -1)
        Y_ANG_FLUX(m, 1, i) = BC(2);
      elseif (m > M / 4 && m <= M / 2 && BC(2) ~= -1)
        Y_ANG_FLUX(m, 1, i) = BC(2);
      elseif (m > M / 2 && m <= 3 * M / 4 && BC(4) ~= -1)
        Y_ANG_FLUX(m, J + 1, i) = BC(4);
      elseif (m > 3 * M / 4 && m <= M && BC(4) ~= -1)
        Y_ANG_FLUX(m, J + 1, i) = BC(4);
      end
    end
  end
  ERR = 1; ITER = -1;
  
  % ITERATIVE PROCESS
  tic;
  fprintf("ITER\t\tMAX_DEV(SCALAR_FLUX)\n");
  while ERR > TOL
    ERR = 0; ITER = ITER + 1;
    
    % IN CASE OF SYMMETRIC BOUNDARY CONDITIONS IN X
    if (BC(1) == -1 || BC(3) == -1)
      JB = 0;
      for ry = 1: RY
        ncy = YDOM(2, ry);
        for j = 1: ncy
          JB = JB + 1;
          for m = 1: M / 4
            if BC(1) == -1.0
              X_ANG_FLUX(m, JB, 1) = X_ANG_FLUX(M / 4 + m, JB, 1);
              X_ANG_FLUX(3 * M / 4 + m, JB, 1) = X_ANG_FLUX(M / 2 + m, JB, 1);
            end
            if BC(3) == -1.0
              X_ANG_FLUX(M / 4 + m, JB, I + 1) =  X_ANG_FLUX(m, JB, I + 1);
              X_ANG_FLUX(M / 2 + m, JB, I + 1) =  X_ANG_FLUX(3 * M / 4 + m, JB, I + 1);
            end
          end
        end
      end
    end
    
    % IN CASE OF SYMMETRIC BOUNDARY CONDITIONS IN Y
    if(BC(2) == -1 || BC(4) == -1)
      IB = 0;
      for rx = 1: RX
        ncx = XDOM(2, rx);
        for i = 1: ncx
          IB = IB + 1;
          for m = 1: M / 4
            if BC(2) == -1.0
              Y_ANG_FLUX(m, 1, IB) = Y_ANG_FLUX(3 * M / 4 + m, 1, IB);
              Y_ANG_FLUX(M / 4 + m, 1, IB) = Y_ANG_FLUX(M / 2 + m, 1, IB);
            end
            if BC(4) == -1.0
              Y_ANG_FLUX(3 * M / 4 + m, J + 1, IB) = Y_ANG_FLUX(m, J + 1, IB);
              Y_ANG_FLUX(M / 2 + m, J + 1, IB) = Y_ANG_FLUX(M / 4 + m, J + 1, IB);
            end
          end
        end
      end
    end
    
    % 1. SW -> NE SWEEP
    JB = 0;
    for ry = 1: RY
      ncy = YDOM(2, ry);
      for j = 1: ncy
        JB = JB + 1; JF = JB + 1;
        IB = 0;
        for rx = 1: RX
          ncx = XDOM(2, rx);
          for i = 1: ncx
            IB = IB + 1; IF = IB + 1;
            
            IN = [X_ANG_FLUX(1: M / 4, JB, IB);
                  X_ANG_FLUX(M / 4 + 1: M / 2, JB, IF);
                  X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IF);
                  X_ANG_FLUX(3 * M / 4 + 1: M, JB, IB);
                  Y_ANG_FLUX(1: M / 4, JB, IB);
                  Y_ANG_FLUX(M / 4 + 1: M / 2, JB, IB);
                  Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JF, IB);
                  Y_ANG_FLUX(3 * M / 4 + 1: M, JF, IB)];

            OUT = R(:, :, JB, IB) * IN + P(:, JB, IB);
            
            X_ANG_FLUX(1: M / 4, JB, IF) = OUT(1: M / 4);
            X_ANG_FLUX(M / 4 + 1: M / 2, JB, IB) = OUT(M / 4 + 1: M / 2);
            X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M / 2 + 1: 3 * M / 4);
            X_ANG_FLUX(3 * M / 4 + 1: M, JB, IF) = OUT(3 * M / 4 + 1: M);
            Y_ANG_FLUX(1: M / 4, JF, IB) = OUT(M + 1: M + M / 4);
            Y_ANG_FLUX(M / 4 + 1: M / 2, JF, IB) = OUT(M + M / 4 + 1: M + M / 2);
            Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M + M / 2 + 1: M + 3 * M / 4);
            Y_ANG_FLUX(3 * M / 4 + 1: M, JB, IB) = OUT(M + 3 * M / 4 + 1: M + M);
          end
        end
      end
    end
    
    % 2. SE -> NW SWEEP
    IB = I + 1;
    for rx = RX: -1: 1
      ncx = XDOM(2,rx);
      for i = 1: ncx
        IB = IB - 1; IF = IB + 1;
        JB = 0;
        for ry = 1: RY
          ncy = YDOM(2,ry);
          for j = 1: ncy
            JB = JB + 1; JF = JB + 1;
            
            IN = [X_ANG_FLUX(1: M / 4, JB, IB);
                  X_ANG_FLUX(M / 4 + 1: M / 2, JB, IF);
                  X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IF);
                  X_ANG_FLUX(3 * M / 4 + 1: M, JB, IB);
                  Y_ANG_FLUX(1: M / 4, JB, IB);
                  Y_ANG_FLUX(M / 4 + 1: M / 2, JB, IB);
                  Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JF, IB);
                  Y_ANG_FLUX(3 * M / 4 + 1: M, JF, IB)];

            OUT = R(:, :, JB, IB) * IN + P(:, JB, IB);
            
            X_ANG_FLUX(1: M / 4, JB, IF) = OUT(1: M / 4);
            X_ANG_FLUX(M / 4 + 1: M / 2, JB, IB) = OUT(M / 4 + 1: M / 2);
            X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M / 2 + 1: 3 * M / 4);
            X_ANG_FLUX(3 * M / 4 + 1: M, JB, IF) = OUT(3 * M / 4 + 1: M);
            Y_ANG_FLUX(1: M / 4, JF, IB) = OUT(M + 1: M + M / 4);
            Y_ANG_FLUX(M / 4 + 1: M / 2, JF, IB) = OUT(M + M / 4 + 1: M + M / 2);
            Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M + M / 2 + 1: M + 3 * M / 4);
            Y_ANG_FLUX(3 * M / 4 + 1: M, JB, IB) = OUT(M + 3 * M / 4 + 1: M + M);
            
          end
        end
      end
    end
    
    % 3. NE -> SW SWEEP
    JB = J + 1;
    for ry = RY: -1: 1
      ncy = YDOM(2,ry);
      for j = 1: ncy
        JB = JB - 1; JF = JB + 1;
        IB = I + 1;
        for rx = RX: -1: 1
          ncx = XDOM(2,rx);
          for i = 1: ncx
            IB = IB - 1; IF = IB + 1;
            
            IN = [X_ANG_FLUX(1: M / 4, JB, IB);
                  X_ANG_FLUX(M / 4 + 1: M / 2, JB, IF);
                  X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IF);
                  X_ANG_FLUX(3 * M / 4 + 1: M, JB, IB);
                  Y_ANG_FLUX(1: M / 4, JB, IB);
                  Y_ANG_FLUX(M / 4 + 1: M / 2, JB, IB);
                  Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JF, IB);
                  Y_ANG_FLUX(3 * M / 4 + 1: M, JF, IB)];

            OUT = R(:, :, JB, IB) * IN + P(:, JB, IB);
            
            X_ANG_FLUX(1: M / 4, JB, IF) = OUT(1: M / 4);
            X_ANG_FLUX(M / 4 + 1: M / 2, JB, IB) = OUT(M / 4 + 1: M / 2);
            X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M / 2 + 1: 3 * M / 4);
            X_ANG_FLUX(3 * M / 4 + 1: M, JB, IF) = OUT(3 * M / 4 + 1: M);
            Y_ANG_FLUX(1: M / 4, JF, IB) = OUT(M + 1: M + M / 4);
            Y_ANG_FLUX(M / 4 + 1: M / 2, JF, IB) = OUT(M + M / 4 + 1: M + M / 2);
            Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M + M / 2 + 1: M + 3 * M / 4);
            Y_ANG_FLUX(3 * M / 4 + 1: M, JB, IB) = OUT(M + 3 * M / 4 + 1: M + M);
            
          end
        end
      end
    end
    
    % 4. NW -> SE SWEEP
    IB = 0;
    for rx = 1: RX
      ncx = XDOM(2,rx);
      for i = 1: ncx
        IB = IB + 1; IF = IB + 1;
        JB = J + 1;
        for ry = RY: -1: 1
          ncy = YDOM(2,ry);
          for j = 1: ncy
            JB = JB - 1; JF = JB + 1;
            
            IN = [X_ANG_FLUX(1: M / 4, JB, IB);
                  X_ANG_FLUX(M / 4 + 1: M / 2, JB, IF);
                  X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IF);
                  X_ANG_FLUX(3 * M / 4 + 1: M, JB, IB);
                  Y_ANG_FLUX(1: M / 4, JB, IB);
                  Y_ANG_FLUX(M / 4 + 1: M / 2, JB, IB);
                  Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JF, IB);
                  Y_ANG_FLUX(3 * M / 4 + 1: M, JF, IB)];

            OUT = R(:, :, JB, IB) * IN + P(:, JB, IB);
            
            X_ANG_FLUX(1: M / 4, JB, IF) = OUT(1: M / 4);
            X_ANG_FLUX(M / 4 + 1: M / 2, JB, IB) = OUT(M / 4 + 1: M / 2);
            X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M / 2 + 1: 3 * M / 4);
            X_ANG_FLUX(3 * M / 4 + 1: M, JB, IF) = OUT(3 * M / 4 + 1: M);
            Y_ANG_FLUX(1: M / 4, JF, IB) = OUT(M + 1: M + M / 4);
            Y_ANG_FLUX(M / 4 + 1: M / 2, JF, IB) = OUT(M + M / 4 + 1: M + M / 2);
            Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUT(M + M / 2 + 1: M + 3 * M / 4);
            Y_ANG_FLUX(3 * M / 4 + 1: M, JB, IB) = OUT(M + 3 * M / 4 + 1: M + M);
            
          end
        end
      end
    end
    
    % SCALAR AND ANGULAR FLUXES CALCULATION AND STOP CRITERIA
    IB = 0;
    for rx = 1: RX
      ncx = XDOM(2, rx);
      for i = 1: ncx
        IB = IB + 1; IF = IB + 1;
        JB = 0;
        for ry = 1: RY
          ncy = YDOM(2, ry);
          for j = 1: ncy
            JB = JB + 1; JF = JB + 1;
            
            XIN = [X_ANG_FLUX(1: M / 4, JB, IB);
                   X_ANG_FLUX(M / 4 + 1: M / 2, JB, IF);
                   X_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IF);
                   X_ANG_FLUX(3 * M / 4 + 1: M, JB, IB)];
               
            YIN = [Y_ANG_FLUX(1: M / 4, JB, IB);
                   Y_ANG_FLUX(M / 4 + 1: M / 2, JB, IB);
                   Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JF, IB);
                   Y_ANG_FLUX(3 * M / 4 + 1: M, JF, IB)];
               
            YOUT = [Y_ANG_FLUX(1: M / 4, JF, IB); ...
                    Y_ANG_FLUX(M / 4 + 1: M / 2, JF, IB); ...
                    Y_ANG_FLUX(M / 2 + 1: 3 * M / 4, JB, IB); ...
                    Y_ANG_FLUX(3 * M / 4 + 1: M, JB, IB)];

            OUTPUT = RM(:, :, JB, IB) * XIN + LM1(:, :, JB, IB) * YOUT ...
                     + LM2(:, :, JB, IB) * YIN + PM(:, JB, IB);
            
            ANGULAR_FLUX(1: M / 4, JB, IB) = OUTPUT(1: M / 4);
            ANGULAR_FLUX(M / 4 + 1: M / 2, JB, IB) = OUTPUT(M / 4 + 1: M / 2);
            ANGULAR_FLUX(M / 2 + 1: 3 * M / 4, JB, IB) = OUTPUT(M / 2 + 1: 3 * M / 4);
            ANGULAR_FLUX(3 * M / 4 + 1: M, JB, IB) = OUTPUT(3 * M / 4 + 1: M);
            
            flux = 0.25 * (OUTPUT' * QUAD(:, 3));
            flux0 = SCALAR_FLUX(JB, IB);
            SCALAR_FLUX(JB, IB) = flux;
            if abs(1 - flux0 / flux) > ERR, ERR = abs(1 - flux0 / flux); end
          end
        end
      end
    end
    
    fprintf("%d\t\t\t%.5e\n", ITER, ERR);
    
  end
  
  TIME = toc;

end
