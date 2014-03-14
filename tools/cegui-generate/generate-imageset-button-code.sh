name=$1
x=$2
y=$3
echo "<Image name=\"${name}TL\" width=\"12\" height=\"12\" xPos=\"$x\" yPos=\"$y\" />"
echo "<Image name=\"${name}T\" width=\"104\" height=\"12\" xPos=\"$(($x+12))\" yPos=\"$y\" />"
echo "<Image name=\"${name}TR\" width=\"12\" height=\"12\" xPos=\"$(($x+116))\" yPos=\"$y\" />"
echo "<Image name=\"${name}L\" width=\"12\" height=\"12\" xPos=\"$x\" yPos=\"$(($y+12))\" />"
echo "<Image name=\"${name}C\" width=\"104\" height=\"104\" xPos=\"$(($x+12))\" yPos=\"$(($y+12))\" />"
echo "<Image name=\"${name}R\" width=\"12\" height=\"12\" xPos=\"$(($x+116))\" yPos=\"$(($y+12))\" />"
echo "<Image name=\"${name}BL\" width=\"12\" height=\"12\" xPos=\"$x\" yPos=\"$(($y+116))\" />"
echo "<Image name=\"${name}B\" width=\"104\" height=\"12\" xPos=\"$(($x+12))\" yPos=\"$(($y+116))\" />"
echo "<Image name=\"${name}BR\" width=\"12\" height=\"12\" xPos=\"$(($x+116))\" yPos=\"$(($y+116))\" />"
