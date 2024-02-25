#! /bin/bash

### Mahsa Dadar , Yashar Zeighami 2024-01  ###
#Input file format:
# id,visit,t1,t2
# Dependencies: minc-toolkit, anaconda, and ANTs
# for use at the CIC, you can load the following modules (or similar versions)
# module load minc-toolkit-v2/1.9.18.2 ANTs/20220513 anaconda/2022.05

if [ $# -eq 3 ];then
    input_list=$1
    model_path=$2
    output_path=$3
else
 echo "Usage $0 <input list> <model path> <output_path>"
 echo "Outputs will be saved in <output_path> folder"
 exit 1
fi

### Naming Conventions ###
# stx: stereotaxic space (i.e. registered to the standard template)
# lin: linear registration 
# nlin: nonlinear registration
# dbm: deformation based morphometry
# cls: tissue classification
# qc: quality control
# tmp: temporary
# nlm: denoised file (Coupe et al. 2008)
# n3: non-uniformity corrected file (Sled et al. 1998)
# vp: acronym for volume_pol, intensity normalized file
# t1: T1 weighted image 
# t2: T2 weighted image
# icbm: standard template
# beast: acronym for brain extraction based on nonlocal segmentation technique (Eskildsen et al. 2012)
# ANTs: Advanced normalization tools (Avants et al. 2009)
# BISON: Brain tissue segmentation (Dadar et al. 2020)

### Pre-processing the native data ###
for i in $(cat ${input_list});do
    id=$(echo ${i}|cut -d , -f 1)
    visit=$(echo ${i}|cut -d , -f 2)
    t1=$(echo ${i}|cut -d , -f 3)
    t2=$(echo ${i}|cut -d , -f 4)
    echo ${id} ${visit}
    ### Creating the directories for preprocessed outputs ###
    # native: where the preprocessed images (denoising, non-uniformity correction, intensity normalization) will be saved (before linear registration)
    # stx_lin: where the preprocessed and linearly registered images will be saved
    # stx_nlin: where nonlinear registration outputs (ANTs) will be saved
    # vbm: where deformation based morphometry (dbm) outputs will be saved
    # cls: where tissue classficiation outputs (BISON) will be saved 
    # template: where linear and nonlinear average template will be saved
    # qc: where quality control images will be saved
    # tmp: temporary files, will be deleted at the end

    mkdir -p ${output_path}/${id}/${visit}/native
    mkdir -p ${output_path}/${id}/${visit}/stx_lin
    mkdir -p ${output_path}/${id}/${visit}/stx_nlin
    mkdir -p ${output_path}/${id}/${visit}/vbm
    mkdir -p ${output_path}/${id}/cls
    mkdir -p ${output_path}/${id}/template
    mkdir -p ${output_path}/${id}/qc
    mkdir -p ${output_path}/${id}/tmp

    ### denoising ###
    #mincnlm ${t1} ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_nlm.mnc -mt 1 -beta 0.7 -clobber
    #if [ ! -z ${t2} ];then mincnlm ${t2} ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_nlm.mnc -mt 1 -beta 0.7 -clobber; fi

    ### co-registration of different modalities to t1 ###
    #if [ ! -z ${t2} ];then bestlinreg_s2 -lsq6 ${t2} ${t1} ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_to_t1.xfm -clobber -mi; fi

    ## generating temporary masks for non-uniformity correction ###
    #bestlinreg_s2 ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_nlm.mnc ${model_path}/Av_T2.mnc ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx_tmp0.xfm  -clobber
    #mincresample  ${model_path}/Mask.mnc -like ${t1} ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_mask_tmp.mnc -transform \
    #    ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx_tmp0.xfm -inv -nearest -clobber
    #mincresample  ${model_path}/Mask.mnc -like ${t2} ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_mask_tmp.mnc -transform \
    #    ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx_tmp0.xfm  -inv -nearest -clobber
      
    ### non-uniformity correction ###
    #nu_correct ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_nlm.mnc ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_n3.mnc \
    # -mask ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_mask_tmp.mnc -iter 200 -distance 200 -stop 0.000001 -normalize_field  -clobber
    #nu_correct ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_nlm.mnc ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_n3.mnc \
    #-mask ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_mask_tmp.mnc -iter 200 -distance 200 -stop 0.000001 -normalize_field  -clobber

    ### intensity normalization ###
    #volume_pol ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_n3.mnc ${model_path}/Av_T1.mnc --order 1 --noclamp --expfile ${output_path}/${id}/tmp/tmp ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_vp.mnc \
    #--source_mask ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_mask_tmp.mnc --target_mask ${model_path}/Mask.mnc  --clobber
    #volume_pol ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_n3.mnc ${model_path}/Av_T2.mnc --order 1 --noclamp --expfile ${output_path}/${id}/tmp/tmp ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_vp.mnc \
    # --source_mask ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_mask_tmp.mnc --target_mask ${model_path}/Mask.mnc  --clobber

done

### registering everything to stx space ###
#bestlinreg_s2 ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_vp.mnc ${model_path}/Av_T2.mnc  \
#    ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx2.xfm  -clobber

#itk_resample ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_vp.mnc ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin.mnc \
#    --like ${model_path}/Av_T1.mnc --transform ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx2.xfm --order 4 --clobber
#itk_resample ${output_path}/${id}/${visit}/native/${id}_${visit}_t2_vp.mnc ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t2_stx2_lin.mnc \
#    --like ${model_path}/Av_T2.mnc --transform ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx2.xfm --order 4 --clobber

#itk_resample ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_vp.mnc ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin_lowres.mnc \
#    --like ${model_path}/lowres.mnc --transform ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm_stx2.xfm --order 4 --clobber

#mincbeast ${model_path}/ADNI_library ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin_lowres.mnc \
#    ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask_lowres.mnc -fill -median -same_resolution \
#    -configuration ${model_path}/ADNI_library/default.2mm.conf -clobber
     
#mincresample ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask_lowres.mnc ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask.mnc -nearest -like \
#    ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin.mnc -clobber


#volume_pol ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin.mnc ${model_path}/Av_T1.mnc --order 1 --noclamp --expfile ${output_path}/${id}/tmp/tmp \
#    ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin_vp.mnc  --source_mask ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask.mnc \
#    --target_mask ${model_path}/Mask.mnc --clobber
#volume_pol ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t2_stx2_lin.mnc ${model_path}/Av_T2.mnc --order 1 --noclamp -expfile ${output_path}/${id}/tmp/tmp \
#${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t2_stx2_lin_vp.mnc  --source_mask ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask.mnc \
#    --target_mask ${model_path}/Mask.mnc --clobber

#trg_mask=${model_path}/Mask.mnc    
#src=${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t2_stx2_lin_vp.mnc
#trg=${model_path}/Av_T2.mnc
#src_mask=${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask.mnc
    
#outp=${output_path}/${id}/${visit}/stx_nlin/${id}_${visit}_inv_nlin_
#if [ ! -z $trg_mask ];then
#    mask="-x [${src_mask},${trg_mask}] "
#fi
#antsRegistration -v -d 3 --float 1  --output "[${outp}]"  --use-histogram-matching 0 --winsorize-image-intensities "[0.005,0.995]" \
#   --transform "SyN[0.7,3,0]" --metric "CC[${src},${trg},1,4]" --convergence "[50x50x30,1e-6,10]" --shrink-factors 4x2x1 --smoothing-sigmas 2x1x0vox ${mask} --minc

#itk_resample ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_lin_vp.mnc ${output_path}/${id}/${visit}/stx_nlin/${id}_${visit}_nlin.mnc \
#    --like ${model_path}/Av_T1.mnc --transform ${output_path}/${id}/${visit}/stx_nlin/${id}_${visit}_inv_nlin_0_inverse_NL.xfm --order 4 --clobber --invert_transform
#grid_proc --det ${output_path}/${id}/${visit}/stx_nlin/${id}_${visit}_inv_nlin_0_inverse_NL_grid_0.mnc ${output_path}/${id}/${visit}/vbm/${id}_${visit}_dbm.mnc
    
#echo Subjects,T1s,Masks,XFMs >> ${output_path}/${id}/to_segment_t2.csv
#echo ${id}_${visit}_t1,${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t2_stx2_lin.mnc,\
#${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask.mnc,\
#${output_path}/${id}/${visit}/stx_nlin/${id}_${visit}_inv_nlin_0_inverse_NL.xfm >> ${output_path}/${id}/to_segment_t2.csv 

#echo Subjects,T1s,Masks,XFMs >> ${output_path}/${id}/to_segment_t1.csv
#echo ${id}_${visit}_t1,${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t2_stx2_lin_inv.mnc,\
#${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_t1_stx2_beast_mask.mnc,\
#${output_path}/${id}/${visit}/stx_nlin/${id}_${visit}_inv_nlin_0_inverse_NL.xfm >> ${output_path}/${id}/to_segment_t1.csv 

### Running BISON for tissue classification ###
#python ${model_path}/BISON.py -c RF0 -m ${model_path}/Pretrained_Library_Just_T2_L9/ \
# -o  ${output_path}/${id}/cls/ -t ${output_path}/${id}/tmp/ -e PT -n  ${output_path}/${id}/to_segment_t2.csv  -p  ${model_path}/Pretrained_Library_Just_T2_L9/ -l 9

python ${model_path}/BISON.py -c RF0 -m ${model_path}/Pretrained_Library_ADNI_L9/ \
 -o  ${output_path}/${id}/cls/ -t ${output_path}/${id}/tmp/ -e PT -n  ${output_path}/${id}/to_segment_t1.csv  -p  ${model_path}/Pretrained_Library_ADNI_L9/ -l 9

itk_resample ${output_path}/${id}/cls/RF0_${id}_${visit}_t1_Label.mnc  ${output_path}/${id}/cls/RF0_${id}_${visit}_t1_native_Label.mnc \
--like ${output_path}/${id}/${visit}/native/${id}_${visit}_t1_vp.mnc --transform ${output_path}/${id}/${visit}/stx_lin/${id}_${visit}_to_icbm.xfm --label --invert_transform --clobber

### generating QC files ###
minc_qc.pl ${output_path}/${id}/${visit_tp}/stx_lin/${id}_${visit_tp}_t1_stx2_lin_vp.mnc ${output_path}/${id}/qc/${id}_${visit_tp}_t1_stx2_lin_vp.jpg \
     --mask ${model_path}/outline.mnc --big --clobber  --image-range 0 100
if [ ! -z ${t2} ];then minc_qc.pl ${output_path}/${id}/${visit_tp}/stx_lin/${id}_${visit_tp}_t2_stx2_lin_vp.mnc ${output_path}/${id}/qc/${id}_${visit_tp}_t2_stx2_lin_vp.jpg \
     --mask ${model_path}/outline.mnc --big --clobber  --image-range 0 100; fi
 minc_qc.pl ${output_path}/${id}/${visit_tp}/stx_lin/${id}_${visit_tp}_t1_stx2_lin_vp.mnc ${output_path}/${id}/qc/${id}_${visit_tp}_t1_mask.jpg \
    --mask ${output_path}/${id}/${visit_tp}/stx_lin/${id}_${visit_tp}_t1_stx2_beast_mask.mnc --big --clobber  --image-range 0 100 
minc_qc.pl ${output_path}/${id}/${visit_tp}/stx_nlin/${id}_${visit_tp}_nlin.mnc  ${output_path}/${id}/qc/${id}_${visit_tp}_stx2_nlin.jpg \
    --mask ${model_path}/outline.mnc --big --clobber  --image-range 0 100     

mv ${output_path}/${id}/${visit_tp}/cls/*.jpg ${output_path}/${id}/qc/
## removing unnecessary intermediate files ###
rm -rf ${output_path}/${id}/tmp/
rm ${output_path}/${id}/*/*/*tmp.xfm
rm ${output_path}/${id}/*/*/*tmp.mnc
rm ${output_path}/${id}/*/*/*tmp
rm ${output_path}/${id}/*/native/*nlm*
rm ${output_path}/${id}/*/native/*n3*
rm ${output_path}/${id}/cls/*Prob_Label*
