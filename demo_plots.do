////////////////////////////////////////////////////////////////////////////////
//
// stataknitr: demo_plots.do file
//
////////////////////////////////////////////////////////////////////////////////
        
// log stata session with *.log file
log using "demo_plots.log", replace

// load in data
webuse school, clear

// create histogram of years in residence with name; export to file
histogram years, name(hist_years)
graph export "hist_years.eps", name(hist_years) replace

// create scatter of years by loginc; export to file
scatter years loginc, name(sc_yearsXloginc)
graph export "sc_yearsXloginc.eps", name(sc_yearsXloginc) replace

// close log and exit
log close                               
exit                                  
