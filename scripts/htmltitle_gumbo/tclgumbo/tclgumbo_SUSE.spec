%{!?directory:%define directory /usr}

%define buildroot %{_tmppath}/%{name}

Name:          tclgumbo
Summary:       Tcl interface for Gumbo library
Version:       0.1
Release:       1
License:       BSD
Group:         Development/Libraries/Tcl
Source:        https://sites.google.com/site/ray2501/tclgumbo/tclgumbo_0.1.tar.gz
URL:           https://sites.google.com/site/ray2501/tclgumbo 
Buildrequires: tcl >= 8.1
BuildRoot:     %{buildroot}

%description
Tcl interface for Gumbo library.

Gumbo is an implementation of the [HTML5 parsing algorithm] implemented
as a pure C99 library with no outside dependencies.  It's designed to serve
as a building block for other tools and libraries such as linters,
validators, templating languages, and refactoring and analysis tools.

%prep
%setup -q -n %{name}

%build
CFLAGS="%optflags" ./configure \
	--prefix=%{directory} \
	--exec-prefix=%{directory} \
	--libdir=%{directory}/%{_lib}
make 

%install
make DESTDIR=%{buildroot} pkglibdir=%{directory}/%{_lib}/tcl/%{name}%{version} install

%clean
rm -rf %buildroot

%files
%defattr(-,root,root)
%{directory}/%{_lib}/tcl
