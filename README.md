### _DEPRECATED_

This repo is deprecated. 

If you need help finishing a project using `Cenote-Taker 2`/`Unlimited Breadsticks`, I will still field questions/troubleshoot (open an issue).

**Otherwise:**

[Please use Cenote-Taker 3](https://github.com/mtisza1/Cenote-Taker3). It's great!!



######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########

######### ######### ######### ######### ######### ######### ######### ######### #########









# Unlimited Breadsticks
Consumers are presented a dillema at certain Italian-American eateries that provide "unlimited breadsticks" with every meal. On the one hand, the value of their dollar undoubtedly increases as more and more delicious breadsticks are eaten.  On the other hand, overconsumption of this appetizer can preclude thorough enjoyment and completion of the forthcoming entree. Furthermore, stomach aches may ensue, and the health of the consumer may ultimately be jeopardized. **Similarly**, virus hunters employing high throughput virus discovery tools on dataset after dataset may feel the exciting buzz as fasta files full of putative virus sequences pile up. However, without inspection of new sequences, e.g. via visualization of genome maps (not to mention sequence dereplication), databases may become filled with garbage sequences. Therefore, it is perhaps ideal to do some manual curation after automated detection.

With that said, please enjoy **Unlimited Breadsticks**.


Unlimited Breadsticks uses probabilistic models (i.e. HMMs) of virus hallmark genes to identify virus sequences from any dataset of contigs (e.g. metagenomic assemblies) or genomes (e.g. bacterial genomes). Optionally, Unlimited Breadsticks will use gene content information to remove flanking cellular chromosomes from contigs representing putative prophages. Generally, the prophage-cellular chromosome boundary will be identified within 100 nt - 2000 nt of the actual location.

```diff
+ The code is currently functional. Feel free to consume Unlimited Breadsticks at will.
+ Minor update to handle very large contig files AND update to HMM databases on June 16th, 2021
```
Unlimited Breadsticks is derived from [Cenote-Taker 2](https://github.com/mtisza1/Cenote-Taker2), but several time-consuming computations are skipped in order to analyze datasets as quickly as possible. Also, Unlimited Breadsticks only takes approximately **16 minutes to download and install** (Cenote-Taker 2 takes about 2 hours due to large databases required for thorough sequence annotation). See installation instructions below.

To update from older versions: 
```
conda activate unlimited_breadsticks_env
cd Cenote_Unlimited_Breadsticks
git pull
python update_ub_databases.py --hmm True
```

## Limitations
Compared to Cenote-Taker 2, there are a few limitations.

1) Unlimited Breadsticks does not do post-hallmark-gene-identification computations to flag plasmid and conjugative element sequences that occasionally slip through.
2) Unlimited Breadsticks does not make genome maps for manual inspection of putative viruses.
3) Contigs are not extensively annotated by Unlimited Breadsticks. No genome maps are created.

## Installation

