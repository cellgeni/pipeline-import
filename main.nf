#!/usr/bin/env nextflow

input_prefix = "/nfs/team283_imaging"

o_owner = params.o_owner
output_dir = file(params.output)

Channel
    .fromPath(params.input)
    .splitCsv(header:true, sep:'\t')
    .map{ row ->
      def project = row.Project
      def filename = row.filename
      def src_to_rsync = row.location + "/" + row.filename
      def o_project = row.OMERO_project
      def o_dataset = row.OMERO_DATASET
      def o_server = row.OMERO_SERVER
      tuple(src_to_rsync, filename, project, o_project, o_dataset, o_server)
    }
    .set { prepare_to_import_ch }

/*
 * rsync file
 */
process rsync_file {

  input:
  set src_to_rsync, filename, project, o_project, o_dataset, o_server from prepare_to_import_ch

  output:
  set filename, dist_folder, project, o_project, o_dataset, o_server into to_import_ch

  shell:
  dist_folder = "${params.output}/${project}"
  dist_to_import = "${dist_folder}/${filename}"
  '''
  echo "src !{src_to_rsync}"
  echo "dist !{dist_to_import}"
  mkdir -p "!{dist_folder}"

  if [[ -f "!{dist_to_import}.idlog" ]]; then cat "!{dist_to_import}.idlog"; exit 1; fi
  if [[ -f "!{dist_to_import}" ]]; then echo "!{dist_to_import} already exist!"; exit 1; fi

  test -f "!{src_to_rsync}"
  rsync -av "!{src_to_rsync}" "!{dist_to_import}"

  if [[ -f "!{src_to_rsync}.render.yml" ]]; then
    rsync -av "!{src_to_rsync}.render.yml" "!{dist_to_import}.render.yml"
  fi

  ls -al "!{dist_to_import}"
  '''
}


/*
 * import to omero
 */
process import_to_omero {

  input:
  set filename, dist_folder, project, o_project, o_dataset, o_server from to_import_ch

  output:
  val dist_to_import

  shell:
  dist_to_import = "${dist_folder}/${filename}"
  '''
  test -f "!{dist_to_import}"
  ssh -t -t "!{o_server}" '/nfs/users/nfs_o/omero/import.sh "!{dist_to_import}" "!{project}" "!{o_owner}" "!{o_project}" "!{o_dataset}"'
  '''

}
