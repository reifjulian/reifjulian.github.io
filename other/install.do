
foreach cmd in appendfile autorename regsave rscript sortobs strgroup svret texsave wyoung {

	ssc install `cmd', replace
	
	* Uncomment the following line to install the latest developer's version
	*net install `cmd', from("https://raw.githubusercontent.com/reifjulian/`cmd'/master") replace
}
