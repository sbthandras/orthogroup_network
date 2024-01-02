#!/usr/bin/env nextflow
nextflow.enable.dsl=2



genome_ch = Channel.fromPath("$launchDir/genomedir/*gb", checkIfExists: true)
genome_tuple_ch = genome_ch | map {[it.getBaseName(), it]}

process prodigal{
  tag "$genome_id"
  errorStrategy = 'ignore'
  container "nanozoo/prodigal:latest"
  storeDir "$launchDir/own_results/predict_orf"
  
  input:
  tuple val(genome_id), path(genome)

  output:
  file("${genome_id}.faa")

  script:
  """
  prodigal -i $launchDir/genomedir/${genome} -o ${genome_id}.orf  -a ${genome_id}.faa ; \
  $launchDir/scripts/append_filename.sh ${genome_id}.faa > tmp; \
  mv tmp ${genome_id}.faa
  """
}

process gene2genome{
  container "sonnenburglab/vcontact2:latest"
  storeDir "$launchDir/own_results/gene_2_genome"
  
  input:
  file orfs

  output:
  file("gene_2_genome.csv")
  file("collected_orfs.fasta")

  script:
  """
  vcontact2_gene2genome -p ${orfs} -o gene_2_genome.csv -s 'Prodigal-FAA';\
  #cp gene_2_genome.csv tmp.backup; \
  #echo 'protein_id,contig_id,keywords' > gene_2_genome.csv; \
  #cat tmp.backup | tail -n+2 >> gene_2_genome.csv \
  """
}
process vcontact2{
  container "sonnenburglab/vcontact2:latest"
  storeDir "$launchDir/results/vcontact2_blastp"
  input:
  file(gene2genome)
  file(orfs)

  script:
  """
  vcontact2 --raw-proteins  $launchDir/own_results/gene_2_genome/${orfs} --rel-mode 'BLASTP' --db 'None' --proteins-fp  $launchDir/own_results/gene_2_genome/${gene2genome}  --output-dir $launchDir/results/vcontact2_blastp/ -b $launchDir/results/vcontact2_blastp/blastp.tsv -t 30 --c1-bin  /node10_R10/asbothandras/Metaphage/bin/cluster_one-1.0.jar   --force-overwrite
  """
}

process taxonomy_annot{
  container "rocker:tidyverse:latest"
  storeDir "$launchDir/results/annotated_networks"
  input:
  file(c1.ntw)
  output:
  file(nodes.rda)
  script:
  """
  Rscript scripts/colornodes.R
  """
}


workflow {
    orfs = prodigal(genome_tuple_ch)
    prodigal.out.collectFile(name: 'collected_orfs.fasta') | gene2genome | vcontact2 
}
