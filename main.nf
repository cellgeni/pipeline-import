#!/usr/bin/env nextflow

input_prefix = "/nfs/team283_imaging"

o_group = params.o_group
o_owner = params.o_owner
output_dir = file(params.output)

Channel
    .fromPath(params.input)
    .splitCsv(header:true, sep:'\t')
    .map{ row-> tuple(row.Location, row.Filename, row.project, row.dataset) }
    .set { prepare_to_import_ch }


/*
 * rsync file
 */
process rsync_file {

  input:
  set file(Location), Filename, Project, Dataset from prepare_to_import_ch

  output:
  set file(file_to_import), Project, Dataset into to_import_ch

  shell:
  file_to_import = "${Location}/${Filename}"
  file_to_import = file("${file_to_import}")
  '''
  test -f "!{file_to_import}"
  rsync -av !{file_to_import} !{output_dir}/!{project}/!{Filename}
  '''
}


/*
 * import to omero
 */
process import_to_omero {

  input:
  set file(file_to_import), Project, Dataset from to_import_ch

  output:
  file file_to_import

  shell:
  '''
  test -f "!{file_to_import}"
  ssh -t omero-server '/nfs/users/nfs_o/omero/import_public.sh "!{file_to_import}" "!{o_group}" "!{o_owner}" "!{project}" "!{dataset}"'
  '''

}
