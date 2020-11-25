## An automated pipeline for homology-modeling



This pipeline is built for high-throughput generation of homology-models of a sets of enzymes with only the sequence information.

The modeling method is based on the [Basic Modeling tutorial](https://salilab.org/modeller/tutorial/basic.html) of Modeller, and the template selection rule is just to select the structure with the highest sequence similarity to the modeled sequence.

The default e-value cutoff is 0.01.

If no template is found,the target id will write to ` non_template.txt`.In this case,you should use other methods(such as hhblits) to search for remote templates.



## Dependencies

```
Biopython==1.78
Modeller==9.25
```

### database

- All PDB sequences:
- [pdball.pir.gz](https://salilab.org/modeller/downloads/pdball.pir.gz)

https://salilab.org/modeller/supplemental.html



## Usage

Your workspace should look like this:

The input.fasta file can contain multiple sequence.

```shell
.
├── input.fasta
├── align2d.py
├── build_profile.py
├── download_pdbchain.py
├── model_single.py
├── pdball.bin
├── rename.sh
└── start-modeling.sh

0 directories, 8 files
```



start automated modelling:

```shell
bash start-modeling.sh input.fasta
```

