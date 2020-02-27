# if you installed Arabica or Tcl in your home directory, change the path(s) below.
ARABICA_PREFIX=	/usr/local
ARABICA_INC=	-I$(ARABICA_PREFIX)/include/arabica
ARABICA_LIB=	-L$(ARABICA_PREFIX)/lib -Wl,-rpath,$(ARABICA_PREFIX)/lib -larabica
TCL_PREFIX=	/usr
TCL_INC=	-I$(TCL_PREFIX)/include/tcl8.5
TCL_LIB=	
# You can probably stop here.

CXXFLAGS=	-fPIC $(ARABICA_INC) $(TCL_INC)
LDFLAGS=	-shared
LIBS=		$(ARABICA_LIB) $(TCL_LIB)

htmltitle.so: htmltitle.o
	$(CXX) $(LDFLAGS) $< -o $@ $(LIBS)

clean:
	rm -f htmltitle.o htmltitle.so
