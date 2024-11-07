for i in $(ls /data/dadmah/frieve/Organized_files/*/Block_photos/*.mnc);do
    id=$(echo ${i}|cut -d / -f 6); # find the block ID 
    echo ${id}
    path_t2=$(ls /data/dadmah/frieve/Organized_files/${id}/MRI_7T_blocks/*T2_TurboRARE*.mnc); #find the T2 TurboRARE image
    path_xfm=$(ls /data/dadmah/frieve/Organized_files/${id}/Registration/*Photo*.xfm); #find the co-registration transformation (block image to MRI)

    mincresample ${i} -like ${path_t2}  -transform ${path_xfm} /data/dadmah/frieve/Organized_files/${id}/Block_photos/${id}_Block_photo_to_MRI.mnc -inv -clobber #transform the block photo to MRI space 
done


