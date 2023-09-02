// basic list comprehension functions

function depth(a) =
   a[0]== undef 
       ? 0
       : 1+depth(a[0]);
        
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function dflatten(l,d=2) =
// hack to flattened mixed list and list of lists
   flatten([for (a = l) depth(a) > d ? dflatten(a, d) : [a]]);
    
function reverse(l) = 
     [for (i=[1:len(l)]) l[len(l)-i]];

function shift(l,shift=0) = 
     [for (i=[0:len(l)-1]) l[(i + shift)%len(l)]];  
 
function slice(list,k) =
    [for (e = list) e[k]];
       
function remove(list,item) =
    [for (t=list) if(t!=item) t];
        
//exploits tail recursion optimisation     
function rstr(list,i=0,s="") =
   i >= len(list)
      ? s
      : rstr(list,i+1,str(s,list[i]));

// workaround to avoid range limit         
function to_n(n) = [for (i=0;i<=n;i=i+1) i];
 
//  functions for creating the matrices for transforming a single point

function m_translate(v) = [ [1, 0, 0, 0],
                            [0, 1, 0, 0],
                            [0, 0, 1, 0],
                            [v.x, v.y, v.z, 1  ] ];

function m_scale(v) =    [ [v.x, 0, 0, 0],
                            [0, v.y, 0, 0],
                            [0, 0, v.z, 0],
                            [0, 0, 0, 1  ] ];
                            
function m_rotate(v) =  [ [1,  0,         0,        0],
                          [0,  cos(v.x),  sin(v.x), 0],
                          [0, -sin(v.x),  cos(v.x), 0],
                          [0,  0,         0,        1] ]
                      * [ [ cos(v.y), 0,  -sin(v.y), 0],
                          [0,         1,  0,        0],
                          [ sin(v.y), 0,  cos(v.y), 0],
                          [0,         0,  0,        1] ]
                      * [ [ cos(v.z),  sin(v.z), 0, 0],
                          [-sin(v.z),  cos(v.z), 0, 0],
                          [ 0,         0,        1, 0],
                          [ 0,         0,        0, 1] ];
                            
function vec3(v) = [v.x, v.y, v.z];
function m_transform(v, m)  = vec3([v.x, v.y, v.z, 1] * m);

function m_rotate_to(normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal.y, normal.x)]);  
    
function m_rotate_from(normal) = 
      m_rotate([0, 0, -atan2(normal.y, normal.x)]) 
    * m_rotate([0, -atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]);  
    
function m_to(centre,normal) = 
      m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
    * m_rotate([0, 0, atan2(normal.y, normal.x)]) 
    * m_translate(centre);   
   
function m_from(centre,normal) = 
      m_translate(-centre)
    * m_rotate([0, 0, -atan2(normal.y, normal.x)]) 
    * m_rotate([0, -atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]); 

function m_rotate_about_line(a,v1,v2) =
      m_from(v1,v2-v1)*m_rotate([0,0,a])*m_to(v1,v2-v1);
      
function transform_points(points, matrix) = 
    [for (p=points) m_transform(p, matrix) ] ;
        
 function orient_to(centre,normal, p) = m_rotate([0, atan2(sqrt(pow(normal.x, 2) + pow(normal.y, 2)), normal.z), 0]) 
                     * m_rotate([0, 0, atan2(normal[1], normal[0])]) 
                     * m_translate(centre);
    
function 3d_to_2d(path) = [for (p=path) [p.x,p.y]];
   
function 2d_to_3d(path,z=0) = [for (p=path) [p.x,p.y,z]];
   
        
// modules to orient objects for rendering
module orient_to(centre, normal) {   
      translate(centre)
      rotate([0, 0, atan2(normal.y, normal.x)]) //rotation
      rotate([0, atan2(sqrt(pow(normal.x, 2)+pow(normal.y, 2)),normal.z), 0])
      children();
}

function signx (x) =
     x==0 ? 1 : sign(x);

function between(a,b,x) = x >= a && x <= b;

function interpolate(t,range) =
     let(r= range[1]- range[0])
     range[0] + t * r;

function point_between(a,b,r) =
    a * r + b * (1-r);

function dround(x,n) = round(x * n)/ n;

// vector functions
function unitv(v)=  
   let (n = norm(v))
   n !=0 ? v/ norm(v) : v;
  

