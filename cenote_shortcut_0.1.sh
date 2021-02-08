#!/bin/bash

# Cenote-Taker Logo
echo "$(tput setaf 2)00000000000000000000000000"
echo "00000000000000000000000000"
echo "000000000$(tput setaf 4)^^^^^^^^$(tput setaf 2)000000000"
echo "000000$(tput setaf 4)^^^^^^^^^^^^^^$(tput setaf 2)000000"
echo "00000$(tput setaf 4)^^^^^$(tput setaf 3)CENOTE$(tput setaf 4)^^^^^$(tput setaf 2)00000"
echo "00000$(tput setaf 4)^^^^$(tput setaf 3)SHORTCUT!$(tput setaf 4)^^^^$(tput setaf 2)00000"
echo "00000$(tput setaf 4)^^^^^^^^^^^^^^^^$(tput setaf 2)00000"
echo "000000$(tput setaf 4)^^^^^^^^^^^^^^$(tput setaf 2)000000"
echo "000000000$(tput setaf 4)^^^^^^^^$(tput setaf 2)000000000"
echo "00000000000000000000000000"
echo "00000000000000000000000000$(tput sgr 0)"

echo " "
sleep 2s

# Setting input parameters
original_contigs=$1
run_title=$2
circ_length_cutoff=$3
linear_length_cutoff=$4
virus_domain_db=$5
LIN_MINIMUM_DOMAINS=$6
PROPHAGE=$7
FOR_PLASMIDS=$8
CENOTE_SCRIPT_DIR=$9
CIRC_MINIMUM_DOMAINS=${10}
LARGE_GENOME=${11}
MEM=${12}
CPU=${13}
base_directory=$PWD

echo "@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "Your specified arguments:"
echo "original contigs:                  $original_contigs"
echo "title of this run:                 $run_title"
echo "minimum circular contig length:    $circ_length_cutoff"
echo "minimum linear contig length:      $linear_length_cutoff"
echo "virus domain database:             $virus_domain_db"
echo "min. viral hallmarks for linear:   $LIN_MINIMUM_DOMAINS"
echo "min. viral hallmarks for circular: $CIRC_MINIMUM_DOMAINS"
echo "Do Prophage Pruning?:              $PROPHAGE"
echo "Input is large cellular genome?:   $LARGE_GENOME" 
echo "Filter out plasmids?:              $FOR_PLASMIDS"
echo "Location of Cenote scripts:        $CENOTE_SCRIPT_DIR"
echo "GB of memory:                      $MEM"
echo "number of CPUs available for run:  $CPU"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@"



MDYT=$( date +"%m-%d-%y---%T" )
echo "time update: locating inputs: " $MDYT

# looking for template file and contigs in working directory, or else copying them there


if [ -s ${base_directory}/${original_contigs} ] ; then 
	echo ${base_directory}/${original_contigs} ; 
else  
	cp ${original_contigs} ${base_directory}/ ; 
	original_contigs=$( basename $original_contigs ) 

fi

# Making output folder
if [ ! -d "$run_title" ]; then
	mkdir "$run_title"
else
	rand_dir=$( head /dev/urandom | tr -dc A-Za-z0-9 | head -c 3 ; echo '' )
	DAY1=$( date +"%m-%d-%y" )
	mv ${run_title}/ ${run_title}_old_${DAY1}_${rand_dir} 
	mkdir "$run_title"
fi 

if [ ${original_contigs: -3} == ".fa" ]; then
	echo "renaming $original_contigs to ${original_contigs}sta"
	mv $original_contigs ${original_contigs}sta
	original_contigs=${original_contigs}sta
fi
if [ ${original_contigs: -4} == ".fna" ]; then
	echo "renaming $original_contigs to ${original_contigs%fna}fasta"
	mv $original_contigs ${original_contigs%fna}fasta
	original_contigs=${original_contigs%fna}fasta
fi
if [ ${original_contigs: -4} == ".fsa" ]; then
	echo "renaming $original_contigs to ${original_contigs%fsa}fasta"
	mv $original_contigs ${original_contigs%fsa}fasta
	original_contigs=${original_contigs%fsa}fasta
fi
# Removing contigs under $circ_length_cutoff nts and detecting circular contigs
if [ $circ_length_cutoff -gt $linear_length_cutoff ] ; then
	LENGTH_MINIMUM=$linear_length_cutoff
else
	LENGTH_MINIMUM=$circ_length_cutoff

fi


