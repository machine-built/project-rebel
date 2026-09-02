i=0
for f in *.jpg; do
  ext="${f##*.}"
  printf -v idx "%02d" "$i"
  mv -- "$f" "fossBG_${idx}.${ext}"
  i=$((i+1))
done
