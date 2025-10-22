rule all:
    input:
        "data/metadata.tsv"
    shell:
        "cat extras/title.txt"
        

rule filtro1:
    input:
        "db/DB_Microglial_exosomes_literature.xlsx"
    output:
        "txt/projects.txt",
        "txt/sras.txt"
    script:
        "scripts/selector.py"

rule metadata:
    input:
        "txt/projects.txt"
    output:
        "data/metadata.tsv"
    log:
        "logs/log_metadata.log"
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


    