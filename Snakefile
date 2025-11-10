import yaml
with open("config/samples_config.yaml") as f:
    samples_config = yaml.safe_load(f)['samples']
runs_paired = [s for s in samples_config if s["layout"].upper() == "PAIRED"]
runs_single = [s for s in samples_config if s["layout"].upper() == "SINGLE"]    

    
rule all:
    input:
        # Todos los FASTQ1 (single + paired)
        "config/samples_config.yaml",
        expand(
            "Pipeline/{layout}/{organism}/{bioproject}/{run}/{run}_1.fastq.gz",
            layout=[s["layout"] for s in samples_config],
            organism=[s["organism"] for s in samples_config],
            bioproject=[s["bioproject"] for s in samples_config],
            run=[s["run"] for s in samples_config],
        ),
        # Solo los FASTQ2 para las paired
        expand(
            "Pipeline/{layout}/{organism}/{bioproject}/{run}/{run}_2.fastq.gz",
            layout=[s["layout"] for s in runs_paired],
            organism=[s["organism"] for s in runs_paired],
            bioproject=[s["bioproject"] for s in runs_paired],
            run=[s["run"] for s in runs_paired],
        )
        
rule filtro1:
    input:
        "db/DB_Microglial_exosomes_literature.xlsx"
    output:
        temp("txt/projects.txt"),
        temp("txt/sras.txt")
    script:
        "scripts/selector.py"

rule microglia:
    input:
        "txt/projects.txt",
        "db/DB_Microglial_exosomes_literature.xlsx"
    output:
        temp("txt/microglia_projects.txt")
    log:
        "logs/log_metadata.log"
    script:
        "scripts/Filter_Microglia.py"

rule Metadata_Microglia:
    input:
        "txt/microglia_projects.txt"
    output:
        "data/metadata_microglia.tsv"
    log:
        "logs/log_metadata_MC.log"
    shell:
        """
        #Consulta a NCBI SRA para obtener la metadata de los proyectos
        QUERY=$(awk '{{printf "%s%s", sep, $0; sep=" OR "}}' {input})
        #Impresión de la consulta (para debugging)
        echo "La consulta a NCBI es:"
        echo "$QUERY"
    
        #Búsqueda
        (esearch -db sra -query "$QUERY" | efetch -format runinfo > {output}) 2> {log}
        """
rule clean_srr:
    input:
        "data/metadata_microglia.tsv"
    output:
        "txt/srrs_clean.txt"
    log:
        "logs/clean_srr.log"
    script:
        "scripts/clean_srr.py"

rule control_Microglia:
    input:
        "txt/srrs_clean.txt"
    output:
        "txt/microglia_exosome_control.txt"
    script:
        "scripts/control_microglia.py"

rule dir_proy:
    input:
        "data/metadata_microglia.tsv",
        "txt/microglia_exosome_control.txt"
    output:
        directory("Pipeline/Projects")
    script:
        "scripts/runs_projects.py"

rule config_samples:
    input:
        "Pipeline/Projects"
    output:
        "config/samples_config.yaml"
    script:
        "scripts/create_config.py"

#Regla para layouts PAIRED
rule download_paired:
    output:
        fq1="Pipeline/PAIRED/{organism}/{bioproject}/{run}/{run}_1.fastq.gz",
        fq2="Pipeline/PAIRED/{organism}/{bioproject}/{run}/{run}_2.fastq.gz"
    shell:
        r"""
        echo "=== Descargando paired-end {wildcards.run} ==="
        mkdir -p Pipeline/PAIRED/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}
        
        fasterq-dump {wildcards.run} --split-files \
            --outdir Pipeline/PAIRED/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}
        
        gzip Pipeline/PAIRED/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}/{wildcards.run}_1.fastq
        gzip Pipeline/PAIRED/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}/{wildcards.run}_2.fastq
        """


#Regla para layouts SINGLE
rule download_single:
    output:
        fq1="Pipeline/SINGLE/{organism}/{bioproject}/{run}/{run}_1.fastq.gz"
    shell:
        r"""
        echo "=== Descargando single-end {wildcards.run} ===" 
        mkdir -p Pipeline/SINGLE/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}
        
        fasterq-dump {wildcards.run} \
            --outdir Pipeline/SINGLE/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}
        
        gzip Pipeline/SINGLE/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}/{wildcards.run}.fastq
        mv Pipeline/SINGLE/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}/{wildcards.run}.fastq.gz \
           Pipeline/SINGLE/{wildcards.organism}/{wildcards.bioproject}/{wildcards.run}/{wildcards.run}_1.fastq.gz
        """

# rule control:
#     input:
#         "data/metadata_microglia.tsv"
#     output:
#         "txt/srr_microglia.txt"
#     script:
        
# rule filtro_microglia:
#     input:
#         "data/metscriptsadata.tsv",
#         "db/DB_Microglial_exosomes_literature.xlsx"
#     log:
#         "logs/filtro_microglia.log"
#     output:
#         "data/metadata_microglia.tsv"
    
#     script:
#         "scripts/Filter_Microglia.py"
        
# rule filtro_control:
#     input:
#         "data/metadata_microglia.tsv"
#     log:
#         "logs/filtro_control.log"
#     output:
#         "data/metadata_microglia_control.tsv"
#     script:
#         "scripts/Filter_control.py"

# rule dir_proy:
#     input:
#         "data/metadata_microglia.tsv"
#     output:
#         "txt/proyectosACC.txt"
#     script:
#         "scripts/script_list.py"

        
    