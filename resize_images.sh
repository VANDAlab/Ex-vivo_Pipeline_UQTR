for i in $(ls /data/dadmah/frieve/Organized_files/*/Histology_Files/.mnc);do 
s=$(echo ${i}|cut -d . -f 1); #get the filename
mincreshape ${i} ${s}_resized.mnc -dimsize xspace=200 -dimsize yspace=200 -clobber 
done