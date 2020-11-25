#!/bin/bash


###########################################################
#
#    this is the scrpt for automated homology-modeling
#
############################################################



# author : yanhong hong

export fasta_file="$1"

# use the build_profile.py script to search templates for the target sequence and map the target sequence to the templates
# output files are .prf file and .ali file

process_num=10   # the number of processes that this script will create.
evalue_cutoff=0.01
non_template_text='non_template.txt' # the path to write the non-template gene_id



# # read the output of the rename.sh script and write it into an array
mapfile -t jobids < <( bash rename.sh ${fasta_file} )


# # # # # # multiple processes
for jobid in "${!jobids[@]}"
do
	ali_jobids[$jobid]=${jobids[$jobid]}"/"${jobids[$jobid]}".ali"
	echo ${ali_jobids[$jobid]}
done | xargs -n 1 -I {} -P ${process_num} bash -c "python build_profile.py {}"


# # # # # #wait

# # # # # # # write the alignment results in a .log file
for jobid in "${!jobids[@]}"
do
	log_jobids[$jobid]=${jobids[$jobid]}"/"${jobids[$jobid]}".log"
    echo -e "index\tpdbid\tidentity" > ${log_jobids[$jobid]}
	prf_jobids[$jobid]=${jobids[$jobid]}"/"${jobids[$jobid]}".prf"
	#!$3==0 delete the target itself
	cat ${prf_jobids[$jobid]}|grep -v "^#"|awk '{print $1 "\t" $2 "\t" $11}'|awk '!$3==0'|sort  -k3nr  >> ${log_jobids[$jobid]}
done

# # # # # # # # extract the highest identity pdbid and write it to the template.txt
echo "the non-templates gene id will write to "${non_template_text}
for jobid in "${!jobids[@]}"
do
	log_jobids[$jobid]=${jobids[$jobid]}"/"${jobids[$jobid]}".log"
	if [ x`cat ${log_jobids[$jobid]}|wc|awk '{print $1}'` = x1 ];
	then
		echo "sorry no templates found for "${log_jobids[$jobid]}" with evalue cutoff "${evalue_cutoff}".please try HHM search method or use ab initio modeling methods."
		#delete the job from the quene
		#https://stackoverflow.com/questions/16860877/remove-an-element-from-a-bash-array
		delete=${jobids[$jobid]}
		echo ${delete} >> ${non_template_text}
		for target in "${delete[@]}"; do
  			for i in "${!jobids[@]}"; do
    			if [[ ${jobids[i]} = $target ]]; then
      				unset 'jobids[i]'
    			fi
  			done
		done
	else
		cat ${log_jobids[$jobid]}|awk 'NR==2 {print $2}' > ${jobids[$jobid]}/${jobids[$jobid]}_template.txt
	fi
done

#no job needs to be processed.exit.

if [ ${#jobids[@]} -eq 0 ]; then
    exit 0
fi


# # # # # # using a python script to fetch the template  structure with specified chain from pdb database.

for jobid in "${!jobids[@]}"
do

	template_text=${jobids[$jobid]}"/"${jobids[$jobid]}"_template.txt"
	outdir=${jobids[$jobid]}"/"${jobids[$jobid]}"_template"
	echo "-o "${outdir}" -p "${template_text}
done | xargs -n 1 -I {} -P ${process_num} bash -c "python download_pdbchain.py {}"


# # # # # # Align the target with the template.

for jobid in "${!jobids[@]}"
do
	templatepath=${jobids[$jobid]}"/"${jobids[$jobid]}"_template"
	targetname=${jobids[$jobid]}
	templatename=`ls ${templatepath}`
	echo "--templatepath "${templatepath}"/"${templatename}" --targetname "${targetname}
done | xargs -n 1 -I {} -P ${process_num} bash -c "python align2d.py {}"





# # #start build model.

for jobid in "${!jobids[@]}"
do
	cd ${jobids[$jobid]}
	templatepath=${jobids[$jobid]}"_template"
	templatename=`ls ${templatepath}|sed 's/.pdb//g'`
	cp ${templatepath}/${templatename}.pdb .
	alignmentname=${jobids[$jobid]}"_"${templatename}".ali"
	echo -e ${jobids[$jobid]}"\n--alignmentname "${alignmentname}
	cd ..
done  |xargs -n 2  -P ${process_num}  -d'\n'  bash -c 'cd $0; python ../model_single.py $1'