if [ ${original_contigs: -6} == ".fasta" ]; then
	echo "$(tput setaf 5)File with .fasta extension detected, attempting to keep contigs over $LENGTH_MINIMUM nt and find circular sequences with apc.pl$(tput sgr 0)"
	bioawk -v run_var="$run_title" -v contig_cutoff="$LENGTH_MINIMUM" -c fastx '{ if(length($seq) > contig_cutoff) { print ">"run_var NR" "$name; print $seq }}' $original_contigs > ${original_contigs%.fasta}.over_${LENGTH_MINIMUM}nt.fasta ;
	cd $run_title
	echo "cenote_shortcut" > ${run_title}.tsv
	perl ${CENOTE_SCRIPT_DIR}/apc_cenote1.pl -b $run_title -c $CENOTE_SCRIPT_DIR ../${original_contigs%.fasta}.over_${LENGTH_MINIMUM}nt.fasta ;
	rm -f apc_aln*
	APC_CIRCS=$( find * -maxdepth 0 -type f -name "${run_title}*.fa" )
	if [ -n "$APC_CIRCS" ] ;then
		for fa1 in $APC_CIRCS ; do 
			CIRC_SEQ_NAME=$( head -n1 $fa1 | sed 's/|.*//g' ) ; 
			CIRC_NEW_NAME=$( echo "$CIRC_SEQ_NAME" | sed 's/>//g ; s/ .*//g' )
			grep -A1 "^$CIRC_SEQ_NAME" ../${original_contigs%.fasta}.over_${LENGTH_MINIMUM}nt.fasta | sed '/--/d' > ${CIRC_NEW_NAME}.fasta
			rm -f $fa1
		done 
	else
		echo "No circular contigs detected."
	fi
elif [ ${original_contigs: -6} == ".fastg" ]; then
	bioawk -v contig_cutoff="$LENGTH_MINIMUM" -c fastx '{ if(length($seq) > contig_cutoff) {print }}' $original_contigs | grep "[a-zA-Z0-9]:\|[a-zA-Z0-9];" | grep -v "':" | awk '{ print ">"$1 ; print $2 }' | sed 's/:.*//g; s/;.*//g' | bioawk -v run_var="$run_title" -c fastx '{ print ">"run_var NR" "$name; print $seq }' > ${original_contigs%.fastg}.over_${LENGTH_MINIMUM}nt.fasta
	cd $run_title
	echo "cenote-taker2" > ${run_title}.tsv
	perl ${CENOTE_SCRIPT_DIR}/apc_cenote1.pl -b $run_title -c $CENOTE_SCRIPT_DIR ../${original_contigs%.fastg}.over_${LENGTH_MINIMUM}nt.fasta ;
	rm -f apc_aln*
	APC_CIRCS=$( find * -maxdepth 0 * -type f -name "${run_title}*.fa" )
	if [ -n "$APC_CIRCS" ] ;then
		for fa1 in $APC_CIRCS ; do 
			CIRC_SEQ_NAME=$( head -n1 $fa1 | sed 's/|.*//g' ) ; 
			CIRC_NEW_NAME=$( echo "$CIRC_SEQ_NAME" | sed 's/>//g ; s/ .*//g' )
			grep -A1 "^$CIRC_SEQ_NAME" ../${original_contigs%.fastg}.over_${LENGTH_MINIMUM}nt.fasta | sed '/--/d' > ${CIRC_NEW_NAME}.fasta
			rm -f $fa1
		done 
	else
		echo "No circular contigs detected."
	fi	
else
	echo "$(tput setaf 4)File with .fasta of .fastg extension not detected as first input. Exiting.$(tput sgr 0)" ;
	exit
fi

# Removing cirles that are smaller than user specified cutoff
CIRC_CONTIGS=$( find * -maxdepth 0 -type f -name "*.fasta" )
if [ ! -z "$CIRC_CONTIGS" ] ;then
	for CIRCLE1 in $CIRC_CONTIGS ; do
		CIRCLE1_LENGTH=$( bioawk -c fastx '{print length($seq) }' $CIRCLE1 )
		if [[ $CIRCLE1_LENGTH -lt $circ_length_cutoff ]] ; then
			mv $CIRCLE1 ${CIRCLE1%.fasta}.too_short.fasta 
		fi
	done
fi
rm -f *.too_short.fasta

# Detecting whether any circular contigs were present
original_fastas=$( find * -maxdepth 0 -type f -name "*.fasta" )
# "$(tput setaf 5)$var1$(tput sgr 0)"

