/* 
 * 
 * 
 * This version implements the following L-system operators
 * 
 *     F (or a defined set of symbols) - draw line 
 *     f  move without drawing
 *     + left rurn
 *     - right turn
 *     [ push state  
 *     ] pop state  ( and move to the restored position
 *     >  multiple step length by scale factor
 *     < divide step length by scale factor 
 * 
 *     stocastic paths with multiple replacement strings and probability
 * 
 *     Several designs form 'The Algorithmic Beity of Plants' which use these extended features added 
 * 
 
 */
 
 function point_add(a, b) {
    return[b[0] + a[0], b[1] + a[1],b[2] +a[2]];
 }
 
 function path_translate(path, p) {
    return path.map(function (v, i) {
        return point_add(v, p);
    });
}

function path_scale(path, s) {
    if (Array.isArray(s))
    return path.map(function (v, i) {
        return[s[0] * v[0], s[1] * v[1], v[2]];
    }); else
    return path.map(function (v, i) {
        return[s * v[0], s * v[1], s* v[2]];
    });
}
 function svg_points(points, closed) {
    s="";
    for (var i = 0; i < points.length; i++) {
        p = points[i];
        s += (p[2]== 0 ? " M " :" L ") + p[0] + "," + p[1];
    }
    if (closed) s += " L " + points[0][0] + "," + points[0][1];
    return s;
}

function svg_path(path, style) {
    var svg = "<path d='" + path + "' ";
    svg += " style='" + style;
    svg += "'/>";
    return svg;
}

var fr;

function select_fractal() {
    var index= $('#index').val();
    var curve = Fractal_curves[index];
    fr = new Fractal_curve(curve);
    $('#gen').val(2);
    refresh();
}

function fractal_selector() {
    var html="<div><select id='index' onchange='select_fractal()'>";
    for (var i =0;i < Fractal_curves.length;i++)
     {
      var curve= Fractal_curves[i];
      html+="<option value='"+i+"'>"+curve[0]+"</option>";
     }
     html+="</div>";
     $('#select-fractal').html(html);
     $('#slidergen' ).slider({
           min:1,
           max:25,
           value:2,
           step:1,
           slide: function(event, ui) {
                     $('#gen').val(ui.value);
                     refresh();  
                  }
           });
     $('#sliderscale' ).slider({
           min:0,
           max:3,
           value:1,
           step:0.01,
           slide: function(event, ui) {
                     $('#scale').val(ui.value);
                     refresh();  
                  }
           });
}

function fractal_named(name) {
   for (var i =0;i < Fractal_curves.length;i++)
     {
      var curve= Fractal_curves[i];
      if (curve[0] == name)
        return new Fractal_curve(curve);
      }
  return undefined;
}

function find_rule(c,rules) {
    for (var i=0;i<rules.length;i++){
        var rule=rules[i];
        if (rule[0]==c)
           return rule[1];
    }
    return -1;
}

function select_rule(rules,p) {
   var replacement;
   var cumulative = 0;
   for (var i=0;i<rules.length;i++) {
       var rule = rules[i];
       if (p >= cumulative  && p < cumulative + rule[1]) {
          replacement=rule[0];
          break;
       }
       else cumulative += rule[1];
   }
   return replacement;   
}

function fractal_replace(s,rules) {
    var ns="";
    for (var i = 0;i < s.length; i++){
        var c= s[i];
        var replacement=find_rule(c,rules);
        if (replacement  == -1)
            ns+=c; 
        else if (Array.isArray(replacement)) {
            p = Math.random();
            ns+= select_rule(replacement,p)       
        }      
        else 
            ns+=replacement;
    }
    return ns;
}


class Fractal_curve {
    name;
    axiom;
    rules;
    angle;
    scale_factor;
    forward_chars;
    closed;
    constructor(data){
        this.name = data[0];
        this.axiom=data[1];
        this.rules=data[2];
        this.angle=data[3];
        this.forward_chars=  data[4] ? data[4] : ["F"];
        this.closed= data[5] ? data[5] : false ;
    
    }
    get to_HTML() {
        var html="";
        html+="<tr><th/><td>name</td><td>"+ this.name+"</td></tr>";
        html+="<tr><th/><td>axiom</td><td>"+ this.axiom+"</td></tr>";
        html+="<tr><th/><td>forward characters</td><td>"+this.forward_chars+"</td></tr>"
        html+="<tr><th/><td>rules</td><td>"+ JSON.stringify(this.rules)+"</td></tr>";
        html+="<tr><th/><td>angle</td><td>"+ this.angle+"</td></tr>";
        html+="<tr><th/><td>closed</td><td>"+ this.closed+"</td></tr>";
        return html;
       }
       
