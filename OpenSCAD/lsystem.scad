/*
  L-system (Lindenmayer) 
    symbols  
       F (or user defined characters) forward step
       + turn right angle
       - turn left angle
       other symbols are ignored when rendering
       
  see http://paulbourke.net/fractals/lsys/ 
    for a plethora of examples
  
  kit wallace Nov 2019 
  with thanks to Ronaldo and the Openscad Forum
  
  Todo:
  add scaling factors
  reverse()
  mirror()
  pop/push
  move
*/


function find(key, list) =
      list[search([key],list)[0]]  ;

function is_key(key,list)= find(key,list) != undef;

function rstr(list,i=0,s="") =
   i < len(list)
      ? rstr(list,i+1,str(s,list[i]))
      : s;
      
function replace(s,rules) =
   rstr([for (c = s)
      let(r=find(c,rules)[1])
      is_undef(r) ? c : r
   ]);
      
function gen(axiom,rules,k) =
    k==0? axiom : gen(replace(axiom,rules),rules,k-1);


function string_to_points(s,step=1,angle=90,pos=[0,0,0],dir=0,forward) =
  let(fchars = is_undef(forward) ? ["F"] : forward)
  [for( i  = 0,
        ps = [pos];

        i <= len(s);

        c   = s[i],
        pos = is_key(c,fchars)
               ? pos + step*[cos(dir), sin(dir),0]
               : pos,
        dir = c=="+"  
              ? dir + angle
              : c=="-"
                ? dir - angle
                : dir,
        ps  = is_key(c,fchars) 
               ? concat([pos], ps) : ps,
        i   = i+1 )
  
        if(i==len(s)) each ps ];

// workaround to avoid range limit         
function to_n(n) = [for (i=0;i<=n;i=i+1) i];
    
module path(points,width,closed=false) {
   r=width/2;
   for (i=to_n(len(points)-2)) {
      hull() {    
          translate(points[i]) circle(r);
          translate(points[i+1]) circle(r);
      }    
    }
    if (closed) {
      hull() {    
          translate(points[len(points)-1]) 
              circle(r);
          translate(points[0])
              circle(r);
      } 
    }
};

module path_fill(points) {
   for (i=to_n(len(points)-1)) 
      translate(points[i])
         children(i % $children);   
};

module path_fill_color(points,colors) {
   for (i=to_n(len(points)-1)) 
      translate(points[i])
         color(colors[i%len(colors)]) children();   
};

module tile(points) {
    polygon(points);    
} 

