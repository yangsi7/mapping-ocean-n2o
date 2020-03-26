function xinterp = interp1_cyclic(x,v,xq)

    xpad = [x(end)-1, x, x(1)+1];
    vpad = [v(end), v, v(1)];
    xinterp = interp1(xpad,vpad,xq);
