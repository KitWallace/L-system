use <../lib/tile.scad>
use <../lib/lsystem-23.scad>

/*
  example script using the lsystem library

  to generate a order 4 sierpinski curvee which is used to create a 2-d object by hulling the points . 
  
  This path is the removed from a squaree and the DXF code exported to laser cut the pock and inlay for a tile 90 mm x90mm
*/
index();

width=1;  
scale=2;
align=45;

ci=11;
k=4;
curve=get_curve(ci);
echo(curve);
factor= curve[4] == undef ? 1 : pow(curve[4],k);
echo(factor);
points = l_system(ci,k);
echo(len(points));
//echo(points);
cpoints= centre_tile(scale_tile(points,scale));
//echo(cpoints);
   difference() {
      square([90,90],center=true);
      rotate([0,0,align])
      color("red")
         path(cpoints,width=width,$fn=12);
}
