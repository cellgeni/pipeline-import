#!/bin/bash
set -eux
export NXF_OPTS='-Xms1G -Xmx4G'

import_request_tsv="$1"
project="$3"
o_owner="$4"
o_group=$project

mkdir -p workdir
mkdir -p $out_dir_base
workdir="/lustre/scratch117/cellgen/cellgeni/imaging/${project}"
output="/nfs/assembled_images/datasets/${project}"

mkdir -p $workdir

if [ -d "$output" ]; then
  echo "$output directory exist!"
  exit 1
else
  mkdir -p $output
fi


export PATH=/nfs/cellgeni/imaging/REQUEST/nf:$PATH

cd $workdir
NXF_OPTS="-Dleveldb.mmap=false" nextflow -trace nextflow.executor run /nfs/cellgeni/imaging/REQUEST/pipeline-import.git/main.nf --input $import_request_tsv --output $output --o_group $project --o_owner $o_owner -profile standard,singularity -with-report $workdir/raport.html -resume
