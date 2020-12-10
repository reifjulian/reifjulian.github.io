
foreach cmd in appendfile autorename regsave rscript sortobs strgroup svret texsave wyoung {

	ssc install `cmd', replace
	
	* Uncomment the following line to install the latest developer's version, which in some cases may be more recent that what is currently available on SSC
	*net install `cmd', from("https://raw.githubusercontent.com/reifjulian/`cmd'/master") replace
}
