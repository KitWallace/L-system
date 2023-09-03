/*
  L-system (Lindenmayer) 
    symbols  
       F,A,B forward step
       + turn right angle
       - turn left angle
       other symbols are ignored
       
  see http://paulbourke.net/fractals/lsys/ 
    for a plethora of examples
  
  kit wallace Nov 2019 
  with thanks to Ronaldo and the Openscad Forum
*/

function find(key, list) =
      list[search([key],list)[0]]  ;

function join(l,s="",i=0) =
   i <len(l) 
      ? join(l,str(s,l[i]),i+1)
      : s;
      
function replace(s,rules) =
   join([for (c = s)
      let(r=find(c,rules)[1])
      r==undef ? c : r
   ]);
      
function gen(s,rules,k) =
    k==0? s : gen(replace(s,rules),rules,k-1);

function string_to_points(s,step=1,angle=90,pos=[0,0],dir=0) =
  [for( i  = 0,
        ps = [pos];

        i <= len(s);

        c   = s[i],
        pos = c=="F" ||c=="A" || c=="B"
               ? pos + step*[cos(dir), sin(dir)]
               : pos,
        dir = c=="+"  
              ? dir + angle
              : c=="-"
                ? dir - angle
                : dir,
        ps  = c=="F" ||c=="A" || c=="B"
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

module tile(points) {
    polygon(points);    
} 
function curves() =
/* curve directory entry structure
   0 - name
   1 - axiom
   2 - rules
   3 - angle in degrees
   4 - increase in size between generations
*/
 [
   ["Dragon",
   "FX",
   [
     ["X","X+YF+"],
     ["Y","-FX-Y"]
   ],
   90],

   ["Twin Dragon",
   "FX+FX+",
   [
     ["X","X+YF"],
     ["Y","FX-Y"]
   ],
   90],
   
   ["Terdragon",
   "F",
   [
     ["F","F+F-F"]
   ],
   120],
   
   ["Terdragon boundary",
    "A-B--A-B--",
    [["A","A+B"],
     ["B","A-B"]
     ],
     60
     ],
     
   ["McWorter's Pentigree",
    "F",
    [["F","+F++F----F--F++F++F-"]],
     36
     ],

    ["Fudgeflake",
     "FX++++FX++++FX",
    [["X","-FY++FX-"],
     ["Y","+FY--FX+"]
    ],
     30],
   
   ["Moore",
    "LFL+F+LFL",
    [
     ["L","-RF+LFL+FR-"],
     ["R","+LF-RFR-FL+"]
    ],
    90],
    
   ["Sierpinski Arrowhead, Sierpinksi Gasket",
     "A",
     [
       ["A", "B-A-B"],
       ["B","A+B+A"]
     ],
    60],
    
   ["Hilbert",
     "X",
     [
       ["X","-YF+XFX+FY-"],
       ["Y","+XF-YFY-FX+"]
     ],
     90,
     3],
     
   ["Peano-Gosper;FlowSnake",
      "A",
     [
       ["A","A-B--B+A++AA+B-"],
       ["B","+A-BB--B-A++A+B"]
      ],
     60],
    
   ["Sierpinski triangle",
      "A-B-B",
      [
        ["A","A-B+A+B-A"],
        ["B","BB"]
      ],
      120],
      
   ["Peano",
       "X",
       [
        ["X","XFYFX+F+YFXFY-F-XFYFX"],
        ["Y","YFXFY-F-XFYFX+F+YFXFY"]
       ],
       90],
       
    ["Peano Curved",
       "X",
       [
        ["X","XFYFXRFRYFXFYLFLXFYFX"],
        ["Y","YFXFYLFLXFYFXRFRYFXFY"],
        ["R","F+F+F+F+"],
        ["L","F-F-F-F-"]
       ],
       22.5],

   ["Koch snowflake",
       "F++F++F",
       [["F","F-F++F-F"]],
       60],

   ["Square Sierpinski", 
        "F+XF+F+XF",
        [["X","XF-F+F-XF+F+XF-F+F-X"]],
       90],

   ["Cesaro fractal",
       "F",
       [["F","F+F--F+F"]],
       85],
       
   ["Paul Bourke 1",
       "F+F+F+F+",
       [["F","F+F-F-FF+F+F-F"]],
       90],
       
   ["Paul Bourke Triangle",
        "F+F+F",
        [["F","F-F+F"]],
        120],
        
   ["ABP Koch a",
         "F+F+F+F",
         [["F","FF+F+F+F+F+F-F"]],
        90],
 
   ["ABP Koch b",
         "F+F+F+F",
         [["F","FF+F+F+F+FF"]],
        90],
        
   ["ABP Koch c",
         "F+F+F+F",
         [["F","FF+F-F+F+FF"]],
        90],
  
   ["ABP Koch d",
         "F+F+F+F",
         [["F","FF+F++F+F"]],
        90],
 
   ["ABP Koch e",
         "F+F+F+F",
         [["F","F+FF++F+F"]],
        90],
        
   ["ABP Koch f",
         "F+F+F+F",
         [["F","F+F-F+F+F"]],
        90],
 
   ["Levy Curve",
         "F",
         [["F","-F++F-"]],
         45],
         
   ["5-rep-tile",
      "F-F-F-F-",
      [["F","F+F-F"]],
      90
    ],
   
   ["7-rep-tile",
      "F-F-F-F-F-F-",
      [["F","F+F-F"]],
      60
    ],
    
   ["Kolem",
   "--D--D",
   [["X","F++FFFF--F--FFFF++F++FFFF--F"],
    ["Y","F--FFFF++F++FFFF--F--FFFF++F"],
    ["C","YFX--YFX"],
    ["D","CFC--CFC"]],
    45
   ],
   
    ["Quadratic Koch Island",
      "F-F-F-F-",
      [["F","F-F+F+FF-F-F+F"]],
    90
    ],
     
    ["Mandle",
     "F++F++F++",
     [["F","F+F--F+F"]],
     60
     ],
     
     ["Mandle6",
     "F+F+F+F+F+F+",
     [["F","F-F+F-F+F"]],
     60
     ],
     
     ["tsq",
      "FRFRFRFR",
      [["R","+F+F+F+F"]],
      22.5
      ],
      
      ["Square Koch tile - out",
       "F--F--F--F--",
       [["F","F+F--F+F"]],
       45,
       2+2*cos(45)],
       
      ["Square Koch tile - in",
       "F--F--F--F--",
       [["F","F-F++F-F"]],
       45,
       2+2*cos(45)],
   ];

function get_lsystem(i) = curves()[i];

function l_system(i,k=1,step=1) =
  let(curve=get_lsystem(i))
  let(name=curve[0])
  let(axiom=curve[1])
  let(rules=curve[2])
  let(angle=curve[3])
  let(sentence=gen(axiom,rules,k))
  string_to_points(sentence,step=step,angle=angle);
  
module index() { 
  curves = curves();
  for (i=[0:len(curves)-1])
    echo(i,curves[i][0]); 
};
