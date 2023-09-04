var Fractal_curves= 
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
   false],

   ["Dragon Curve: 3",
   // http://larryriddle.agnesscott.org/ifs/heighway/heighway.htm
       "FX",
       [["F",""],
        ["X","+FX--FY+"],
        ["Y","-FX++FY-"]
       ],
       45,
       ["F"],
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
   true],
   
   ["Terdragon",
   "F",
   [
     ["F","F+F-F"]
   ],
   120,
   ["F"],
   false],
   
   ["Terdragon Boundary",
     "A-B--A-B--",
    [["A","A+B"],
     ["B","A-B"]
     ],
     60,
     ["A","B"],
     true
     ],
     
   ["McWorter's Pentigree",
    "F",
    [["F","+F++F----F--F++F++F-"]],
     36,
     ["F"],
     false
     ],

    ["Fudgeflake",
     "FX++++FX++++FX",
    [["X","-FY++FX-"],
     ["Y","+FY--FX+"]
    ],
     30,
     ["F"],
     true],
   
   ["Moore",
    "LFL+F+LFL",
    [
     ["L","-RF+LFL+FR-"],
     ["R","+LF-RFR-FL+"]
    ],
    90,
    ["F"],
    true],
        
   ["Hilbert",
     "X",
     [
       ["X","-YF+XFX+FY-"],
       ["Y","+XF-YFY-FX+"]
     ],
     90,
     ["F"],
      
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
       
       false
    ],
    
   ["Peano Curve Variation",  // https://tecnoloxia.org/100hex/product/peano-variacion/
     "F",
     [
      ["F","F+F-F-F-G+F+F+F-F"],["G","FFF"]],
      90,
      ["F"],
       
       false],
     
   ["Sierpinski Curve",
         "F--XF--F--X",
         [["X", "XF+F+XF--F--XF+F+X"]],
         45,
         ["F"] ,
         true],
      ["Sierpinski Curve stocastic",
         "F--XF--F--X",
         [["X", [["XF+F+XF--F--XF+F+X",0.5],["XF+F+XF+F+XF",0.5]]]],
         45,
         ["F"] ,
         false],
         
     
   ["Sierpinski Curve Rounded",
     "X--F--X--",
     [["X","+Y-F-Y+"],
      ["Y","-X+F+X-"]],
     45,
     ["F"],
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
      
     true],
     
    
       
   ["Sierpinski Triangle",
      "A-B-B",
      [
        ["A","A-B+A+B-A"],
        ["B","BB"]
      ],
     120,
     ["A","B"],
      
     true],

// done to here

   ["Sierpinski Square", 
        "F+XF+F+X",
        [["X","XF-F+F-XF+F+XF-F+F-X"]],
       90,
       ["F"],
        
       true],
       
   ["Levy Curve",
         "F",
         [["F","-F++F-"]],
         45,
         ["F"],
          
         false
         ],
 
   ["Cesaro Curve",
       "F",
       [["F","F+F--F+F"]],
       85,
       ["F"],
         
       false],
       
   ["Minkowski Sausage", 
    // Also Paul Bourke 1, Quadratic Koch Island
       "F+F+F+F+",
       [["F","F+F-F-FF+F+F-F"]],
       90,
       ["F"],
        
       true],
       
   ["Paul Bourke Triangle",
        "F+F+F",
        [["F","F-F+F"]],
        120],
 
   ["Koch Snowflake",
       "F++F++F",
       [["F","F-F++F-F"]],
       60,,true],
       
   ["Koch Anti-snowflake",
       "F++F++F",
       [["F","F+F--F+F"]],
       60,,true],
      
    ["Koch Square",
       "F--F--F--F--",
       [["F","F+F--F+F"]],
       45,,true],
       
    ["Anti Koch Square",
       "F--F--F--F--",
       [["F","F-F++F-F"]],
       45,,true],

   ["ABP Koch A",
         "F+F+F+F",
         [["F","FF+F+F+F+F+F-F"]],
        90,,true],
 
   ["ABP Koch B",
         "F+F+F+F",
         [["F","FF+F+F+F+FF"]],
        90,,true],
        
   ["ABP Koch C",
         "F+F+F+F",
         [["F","FF+F-F+F+FF"]],
        90,,true],
  
   ["ABP Koch D",
         "F+F+F+F",
         [["F","FF+F++F+F"]],
        90,,true],
 
   ["ABP Koch E",
         "F+F+F+F",
         [["F","F+FF++F+F"]],
        90,,true],
        
   ["ABP Koch F",
         "F+F+F+F",
         [["F","F+F-F+F+F"]],
        90,,true],
    
    ["Mandle6",
     "F+F+F+F+F+F+",
     [["F","F-F+F-F+F"]],
     60,,true
     ],
         
   ["5-rep-tile",
      "F-F-F-F-",
      [["F","F+F-F"]],
      90,
      ,
      true
    ],
   
   ["7-rep-tile",
   // also Gosper island (boundary of flowsnake
      "F-F-F-F-F-F-",
      [["F","F+F-F"]],
      60,,true
    ],
    ["Quadratic Gosper",
       "-YF",
       [["Y","+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"],
       ["X","XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-"]],
       
       90,
       ["F"],
        false ],
     
    ["Anklets of Krishna",
        "-X--X",
        [["X","XFX--XFX"]],
        45 ,   //45.02 splits it down a diagonal
        ["F"],
        true  
     ],
     
     ["Bourke Kolem",
       "--D--D",
        [["X","F++FFFF--F--FFFF++F++FFFF--F"],
        ["Y","F--FFFF++F++FFFF--F--FFFF++F"],
        ["C","YFX--YFX"],
        ["D","CFC--CFC"]],
        45,,true
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
         90,,true],
     ["100hex maple leaf",
      "F",
      [["F", "F-F+F+FF-F-F+FF"]],
      120
     ],
     ["Burke1",
     "F+F+FF+F+F+",
     [["F","F+F-F-FF+F+F-F"]],
     90,true],
     
 //    {"start":"DFF","rules":{"F":"D+D","D":"-FF---+FF"},"a":36,"iter":7}
 
     ["LSystemBot1",
     "DFF",
     [["F","D+D"],["D","-FF---+FF"]],
     36,,true],
 // {"start":"FL","rules":{"F":"FFFFF+","L":"[L+]"},"a":45,"iter":5}
     ["LSystemBot2",
     "FL",
     [["F","FFFFF+"],["L","L+"]],
     45,,true],
     
     ["Fern",
      "X",
      [["F","FF"],
       ["X","F-[[X]+X]+F[+FX]-X"]
       ],
      22.5,
      "F"],
      ["Tree",
      "F",
      [["F","FF+[+F-F-F]-[-F+F+F]"]],
      22.5 
      ],
      ["Fan",
      "FX",
      [["X",">[-FX]+FX"]],
      40
      ],
      ["Snake Golem",
      "F+XF+F+XF",
      [["X","X{F-F-F}+XF+F+X{F-F-F}+X" ]],
      90],
      ["ABP-25-a",
      "F",
      [["F","F[+F]F[-F]F"]],
      25.7
      ],
      ["ABP-25-d",
      "X",
      [["X","F[+X]F[-X]+X"],
       ["F","FF"]],
      20
      ],
      ["ABP-26",
      "F",
      [["F",[["F[+F]F[-]F",0.33],["F[+F]F",0.33],["F[-F]F",0.34]]]],
     40
      ]
      
  ];
