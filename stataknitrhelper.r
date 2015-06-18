################################################################################
##
## NAME: R helper scripts
## FILE: stataknitrhelper.r
## AUTH: Benjamin Skinner
##
################################################################################

logparse <- function(logfile, start = NULL, end = NULL, include = FALSE) {

    ## -------------------------------------------------------------------------
    ## PURPOSE
    ##
    ## Work-around for problem of knitting Stata into Markdown. This function
    ## parses the Stata log files (really any file) by taking as its input
    ## a starting point in the log file and returning only a subsection.
    ## Requires consistent commenting in Stata do file (or whatever is
    ## being parsed). If no start or end is given, the entire log will
    ## be returned.
    ## -------------------------------------------------------------------------

    ## read in logfile
    f <- readLines(logfile)

    ## start
    if (!is.null(start)) {

        ## convert to numeric if character string or regex is used
        if (!is.numeric(start)) {

            start <- grep(start, f)

            ## if more than one, take the first to be more inclusive
            if (length(start > 1)) {
                
                start <- start[1]
                
            }
            
        }

        ## subset from start
        f <- f[c(start:length(f))]
    }

    ## end
    if (!is.null(end)) {

        ## if numeric, need to adjust based on above subset (if any)
        if (!is.null(start) & is.numeric(end)) {

            end <- end - start + 1

        }

        ## convert to numeric if character string or regex is used
        else if (!is.numeric(end)) {

            end <- grep(end, f)

            ## if more than one, take the second to be more inclusive
            if (length(end > 1)) {
                
                end <- end[length(end)]
                
            }
    
        }

        ## subset to end
        f <- f[c(1:end)]
    }

    ## strip start and stop lines
    if (!include) {

        newend <- length(f) - 1
        f <- f[2:newend]

    }

    ## strip period only lines
    blankrows <- grep('^\\. $', f)
    f <- f[-(blankrows)]
    
    ## return
    return(f)
}

alignfigure <- function(image, alignment = c('left', 'center', 'right')) {

    ## -------------------------------------------------------------------------
    ## PURPOSE
    ##
    ## Work-around for problem of centering plots/images. Markdown's philosophy
    ## is to leave well enough alone, but sometimes you want a centered image.
    ## This code will wrap the image in HTML <div>...</div> tags with the chosen
    ## alignment. Keep in mind that if your plot/image is larger than the
    ## overall wrapper, the alignment will not matter!
    ## -------------------------------------------------------------------------

    ## opening tag
    opentag <- paste0('<div style = \"text-align: ', alignment, '\">')

    ## content filler
    fill <- paste0('<img src = \"', image,'\" />')

    ## closing tag
    closetag <- '</div>'

    ## return
    return(c(opentag, fill, closetag))
    
}


## END
