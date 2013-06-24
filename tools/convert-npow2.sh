function nearest_pow2 {
    python -c "import math; print(2 ** int(math.ceil(math.log($1) / math.log(2.0))))"
}

mkdir -p new

for file in $@ do
  size=$(identify $file | cut -d' ' -f 3)
  w=$(echo $size | cut -d'x' -f 1)
  h=$(echo $size | cut -d'x' -f 2)
  n_w=$(nearest_pow2 $w)
  n_h=$(nearest_pow2 $h)
  echo "$file: ${w}x${h} -> ${n_w}x${n_h}"
  convert $file -resize ${n_w}x${n_h}\! new/$file
done
