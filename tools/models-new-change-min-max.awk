/^min/ { min=""$2; next; }
/^max/ {
 max=""$2;
 if (min == "0" && max == "1e+06") {
   print("lod_level 0"); 
 } else if (min == "0" && max == "100") {
   print("lod_level 3");
 } else if (min == "100" && max == "200") {
   print("lod_level 2");
 } else if (min == "200" && max == "1e+06") {
   print("lod_level 1");
 } else {
   print "Unknown LOD levels: min: " min ", max: " max > "/dev/stderr";
   exit 1;
 }
 next;
}
{ print; }
