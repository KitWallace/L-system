
// basic function for use in function scripts

// dates

function formatted_date() {
    var d = new Date();
    var datestring = d.getDate() + "-" + ("0" +(d.getMonth() + 1)).slice(-2) + "-" +
    d.getFullYear() + " " + d.getHours() + ":" + ("0" + d.getMinutes()).slice(-2);
    return datestring;
}

// math
var RAD = Math.PI / 180.0;

function sgn(t) {
    return (t > 0) ? 1: (t < 0) ? -1: 0;
}

function d2r(d) {
    return d * RAD
}
function r2d(r) {
    return r / RAD
}

function sin(t) {
    return Math.sin(t * RAD);
}

function asin(t) {
    return r2d(Math.asin(t));
}

function cos(t) {
    return Math.cos(t * RAD);
}
function acos(t) {
    return r2d(Math.acos(t));
}

function tan(t) {
    return Math.tan(t * RAD);
}

function positive(x) {
    return x > 0;
}

function rdiv(a, b) {
    return Math.floor(a / b);
}

function rmod(a, b) {
    return a - rdiv(a, b) * b;
}

function is_between(x, a, b) {
    return x >= a && x <= b;
}

function interpolate(a, b, t) {
    return (1 - t) * a + t * b;
}

function list_interpolate(lista, listb, t) {
    return lista.map(function (x, i) {
        return interpolate(x, listb[i], t);
    });
}

function is_triangle(a, b, c) {
    return (a >= 0 && b >= 0 && c >= 0 && b + c >= a && a + c >= b && a + b >= c);
}

function round(number, precision) {
    var factor = Math.pow(10, precision);
    var tempNumber = number * factor;
    var roundedTempNumber = Math.round(tempNumber);
    return roundedTempNumber / factor;
};

// xy <> polar

function xy_to_polar(xy) {
    return[Math.sqrt(Math.pow(xy[0], 2) + Math.pow(xy[1], 2)),
    r2d(Math.atan2(xy[1], xy[0]))];
}

function polar_to_xy(rt) {
    return[rt[0] * cos(rt[1]), rt[0] * sin(rt[1])];
}


// 2-d point operations

function point_add(a, b) {
    return[b[0] + a[0], b[1] + a[1]];
}

function point_diff(a, b) {
    return[a[0] - b[0], a[1] - b[1]];
}

function point_mult(p, s) {
    return[p[0] * s, p[1] * s];
}

function point_interpolate(a, b, t) {
    return[interpolate(a[0], b[0], t), interpolate(a[1], b[1], t)];
}

function point_rotate(p, a) {
    return[p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)];
}

function point_perturb(p, r) {
    return[p[0] + (Math.random() -0.5) * r, p[1] + (Math.random() -0.5) * r];
}

function norm(p) {
    return Math.sqrt(p[0] * p[0] + p[1] * p[1]);
}

function unitv (a) {
    return point_mult(a, 1 / norm(a));
}

function dot(u, v) {
    return u[0] * v[0] + u[1] * v[1];
}

function cross(u, v) {
    return u[0] * v[1] - u[1] * v[0];
}

function angle_between(u, v) {
    var x = cross(u, v);
    var angle = Math.atan2(Math.abs(x), dot(u, v));
    if (x < 0)
    return 2 * Math.PI - angle; else
    return angle;
}

// 2-d line (edge) operations


function line_intersection(a, b) {
    var x1 = a[0][0];
    var y1 = a[0][1];
    var x2 = a[1][0];
    var y2 = a[1][1];
    var x3 = b[0][0];
    var y3 = b[0][1];
    var x4 = b[1][0];
    var y4 = b[1][1];
    
    var det = (x1 - x2) *(y3 - y4) - (y1 - y2) * (x3 - x4);
    if (det != 0) {
        var n1 = x1 * y2 - y1 * x2;
        var n2 = x3 * y4 - y3 * x4;
        var px = n1 *(x3 - x4) - n2 *(x1 - x2);
        var py = n1 *(y3 - y4) - n2 *(y1 - y2);
        return[px / det, py / det];
    }
}

// 2-d path operations

function path_translate(path, p) {
    return path.map(function (v, i) {
        return point_add(v, p);
    });
}

