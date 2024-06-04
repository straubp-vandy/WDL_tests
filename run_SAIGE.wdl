wdl
version 1.0

workflow SAIGE_analysis {
input {
File step1_geno_file
File step2_geno_file
File phenotype_file
String output_prefix
String phenoCol
String covarColList
String qCovarColList
String sampleIDColinphenoFile
String traitType
String LOCO
String sexCol
String femaleCode
String maleCode
String maleOnly
String femaleOnly
String chrom
String docker_image = "wzhou88/saige:1.3.0"
}

call run_SAIGE_step1 {
input:
step1_geno_file = step1_geno_file,
phenotype_file = phenotype_file,
output_prefix = output_prefix,
docker_image = docker_image,

output_prefix = output_prefix,
phenoCol = phenoCol,
covarColList = covarColList,
qCovarColList = qCovarColList,
sampleIDColinphenoFile = sampleIDColinphenoFile,
traitType = traitType,
LOCO = LOCO,
sexCol = sexCol,
femaleCode = femaleCode,
maleCode = maleCode,
maleOnly = maleOnly,
femaleOnly = femaleOnly

}


call run_SAIGE_step2 {
input:
step1_result_rda = run_SAIGE_step1.output_rda,
step1_result_varianceratio = run_SAIGE_step1.output_rda,
output_prefix = output_prefix,
docker_image = docker_image,
LOCO = LOCO,
step2_geno_file = step2_geno_file
chrom=chrom

}


output {
File step1_output = run_SAIGE_step1.output
File step2_output = run_SAIGE_step2.output
}
}

task run_SAIGE_step1 {
input {
File step1_geno_file
File phenotype_file
String output_prefix
String phenoCol
String covarColList
String qCovarColList
String sampleIDColinphenoFile
String traitType
String LOCO
String sexCol
String femaleCode
String maleCode
String maleOnly
String femaleOnly
String docker_image
}

command <<<
Rscript /usr/local/bin/step1_fitNULLGLMM.R --plinkFile=${step1_geno_file} --phenoFile=${phenotype_file} --phenoCol=${phenoCol} --covarColList=${covarColList} --qCovarColList=${qCovarColList}  --sampleIDColinphenoFile=${sampleIDColinphenoFile} --traitType=${traitType}  --outputPrefix=${output_prefix}.SAIGE_step1 --IsOverwriteVarianceRatioFile=TRUE --LOCO=${LOCO} --sexCol=${sexCol} --FemaleCode=${femaleCode} --MaleCode=${maleCode} --MaleOnly=${maleOnly} --FemaleOnly=${femaleOnly}

>>>

runtime {
docker: docker_image
}

output {
File output_rda = "${output_prefix}_step1.rda"
File output_varianceratio = "${output_prefix}_step1.varianceRatio.txt"
}
}

task run_SAIGE_step2 {
input {
File step1_result_rda
File step1_result_varianceratio
String output_prefix
String docker_image
String LOCO
File step2_geno_file


}

command <<<


Rscript /usr/local/bin/step2_SPAtests.R --bedFile=${step2_geno_file}.bed --bimFile=${step2_geno_file}.bim --famFile=${step2_geno_file}.fam  --AlleleOrder=alt-first --SAIGEOutputFile=${output_prefix}.SAIGE_step2.chr${i} --minMAF=0 --minMAC=20 --GMMATmodelFile=${step1_result_rda}  --varianceRatioFile=${step1_result_varianceratio}  --is_output_moreDetails=TRUE --is_imputed_data=TRUE --LOCO=${LOCO} --chrom=${chrom}
 

>>>

runtime {
docker: docker_image
}

output {
File output = "${output_prefix}_step2.chr${chrom}.txt.gz"
}
}
