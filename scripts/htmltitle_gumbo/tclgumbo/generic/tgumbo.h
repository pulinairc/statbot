#ifndef _TCLGUMBO
#define _TCLGUMBO

#include <tcl.h>


/*
 * For C++ compilers, use extern "C"
 */

#ifdef __cplusplus
extern "C" {
#endif


/*
 * Only the _Init function is exported.
 */

extern DLLEXPORT int	Tclgumbo_Init(Tcl_Interp * interp);

int tcl_gumbo_parse _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_destroy_output _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_output_get_root _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_node_get_type _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_element_get_tag_name _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_element_get_children _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_text_get_text _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_element_get_attributes _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_element_get_tag_open _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));
int tcl_gumbo_element_get_tag_close _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]));


void Tclgunbo_InitHashTable _ANSI_ARGS_(());


/*
 * end block for C++
 */

#ifdef __cplusplus
}
#endif

#endif /* _TCLGUMBO */
