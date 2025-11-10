import os
import yaml
directorio="Pipeline/Projects"
config={"samples":[]}
for layout in os.listdir(directorio):
    layout_path=os.path.join(directorio, layout)
    if not os.path.isdir(layout_path):
        continue
    
    for organism in os.listdir(layout_path):
        organism_path=os.path.join(layout_path, organism)
        if not os.path.isdir(organism_path):
            continue
        
        for bioproject in os.listdir(organism_path):
            bioproject_path=os.path.join(organism_path, bioproject)
            if not os.path.isdir(bioproject_path):
                continue
            
            for run in os.listdir(bioproject_path):
                run_path=os.path.join(bioproject_path, run)
                if not os.path.isdir(run_path):
                    continue
                config["samples"].append({
                    "layout": layout,
                    "organism": organism,
                    "bioproject": bioproject,
                    "run": run,
                    "path": run_path
                })
with open("config/samples_config.yaml", "w") as f:
    yaml.dump(config, f, sort_keys=False, default_flow_style=False)