bind pub - * annavoicet
proc annavoicet {nick chan} {
pushmode $chan +v $nick
}
bind time - "* */5 * * *" vievoicet
proc vievoicet {nick chan} {

pushmode $chan -v $nick
}
putlog "Script loaded: \002Rollen voicettaja 0.1\002"

