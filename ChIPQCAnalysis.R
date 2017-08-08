#=================================================================
#                   argparse Argument Parser
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#Loads argparse package and creates a command line parser.  Parses
#arguments into a named list.  Arguments for input rds/csv path,
#output html path, markdown title, x and y faceting variables, and
#RColorBrewer palette.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
library(argparse)
QCparser <- ArgumentParser()
QCparser$add_argument(
  "-i", "--input",
  type = "character",
  default = "Analysis.rds",
  help = "Path to stitch sheet (.csv) or analyzed experiment (.rds) to visualize."
)
QCparser$add_argument(
  "-o", "--output",
  type = "character",
  default = "ChIPQCAnalysis.html",
  help = "Path to output html file to generate."
)
QCparser$add_argument(
  "-t", "--title",
  type = "character",
  default = "ChIPQC Analysis",
  help = "In-document title for analysis markdown."
)
QCparser$add_argument(
  "-e", "--echo",
  type = "logical",
  default = FALSE,
  help = "Determines whether to echo the source code in the generated markdown."
)
QCparser$add_argument(
  "-x", "--facetX",
  type = "character",
  default = "Tissue",
  help = "Factor to facet columns of plots by."
)
QCparser$add_argument(
  "-y", "--facetY",
  type = "character",
  default = "Factor",
  help = "Factor to facet rows of plots by."
)
QCparser$add_argument(
  "-z", "--facetZ",
  type = "character",
  default = "Replicate",
  help = "Factor to color plots by.  Used to break x axis for reads in peaks plots."
)
QCparser$add_argument(
  "-p", "--palette",
  type = "character",
  default = "Set1",
  help = "Qualitative RColorBrewer palette to color by."
)
QCargs <- QCparser$parse_args()
#=================================================================

#=================================================================
#                     RMarkdown Rendering
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#Loads RMarkdown and knitr packages, and knits analysis markdown
#with the specified parameters.  Outputs as html file to specified
#location.
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
library(knitr)
library(rmarkdown)
render("ChIPQCAnalysis.Rmd",
  output_file = QCargs$output,
  params = list(
    input = QCargs$input,
    title = QCargs$title,
    echo = QCargs$echo,
    facetX = QCargs$facetX,
    facetY = QCargs$facetY,
    facetZ = QCargs$facetZ,
    palette = QCargs$palette
  )
)
#=================================================================