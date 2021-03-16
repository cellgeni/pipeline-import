#!/bin/bash

rootdir='/nfs/cellgeni/imaging_pipeline'
set -eux
export NXF_OPTS='-Xms1G -Xmx4G'

pipeline_main="${PIPELINE_MAIN:-main.nf}"

import_request_tsv="$1"
dir_name="$2"
o_owner="$3"

workdir="/lustre/scratch117/cellgen/cellgeni/imaging_pipeline/${dir_name}"
output="/nfs/assembled_images/datasets/${dir_name}"

if test -d "${output}" 2>/dev/null; then 
  mkdir -p "${output}";
fi
mkdir -p "${workdir}"

export PATH="${rootdir}/REQUEST/nf":$PATH

cd $workdir
NXF_OPTS="-Dleveldb.mmap=false" NXF_VER="20.07.1" nextflow -trace nextflow.executor run "${rootdir}/pipeline-import.git/${pipeline_main}" --input $import_request_tsv --output "$output" --o_owner "$o_owner" -profile standard,singularity -with-report "$workdir/raport.html" -resume
