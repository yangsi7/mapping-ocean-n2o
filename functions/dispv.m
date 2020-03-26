function dispv(stxt, vb)
    if nargin == 1
        vb = 0;
    end
    
    if vb
        disp(stxt);
    end
