# if you installed Arabica or Tcl in your home directory, change the path(s) below.
GUMBO_INC=	$(shell pkg-config --cflags gumbo)
GUMBO_LIB=	$(shell pkg-config --libs gumbo)
TCL_PREFIX=	/usr
TCL_INC=	-I$(TCL_PREFIX)/include/tcl8.5
TCL_LIB=	
# You can probably stop here.

CFLAGS=		-std=c99 -fPIC $(GUMBO_INC) $(TCL_INC)
LDFLAGS=	-shared
LIBS=		$(GUMBO_LIB) $(TCL_LIB)

htmltitle.so: htmltitle.o
	$(CC) $(LDFLAGS) -o $@ $< $(LIBS)

clean:
	rm -f htmltitle.o htmltitle.so
