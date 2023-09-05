xquery version "3.1";
declare variable $local:fractals := doc("fractals.xml")//fractal;
declare function local:radians($d) {
    $d * math:pi() div 180.0
};

declare function local:index() {
  <table>
  {for $fractal in $local:fractals
   return 
   <tr>
     <td><a href="?name={$fractal/name[1]}&amp;generations=2">{$fractal/name[1]}</a></td>
     <td>aka {string-join(subsequence($fractal/name,2),", ")}</td>
     <td>{if ($fractal/isclosed) then "Closed" else "Open"}</td>
   </tr>
  }
  </table>
};

declare function local:show-fractal($fractal,$generation,$points) {
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
  <tr><th># points</th><td>{count($points)}</td></tr>
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


declare function local:symbols-to-points($fractal,$symbols) {
  let $pos := <point x="0" y="0"/>
  return local:symbols-to-points($fractal,$symbols,$pos,0,1,($pos))
};

declare function local:symbols-to-points($fractal,$symbols,$pos,$dir,$i,$points) {
    if ($i > count($symbols))
    then $points
    else
      let $step := $symbols[$i]
      let $new-pos := 
            if ($step="F")
            then 
              let $dir-rad := local:radians($dir)
              return
                element point {
                  attribute x {round-half-to-even($pos/@x + 10 * math:cos($dir-rad),6)}, 
                  attribute y {round-half-to-even($pos/@y + 10 * math:sin($dir-rad),6)}
                }
            else ()
      let $dir :=
            if ($step = "+")
            then $dir + $fractal/angle
            else if ($step="-")
            then $dir - $fractal/angle
            else $dir
      return 
        if (exists($new-pos))
        then local:symbols-to-points($fractal,$symbols,$new-pos,$dir,$i+1,($points,$new-pos))
        else local:symbols-to-points($fractal,$symbols,$pos,$dir,$i+1,$points)
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
let $symbol-array := string-to-codepoints($symbols)!codepoints-to-string(.)
let $points := local:symbols-to-points($fractal,$symbol-array)
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
   {local:show-fractal($fractal,$generations,$points)}
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
