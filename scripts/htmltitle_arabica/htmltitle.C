/* This file is hereby placed in the public domain. There is no warranty. */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tcl.h>
#include <arabica/Taggle/Taggle.hpp>
#include <arabica/SAX/SAXException.hpp>
#include <iostream>

#ifndef CONST84
#	define CONST84
#endif

volatile static char const rcsid[] = "$Id: htmltitle.C,v 1.3 2014/01/01 17:44:36 nerv Exp nerv $";

extern "C" {
	Tcl_CmdProc Tcl_htmltitle;
	int Htmltitle_Init(Tcl_Interp *interp);
}

class Enough : public Arabica::SAX::SAXException
{
public:
	Enough() : Arabica::SAX::SAXException("Enough") {}
};

class SAXHandler : public Arabica::SAX::DefaultHandler<std::string> 
{
public:
	SAXHandler() : state(ROOT) {};
	virtual void startElement(const std::string& namespaceURI, const std::string& localName,
		const std::string& qName, const AttributesT& atts);
	virtual void characters(const std::string& ch);

#if 0
	virtual void endElement(const std::string& namespaceURI, const std::string& localName,
		const std::string& qName);
#endif


	std::string title;
private:
	int state;

	enum {
		ROOT,
		HTML,
		HEAD,
		TITLE
	};
};

void SAXHandler::startElement(
	const std::string& namespaceURI,
	const std::string& localName,
	const std::string& qName,
	const AttributesT& atts
)
{
	if (  state == ROOT && localName == "html"
	   || state == HTML && localName == "head"
	   || state == HEAD && localName == "title")
		state++;
	else if (localName == "body")
		throw Enough();
}

#if 0
void SAXHandler::endElement(
	const std::string& namespaceURI,
	const std::string& localName,
	const std::string& qName
)
{
	//std::cout << "namespace: " << namespaceURI << "\nlocalName: " << localName << "\nqName: " << qName << std::endl;
	std::cout << "end: " << localName << std::endl;
}
#endif

void SAXHandler::characters(const std::string& ch)
{
	if (state == TITLE)
		title.append(ch);
}


int Htmltitle_Init(Tcl_Interp *interp)
{
	Tcl_PkgProvide(interp, "Htmltitle", "1");
	Tcl_CreateCommand(interp, "htmltitle", Tcl_htmltitle, NULL, NULL);

	if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
		return TCL_ERROR;
	}

	return TCL_OK;
}

int Tcl_htmltitle(ClientData dummy, Tcl_Interp *interp, int argc, CONST84 char *argv[])
{
	char const error[] = "Wrong # args: usage is \"htmtitle str\"";
	char *title;

	if (argc != 2) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(error, -1));
		return TCL_ERROR;
	}

	std::istringstream stream(argv[1]);
	Arabica::SAX::Taggle<std::string> parser;
	Arabica::SAX::InputSource<std::string> is(stream);
	SAXHandler handler;

	parser.setContentHandler(handler);
	
	try {
		parser.parse(is);
	} catch (Enough e) {
	} catch (Arabica::SAX::SAXException e) {
		goto Out;
	}

	Tcl_SetObjResult(interp, Tcl_NewStringObj(handler.title.c_str(), -1));

Out:
	return TCL_OK;
}

