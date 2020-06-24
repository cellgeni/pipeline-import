#!/bin/bash
set -eux
export NXF_OPTS='-Xms1G -Xmx4G'

import_request_tsv="$1"
dir_name="$2"
project="$3"
o_owner="$4"

workdir="/lustre/scratch117/cellgen/cellgeni/imaging/${dir_name}"
output="/nfs/assembled_images/datasets/${dir_name}"

mkdir -p "${workdir}"
mkdir -p "${output}"

export PATH=/nfs/cellgeni/imaging/REQUEST/nf:$PATH

cd $workdir
NXF_OPTS="-Dleveldb.mmap=false" NXF_VER="20.04.1" nextflow -trace nextflow.executor run /nfs/cellgeni/imaging/REQUEST/pipeline-import.git/main.nf --input $import_request_tsv --output "$output" --o_group "$project" --o_owner "$o_owner" -profile standard,singularity -with-report "$workdir/raport.html" -resume
