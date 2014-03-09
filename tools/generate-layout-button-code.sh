name=$1
x=$2 # pos.y = oy+sy*x; - see maindialog.cpp
echo "<Window type=\"Colobot/TextButton\" name=\"${name}_button\">"
echo "    <Property name=\"Area\" value=\"{{0.41,0},{$(bc <<< "0.927083333-(0.070833333*$x)" | awk '{printf "%f", $0}'), 0},{0.59,0},{$(bc -l <<< "0.99375-(0.070833333*${x})" | awk '{printf "%f", $0}'),0}}\" />"
echo "</Window>"