function angle_between(u, v, normal) = 
// protection against inaccurate computation
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     normal == undef
        ? a 
        : signx(normal * cross(u,v)) * a;



// this version used intiling works when the one above fails
/*
function angle_between_tile(u, v, eps=0.00001) = 
     let (x= unitv(u) * unitv(v))
     let (y = x <= -1 ? -1 :x >= 1 ? 1 : x)
     let (a = acos(y))
     let (d = cross(u,v).z)
     d  > 0 
        ? a 
        : 360 - a;
*/

function vadd(points,v,i=0) =
      i < len(points)
        ?  concat([points[i] + v], vadd(points,v,i+1))
        :  [];

function subseq(l,start,end) =
   [for (i=[start:end]) l[i]];

function vsum(points,i=0) =  
      i < len(points)
        ?  (points[i] + vsum(points,i+1))
        :  [0,0,0];
          
function norm2(v) = v.x*v.x+ v.y*v.y + v.z*v.z;

function reciprocal(v) = v/norm2(v);
           
function ssum(list,i=0) =  
      i < len(list)
        ?  (list[i] + ssum(list,i+1))
        :  0;

function vcontains(val,list) =
     search([val],list)[0] != [];
 
         
function index_of(key, list) =
      search([key],list)[0]  ;

function value_of(key, list) =
      list[search([key],list)[0]][1]  ;


function orthogonal(v0,v1,v2) =  cross(v1-v0,v2-v1);

function normal(face) =
     let (n=orthogonal(face[0],face[1],face[2]))
     - n / norm(n);
 
function centroid(points) = 
      vsum(points) / len(points);
      
function scale_points(points,scale) =
     scale[0] == undef
       ? [for (p=points) p*scale]
       : [for (p=points) [p[0]*scale[0],p[1]*scale[1],p[2]*scale[2]]] ; 
           
// dictionary shorthand assuming present
function find(key,array) =  array[search([key],array)[0]];

function count(val, list) =  // number of occurances of val in list
   ssum([for(v= list) v== val ? 1 :0]);
    
function distinct(list,dlist=[],i=0) =  // return only distinct items of dlist 
      i==len(list)
         ? dlist
         : search(list[i],dlist) != []
             ? distinct(list,dlist,i+1)
             : distinct(list,concat(dlist,list[i]),i+1)
      ;

//sort a key value dictionary
function quicksort_kv(kvs) = 
//  kv[0] is the value to sort on,  kv[1] is the object sorted
 len(kvs)>0
     ? let( 
         pivot   = kvs[floor(len(kvs)/2)][0], 
         lesser  = [ for (y = kvs) if (y[0]  < pivot) y ], 
         equal   = [ for (y = kvs) if (y[0] == pivot) y ], 
         greater = [ for (y = kvs) if (y[0]  > pivot) y ] )
          concat( quicksort_kv(lesser), equal, quicksort_kv(greater))
      : [];

// sort table on column col

function quicksort1(arr,col=0) = 
  !(len(arr)>0) ? [] : 
      let(  pivot   = arr[floor(len(arr)/2)][col], 
            lesser  = [ for (y = arr) if (y[col]  < pivot) y ], 
            equal   = [ for (y = arr) if (y[col] == pivot) y ], 
            greater = [ for (y = arr) if (y[col]  > pivot) y ] 
      ) 
      concat( quicksort1(lesser), equal, quicksort1(greater) ); 

function quicksort(arr) = 
  !(len(arr)>0) ? [] : 
      let(  pivot   = arr[floor(len(arr)/2)], 
            lesser  = [ for (y = arr) if (y  < pivot) y ], 
            equal   = [ for (y = arr) if (y == pivot) y ], 
            greater = [ for (y = arr) if (y  > pivot) y ] 
      ) 
      concat( quicksort(lesser), equal, quicksort(greater) ); 
            
  
// easing functions : animation shaping
function ramp(t,dwell) =
// to shape the animation to give a dwell at begining and end
   t < dwell 
       ? 0
       : t > 1 - dwell 
         ? 1
         :  ( t-dwell) /(1 - 2 * dwell);

function updown(t,dwell) =
    let(ramp=(1 - 2 * dwell)/2)
    t < dwell ? 0 :
        t < 0.5 ?( t-dwell)/ramp :
           t < 0.5 +dwell ? 1 :
              1 - (t - ramp - 2*dwell)/ramp;
  
