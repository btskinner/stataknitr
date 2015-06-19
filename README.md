Unlike many of the other programming languages that knitr supports, Stata doesn't work as well when trying to compile literate programming documents. Other discussions about this issue and potential solutions can be found [here](https://hopstat.wordpress.com/2014/01/11/stata-markdown-2/), [here](https://github.com/amarder/stata-tutorial), and [here](http://www.ssc.wisc.edu/~hemken/Stataworkshops/Stata%20and%20R%20Markdown/Statalinux.html). 

The biggest problem of using Stata with knitr is that each chunk is treated as its own do file and run in independent Stata sessions through the command line. This means that changes aren't persistent across chunks and strange behaviors occur, assuming the document compiles at all. One can attempt to set up a `profile.do` file to help with persistence, but I had trouble with it.


StataKnitr comes from my attempt to knit a Stata do file into an HTML file. My solution is to run the Stata do file using a bash chunk in knitr and then parse the resulting log file with an R helper function I wrote called `logparse()`. Images are aligned with another R function, `alignfigure()`. The resulting workflow isn't as smooth as one might desire, but it works well for making a nice presentation of Stata code and output when that is required.

## Requirements

This method requires:

*  a do that can be run from top to bottom and is well commented with unique comments
*  a log file of the session
*  the ability to run Stata from the [command line (batch mode)](http://www.stata.com/support/faqs/unix/batch-mode/)
*  [`rmarkdown`](http://cran.r-project.org/web/packages/rmarkdown/) package in R
*  `stataknitrhelper.r` be accessible by the rmarkdown file (the default is to have it in the same directory)

> ##### NOTE
> I have an OS X system, so I suspect it will work on other \*NIX systems. I'm not sure about Windows.

## Set up

### Construct your stata do file 

It must run from top to bottom without error and save a log of the output. Also, every section that you want displayed should have a unique comment. `demo.do` is an example:

```
// log stata session with *.log file
log using "demo.log", replace

// load data
webuse school, clear

// create nominal income variable; summarize
gen inc = exp(loginc)
summarize inc

// list observations inc
list obs inc

// close log and exit
log close                               
exit
```

### Construct your knitr rmd file 
#### Call do file  

After setting any knitr chunk options that you want, call your do file with a knitr chunk that uses `engine = 'bash'` in the options:

```
## run accompanying .do file to get log file for parsing   
stata -b -q do demo.do
```

> ##### NOTE
> Your command line Stata call may be different from `stata`. If you have StataSE or StataMP and you haven't created a symlink using `stata`, you may need to call the command with `stata-se` or `stata-mp`.

#### Store log file

Store the log file in an object in the next knitr chunk:

```
## save log file in object
lf <- 'demo.log'
```

#### Parse log

To get the chunk you want, use `logparse()` wraped with `writeLines()` to grab the relevant part of the log file and print to output. The R function will take line numbers, but it's easiest to use with unique comments. If the comments aren't unique, the function should still run, but with undesired output:

```
start <- 'load data'
end <- 'create nominal income variable; summarize'
writeLines(logparse(lf, start = start, end = end))
```

> ##### NOTE
> The default option for `logparse()` is to drop the first and last lines when printing the pulled section. This is so the first and last comment aren't printed to the console when the comments are placed above, rather than inline with, the relevant code. If you use inline comments or want to show the first and last lines, set the `logparse` option `include = TRUE`.

## Set up with graphics

When called from the command line, Stata can only produce graphics in `*.ps` and `*.eps` format. I couldn't get rmarkdown to work with these files. To work around this, I include code at the beginning of the knitr document (in the BASH chunk just below the `stata ... ` call) that uses [ImageMagick](http://www.imagemagick.org/script/index.php) to convert the EPS files to PNG:

```
## convert plots used in this file to png
plotlist=(*.eps)
for i in ${plotlist[@]};
do
base=${i%.eps}
convert -density $dpi -flatten $base.eps $base.png;
done
```

This code finds all EPS files in the directory and converts them to PNG files with the same name. For it to work, the YAML frontmatter needs to include the `params:dpi` option and the following line in the first knitr setup chunk:

```
## set yaml params in environment
Sys.setenv(dpi = params$dpi)
```


To get files of different size, change the current density value of `150` to whatever you want in the `params` option of `rmarkdown::render()` (see below).

### Do file setup for plots

Make sure your do file exports images using the `graph export` command:

```
// create scatter of years by loginc; export to file
scatter years loginc, name(sc_yearsXloginc)
graph export "sc_yearsXloginc.eps", name(sc_yearsXloginc) replace
```

### Call plot in document

Call the plot in the rmarkdown document either with the standard `![]` command or, if you want to align it, using `alignfigure()` wrapped in `writeLines()` and using the `results = 'asis'` chunk option. Here is an example using the `demo_plots.rmd`:

```
writeLines(alignfigure('sc_yearsXloginc.png', 'center'))
```

## Run

To run, open an R session in the same directory as your RMD file and run `rmarkdown::render()`. Here's an example using `demo.rmd`:

```
rmarkdown::render('demo.rmd')
```

If you want to change the size of the image, you need to pass the change in the `render` options:

```
rmarkdown::render('demo.rmd', params = list(dpi = 300))
```

See the files in `demo_html` for examples HTML output.

## Styling options

Because Stata, unlike R, repeats the command in the output, I didn't want to echo the command as well. This means, by default, all the output code chunks were the same color as the backgroud. To add contrast, I change the CSS with the `custom.css` file. You can change as you like or remove the call from the YAML to use the default settings.








