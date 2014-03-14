name=$1
x=$2 # pos.y = oy+sy*x; - see maindialog.cpp
echo "<Window type=\"Colobot/TextButton\" name=\"${name}_button\">"
echo "    <Property name=\"Area\" value=\"{{0.4,0},{$(bc <<< "0.83375-(0.070833333*$x)" | awk '{printf "%f", $0}'), 0},{0.6,0},{$(bc <<< "0.99375-(0.070833333*${x})" | awk '{printf "%f", $0}'),0}}\" />"
echo "</Window>"