/* curve directory entry structure
   0 - name
   1 - axiom
   2 - rules
   3 - angle in degrees
   4 - forward characters - default F
   5 - scaling between generations
   6 - closed: true,  open:false
*/
curves =

 [
   ["Dragon Curve",
// https://en.wikipedia.org/wiki/Dragon_curve
   "FX",
   [
     ["X","X+YF+"],
     ["Y","-FX-Y"]
   ],
   90,
   ["F"],
   1.5,
   false],

// doesnt work
   ["Dragon Curve: 2",   // simpler form
     "F",
    [
     ["F", "F-A"],
     ["A","F+A"]
     ],
     90,
     ["F","A"],
     1.5,
     false
   ],
   ["Dragon Curve: 3",
   // http://larryriddle.agnesscott.org/ifs/heighway/heighway.htm
       "FX",
       [["F",""],
        ["X","+FX--FY+"],
        ["Y","-FX++FY-"]
       ],
       45,
       ["F"],
       1,
       false
      ],
             
   ["Twin Dragon",
   "FX+FX+",
   [
     ["X","X+YF"],
     ["Y","FX-Y"]
   ],
   90,
   ["F"],
   1.5,
   false],
   
   ["Terdragon",
   "F",
   [
     ["F","F+F-F"]
   ],
   120,
   ["F"],
   1.75,
   false],
   
   ["Terdragon Boundary",
     "A-B--A-B--",
    [["A","A+B"],
     ["B","A-B"]
     ],
     60,
     ["A","B"],
     1.75,
     true
     ],
     
   ["McWorter's Pentigree",
    "F",
    [["F","+F++F----F--F++F++F-"]],
     36,
     ["F"],
     1,
     false
     ],

    ["Fudgeflake",
     "FX++++FX++++FX",
    [["X","-FY++FX-"],
     ["Y","+FY--FX+"]
    ],
     30,
     ["F"],
     1,
     true],
   
   ["Moore",
    "LFL+F+LFL",
    [
     ["L","-RF+LFL+FR-"],
     ["R","+LF-RFR-FL+"]
    ],
    90,
    ["F"],
    1,
    true],
        
   ["Hilbert",
     "X",
     [
       ["X","-YF+XFX+FY-"],
       ["Y","+XF-YFY-FX+"]
     ],
     90,
     ["F"],
     1,
     false
     ],
     
   ["Gosper Curve",
  // Flowsnake, Peano-Gosper Curve
      "A",
     [
       ["A","A-B--B+A++AA+B-"],
       ["B","+A-BB--B-A++A+B"]
      ],
     60,
     ["A","B"],
     1,
     false
    ],
    ["Inner-flip Gosper",
      "A",
     [
       ["A","A-FB--FB-F++AF++A-F+AF+B-"],
       ["B","+A-FB-F+B--FB--F+AF++AF+B"]
      ],
     60,
     ["F"],
     1,
     false
     
   ],    
   ["Peano Curve",
       "X",
       [
        ["X","XFYFX+F+YFXFY-F-XFYFX"],
        ["Y","YFXFY-F-XFYFX+F+YFXFY"]
       ],
       90,
       ["F"],
       1,
       false],
    ["Peano Curve Octagonal",   // https://tecnoloxia.org/100hex/product/peano-curve/
    //  smooth for curved path
      "FX",
      [["F",""],
       ["X","FX-FY-FX+FY+FX+FY+FX+FY+FX-FY-FX-FY-FX-FY-FX+FY+FX"],
       ["Y","FY"]
       ],
       45,
       ["F"],
       1,
       false
    ],
    
   ["Peano Curve Variation",  // https://tecnoloxia.org/100hex/product/peano-variacion/
     "F",
     [
      ["F","F+F-F-F-G+F+F+F-F"],["G","FFF"]],
      90,
      ["F"],
       1,
       false],
     
   ["Sierpinski Curve",
         "F--XF--F--XF",
         [["X", "XF+F+XF--F--XF+F+X"]],
         45,
         ["F"] ,
         2.1,
         true],
         
   ["Sierpinski Curve Rounded",
     "X--F--X--F",
     [["X","+Y-F-Y+"],
      ["Y","-X+F+X-"]],
     45,
     ["F"],
     1.45,
     true
    ],  
    
   ["Sierpinski Arrowhead",
     "A",
     [
       ["A", "B-A-B"],
       ["B","A+B+A"]
     ],
    60,
     ["A","B"],
     1,
     false],
     
   ["Sierpinski Arrowhead Hex",
     // even iterations star, odd iterations filled hex
     "A-A-A-A-A-A",
     [
       ["A", "B-A-B"],
       ["B","A+B+A"]
     ],
     60,
     ["A","B"],
     1,
     true],
     
     ["Sierpinski Arrowhead Anti-Hex",
     // odd iterations star, even iterations filled hex
     "A+A+A+A+A+A",
     [
       ["A", "B-A-B"],
       ["B","A+B+A"]
     ],
    60,
     ["A","B"],
     1,
     true],
     
    
       
   ["Sierpinski Triangle",
      "A-B-B",
      [
        ["A","A-B+A+B-A"],
        ["B","BB"]
      ],
     120,
     ["A","B"],
     1,
     true],

// done to here

   ["Sierpinski Square", 
        "F+XF+F+XF",
        [["X","XF-F+F-XF+F+XF-F+F-X"]],
       90,
       ["F"],
       1,
       true],
       
   ["Levy Curve",
         "F",
         [["F","-F++F-"]],
         45,
         ["F"],
         1,
         false
         ],
 
   ["Cesaro Curve",
       "F",
       [["F","F+F--F+F"]],
       85,
       ["F"],
        1,
       false],
       
   ["Minkowski Sausage", 
    // Also Paul Bourke 1, Quadratic Koch Island
       "F+F+F+F+",
       [["F","F+F-F-FF+F+F-F"]],
       90,
       ["F"],
       1,
       true],
       
   ["Paul Bourke Triangle",
        "F+F+F",
        [["F","F-F+F"]],
        120],
 
   ["Koch Snowflake",
       "F++F++F",
       [["F","F-F++F-F"]],
       60],
       
   ["Koch Anti-snowflake",
       "F++F++F",
       [["F","F+F--F+F"]],
       60],
      
    ["Koch Square",
       "F--F--F--F--",
       [["F","F+F--F+F"]],
       45],
       
    ["Anti Koch Square",
       "F--F--F--F--",
       [["F","F-F++F-F"]],
       45],

   ["ABP Koch A",
         "F+F+F+F",
         [["F","FF+F+F+F+F+F-F"]],
        90],
 
   ["ABP Koch B",
         "F+F+F+F",
         [["F","FF+F+F+F+FF"]],
        90],
        
   ["ABP Koch C",
         "F+F+F+F",
         [["F","FF+F-F+F+FF"]],
        90],
  
   ["ABP Koch D",
         "F+F+F+F",
         [["F","FF+F++F+F"]],
        90],
 
   ["ABP Koch E",
         "F+F+F+F",
         [["F","F+FF++F+F"]],
        90],
        
   ["ABP Koch f",
         "F+F+F+F",
         [["F","F+F-F+F+F"]],
        90],
    
    ["Mandle6",
     "F+F+F+F+F+F+",
     [["F","F-F+F-F+F"]],
     60
     ],
         
   ["5-rep-tile",
      "F-F-F-F-",
      [["F","F+F-F"]],
      90
    ],
   
   ["7-rep-tile",
   // also Gosper island (boundary of flowsnake
      "F-F-F-F-F-F-",
      [["F","F+F-F"]],
      60
    ],
    ["Quadratic Gosper",
       "-YF",
       [["Y","+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"],
       ["X","XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-"]],
       
       90,
       ["F"],
        1,
        false ],
     
    ["Anklets of Krishna",
        "-X--X",
        [["X","XFX--XFX"]],
        45 ,   //45.02 splits it down a diagonal
        ["F"],
        1,
        true  
     ],
     
     ["Bourke Kolem",
       "--D--D",
        [["X","F++FFFF--F--FFFF++F++FFFF--F"],
        ["Y","F--FFFF++F++FFFF--F--FFFF++F"],
        ["C","YFX--YFX"],
        ["D","CFC--CFC"]],
        45
      ],
     ["Greek Cross",
         "F",
         [["F", "FF+F+F+FF+F+F-F"]],
         90],
     ["Plus Square",
     // by 100hex
       "XYXYXYX+XYXYXYX+XYXYXYX+XYXYXYX+",         
       [["X", "FX+FX+FXFY-FY-"],
           ["Y", "+FX+FXFY-FY-FY"],
           ["F",""]],
         90],
     ["100hex maple leaf",
      "F",
      [["F", "F-F+F+FF-F-F+FF"]],
      120
     ],
     ["Burke1",
     "F+F+FF+F+",
     [["F","F+F-F-FF+F+F-F"]],
     90]
  ];
   
function curves(i) = curves[i];
function all_curves() = curves;
function curve_named(s) = find(s,curves);

function curve_name(c) = c[0];
function curve_axiom(c) = c[1];
function curve_rules(c) = c[2];
function curve_angle(c) = c[3];
function curve_forward(c) = c[4];
function curve_factor(c) = c[5];

module curve_index() { 
  for (c=curves)
    echo(c); 
};

module frame(x,y,r) {
   hull() {
       translate([-x/2+r,-y/2+r]) circle(r);
       translate([x/2-r,-y/2+r]) circle(r);
       translate([x/2-r,y/2-r]) circle(r);
       translate([-x/2+r,y/2-r]) circle(r);       
   }
}

module print_curve(curve) {
     echo("name:",curve[0]);
     echo("axiom:",curve[1]);  
     echo("rules:",curve[2]);  
     echo("angle:",curve[3]);  
     echo("forward chars:",curve[4]);  
     echo("factor:",curve[5]);
};