if [ -z "$original_fastas" ] ; then
	echo "$(tput setaf 4)No circular fasta files detected. $(tput sgr 0)" 
	#exit
	mkdir other_contigs	
	if [ ${original_contigs: -6} == ".fasta" ]; then
		grep -A1 "^>" ../${original_contigs%.fasta}.over_${LENGTH_MINIMUM}nt.fasta | sed 's/--//g' | bioawk -v contig_cutoff="$linear_length_cutoff" -c fastx '{ if (length($seq) > contig_cutoff) { print ">"$name" "$4 ; print $seq }}' > other_contigs/all_non_circular.fasta
	elif [ ${original_contigs: -6} == ".fastg" ]; then
		grep -A1 "^>" ../${original_contigs%.fastg}.over_${LENGTH_MINIMUM}nt.fasta | sed 's/--//g' | bioawk -v contig_cutoff="$linear_length_cutoff" -c fastx '{ if (length($seq) > contig_cutoff) { print ">"$name" "$4 ; print $seq }}' > other_contigs/all_non_circular.fasta
	fi			
	if [ -s other_contigs/all_non_circular.fasta ] ; then
		grep "^>" other_contigs/all_non_circular.fasta | sed 's/>//g' | cut -d " " -f1 | while read LINE ; do 
			grep -A1 "$LINE [a-zA-Z]" other_contigs/all_non_circular.fasta > other_contigs/$LINE.fasta ; 
		done
	fi
else
	echo "$(tput setaf 5)Circular fasta file(s) detected$(tput sgr 0)"
	echo " "
	cat *fasta > all_circular_contigs_${run_title}.fna
# Putting non-circular contigs in a separate directory
	echo "$(tput setaf 4)Putting non-circular contigs in a separate directory $(tput sgr 0)" 

	mkdir other_contigs

	for CIRCLE in $original_fastas ; do
		grep "^>" $CIRCLE | sed 's/|.*//g' >> circular_contigs_spades_names.txt
	done
	if [ ${original_contigs: -6} == ".fasta" ]; then
		LINEAR_COUNT=$( grep -v -f circular_contigs_spades_names.txt ../${original_contigs%.fasta}.over_${LENGTH_MINIMUM}nt.fasta | grep -A1 "^>" | wc -l )
		if [ $LINEAR_COUNT -ge 1 ] ; then
			grep -v -f circular_contigs_spades_names.txt ../${original_contigs%.fasta}.over_${LENGTH_MINIMUM}nt.fasta | grep -A1 "^>" | sed 's/--//g' | bioawk -v contig_cutoff="$linear_length_cutoff" -c fastx '{ if (length($seq) > contig_cutoff) { print ">"$name" "$4 ; print $seq }}' > other_contigs/all_non_circular.fasta
		else
			echo "No linear contigs over ${LENGTH_MINIMUM}nt found in run"
		fi
	elif [ ${original_contigs: -6} == ".fastg" ]; then
		LINEAR_COUNT=$( grep -v -f circular_contigs_spades_names.txt ../${original_contigs%.fastg}.over_${LENGTH_MINIMUM}nt.fasta | grep -A1 "^>" | wc -l )
		if [ $LINEAR_COUNT -ge 1 ] ; then		
			grep -v -f circular_contigs_spades_names.txt ../${original_contigs%.fastg}.over_${LENGTH_MINIMUM}nt.fasta | grep -A1 "^>" | sed 's/--//g' | bioawk -v contig_cutoff="$linear_length_cutoff" -c fastx '{ if (length($seq) > contig_cutoff) { print ">"$name" "$4 ; print $seq }}' > other_contigs/all_non_circular.fasta
		else
			echo "No linear contigs over ${LENGTH_MINIMUM}nt found in run"
		fi
	fi
	if [ -s other_contigs/all_non_circular.fasta ] ; then
		grep "^>" other_contigs/all_non_circular.fasta | sed 's/>//g' | cut -d " " -f1 | while read LINE ; do 
			grep -A1 "$LINE [a-zA-Z0-9]" other_contigs/all_non_circular.fasta > other_contigs/$LINE.fasta ; 
		done
	fi

fi

cd other_contigs
CONTIGS_NON_CIRCULAR=$( find * -maxdepth 0 -type f -name "*[0-9].fasta" )

