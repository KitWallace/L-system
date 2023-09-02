import module namespace math ="http://exist-db.org/xquery/math"  at "org.exist.xquery.modules.math.MathModule";
declare variable $local:fractals := doc("fractals.xml")//fractal;

declare function local:index() {
  <table>
  {for $fractal in $local:fractals
   return 
   <tr>
     <td><a href="?name={$fractal/name[1]}&amp;generations=2">{$fractal/name[1]}</a></td>
     <td>{if ($fractal/isclosed) then "Closed" else "Open"}</td>
   </tr>
  }
  </table>
};

declare function local:show-fractal($fractal,$generation) {
<table>
  <tr><th>Names</th><td>{string-join($fractal/name,", ")}</td></tr>
  <tr><th>Axiom</th><td>{$fractal/axiom/string()}</td></tr>
  <tr><th>Rules</th><td>{for $rule in $fractal/rules/rule
                         return <div> {$rule/@replace/string()} >> {$rule/@with/string()}</div>
                        }</td></tr>
  <tr><th>Angle</th><td>{$fractal/angle/string()}</td></tr>
  <tr><th>Open/Closed</th><td>{if ($fractal/isclosed) then "Closed" else "Open"}</td></tr>
  <tr><th>Forward symbols</th><td>{$fractal/forward-symbols/string()}</td></tr>
  <tr><th>Generation</th><td>{$generation}</td></tr>
</table>
};

declare function local:replace($fractal, $symbols as xs:string, $generation as xs:integer) {
   if ($generation > 0)
   then
      let $new-symbols :=
         string-join(
          for $char in string-to-codepoints($symbols)!codepoints-to-string(.)
          let $rule := $fractal//rule[@replace=$char]
          return
             if ($rule)
             then $rule/@with/string()
             else $char
         ,"")
     return local:replace($fractal,$new-symbols,$generation - 1)
   else $symbols
};

declare function local:symbols-to-turtle($fractal,$symbols) {
   let $forward-symbols := $fractal/forward-symbols
   return
      for $char in string-to-codepoints($symbols)!codepoints-to-string(.)
      return
          if (contains($forward-symbols,$char))
          then <step command="F" d="20"/>
          else if ($char="+")
          then <step command="L" d="{$fractal/angle}"/>
          else if ($char="-")
          then <step command="R" d="{$fractal/angle}"/>
          else ()    
};

declare function local:turtle-to-points($turtle) {
  let $pos := <point x="0" y="0"/>
  return local:turtle-to-points($turtle,$pos,0,1,($pos))
};

declare function local:turtle-to-points($turtle,$pos,$dir,$i,$points) {
    if ($i > count($turtle))
    then $points
    else
      let $step := $turtle[$i]
      let $new-pos := 
            if ($step/@command = "F")
            then 
              let $dir-rad := math:radians($dir)
              return
                element point {
                  attribute x {round-half-to-even($pos/@x + $step/@d * math:cos($dir-rad),6)}, 
                  attribute y {round-half-to-even($pos/@y + $step/@d * math:sin($dir-rad),6)}
                }
            else ()
      let $dir :=
            if ($step/@command = "L")
            then $dir + $step/@d
            else if ($step/@command ="R")
            then $dir - $step/@d
            else $dir
      return 
        if (exists($new-pos))
        then local:turtle-to-points($turtle,$new-pos,$dir,$i+1,($points,$new-pos))
        else local:turtle-to-points($turtle,$pos,$dir,$i+1,$points)
};

declare function local:points-to-svg-path($fractal,$points) {
   let $start := $points[1]
   let $last := $points[last()]
   let $diff := <point x="{$last/@x - $start/@x}" y = "{$last/@y - $start/@y}"/>
   let $d := $diff/@x * $diff/@x + $diff/@y * $diff/@y
   return
        concat(
        " M " || $start/@x || "," || $start/@y ,
        string-join(
           for $point in subsequence($points,2)
           return " L " || $point/@x || "," || $point/@y
           ,""),
         if ($fractal/isclosed and $d > 0.1)
         then  " L " || $start/@x || "," || $start/@y 
         else ()
         )
};

