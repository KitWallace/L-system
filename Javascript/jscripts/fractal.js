/* 
 * 
 * 
 *  change to generating turtle (which can be output for interface to Turtle tool) and then interpreting the turtle code
 * 
 * -  issue with closing paths - moore has step missing 
 * -  successive turns need amalgamating to a single turn
 * 
 */
 
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

function fractal_replace(s,rules) {
    var ns="";
    for (var i = 0;i < s.length; i++){
        var c= s[i];
        var r=find_rule(c,rules);
        if (r  == -1)
            ns+=c; 
        else ns+=r;
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
       var dir=0;
       var step=1;
       var points=[pos];

       for (var i = 0;i < s.length;i++) {
           var c = s[i];         
           if (forward_chars.indexOf(c) > -1) {
              pos =  point_add(pos, [step * cos(dir),step * sin(dir)]);
              points.push(pos);
           }
            else if (c=="+")
              dir= dir - this.angle;
            else if (c=="-")
              dir= dir + this.angle;  
 //           console.log(pos,dir);
       }       
       return points;
    }

   string_to_turtle(s) {
       var forward_chars = this.forward_chars  ? this.forward_chars : ["F"] 
       var t= [];

       for (var i = 0;i < s.length;i++) {
           var c = s[i];         
           if (forward_chars.indexOf(c) > -1) {
              var step ="F 20";
              t.push(step);
           }
           else if (c=="+") {
              var step = "L " + this.angle;
              t.push(step);
           }
            else if (c=="-"){
              var step ="R " + this.angle;
              t.push(step);
           }
       }       
       return t.join();
    }

    make_fractal(generations)  {
        console.log("fractal",this);
        var eps = 0.01;
        var s = this.make_string(generations);
        console.log("s",s);
        var points = this.string_to_points(s);
        console.log("points",points);
        var turtle =this.string_to_turtle(s);
        console.log("turtle", JSON.stringify(turtle));
/*         if (this.closed  && norm(point_diff(points[0],points[points.length-1])) < eps )
          points.pop;

        console.log("after pop",points);
*/        var box = bounding_box(points);
        var width = box[1]-box[0];
        var height = box[3]-box[2];
        var centre = [box[0]+width/2,box[2]+height/2];
    
        points = path_translate(points, [-centre[0],-centre[1]]);
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
    console.log(fr);
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
   var box_path= [[-w,-h],[w,-h],[w,h],[-w,h]];

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

   
   canvas.append(svg_path(svg_points(box_path,true),"fill: none; stroke:black; stroke-width:3;"));  
   
   
   points = path_scale(points,screen_scale*10);  
   canvas.append(svg_path(svg_points(points,fractal.closed),"fill: none; stroke:blue; stroke-width:2;"));

   $("#svgframe").html($('#svgframe').html());  
}


$(document).ready(function(){
   fractal_selector();
   select_fractal();
})
