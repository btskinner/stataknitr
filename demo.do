////////////////////////////////////////////////////////////////////////////////
//
// stataknitr: demo.do file
//
////////////////////////////////////////////////////////////////////////////////
        
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
