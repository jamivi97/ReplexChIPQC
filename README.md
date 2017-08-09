# ReplexChIPQC
ReplexChIPQC is a pair of R scripts and an R markdown replicating and extending the functionality of the R package ChIPQC.
## Workflow
![ReplexChIPQC Workflow Diagram](https://raw.githubusercontent.com/jmvieira97/ReplexChIPQC/master/Examples/ReplexChIPQCFlowchart.png)
The scripts of ReplexChIPQC follow this workflow, beginning with indexed ChIP-seq .bam files and their corresponding called peaks and ending with an analysis html document.  It is broken into two major scripts, or stages, both of which are called from the command line and passed parameters using argparse.  The scripts can follow two pathways of analysis, both of which will be explained here.
## Stage 1: ChIPQCrds.R | rds Generator
This stage of the ReplexChIPQC pipeline runs ChIPQC's quality control calculations on input data, and stores the results of this analysis in R readable .rds files, which are then passed to the second stage.
##### Usage:
```shell
Rscript ChIPQCrds.R [-h] [-i INPUT] [-p PEAKS] [-o OUTPUT] [-c CHROMOSOMES...] [-w WORKERS]
```
`-h` returns a command line help message then exits.
`-i` is a mandatory argument specifying the file path to the input (**sample-wise**: .bam; **experiment-wise**: .csv)
`-p` is a mandatory argument for **sample-wise mode only** specifying the file path to called peaks for the sample.
`-o` is a mandatory argument specifying the file path to the output (.rds).
`-c` is an optional argument specifying a space separated list of chromosomes to perform analysis on.  If none are specified, defaults to analyzing all chromosomes present in samples.
`-w` is an optional argument for **experiment-wise mode only** specifying the number of worker cpus for running parallel analysis via biocparallel.  Defaults to 1 (serial computing).
#### Sample-Wise
Sample-wise rds generation performs analysis on an individual sample's .bam file and corresponding called peaks.  The output rds contains all calculations for that individual sample, sans metadata.  To generate this flavor of rds, `-i` must be the path to a sample's .bam file, and `-p` must be the path to the corresponding peaks file.
##### Example Command:
```shell
Rscript ChIPQCrds.R -i=reads/01_bg3_mod.bam -p=peaks/01_bg3_mod.narrowPeak -o=analyses/01_bg3_mod.ChIPQC.rds -c chrX chrY
```
This will generate a sample-wise .rds file titled  `01_bg3_mod.ChIPQC.rds` with analysis on the X and Y chromosomes from the input sample `01_bg3_mod.bam` and its peaks `01_bg3_mod.narrowPeak`.
#### Experiment-Wise
Experiment-wise rds generation performs analysis on a DiffBind Sample Sheet .csv file.  The output rds contains calculations for all samples specified, including their DiffBind restricted metadata.  To generate this flavor of rds, `-i` must be the path to the experiment's DiffBind Sample Sheet .csv file.

| SampleID   | Tissue | Factor | Replicate | bamReads              | Peaks                        | PeakCaller | 
|------------|--------|--------|-----------|-----------------------|------------------------------|------------| 
| bg3_mod_1  | bg3    | mod    | 1         | reads/01_bg3_mod.bam  | peaks/01_bg3_mod.narrowPeak  | narrow     | 
| bg3_mod_2  | bg3    | mod    | 2         | reads/02_bg3_mod.bam  | peaks/02_bg3_mod.narrowPeak  | narrow     | 
| bg3_shep_1 | bg3    | shep   | 1         | reads/03_bg3_shep.bam | peaks/03_bg3_shep.narrowPeak | narrow     | 
| bg3_shep_2 | bg3    | shep   | 2         | reads/04_bg3_shep.bam | peaks/04_bg3_shep.narrowPeak | narrow     | 
| kc_mod_1   | kc     | mod    | 1         | reads/05_kc_mod.bam   | peaks/05_kc_mod.narrowPeak   | narrow     | 
| kc_mod_2   | kc     | mod    | 2         | reads/06_kc_mod.bam   | peaks/06_kc_mod.narrowPeak   | narrow     | 
| kc_shep_1  | kc     | shep   | 1         | reads/07_kc_mod.bam   | peaks/07_kc_mod.narrowPeak   | narrow     | 
| kc_shep_2  | kc     | shep   | 2         | reads/08_kc_shep.bam  | peaks/08_kc_shep.narrowPeak  | narrow     | 

This DiffBind sample sheet contains the data used to generate the example plots.
* **SampleID** is unique identifier string for each sample.
* **Tissue**, **Factor**, and **Replicate** contain metadata values for each sample.
* **bamReads** and **Peaks** contain file paths to the samples' .bam reads and .narrowPeak peaks.
* **PeakCaller** contains the peak caller used to generate peaks.

For more information on acceptable data for these sample sheets, please refer to [ChIPQC's documentation on sample sheets [Sections 2.1 & 3.1]](https://bioconductor.org/packages/release/bioc/vignettes/ChIPQC/inst/doc/ChIPQC.pdf).
##### Example Command:
```shell
Rscript ChIPQCrds.R -i=experiments/ExampleDiffBindSampleSheet.csv -o=analyses/ExampleAnalysis.ChIPQC.rds -c chrX chrY -w=4
```
This will generate (using 4 worker cpus) an experiment-wise .rds file titled `ExampleAnalysis.ChIPQC.rds` with analysis on the X and Y chromosomes from the above sample sheet `ExampleDiffBindSampleSheet.csv`.