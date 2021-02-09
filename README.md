# Cenote Shortcut
Cenote Shortcut uses probabilistic models (i.e. HMMs) of virus hallmark genes to identify virus sequences from any dataset of contigs (e.g. metagenomic assemblies) or genomes (e.g. bacterial genomes). Optionally, Cenote Shortcut will use gene content information to remove flanking cellular chromosomes from contigs representing putative prophages. Generally, the prophage-cellular chromosome boundary will be identified within 100 nt - 2000 nt of the actual location.

```diff
The code is currently functional. Feel free to Cenote Shortcut at will.
```
Cenote Shortcut is derived entirely from Cenote-Taker 2, but several time-consuming computations are skipped in order to analyze datasets as quickly as possible. Also, Cenote Shortcut only takes approximately 16 minutes to download and install (Cenote-Taker 2 takes about 2 hours due to large databases required for thorough sequence annotation). See installation instructions below.

## Limitations
Compared to Cenote-Taker 2, there are a few limitations.

1) Cenote Shortcut does not do post-hallmark-gene-identification computations to flag plasmid and conjugative element sequences that occasionally slip through.
2) Cenote Shortcut does not make genome maps for manual inspection of putative viruses.
3) Contigs are not extensively annotated by Cenote Shortcut.

## Installation

TOTAL INSTALLATION SIZE IS APPROXIMATELY 7 GB
1. Change to the directory you'd like to be the parent to the install directory
2. Ensure Conda is installed and working. Use version 4.8.2 or better.
```
conda -V
```
3. Download the install script from this github repo into your current directory. (i.e. install_cenote_shortcut.sh). (remove any older versions of cenote_install1.sh first, if applicable)
```
wget  https://raw.githubusercontent.com/mtisza1/Cenote_Shortcut/main/install_cenote_shortcut.sh
```
4. Run the install script. Includes downloading all required databases. Should take 15-20 minutes. 
```
bash install_cenote_shortcut.sh 2>&1 | tee install_cenote_shortcut.log

(The "2>&1 | tee install_cenote_shortcut.log" part isn't necessary, but it will save the installation notes/errors to a log file)
```
That's it!

# Running Cenote Shortcut
1. Activate the Conda environment.
```
conda activate cenote_shortcut_env
```
2. Run the python script (see options below).
```
python /path/to/Cenote_Shortcut/cenote_shortcut.py
```
Options:
```
usage: cenote_shortcut.py [-h] 
                          --contigs ORIGINAL_CONTIGS 
                          --run_title RUN_TITLE 
                          --prune_prophage PROPHAGE 
                          --mem MEM 
                          --cpu CPU 
                          [--minimum_length_circular CIRC_LENGTH_CUTOFF]
                          [--minimum_length_linear LINEAR_LENGTH_CUTOFF]
                          [--virus_domain_db VIRUS_DOMAIN_DB]
                          [--lin_minimum_hallmark_genes LIN_MINIMUM_DOMAINS]
                          [--circ_minimum_hallmark_genes CIRC_MINIMUM_DOMAINS]
                          [--filter_out_plasmids FILTER_PLASMIDS]
``` 

## Use Case Suggestions/Settings
**Virus-like particle (VLP) prep assembly:**
```
--prune_prophage False --virus_domain_db standard
```
You might apply a size cutoff for linear contigs as well
```
--minimum_length_linear 3000
OR
--minimum_length_linear 5000
```
**Whole genome shotgun (WGS) metagenomic assembly:**
```
--prune_prophage True --virus_domain_db virion --minimum_length_linear 5000 --lin_minimum_hallmark_genes 2
```
While you should definitely ***definitely*** prune virus sequences from WGS datasets, [CheckV](https://bitbucket.org/berkeleylab/checkv/src/master/) also does a very good job (I'm still formally comparing these approaches) and you could use `--prune_prophage False` and feed the contigs from Cenote Shortcut into checkv end_to_end if you prefer.
**Bacterial reference genome**
```
--prune_prophage True --virus_domain_db virion --minimum_length_linear 5000 --lin_minimum_hallmark_genes 2
```
**RNAseq assembly of any kind (if you only want RNA viruses)**
```
--prune_prophage False --virus_domain_db rna_virus
```
If you also want DNA virus transcripts, or if your data is mixed RNA/DNA sequencing `--virus_domain_db standard` is the appropriate option.

For all runs more CPUs will make this run faster. Mem GBs should be about 50% or more of the CPU value.

## Citation
Michael J Tisza, Anna K Belford, Guillermo Domínguez-Huerta, Benjamin Bolduc, Christopher B Buck, Cenote-Taker 2 democratizes virus discovery and sequence annotation, Virus Evolution, Volume 7, Issue 1, January 2021, veaa100, https://doi.org/10.1093/ve/veaa100