if [ ! -z "$CONTIGS_NON_CIRCULAR" ] ;then
	echo "$(tput setaf 4) Looking for non-circular contigs that have at least 1 virus-specific or plasmid-specific domain $(tput sgr 0)"

	mkdir ../no_end_contigs_with_viral_domain
	MDYT=$( date +"%m-%d-%y---%T" )
	echo "time update: running prodigal on linear contigs " $MDYT
	echo "$CONTIGS_NON_CIRCULAR" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t prodigal -a {}.AA.fasta -i {}.fasta -p meta -q
	for NO_END in $CONTIGS_NON_CIRCULAR ; do 
		sed 's/ /@/g' ${NO_END%.fasta}.AA.fasta | bioawk -c fastx '{print}' | while read LINE ; do 
			START_BASE=$( echo "$LINE" | cut -d "#" -f 2 | sed 's/@//g' ) ; 
			END_BASE=$( echo "$LINE" | cut -d "#" -f 3 | sed 's/@//g' ) ; 
			ORF_NAME=$( echo "$LINE" | cut -d "#" -f 1 | sed 's/@//g; s/\./_/g' ) ; 
			AA_SEQ=$( echo "$LINE" | cut -f2 | sed 's/\*//g' ) ;
			echo ">"${ORF_NAME} "["$START_BASE" - "$END_BASE"]" ; echo $AA_SEQ ; 
		done > ${NO_END%.fasta}.AA.sorted.fasta
	done
	if [[ $LARGE_GENOME = "False" ]] ; then
		# Looking for non-circular contigs without ITRs that have at least 1 virus-specific domain

		MDYT=$( date +"%m-%d-%y---%T" )
		echo "time update: running hmmscan of linear contigs against virus hallmark gene database: $virus_domain_db " $MDYT	
			# Taking arguments for "virus specific" database and conducting hmmscan
		if  [[ $virus_domain_db = "standard" ]] ; then
			echo "$CONTIGS_NON_CIRCULAR" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_specific_baits_plus_missed6a {}.AA.sorted.fasta
			echo "$CONTIGS_NON_CIRCULAR" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan_replicate.out --cpu 1 -E 1e-15 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_replication_clusters3 {}.AA.sorted.fasta	
		elif [[ $virus_domain_db = "virion" ]]; then
			echo "$CONTIGS_NON_CIRCULAR" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_specific_baits_plus_missed6a {}.AA.sorted.fasta		
		elif [[ $virus_domain_db = "rna_virus" ]]; then
			echo "$CONTIGS_NON_CIRCULAR" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/rna_virus_rdrp_capsid_hmms1 {}.AA.sorted.fasta
		else
			echo "$(tput setaf 5) Incorrect argument given for virus_domain_db variable. Try standard, virion, or rna_virus as arguments. For this run, no contigs with viral domains but without circularity or ITRs will be detected $(tput sgr 0)"
			rm -f ./*{0..9}.fasta
			break
		fi
		for NO_END in $CONTIGS_NON_CIRCULAR ; do 

			if [[ $FOR_PLASMIDS = "True" ]]; then
				grep -v "^#\|plasmid_clust" ${NO_END%.fasta}.AA.hmmscan.out | sed 's/ \+/	/g' | sort -u -k3,3 > ${NO_END%.fasta}.AA.hmmscan.sort.out
				if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.out ] ; then
					grep -v "^#\|plasmid_clust" ${NO_END%.fasta}.AA.hmmscan_replicate.out | sed 's/ \+/	/g' | sort -u -k3,3 > ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out
				fi
			elif [[ $FOR_PLASMIDS = "False" ]]; then
				grep -v "^#" ${NO_END%.fasta}.AA.hmmscan.out | sed 's/ \+/	/g' | sort -u -k3,3 > ${NO_END%.fasta}.AA.hmmscan.sort.out
				if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.out ] ; then
					grep -v "^#" ${NO_END%.fasta}.AA.hmmscan_replicate.out | sed 's/ \+/	/g' | sort -u -k3,3 > ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out
				fi
			else	
				grep -v "^#" ${NO_END%.fasta}.AA.hmmscan.out | sed 's/ \+/	/g' | sort -u -k3,3 > ${NO_END%.fasta}.AA.hmmscan.sort.out
				if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.out ] ; then
					grep -v "^#" ${NO_END%.fasta}.AA.hmmscan_replicate.out | sed 's/ \+/	/g' | sort -u -k3,3 > ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out
				fi		
			fi	

			if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.out ] ; then
				VIRAL_HALLMARK_COUNT=$( cat ${NO_END%.fasta}.AA.hmmscan.sort.out ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out | sort -u -k3,3 | wc -l )
			else
				VIRAL_HALLMARK_COUNT=$( cat ${NO_END%.fasta}.AA.hmmscan.sort.out | sort -u -k3,3 | wc -l )
			fi

			if [ $VIRAL_HALLMARK_COUNT -gt $LIN_MINIMUM_DOMAINS ] || [ $VIRAL_HALLMARK_COUNT == $LIN_MINIMUM_DOMAINS ] ; then
				
				echo $NO_END "contains at least $LIN_MINIMUM_DOMAINS viral structural domain(s)"
				if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.out ] ; then
					cat ${NO_END%.fasta}.AA.hmmscan.sort.out ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out | sort -u -k3,3 | cut -f3 > ${NO_END%.fasta}.AA.called_hmmscan.txt ; 
				else
					cat ${NO_END%.fasta}.AA.hmmscan.sort.out | sort -u -k3,3 | cut -f3 > ${NO_END%.fasta}.AA.called_hmmscan.txt ; 
				fi
				grep -v -f ${NO_END%.fasta}.AA.called_hmmscan.txt ${NO_END%.fasta}.AA.sorted.fasta | grep -A1 ">" | sed '/--/d' > ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.no_hmmscan1.fasta
				echo ">Feature "${NO_END%.fasta}" Table1" > ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.SCAN.tbl

				mv $NO_END ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.fna
				mv ${NO_END%.fasta}.AA.hmmscan.out ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.AA.hmmscan.out
				mv ${NO_END%.fasta}.AA.hmmscan.sort.out ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.AA.hmmscan.sort.out
				if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.out ] ; then
					mv ${NO_END%.fasta}.AA.hmmscan_replicate.out ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.AA.hmmscan_replicate.out
				fi
				if [ -s ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out ] ; then
					mv ${NO_END%.fasta}.AA.hmmscan_replicate.sort.out ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.AA.hmmscan_replicate.sort.out
				fi

				mv ${NO_END%.fasta}.AA.sorted.fasta ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.AA.sorted.fasta
			else 
				cat $NO_END >> non_viral_domains_contigs.fna
				rm -f $NO_END
			fi
		done
	else
		###instructions for large genomes
		MDYT=$( date +"%m-%d-%y---%T" )
		echo "time update: splitting AA files from cellular genome into equal parts and running hmmscan against virus hallmark gene database: $virus_domain_db " $MDYT	
		mkdir ../no_end_contigs_with_viral_domain
		cat $( find * -maxdepth 0 -type f -name "*.AA.sorted.fasta" ) > all_large_genome_proteins.AA.fasta
		TOTAL_AA_SEQS=$( grep -F ">" all_large_genome_proteins.AA.fasta | wc -l | bc )
		AA_SEQS_PER_FILE=$( echo "scale=0 ; $TOTAL_AA_SEQS / $CPU" | bc )
		if [ $AA_SEQS_PER_FILE = 0 ] ; then
			AA_SEQS_PER_FILE=1
		fi
		awk -v seq_per_file="$AA_SEQS_PER_FILE" 'BEGIN {n_seq=0;} /^>/ {if(n_seq%seq_per_file==0){file=sprintf("SPLIT_LARGE_GENOME_AA_%d.fasta",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < all_large_genome_proteins.AA.fasta
		SPLIT_AA_LARGE=$( find * -maxdepth 0 -type f -name "SPLIT_LARGE_GENOME_AA_*.fasta" )
		if  [[ $virus_domain_db = "standard" ]] ; then
			echo "$SPLIT_AA_LARGE" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_specific_baits_plus_missed6a {}.fasta
			echo "$SPLIT_AA_LARGE" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan_replicate.out --cpu 1 -E 1e-15 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_replication_clusters3 {}.fasta	
		elif [[ $virus_domain_db = "virion" ]]; then
			echo "$SPLIT_AA_LARGE" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_specific_baits_plus_missed6a {}.fasta		
		elif [[ $virus_domain_db = "rna_virus" ]]; then
			echo "$SPLIT_AA_LARGE" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/rna_virus_rdrp_capsid_hmms1 {}.fasta
		else
			echo "$(tput setaf 5) Incorrect argument given for virus_domain_db variable. Try standard, virion, or rna_virus as arguments. For this run, no contigs with viral domains but without circularity or ITRs will be detected $(tput sgr 0)"
			rm -f ./*{0..9}.fasta
			break
		fi		
		HMM_REP_NUMEBR=$( find * -maxdepth 0 -type f -name "SPLIT_LARGE_GENOME_AA_*AA.hmmscan_replicate.out" | wc -l )
		if [[ $FOR_PLASMIDS = "True" ]]; then
			if [ $HMM_REP_NUMEBR -gt 0 ] ; then
				cat SPLIT_LARGE_GENOME_AA_*AA.hmmscan.out SPLIT_LARGE_GENOME_AA_*AA.hmmscan_replicate.out | grep -v "^#\|plasmid_clust" | sed 's/ \+/	/g' | sort -u -k3,3 > LARGE_GENOME_COMBINED.AA.hmmscan.sort.out
			else
				cat SPLIT_LARGE_GENOME_AA_*AA.hmmscan.out | grep -v "^#\|plasmid_clust" | sed 's/ \+/	/g' | sort -u -k3,3 > LARGE_GENOME_COMBINED.AA.hmmscan.sort.out
			fi
		else
			if [ $HMM_REP_NUMEBR -gt 0 ] ; then
				cat SPLIT_LARGE_GENOME_AA_*AA.hmmscan.out SPLIT_LARGE_GENOME_AA_*AA.hmmscan_replicate.out | grep -v "^#" | sed 's/ \+/	/g' | sort -u -k3,3 > LARGE_GENOME_COMBINED.AA.hmmscan.sort.out
			else
				cat SPLIT_LARGE_GENOME_AA_*AA.hmmscan.out | grep -v "^#" | sed 's/ \+/	/g' | sort -u -k3,3 > LARGE_GENOME_COMBINED.AA.hmmscan.sort.out
			fi
		fi		
		if [ -s LARGE_GENOME_COMBINED.AA.hmmscan.sort.out ] ; then
			cut -f3 LARGE_GENOME_COMBINED.AA.hmmscan.sort.out | sed 's/[^_]*$//' | sed 's/\(.*\)_/\1/' | sort -u | while read HIT ; do
				HALL_COUNT=$( grep "${HIT}_" LARGE_GENOME_COMBINED.AA.hmmscan.sort.out | wc -l | bc )
				if [ $HALL_COUNT -ge $LIN_MINIMUM_DOMAINS ] ; then 
					### not sure on this
					mv ${HIT}.fasta ../no_end_contigs_with_viral_domain/${HIT}.fna
					grep "${HIT}_" LARGE_GENOME_COMBINED.AA.hmmscan.sort.out > ../no_end_contigs_with_viral_domain/${HIT}.AA.hmmscan.sort.out
					# ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.no_hmmscan1.fasta
					grep "${HIT}_" LARGE_GENOME_COMBINED.AA.hmmscan.sort.out | sort -u -k3,3 | cut -f3 > ${HIT}.AA.called_hmmscan.txt
					grep -v -f ${HIT}.AA.called_hmmscan.txt ${HIT}.AA.sorted.fasta | grep -A1 ">" | sed '/--/d' > ../no_end_contigs_with_viral_domain/${HIT}.AA.no_hmmscan1.fasta
					mv ${HIT}.AA.sorted.fasta ../no_end_contigs_with_viral_domain/

				else
					cat ${HIT}.fasta >> non_viral_domains_contigs.fna
					rm -f ${HIT}.fasta
				fi
			done
		fi
		for REMAINDER in $CONTIGS_NON_CIRCULAR ; do
			if [ -s $REMAINDER ] ; then
				cat $REMAINDER >> non_viral_domains_contigs.fna
				rm -f $REMAINDER
			fi
		done
	fi
fi


cd ..


CIRCLES_AND_ITRS=$( find * -maxdepth 0 -type f -regextype sed -regex "${run_title}[0-9]\{1,6\}.fasta" )


# 3 ORF calling
if [ ! -z "$CIRCLES_AND_ITRS" ] ; then 
	mkdir DTR_contigs_with_viral_domain
	MDYT=$( date +"%m-%d-%y---%T" )
	echo "time update: Calling ORFs for circular/DTR sequences with prodigal " $MDYT
	echo "$CIRCLES_AND_ITRS" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t prodigal -a {}.AA.fasta -i {}.fasta -p meta -q
	for CIRC in $CIRCLES_AND_ITRS ; do 
		sed 's/ /@/g' ${CIRC%.fasta}.AA.fasta | bioawk -c fastx '{print}' | while read LINE ; do 
			START_BASE=$( echo "$LINE" | cut -d "#" -f 2 | sed 's/@//g' ) ; 
			END_BASE=$( echo "$LINE" | cut -d "#" -f 3 | sed 's/@//g' ) ; 
			ORF_NAME=$( echo "$LINE" | cut -d "#" -f 1 | sed 's/@//g; s/\./_/g' ) ; 
			AA_SEQ=$( echo "$LINE" | cut -f2 | sed 's/\*//g' ) ;
			echo ">"${ORF_NAME} "["$START_BASE" - "$END_BASE"]" ; echo $AA_SEQ ; 
		done > ${CIRC%.fasta}.AA.sorted.fasta
	done	
		### stopping point -insert hmmscan
	cat $( find * -maxdepth 0 -type f -name "*.AA.sorted.fasta" ) > all_circular_genome_proteins.AA.fasta
	TOTAL_AA_SEQS=$( grep -F ">" all_circular_genome_proteins.AA.fasta | wc -l | bc )
	AA_SEQS_PER_FILE=$( echo "scale=0 ; $TOTAL_AA_SEQS / $CPU" | bc )
	if [ $AA_SEQS_PER_FILE = 0 ] ; then
		AA_SEQS_PER_FILE=1
	fi
	awk -v seq_per_file="$AA_SEQS_PER_FILE" 'BEGIN {n_seq=0;} /^>/ {if(n_seq%seq_per_file==0){file=sprintf("SPLIT_CIRCULAR_AA_%d.fasta",n_seq);} print >> file; n_seq++; next;} { print >> file; }' < all_circular_genome_proteins.AA.fasta
	MDYT=$( date +"%m-%d-%y---%T" )
	echo "time update: running hmmscan on circular/DTR contigs " $MDYT
	SPLIT_AA_CIRC=$( find * -maxdepth 0 -type f -name "SPLIT_CIRCULAR_AA_*.fasta" )
	if  [[ $virus_domain_db = "standard" ]] ; then
		echo "$SPLIT_AA_CIRC" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_specific_baits_plus_missed6a {}.fasta
		echo "$SPLIT_AA_CIRC" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan_replicate.out --cpu 1 -E 1e-15 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_replication_clusters3 {}.fasta	
	elif [[ $virus_domain_db = "virion" ]]; then
		echo "$SPLIT_AA_CIRC" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/virus_specific_baits_plus_missed6a {}.fasta		
	elif [[ $virus_domain_db = "rna_virus" ]]; then
		echo "$SPLIT_AA_CIRC" | sed 's/.fasta//g' | xargs -n 1 -I {} -P $CPU -t hmmscan --tblout {}.AA.hmmscan.out --cpu 1 -E 1e-8 --noali ${CENOTE_SCRIPT_DIR}/hmmscan_DBs/rna_virus_rdrp_capsid_hmms1 {}.fasta
	else
		echo "$(tput setaf 5) Incorrect argument given for virus_domain_db variable. Try standard, virion, or rna_virus as arguments. For this run, no contigs with viral domains but without circularity or ITRs will be detected $(tput sgr 0)"
		rm -f ./*{0..9}.fasta
		break
	fi
	HMM_REP_NUMEBR=$( find * -maxdepth 0 -type f -name "SPLIT_CIRCULAR_AA_*AA.hmmscan_replicate.out" | wc -l )
	if [[ $FOR_PLASMIDS = "True" ]]; then
		if [ $HMM_REP_NUMEBR -gt 0 ] ; then
			cat SPLIT_CIRCULAR_AA_*AA.hmmscan.out SPLIT_CIRCULAR_AA_*AA.hmmscan_replicate.out | grep -v "^#\|plasmid_clust" | sed 's/ \+/	/g' | sort -u -k3,3 > CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out
		else
			cat SPLIT_CIRCULAR_AA_*AA.hmmscan.out | grep -v "^#\|plasmid_clust" | sed 's/ \+/	/g' | sort -u -k3,3 > CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out
		fi
	else
		if [ $HMM_REP_NUMEBR -gt 0 ] ; then
			cat SPLIT_CIRCULAR_AA_*AA.hmmscan.out SPLIT_CIRCULAR_AA_*AA.hmmscan_replicate.out | grep -v "^#" | sed 's/ \+/	/g' | sort -u -k3,3 > CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out
		else
			cat SPLIT_CIRCULAR_AA_*AA.hmmscan.out | grep -v "^#" | sed 's/ \+/	/g' | sort -u -k3,3 > CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out
		fi
	fi		
	if [ -s CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out ] ; then
		cut -f3 CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out | sed 's/[^_]*$//' | sed 's/\(.*\)_/\1/' | sort -u | while read HIT ; do
			HALL_COUNT=$( grep "${HIT}_" CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out | wc -l | bc )
			if [ $HALL_COUNT -ge $CIRC_MINIMUM_DOMAINS ] ; then 
				### not sure on this
				mv ${HIT}.fasta DTR_contigs_with_viral_domain/${HIT}.fna
				grep "${HIT}_" CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out > DTR_contigs_with_viral_domain/${HIT}.AA.hmmscan.sort.out
				# ../no_end_contigs_with_viral_domain/${NO_END%.fasta}.no_hmmscan1.fasta
				grep "${HIT}_" CIRCULAR_GENOME_COMBINED.AA.hmmscan.sort.out | sort -u -k3,3 | cut -f3 > ${HIT}.AA.called_hmmscan.txt
				grep -v -f ${HIT}.AA.called_hmmscan.txt ${HIT}.AA.sorted.fasta | grep -A1 ">" | sed '/--/d' > DTR_contigs_with_viral_domain/${HIT}.AA.no_hmmscan1.fasta
				mv ${HIT}.AA.sorted.fasta DTR_contigs_with_viral_domain/

			else
				cat ${HIT}.fasta >> non_viral_domains_contigs.fna
				rm -f ${HIT}.fasta
			fi
		done
	fi
	for REMAINDER in $CONTIGS_NON_CIRCULAR ; do
		if [ -s $REMAINDER ] ; then
			cat $REMAINDER >> other_contigs/non_viral_domains_contigs.fna
			rm -f $REMAINDER
		fi
	done
fi



cd ${base_directory}/${run_title}

### script for annotating no_end contigs with viral domains
LIST_OF_VIRAL_DOMAIN_CONTIGS=$( find * -maxdepth 1 -type f -wholename "no_end_contigs_with_viral_domain/*fna" )

if [ ! -z "$LIST_OF_VIRAL_DOMAIN_CONTIGS" ] ;then
	echo "$(tput setaf 3) Starting annotation of contigs with viral domains but are neither circular nor have ITRs $(tput sgr 0)"

	. ${CENOTE_SCRIPT_DIR}/prune_linear_contigs_0.1.sh
fi


cd ${base_directory}/${run_title}

### make summary tables

echo "removing ancillary files"

rm -f *.all_start_stop.txt *.bad_starts.txt *.comb.tbl *.comb2.tbl *.good_start_orfs.txt *.hypo_start_stop.txt *.nucl_orfs.fa *.remove_hypo.txt *.log *.promer.contigs_with_ends.fa *.promer.promer *.out.hhr *.starting_orf.txt *.out.hhr *.nucl_orfs.txt *.called_hmmscan.txt *.hmmscan_replicate.out *.hmmscan.out *.rotate.no_hmmscan.fasta *.starting_orf.1.fa *.phan.*fasta *used_positions.txt *.prodigal.for_prodigal.fa *.prodigal.gff *.trnascan-se2.txt *.for_blastp.txt *.for_hhpred.txt circular_contigs_spades_names.txt
rm -rf bt2_indices/
rm -f other_contigs/*.AA.fasta other_contigs/*.AA.sorted.fasta other_contigs/*.out other_contigs/*.dat other_contigs/*called_hmmscan.txt 
rm -f no_end_contigs_with_viral_domain/*.called_hmmscan2.txt no_end_contigs_with_viral_domain/*.hmmscan2.out no_end_contigs_with_viral_domain/*all_hhpred_queries.AA.fasta no_end_contigs_with_viral_domain/*.all_start_stop.txt no_end_contigs_with_viral_domain/*.trnascan-se2.txt no_end_contigs_with_viral_domain/*.for_hhpred.txt no_end_contigs_with_viral_domain/*.for_blastp.txt no_end_contigs_with_viral_domain/*.HH.tbl no_end_contigs_with_viral_domain/*.hypo_start_stop.txt  no_end_contigs_with_viral_domain/*.remove_hypo.txt no_end_contigs_with_viral_domain/*.rps_nohits.fasta no_end_contigs_with_viral_domain/*.tax_guide.blastx.tab no_end_contigs_with_viral_domain/*.tax_orf.fasta no_end_contigs_with_viral_domain/*.trans.fasta no_end_contigs_with_viral_domain/*.called_hmmscan*.txt no_end_contigs_with_viral_domain/*.no_hmmscan*.fasta no_end_contigs_with_viral_domain/*.comb*.tbl 

echo " "
echo "$(tput setaf 3)output directory: "$run_title" $(tput sgr 0)"
echo "$(tput setaf 3) >>>>>>CENOTE SHORTCUT HAS FINISHED SHORTCUTTING CENOTES<<<<<< $(tput sgr 0)"