function path_scale(path, s) {
    if (Array.isArray(s))
    return path.map(function (v, i) {
        return[s[0] * v[0], s[1] * v[1]];
    }); else
    return path.map(function (v, i) {
        return[s * v[0], s * v[1]];
    });
}

function path_centre (path) {
    var box = bounding_box(path);
    return[(box[1] + box[0]) / 2,(box[3] + box[2]) / 2];
}

function path_centroid(path) {
    var sx = 0;
    var sy = 0;
    for (var i = 0; i < path.length; i++) {
        sx += path[i][0];
        sy += path[i][1];
    }
    return[sx / path.length, sy / path.length];
}

function path_to_centre(path) {
    var c = path_centre(path);
    c = point_mult(c, -1);
    return path_translate(path, c);
}
function path_to_centroid(path) {
    var c = path_centroid(path);
    c = point_mult(c, -1);
    return path_translate(path, c);
}

function matrix_round(matrix,n) {
   return matrix.map(function (v, i) {
        if (v.length >0)
            return v.map(function(r,j) {return round(r,n)});
        else return round(v,n);
    }); 
}

function path_round(path, n) {
    return path.map(function (v, i) {
        return [round(v[0], n), round(v[1], n)];
    });
}

function path_toFixed(path, n) {
    return path.map(function (v, i) {
        return[Number(v[0].toFixed(n)), Number(v[1].toFixed(n))];
    });
}

function path_shift(path, n) {
    return path.map(function (v, i) {
        return path[(i + n) % path.length];
    });
}

function path_segment(path, from, to) {
    var npath =[];
    for (var i = from; i < to; i++) {
        npath.push(path[i])
    }
    return npath;
}

function path_steps_between(a, b, n) {
    var path =[];
    for (var i = 0; i < n; i++) {
        var k = i /(n -1);
        path.push(point_interpolate(a, b, k));
    }
    return path;
}

function path_reverse(path) {
    return path.map(function (v, i) {
        return path[path.length - 1 - i];
    });
}

function path_rotate(path, a) {
    return path.map(function (v, i) {
        return point_rotate(v, a);
    });
}

function path_perturb(path, p) {
    return path.map(function (v, i) {
        return point_perturb(v, p);
    });
}

function path_at (path, t) {
    // t= [0,1]
    var i = Math.floor(i * path.length);
    return point_interpolate(path[i], path[i + 1], t - i / path.length);
}

function path_interpolate(patha, pathb, t) {
    return patha.map(function (v, i) {
        return point_interpolate(patha[i], pathb[i], t);
    });
}

function path_continuous_interpolate(patha, pathb) {
    var k = 1.0 / patha.length;
    var v =[];
    for (i = 0; i < patha.length; i++) {
        p = point_interpolate(patha[i], pathb[i], i * k);
        v.push(p);
    }
    return v;
}

function path_length(path) {
    var length = 0;
    for (i = 1; i < path.length; i++)
    length += norm(point_diff(path[i], path[i -1]));
    length += norm(point_diff(path[path.length - 1], path[0]));
    return length;
}

function path_diff(patha, pathb) {
    if (patha.length == pathb.length)
    return patha.map(function (v, i) {
        return point_diff(v, pathb[i]);
    }); else return false;
}

function path_offset(path, d) {
    // needs a bit of tidying  and optimisation -  mixture of rads and degrees
    var ipath =[];
    for (var i = 0; i < path.length; i++) {
        var iprev = (i - 1 + path.length) % path.length;
        var inext = (i + 1) % path.length;
        var vp = unitv(point_diff(path[i], path[iprev]));
        var vn = unitv(point_diff(path[inext], path[i]));
        var a = Math.PI - angle_between(vn, vp);
        var vd = unitv(point_add(vp, vn));
        var vm =[- vd[1], vd[0]];
        if (a > 0)
        vm = point_mult(vm, -1);
        var offset = d / Math.sin(a / 2);
        var offset_v = point_mult(vm, offset);
        var offset_p = point_add(path[i], offset_v);
        //      console.log(i,path[i],vp,vn,r2d(a/2),vm,offset,offset_v,offset_p);
        ipath.push(offset_p);
    }
    return ipath;
}

