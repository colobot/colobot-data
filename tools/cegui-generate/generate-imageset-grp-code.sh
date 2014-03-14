name=$1
x=$2
y=$3
echo "<Image name=\"${name}TL\" width=\"6\" height=\"6\" xPos=\"$x\" yPos=\"$y\" />"
echo "<Image name=\"${name}T\" width=\"52\" height=\"6\" xPos=\"$(($x+6))\" yPos=\"$y\" />"
echo "<Image name=\"${name}TR\" width=\"6\" height=\"6\" xPos=\"$(($x+6+52))\" yPos=\"$y\" />"
echo "<Image name=\"${name}L\" width=\"6\" height=\"6\" xPos=\"$x\" yPos=\"$(($y+6))\" />"
echo "<Image name=\"${name}C\" width=\"52\" height=\"52\" xPos=\"$(($x+6))\" yPos=\"$(($y+6))\" />"
echo "<Image name=\"${name}R\" width=\"6\" height=\"6\" xPos=\"$(($x+6+52))\" yPos=\"$(($y+6))\" />"
echo "<Image name=\"${name}BL\" width=\"6\" height=\"6\" xPos=\"$x\" yPos=\"$(($y+6+52))\" />"
echo "<Image name=\"${name}B\" width=\"52\" height=\"6\" xPos=\"$(($x+6))\" yPos=\"$(($y+6+52))\" />"
echo "<Image name=\"${name}BR\" width=\"6\" height=\"6\" xPos=\"$(($x+6+52))\" yPos=\"$(($y+6+52))\" />"