TOTAL INSTALLATION SIZE IS APPROXIMATELY 7 GB
1. Change to the directory you'd like to be the parent to the install directory
2. Ensure Conda is installed and working. Use version 4.8.2 or better.
```
conda -V
```
3. Download the install script from this github repo into your current directory. (i.e. install_unlimited_breadsticks.sh). (remove any older versions of install_unlimited_breadsticks.sh first, if applicable)
```
wget  https://raw.githubusercontent.com/mtisza1/Cenote_Unlimited_Breadsticks/main/install_unlimited_breadsticks.sh
```
4. Run the install script. Includes downloading all required databases. Should take 15-20 minutes. 
```
bash install_unlimited_breadsticks.sh 2>&1 | tee install_unlimited_breadsticks.log
```
(The "2>&1 | tee install_unlimited_breadsticks.log" part isn't necessary, but it will save the installation notes/errors to a log file)

That's it!

# Running Unlimited Breadsticks
1. Activate the Conda environment.
```
conda activate unlimited_breadsticks_env
```
2. Run the python script without arguments to bring up the quick menu (see options below).
```
python /path/to/Cenote_Unlimited_Breadsticks/unlimited_breadsticks.py
```
3. Run some contigs with Unlimited Breadsticks:

```
python /path/to/Cenote_Unlimited_Breadsticks/unlimited_breadsticks.py -c MY_CONTIGS.fasta -r my_contigs1_ub -m 32 -t 32 -p true -db virion
```
Options:
```
usage: unlimited_breadsticks.py [-h] 
                                -c ORIGINAL_CONTIGS 
                                -r RUN_TITLE 
                                -p PROPHAGE 
                                -m MEM 
                                -t CPU
                                [--minimum_length_circular CIRC_LENGTH_CUTOFF]
                                [--minimum_length_linear LINEAR_LENGTH_CUTOFF]
                                [-db VIRUS_DOMAIN_DB]
                                [--lin_minimum_hallmark_genes LIN_MINIMUM_DOMAINS]
                                [--circ_minimum_hallmark_genes CIRC_MINIMUM_DOMAINS]
                                [--filter_out_plasmids FILTER_PLASMIDS]

unlimited_breadsticks is a pipeline for virus discovery and cursory annotation
of viral contigs and genomes. Visit
https://github.com/mtisza1/Cenote_Unlimited_Breadsticks for further
description

optional arguments:
  -h, --help            show this help message and exit

 REQUIRED ARGUMENTS for unlimited_breadsticks :
  -c ORIGINAL_CONTIGS, --contigs ORIGINAL_CONTIGS
                        Contig file with .fasta extension in fasta format - OR
                        - assembly graph with .fastg extension. Each header
                        must be unique before the first space character
  -r RUN_TITLE, --run_title RUN_TITLE
                        Name of this run. A directory of this name will be
                        created. Must be unique from older runs or older run
                        will be renamed. Must be less than 18 characters,
                        using ONLY letters, numbers and underscores (_)
  -p PROPHAGE, --prune_prophage PROPHAGE
                        True or False. -- Attempt to identify and remove
                        flanking chromosomal regions from non-circular contigs
                        with viral hallmarks (True is highly recommended for
                        sequenced material not enriched for viruses. Virus
                        enriched samples probably should be False (you might
                        check actaul enrichment with ViromeQC). Also, please
                        use False if --lin_minimum_hallmark_genes is set to 0)
  -m MEM, --mem MEM     example: 56 -- Gigabytes of memory available for
                        unlimited_breadsticks. Typically, 16 to 32 should be
                        used. Lower memory will work in theory, but could
                        extend the length of the run
  -t CPU, --cpu CPU     Example: 32 -- Number of CPUs available for
                        unlimited_breadsticks. Typically, 32 CPUs should be
                        used. For large datasets, increased performance can be
                        seen up to 120 CPUs. Fewer than 16 CPUs will work in
                        theory, but could extend the length of the run

 OPTIONAL ARGUMENTS for unlimited_breadsticks. Most of which are important to consider!!! :
  --minimum_length_circular CIRC_LENGTH_CUTOFF
                        Default: 1000 -- Minimum length of contigs to be
                        checked for circularity. Absolute minimun is 1000 nts
  --minimum_length_linear LINEAR_LENGTH_CUTOFF
                        Default: 1000 -- Minimum length of non-circualr
                        contigs to be checked for viral hallmark genes.
  -db VIRUS_DOMAIN_DB, --virus_domain_db VIRUS_DOMAIN_DB
                        default: virion -- 'standard' database: all virus (DNA
                        and RNA) hallmark genes (i.e. genes with known
                        function as virion structural, packaging, replication,
                        or maturation proteins specifically encoded by virus
                        genomes) with very low false discovery rate. 'virion'
                        database: subset of 'standard', hallmark genes
                        encoding virion structural proteins, packaging
                        proteins, or capsid maturation proteins (DNA and RNA
                        genomes). 'rna_virus' database: For RNA virus
                        hallmarks only. Includes RdRp and capsid genes of RNA
                        viruses. Low false discovery rate due to structural
                        similarity between RdRp genes and e.g. transposon-
                        encoded RT genes
  --lin_minimum_hallmark_genes LIN_MINIMUM_DOMAINS
                        Default: 1 -- Number of detected viral hallmark genes
                        on a non-circular contig to be considered viral.
  --circ_minimum_hallmark_genes CIRC_MINIMUM_DOMAINS
                        Default:1 -- Number of detected viral hallmark genes
                        on a circular contig to be considered viral.
  --filter_out_plasmids FILTER_PLASMIDS
                        Default: True -- True - OR - False. If True, hallmark
                        genes of plasmids will not count toward the minimum
                        hallmark gene parameters. If False, hallmark genes of
                        plasmids will count. Plasmid hallmark gene set is not
                        necessarily comprehensive at this time.
``` 

## Use Case Suggestions/Settings
**Virus-like particle (VLP) prep assembly:**
```
-p False -db standard
```
You might apply a size cutoff for linear contigs as well, e.g. ` --minimum_length_linear 3000` OR `--minimum_length_linear 5000`. Changing length minima does not affect false positive rates, but short linear contigs may not be useful, depending on your goals.

**Whole genome shotgun (WGS) metagenomic assembly:**
```
-p True -db virion --minimum_length_linear 3000 --lin_minimum_hallmark_genes 2
```
While you should definitely ***definitely*** prune virus sequences from WGS datasets, [CheckV](https://bitbucket.org/berkeleylab/checkv/src/master/) also does a very good job (I'm still formally comparing these approaches) and you could use `--prune_prophage False` and feed the unpruned contigs from Unlimited Breadsticks into `checkv end_to_end` if you prefer.

**Bacterial reference genome**
```
-p True -db virion --minimum_length_linear 3000 --lin_minimum_hallmark_genes 2
```
Using `--lin_minimum_hallmark_genes 1 --virus_domain_db virion` with WGS or bacterial genome data will (in my experience) yield very few sequences that appear to be false positives, however, there are lots of "degraded" prophage sequences in these sequencing sets, i.e. some/most genes of the phage have been lost. That said, sequence with just 1 hallmark gene is neither a guarantee of a degraded phage (especially in the case of ssDNA viruses) nor is 2+ hallmark a guarantee of of a complete phage.

**RNAseq assembly of any kind (if you only want RNA viruses)**
```
-p False -db rna_virus
```
If you also want DNA virus transcripts, or if your data is mixed RNA/DNA sequencing `--virus_domain_db standard` is the appropriate option.

### CPUs and Memory
For all runs more CPUs will make this run faster. Mem GBs should be about 50% or more of the CPU value.

## Citation
Michael J Tisza, Anna K Belford, Guillermo Domínguez-Huerta, Benjamin Bolduc, Christopher B Buck, Cenote-Taker 2 democratizes virus discovery and sequence annotation, Virus Evolution, Volume 7, Issue 1, January 2021, veaa100, https://doi.org/10.1093/ve/veaa100