function path_offset_function(path, fn, y, p) {
    // needs a bit of tidying  and optimisation -  mixture of rads and degrees
    var ipath =[];
    for (var i = 0; i < path.length; i++) {
        var iprev = (i - 1 + path.length) % path.length;
        var inext = (i + 1) % path.length;
        var vp = unitv(point_diff(path[i], path[iprev]));
        var vn = unitv(point_diff(path[inext], path[i]));
        var a = Math.PI - angle_between(vn, vp);
        var vd = unitv(point_add(vp, vn));
        var vm =[- vd[1], vd[0]];
        if (a > 0)
        vm = point_mult(vm, -1);
        var x = i / path.length;
        var d = fn(x, y, p);
        //       console.log("offset",i,d);
        var offset = d / Math.sin(a / 2);
        var offset_v = point_mult(vm, offset);
        var offset_p = point_add(path[i], offset_v);
        ipath.push(offset_p);
    }
    return ipath;
}
function path_min_distance(path, p) {
    var min = 1000;
    var i_min = 0;
    for (var i = 0; i < path.length; i++) {
        var d = norm(point_diff(path[i], p));
        if (d < min) {
            min = d;
            i_min = i;
        }
    }
    return i_min;
}
// path smoothing


// closed paths
function weighted_interpolation(path, n, i, weight) {
    var p1 = point_mult(path[(i - 1 + n) % n], weight[0]);
    var p2 = point_mult(path[i], weight[1]);
    var p3 = point_mult(path[(i + 1 + n) % n], weight[2]);
    var p4 = point_mult(path[(i + 2 + n) % n], weight[3]);
    var new_point = point_add(p1, point_add(p2, point_add(p3, p4)));
    //     console.log(new_point);
    return new_point;
}

function path_smooth_r(path, weights) {
    var spath =[];
    for (var i = 0; i < path.length; i++) {
        //        spath.push(path[i]);
        spath.push(weighted_interpolation(path, path.length, i, weights));
    }
    return spath;
}

function path_smooth(path, n) {
    var weights =[-1 / 16, 9 / 16, 9 / 16, -1 / 16];
    if (n == 0)
         return path;
    else {
        spath = path_smooth_r(path, weights);
        //        console.log(spath);
        return path_smooth(spath, n -1);
    }
}

// Chalkin smoothing - closed paths

function path_chalkin_smooth_r(path, weight) {
    var spath =[];
    for (var i = 0; i < path.length; i++) {
        spath.push(point_interpolate(path[i], path[(i + 1) % path.length], weight));
        spath.push(point_interpolate(path[i], path[(i + 1) % path.length], 1 - weight));
    }
    return spath;
}

function path_chalkin_smooth(path,n) {
    var weight = 1 / 4;
    if (n == 0)
        return path; 
    else {
        spath = path_chalkin_smooth_r(path, weight);
        //        console.log(spath);
        return path_chalkin_smooth(spath, n -1);
    }
}

// fourier smoothing

function path_fourier_spectrum(points,amp_threshold,freq_threshold=1000) {
    var steps = points.length;    
//  convert to spectrum with DFT
    var input_x = points.map(function(value,index) { return value[0]; });
    var input_y = points.map(function(value,index) { return value[1]; });
    Out_xf = new Array(steps);
    Out_yf = new Array(steps);
    naiveDft(input_x, input_y, Out_xf, Out_yf, false);
// convert to amp-phase spectrum
    var spectrum = fourier_to_spectrum(Out_xf,Out_yf);
//  filter spectrum
    spectrum = fourier_spectrum_filter(spectrum, amp_threshold, freq_threshold)
    return spectrum;
}


function fourier_to_spectrum(px,py) {
    var p = [];
    for (var i=0;i<px.length;i++) {
        var amp= Math.sqrt(px[i]*px[i] + py[i]*py[i]);
        var phase=Math.atan2(py[i],px[i])*180/3.14159;
        var f= (i > px.length/2) ? -(px.length - i): i;
        if (amp  != 0) 
            p.push([amp,f,phase]);
    }
    return p;
}
function fourier_spectrum_filter(spectrum,amp_threshold,freq_threshold) {
    var out = [];
    for (var i=0;i < spectrum.length;i++) {
         var p = spectrum[i];
         if (p[0] >= amp_threshold  && p[1]  < freq_threshold)
              out.push(p);         
    }
    return out;
}

