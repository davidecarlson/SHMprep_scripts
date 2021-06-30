#!/usr/bin/env bash

#######################################################################################
#                                                                                     #
# Sample script for running SHMprep on a single dataset (SRR1383456 in this case).    #
#                                                                                     #
#######################################################################################

usage() { echo "Usage: $0 [-d <path to SHMprep directory>] [-f <path to forward primers fasta file>] [-r <path to reverse primers fasta file>]" 1>&2; exit 1; }

while getopts ":d:f:r:" o; do
    case "${o}" in
        d)
            d=${OPTARG}

            ;;
        f)
            f=${OPTARG}
            ;;
        r)
            r=${OPTARG}

            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ] || [ -z "${f}" ] || [ -z "${r}" ]; then
    usage
fi

SHMPREPDIR=${d}
FWDPRIMER=${f}
REVPRIMER=${r}


#Specify the number of cpus to be used for the run

CPU=16

#create directory for fastq files

mkdir fastqs

# download the SRR1383456 fastqs

fastq-dump --split-files --readids  --outdir fastqs SRR1383456

#create output directory

mkdir shmprep_SRR1383456_output


# create table of results to be filled in later

paste <(echo Sample) <(echo Raw_Read_Count) <(echo Wall_Time) <(echo CPU_TIME) <(echo Clustered_Sequences) > shmprep_SRR1383456_results.txt


ID=SRR1383456
echo Running SHMprep for sample: $ID

# get count of raw reads

READS=$(cat fastqs/SRR1383456_1.fastq | sed -n '2~4p' | wc -l)

# modify the config file for the current data
cat << EOF > $SHMPREPDIR/config_SRR1383456.txt
###
$ID
$FWDPRIMER
$REVPRIMER
**
./fastqs/${ID}_1.fastq
./fastqs/${ID}_2.fastq
./shmprep_SRR1383456_output/
EOF

#Run SHMprep
/usr/bin/time -f %e+%S+%U -o shmprep_SRR1383456_output/$ID.time $SHMPREPDIR/aligner_linux64 -f $SHMPREPDIR/config_SRR1383456.txt  -n16 -lrbdqptz -C2 > shmprep_SRR1383456_output/$ID.log 2>&1

# Gather stats about the completed SHMprep analysis

WALLTIME=$(cat shmprep_SRR1383456_output/$ID.time |  awk -F "+" '{print $1}')
CPUTIME=$(cat shmprep_SRR1383456_output/$ID.time |  awk -F "+" '{print $2+$3;}')
SEQS=$(cat shmprep_SRR1383456_output/${ID}_All.fastq | sed -n '2~4p' | wc -l)

paste <(echo "$ID") <(echo "$READS") <(echo "$WALLTIME") <(echo "$CPUTIME") <(echo "$SEQS") >> shmprep_SRR1383456_results.txt
