function [] = reduce(this, num)

xy_old = this.Vertices;
xy_new = reduce_poly(xy_old.', num).';
this.Vertices = xy_new;

end
