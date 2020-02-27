source eggsim.tcl
source urlmagic.tcl

namespace eval urlmagic {
	set twitter(username) pulinainfo
	set twitter(password) lk3kRBk6i
	twitter_login
	after 2000 {tweet "Test tweet. Hello from #Tcl!"}
}