function fourier_spectrum_to_path (spectrum, steps) {
	var n=spectrum.length;
    var s=1;
    var pts =[];
    for (var i =0; i < steps; i++) {
      var X = 0;
	  var Y = 0;
	  var t= 360 * i / (steps-1);
      for (var j = 0; j < n; j++) { 
	        p=spectrum[j];
			X += ( p[0] * cos((t*p[1] + p[2]))) ;
			Y += ( p[0] * sin((t*p[1] + p[2]))) ;
		}
	   pts.push([s*X,s*Y]);
    }
    return pts;
}

function naiveDft(inreal, inimag, outreal, outimag, inverse) {
	var n = inreal.length;
	if (n != inimag.length || n != outreal.length || n != outimag.length)
		throw "Mismatched lengths";
	
	var coef = (inverse ? 2 : -2) * Math.PI;
	var scale = inverse ? 1 : 1 / (1*n);
	for (var k = 0; k < n; k++) {  // For each output element
		var sumreal = 0;
		var sumimag = 0;
		for (var t = 0; t < n; t++) {  // For each input element
			var angle = coef * (t * k % n) / n;  // This is more accurate than t * k
			sumreal += inreal[t] * Math.cos(angle) - inimag[t] * Math.sin(angle);
			sumimag += inreal[t] * Math.sin(angle) + inimag[t] * Math.cos(angle);
		}
		outreal[k] = sumreal * scale;
		outimag[k] = sumimag * scale;
	}
}


// path equalisation - construct path as a sequence of equal length segments  -

function path_cumulative_lengths(path, closed) {
    var length = 0;
    var qlengths =[0];
    var last = closed ? 0: 1;
    for (i = 1; i <= path.length - last; i++) {
        length += norm(point_diff(path[i % path.length], path[i -1]));
        qlengths.push(length);
    }
    return qlengths;
}

function path_equalize(path, n, closed) {
    var qlengths = path_cumulative_lengths(path, closed);
    var length = qlengths[qlengths.length -1];
    var delta = length / n;
    var epath =[];
    for (var i = 0; i < n; i++) {
        d = i * delta;
        p = path_position(path, qlengths, d);
        epath.push(p);
    }
    //    if (! closed) epath.push(path[path.length-1]);
    return epath;
}

function path_position(path, qlengths, d) {
    var i = 0;
    while (d >= qlengths[i]) i++;
    var step_length = qlengths[i] - qlengths[i -1];
    var excess = d - qlengths[i -1];
    var p = point_interpolate(path[i -1], path[i % path.length], excess / step_length);
    //  console.log(i,d,step_length,excess,excess/step_length,path[i-1],path[i],p);
    return p;
}

function bounding_box(points) {
    xs = points.map(function (v, i) {
        return v[0];
    });
    ys = points.map(function (v, i) {
        return v[1];
    });
    minx = Math.min.apply(Math, xs);
    maxx = Math.max.apply(Math, xs);
    miny = Math.min.apply(Math, ys);
    maxy = Math.max.apply(Math, ys);
    return[minx, maxx, miny, maxy];
}

function box_to_path(box) {
    //  [minx,maxx,miny,maxy];
    return[[box[0], box[2]],[box[1], box[2]],[box[1], box[3]],[box[0], box[3]]];
}
// svg functions
function svg_points(points, closed) {
    var start = points[0];
    var s = " M " + start[0] + " " + start[1];
    for (var i = 1; i < points.length; i++) {
        p = points[i];
        s += " L " + p[0] + "," + p[1];
    }
    if (closed) s += " L " + start[0] + "," + start[1];
    return s;
}

function svg_path(path, style) {
    var svg = "<path d='" + path + "' ";
    svg += " style='" + style;
    svg += "'/>";
    return svg;
}


function svg_dot(point, r, style) {
    return "<circle cx=" + point[0] + " cy=" + point[1] + " r=" + r + " style='" + style + "'/>";
}

// UI assists

function parsefloat(s) {
    var n = parseFloat(s);
    if (isNaN(n))
    return 0; else return x;
}
