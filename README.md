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
`-i` is a mandatory argument specifying the file path to the input (**Sample-wise**: .bam; **Experiment-wise**: .csv).
`-p` is a mandatory argument for **sample-wise mode only** specifying the file path to called peaks for the sample.  
`-o` is a mandatory argument specifying the file path to the output (.rds).  
`-c` is an optional argument specifying a space separated list of chromosomes to perform analysis on.  If none are specified, defaults to analyzing all chromosomes present in samples.  
`-w` is an optional argument for **experiment-wise mode only** specifying the number of worker cpus for running parallel analysis via biocparallel.  Defaults to 1 (serial computing).
### Sample-Wise
**Sample-wise** rds generation performs analysis on an individual sample's .bam file and corresponding called peaks.  The output rds contains all calculations for that individual sample, sans metadata.  To generate this flavor of rds, `-i` must be the path to a sample's .bam file, and `-p` must be the path to the corresponding peaks file.
##### Example Command:
```shell
Rscript ChIPQCrds.R -i=reads/01_bg3_mod.bam -p=peaks/01_bg3_mod.narrowPeak -o=analyses/01_bg3_mod.ChIPQC.rds -c chrX chrY
```
This will generate a **sample-wise** .rds file titled  `01_bg3_mod.ChIPQC.rds` with analysis on the X and Y chromosomes from the input sample `01_bg3_mod.bam` and its peaks `01_bg3_mod.narrowPeak`.
### Experiment-Wise
**Experiment-wise** rds generation performs analysis on a DiffBind Sample Sheet .csv file.  The output rds contains calculations for all samples specified, including their DiffBind restricted metadata.  To generate this flavor of rds, `-i` must be the path to the experiment's DiffBind Sample Sheet .csv file.

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

For more information on acceptable data for these sample sheets, refer to [ChIPQC's documentation on sample sheets [Sections 2.1 & 3.1]](https://bioconductor.org/packages/release/bioc/vignettes/ChIPQC/inst/doc/ChIPQC.pdf).
##### Example Command:
```shell
Rscript ChIPQCrds.R -i=experiments/ExampleDiffBindSampleSheet.csv -o=analyses/ExampleAnalysis.ChIPQC.rds -c chrX chrY -w=4
```
This will generate (using 4 worker cpus) an **experiment-wise** .rds file titled `ExampleAnalysis.ChIPQC.rds` with analysis on the X and Y chromosomes from the above sample sheet `ExampleDiffBindSampleSheet.csv`.
## Stage 2: ChIPQCAnalysis.R | Markdown Generator
This stage of the ReplexChIPQC pipeline takes the quality control calculations stored in rds files by the first stage and visualizes them as an html file using R Markdown.
##### Usage:
```shell
Rscript ChIPQCAnalysis.R [-h] [-i INPUT] [-o OUTPUT] [-t TITLE] [-e ECHO] [-x FACETX] [-y FACETY] [-z FACETZ] [-p PALETTE]
```
`-h` returns a command line help message then exits.  
`-i` is a mandatory argument specifying the file path to the input (**Stitch Mode**: .csv; **Experiment Mode**: .rds)
`-o` is a mandatory argument specifying the file path to the output (.html).
`-t` is an optional argument specifying an in-document title for the analysis markdown.  Defaults to "ReplexChIPQC Analysis".
`-e` is an optional argument specifying whether or not to echo the source code in the markdown (_TRUE_ or _FALSE_).  Defaults to _FALSE_.
`-x` is an optional argument specifying the metadata used to facet the columns of the report's plots.  Defaults to "Tissue".
`-y` is an optional argument specifying the metadata used to facet the rows of the report's plots.  Defaults to "Factor".
`-z` is an optional argument specifying the metadata used to color the Coverage Histogram, Cross Coverage, and Peak Profile plots, and used as the x axis of the Reads in Peaks and Counts in Peaks plots.  Defaults to "Replicate".
`-p` is an optional argument specifying an RColorBrewer palette to use for coloring (if there is more than one possibility for the facetZ parameter).  Defaults to "Set1", must be the name of a **qualitative** RColorBrewer palette.  For more information refer to [RColorBrewer's reference manual](https://cran.r-project.org/web/packages/RColorBrewer/RColorBrewer.pdf).
### Stitch Mode
**Stitch Mode** operates on **sample-wise** rds files, and stitches the individual rds files together into a single analysis.  To accomplish this, `-i` must be the path to a Stitch Sample Sheet .csv containing all samples to be included.

| SampleID   | Tissue | Factor | Replicate | rds                             | 
|------------|--------|--------|-----------|---------------------------------| 
| bg3_mod_1  | bg3    | mod    | 1         | analyses/01_bg3_mod.ChIPQC.rds  | 
| bg3_mod_2  | bg3    | mod    | 2         | analyses/02_bg3_mod.ChIPQC.rds  | 
| bg3_shep_1 | bg3    | shep   | 1         | analyses/03_bg3_shep.ChIPQC.rds | 
| bg3_shep_2 | bg3    | shep   | 2         | analyses/04_bg3_shep.ChIPQC.rds | 
| kc_mod_1   | kc     | mod    | 1         | analyses/05_kc_mod.ChIPQC.rds   | 
| kc_mod_2   | kc     | mod    | 2         | analyses/06_kc_mod.ChIPQC.rds   | 
| kc_shep_1  | kc     | shep   | 1         | analyses/07_kc_mod.ChIPQC.rds   | 
| kc_shep_2  | kc     | shep   | 2         | analyses/08_kc_shep.ChIPQC.rds  | 
This Stitch Sample Sheet contains the data used to generate the example plots.
* **SampleID** is unique identifier string for each sample.
* **Tissue**, **Factor**, and **Replicate** contain metadata values for each sample.
* **rds** contains the path to the samples' **sample-wise** rds files.

This flavor of sample sheet serves to append the previously missing metadata to **sample-wise** rds files in order to give the same output as an **experiment-wise** rds.  Unlike DiffBind sample sheets however, these sample sheets can accept arbitrary user-defined metadata without restrictions.  **SampleID** and **rds** are mandatory, faceting variables and additional metadata can be anything specified by the end user.
##### Example Command:
```shell
Rscript ChIPQCAnalysis.R -i=experiments/ExampleStitchSampleSheet.csv -o=reports/ExampleAnalysis.html -t="Example QC Analysis"
```
This will generate the report `ExampleAnalysis.html` from the stitch sample sheet `ExampleStitchSampleSheet.csv` with the in-document title `"Example QC Analysis"`.  (Echo, faceting, and palette are left as their defaults).
### Experiment Mode
**Experiment Mode** operates on **experiment-wise** rds files.  For this mode, `-i` must be an **experiment-wise** rds file, as these already contain all samples and metadata.
##### Example Command:
```shell
Rscript ChIPQCAnalysis.R -i=analyses/ExampleAnalysis.ChIPQC.rds -o=reports/ExampleAnalysis.html -t="Example QC Analysis"
```
This will generate the report `ExampleAnalysis.html` from the **experiment-wise** rds file `ExampleAnalysis.ChIPQC.rds` with the in-document title `"Example QC Analysis"`.  (Echo, faceting, and palette are left as their defaults).