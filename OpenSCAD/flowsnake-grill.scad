use <tile.scad>
use <lsystem-23.scad>

/*
  example script using the lsystem library

  to generate a order 4 flowsnake which is used to create a 2-d objects by hulling the points . 
  
  This path is the removed from a circle and the DXF code exported to laser cut a grill for a VHF spreaker 
*/
index();

width=0.9;  
scale=2;
align=0;

ci=9;
k=4;
curve=curves()[ci];
echo(curve);
factor= curve[4] == undef ? 1 : pow(curve[4],k);
echo(factor);
points = l_system(ci,k);
echo(len(points));
//echo(points);
cpoints= centre_tile(scale_tile(points,scale));
//echo(cpoints);
   difference() {
       circle(38,$fn=100);
       rotate([0,0,align])
     color("red")
         path(cpoints,width=width,$fn=12);
}
