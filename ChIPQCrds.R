#=================================================================
#                   argparse Argument Parser
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#Loads argparse package and creates a command line parser.  Parses
#arguments into a named list.  Universal arguments for input bam/
#csv path, output rds path, and list of chromosomes for analysis.
#Single mode exclusive argument for peaks file path, multiple mode
#exclusive argument for number of worker cpus.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
library(argparse)
QCparser <- ArgumentParser()
QCparser$add_argument(
  "-i", "--input",
  type = "character",
  default = NULL,
  help = "Path to input sample (.bam) or sample sheet (.csv) to analyze."
)
QCparser$add_argument(
  "-p", "--peaks",
  type = "character",
  default = NULL,
  help = "Path to called peaks for sample reads. [Single Sample (.bam)]"
)
QCparser$add_argument(
  "-o", "--output",
  type = "character",
  default = "Analysis.rds",
  help = "Path to output rds file to generate."
)
QCparser$add_argument(
  "-c", "--chromosomes",
  type = "character", nargs="*",
  default = NULL,
  help = "Space separated list of chromosomes to analyze.  Analyzes all if none specified."
)
QCparser$add_argument(
  "-w", "--workers",
  type = "integer",
  default = 1,
  help = "Number of worker cpus. [Multiple Samples (.csv)]"
)
QCargs <- QCparser$parse_args()
#=================================================================

#=================================================================
#                     Parameter Processing
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#Determines script mode based on whether script is handling a
#single sample or multiple samples.  Loads necessary arguments
#into their own variables.  If necessary, makes columns of input
#csv into names to handle hyphens.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if (grepl(QCargs$input, pattern = ".bam")) {
  QCmode <- "single"
} else if (grepl(QCargs$input, pattern = ".csv")) {
  QCmode <- "multiple"
} else {
  stop("Invalid input format; must be .bam (single sample) or .csv (multiple samples).")
}
switch(QCmode,
  single = {
    QCreads <- QCargs$input
    QCpeaks <- QCargs$peaks
  },
  multiple = {
    QCsampleSheet <- read.csv(QCargs$input)
    MNblacklist <- c("Replicate", "bamReads", "bamControl", "Peaks")
    for (MNcol in colnames(QCsampleSheet)) {
      if (!(MNcol %in% MNblacklist) && !is.null(MNcol)) {
        QCsampleSheet[, MNcol] <- make.names(QCsampleSheet[, MNcol])
      }
    }
    QCworkers <- QCargs$workers
  }
)
QCrdsPath <- QCargs$output
QCchromosomes <- QCargs$chromosomes
#=================================================================

#=================================================================
#             BiocParallel Processor Determination
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#Loads BiocParallel package and creates a serial or parallel
#processor based on the requested number of worker cpus.
#Registers processor for use. (Multiple mode only)
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if (QCmode == "multiple") {
  library(BiocParallel)
  if (QCworkers>=2) {
    QCprocessor <- MulticoreParam(
      workers = QCworkers,
      progressbar = TRUE,
      jobname = "QCrds"
    )
  } else {
    QCprocessor <- SerialParam()
  }
  register(QCprocessor)
}
#=================================================================

#=================================================================
#                 ChIPQC Analysis and Output
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#Loads ChIPQC package and runs analysis in sample or standard mode
#depending on input type.  Outputs analysis to rds file and prints
#location.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
library(ChIPQC)
switch(QCmode,
  single = {
    QCanalysis <- ChIPQCsample(
      reads = QCreads,
      peaks = QCpeaks,
      annotation = NULL,
      chromosomes=QCchromosomes
    )
  },
  multiple = {
    QCanalysis <- ChIPQC(
      experiment = QCsampleSheet,
      annotation = NULL,
      chromosomes = QCchromosomes
    )
  }
)
saveRDS(QCanalysis, file=QCrdsPath)
print(paste("Analysis saved to rds file:", QCrdsPath))
#=================================================================