declare function local:points-to-array($points) {
  concat("[", string-join(for $point in $points return concat("[",$point/@x,",",$point/@y,"]"),","), "]")
};

declare function local:bounding-box($points,$padding) {
   <bounding-box minx="{min($points/@x) - $padding}" maxx = "{max($points/@x) + $padding}" miny ="{min($points/@y) - $padding}" maxy = "{max($points/@y) + $padding}"/>  
};

declare function local:points-to-svg($fractal,$points,$style,$padding) {
   let $bounding-box := local:bounding-box($points,$padding)
   let $width := $bounding-box/@maxx - $bounding-box/@minx 
   let $height := $bounding-box/@maxy - $bounding-box/@miny 
   return
      <svg xmlns="http://www.w3.org/2000/svg"  width="{$width}px" height="{$height}px" viewbox="0 0 {$width} {$height}" >
          <g id="canvas" transform="translate({ - xs:float($bounding-box/@minx)},{- xs:float($bounding-box/@miny)})" >
           <path d="{local:points-to-svg-path($fractal,$points)}"  
            style="fill: none; stroke:{$style/@colour}; stroke-linejoin: round; stroke-width:{$style/@width}">
           </path>
          </g>
      </svg>
};

declare function local:points-to-openscad($fractal,$points,$generation,$construction) {
        string-join((
          util:binary-to-string(util:binary-doc("/db/apps/fractals/openscad.txt")),
          concat('fractal_name="',$fractal/name[1],'";'),
          concat("generation=",$generation,";"),
          concat("width=",$construction/@width,";"),
          concat("isclosed=",exists($fractal/isclosed),";"),
          concat("scale = ",$construction/@scale,";"),
          concat("points = ", local:points-to-array($points), ";"),
          "//",
          if ($construction/@mode="perimeter")
          then "scale(scale) path(points,width,isclosed);"
          else "polygon(points);"
         ),"&#10;"
        )
 };
 
let $serialise := util:declare-option("exist:serialize","method=xhtml media-type=text/html")
let $mode := request:get-parameter("mode","svg")
let $name := request:get-parameter("name",())
return 
if (exists($name)) 
then 
let $generations := request:get-parameter("generations",())
let $fractal := $local:fractals[name=$name]
let $symbols := local:replace($fractal,$fractal/axiom,$generations)
let $turtle := local:symbols-to-turtle($fractal,$symbols)
let $points := local:turtle-to-points($turtle)
let $style := <style colour="red" width="3"/>
return
if ( $mode="svg")
then
  <div>
   <h2><a href="?">Fractal curves</a> :  {$fractal/name[1]/string()} </h2>
   <form action="?" >Generations <input type="hidden" name="name" value="{$fractal/name[1]}"
   /><input type="text" size="4" name="generations" value="{$generations}"/> as 
   <input type="submit" name="mode" value="svg"/> <input type="submit" name="mode" value="points"/> <input type="submit" name="mode" value="openscad"/>
   </form>
   {local:show-fractal($fractal,$generations)}
   <div>
     {local:points-to-svg($fractal,$points,$style,20)}
   </div>
   </div>
else if ($mode="points")
then    
  <div>
  <h2><a href="?name={$fractal/name[1]}&amp;generations={$generations}">{$fractal/name[1]/string()}</a> : Points </h2>
<div>
    {local:points-to-array($points)}
   </div>
   </div>
else if ($mode="openscad")
then
   let $construction := <construction mode="perimeter" width="5" scale="1"/>
   let $serialise := util:declare-option("exist:serialize","method=text media-type=text/text")
   return 
   local:points-to-openscad($fractal,$points,$generations,$construction)
else if ($mode="diag")
then $fractal
else ()
else
   <div>
   <h1>Fractal curves</h1>
   {local:index()}
   </div>
