for i in $(ls /data/dadmah/frieve/Organized_files/*/Histology_Files/*.mnc);do
    id=$(echo ${i}|cut -d / -f 6); # find the block ID 
    #echo ${id}
    path_t2=$(ls /data/dadmah/frieve/Organized_files/${id}/MRI_7T_blocks/*T2_TurboRARE*.mnc); #find the T2 TurboRARE image

    stain_1=$(echo ${i}|cut -d _ -f 10); # find the stain name
    stain_2=$(echo ${i}|cut -d _ -f 11); # find the stain number
    path_xfm=$(ls /data/dadmah/frieve/Organized_files/${id}/Registration/*${stain_1}_${stain_2}*.xfm); #find the co-registration transformation (stain image to MRI)

    mincresample ${i} -like ${path_t2}  -transform ${path_xfm} /data/dadmah/frieve/Organized_files/${id}/Histology_Files/${id}_${stain_1}_${stain_2}_Histology_to_MRI.mnc -inv -clobber #transform the histology photo to MRI space 
done