    make_string(k) {
       var s=this.axiom;
       for (var i = 0;i<k; i++) {
           s = fractal_replace(s,this.rules);
       }

       return s;
    }
     
    string_to_points(s) {
       var forward_chars = this.forward_chars  ? this.forward_chars : ["F"] 
       var pos = [0,0];
       var dir=-90;
       var stack = [];
       var state ;
       var step=1;
       var scale_factor =0.75;
       var points=[[pos[0],pos[1],0]];   // 0 is move

       for (var i = 0;i < s.length;i++) {
           var c = s[i];         
           if (forward_chars.indexOf(c) > -1) {
              pos =  point_add(pos, [step * cos(dir),step * sin(dir)]);
              points.push([pos[0],pos[1],1]);  // 1 is draw
           }
            else if (c=="f") {
              pos =  point_add(pos, [step * cos(dir),step * sin(dir)]);
              points.push([pos[0],pos[1],0]);  // 01 is movr               
            }
            else if (c=="+")
              dir= dir - this.angle;
            else if (c=="-")
              dir= dir + this.angle;  
            else if (c==">")
               step = step* scale_factor;
           else if (c=="<")
               step = step / scale_factor;
            else if (c=="[") {
               state = [pos,dir,step];
               stack.push(state);
               }
            else if (c=="]") {
               state = stack.pop();
               pos = state[0];
               dir = state[1];
               step=state[2];
               points.push([pos[0],pos[1],0]); // 0 is move
             }
       }  
       return points;
    }

    make_fractal(generations)  {
//        console.log("fractal",this);
        var eps = 0.01;
        var s = this.make_string(generations);
//        console.log("s",s);
        var points = this.string_to_points(s);
//        console.log("points",points);
/*         if (this.closed  && norm(point_diff(points[0],points[points.length-1])) < eps )
          points.pop;

        console.log("after pop",points);
*/      
        var box = bounding_box(points);
 //       console.log("BB",box);
        var width = box[1]-box[0];
        var height = box[3]-box[2];
        var centre = [box[0]+width/2,box[2]+height/2];
       
        points = path_translate(points, [-centre[0],-centre[1],0]);
        points = path_scale (points,5 / Math.max(width,height));
        return points;
    }
}

function refresh() {
    var gen = parseFloat($('#gen').val());
    var scale = parseFloat($('#scale').val());
    var html = fr.to_HTML;
//    console.log(html);
    $('#def').html(html);    
    var points = fr.make_fractal(gen);
    points = path_scale(points,scale);
    $('#n-points').text(points.length);
//    console.log(fr);
    $('#points').text(JSON.stringify(path_toFixed(points,5)));
    make_svg(fr,points);
}

function make_svg(fractal,points) {
//   var bed_width = parseFloat($('#bed-width').val());
//   var bed_height = parseFloat($('#bed-height').val());
   var bed_width = "150";
   var bed_height = "150";
   var screen_scale=4;
   var w=screen_scale * bed_width/2;
   var h =screen_scale * bed_height/2;
   var box = [[-w,-h], [w,h]];
   var box_path= [[-w,-h,0],[w,-h,1],[w,h,1],[-w,h,1]];

//   box = bounding_box(points);
   padding=20;
   canvas=$('#canvas');
   width = 2*w + 2 * padding;
   height= 2*w + 2 * padding;
   $('#svgimage').attr("width",width);
   $('#svgimage').attr("height",height);
//   console.log(width,height);
   canvas.empty();
   transform = "translate(" + ( w +padding) +","+ (w + padding)  +") ";
//  alert(transform);
   canvas.attr("transform", transform);
   canvas.append("<title>"+$('#fname').text()+"</title>");
   var path = svg_path(svg_points(box_path,true),"fill: none; stroke:black; stroke-width:3;");
 //  console.log(path);
   canvas.append(path);
   
   points = path_scale(points,screen_scale*10);  
   path = svg_path(svg_points(points,fractal.closed),"fill: none; stroke:blue; stroke-width:2;");
 //  console.log(path);
   canvas.append(path);

   $("#svgframe").html($('#svgframe').html());  
}


$(document).ready(function(){
   fractal_selector();
   select_fractal();
})
