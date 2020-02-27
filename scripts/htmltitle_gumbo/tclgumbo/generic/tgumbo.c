#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "tgumbo.h"
#include "gumbo.h"

Tcl_HashTable *gumbo_hashtblPtr;
int gumbo_count = 0;
int gumbo_root_count = 0;
int gumbo_node_count = 0;


/*!
 * This program use a static Hash table to maintain pointer and Tcl handle
 * mapping. Initial our Hash table here
 */
void Tclgunbo_InitHashTable()
{
    gumbo_hashtblPtr = (Tcl_HashTable *) malloc (sizeof(Tcl_HashTable));

    Tcl_InitHashTable(gumbo_hashtblPtr, TCL_STRING_KEYS);
}



int tcl_gumbo_parse _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{    
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;    
    char *htmltext = NULL;
    char handleName[16 + TCL_INTEGER_SPACE];
    int newvalue;
    GumboOutput* output;
    
    TCL_DECLARE_MUTEX(myMutex);

    
    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "HtmlString");
        return TCL_ERROR;
    }

    htmltext = Tcl_GetString(obj[1]);
    
    
    output = gumbo_parse(htmltext);
        
    
    Tcl_MutexLock(&myMutex);
    sprintf( handleName, "gumbo%d", gumbo_count++ );
    Tcl_MutexUnlock(&myMutex);    
    
    
    returnvalue = Tcl_NewStringObj( handleName, -1 );

    hashEntryPtr = Tcl_CreateHashEntry(gumbo_hashtblPtr, handleName, &newvalue);
    Tcl_SetHashValue(hashEntryPtr, output);

    Tcl_SetObjResult(interp, returnvalue);     
    
    
    return TCL_OK;
}


int tcl_gumbo_destroy_output _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{    
    Tcl_HashEntry *hashEntryPtr;
    char *handle;    
    GumboOutput* output;    


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_output");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    


    output = Tcl_GetHashValue( hashEntryPtr );  

    gumbo_destroy_output(&kGumboDefaultOptions, output);    


    return TCL_OK;
}


int tcl_gumbo_output_get_root _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;  
    GumboOutput* output;
    GumboNode* root;
    char handleName[16 + TCL_INTEGER_SPACE];
    char *handle;    
    int newvalue;   

    TCL_DECLARE_MUTEX(myMutex);


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_output");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo output handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    output = (GumboOutput*) Tcl_GetHashValue( hashEntryPtr );     
    
    
    root = output->root;

    Tcl_MutexLock(&myMutex);  
    sprintf( handleName, "gumbo_root%d", gumbo_root_count++); 
    Tcl_MutexUnlock(&myMutex);  

    returnvalue = Tcl_NewStringObj( handleName, -1 );

    hashEntryPtr = Tcl_CreateHashEntry(gumbo_hashtblPtr, handleName, &newvalue);
    Tcl_SetHashValue(hashEntryPtr, root);

    Tcl_SetObjResult(interp, returnvalue);
    

    return TCL_OK;
}


int tcl_gumbo_node_get_type _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;    
    GumboNode *node;
    char *handle;  
    long nodetype;


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr );  
    
    nodetype = node->type;    
    
    
    returnvalue = Tcl_NewLongObj(nodetype);    
    Tcl_SetObjResult(interp, returnvalue);
    
    return TCL_OK;  
}


int tcl_gumbo_element_get_tag_name _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;    
    GumboNode *node;
    char *handle;  
    const char *tag_name;


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr );  
    
    if ( node->type != GUMBO_NODE_ELEMENT ) {
        return TCL_ERROR;
    }    


    tag_name = gumbo_normalized_tagname(node->v.element.tag);
    
    returnvalue = Tcl_NewStringObj( tag_name, -1 );
    Tcl_SetObjResult(interp, returnvalue);
    
    
    return TCL_OK;  
}


int tcl_gumbo_element_get_children _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *listobj;  
    Tcl_Obj *returnvalue;  
    GumboNode *node;
    char handleName[16 + TCL_INTEGER_SPACE];
    char *handle;
    int newvalue;
    
    TCL_DECLARE_MUTEX(myMutex);    


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr );
    
    if ( node->type != GUMBO_NODE_ELEMENT ) {
        return TCL_ERROR;
    }     
    
    
    listobj = Tcl_NewListObj(0, NULL);
    
    GumboVector *children = &node->v.element.children;
    for ( int i = 0; i < children->length; i++ ) {
        GumboNode *children_node = children->data[i];
        
	Tcl_MutexLock(&myMutex);  
        sprintf( handleName, "gumbo_node%d", gumbo_node_count++); 
        Tcl_MutexUnlock(&myMutex); 
	
	returnvalue = (Tcl_Obj *) Tcl_NewStringObj( handleName, -1 );
		
        Tcl_ListObjAppendElement(interp, listobj, returnvalue);

        hashEntryPtr = Tcl_CreateHashEntry(gumbo_hashtblPtr, handleName, &newvalue);
        Tcl_SetHashValue(hashEntryPtr, children_node);
    }    
    

    Tcl_SetObjResult(interp, listobj);
    
    return TCL_OK;  
}


int tcl_gumbo_text_get_text _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;    
    GumboNode *node;
    char *handle;  
    const char *text;


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr );  
    
    if ( node->type != GUMBO_NODE_TEXT ) {
        return TCL_ERROR;
    }    


    text = node->v.text.text;
    
    returnvalue = Tcl_NewStringObj( text, -1 );
    Tcl_SetObjResult(interp, returnvalue);
    
    
    return TCL_OK; 
}


int tcl_gumbo_element_get_attributes _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;    
    Tcl_Obj *returnvalue, *nameobj, *valueobj;    
    GumboNode *node;
    char *handle;


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr ); 
    
    if ( node->type != GUMBO_NODE_ELEMENT ) {
        return TCL_ERROR;
    }    
    
    
    returnvalue = Tcl_NewStringObj( "attribute", -1 );
    
    GumboVector * attributes = &node->v.element.attributes;
    for ( int i = 0; i < attributes->length; i++ ) {
        GumboAttribute * attribute = attributes->data[ i ];
	
	nameobj = Tcl_NewStringObj(  attribute->name, -1 );
	valueobj = Tcl_NewStringObj(  attribute->value, -1 );
	Tcl_ObjSetVar2 (interp, returnvalue, nameobj, valueobj, 0);
    }    
    
    Tcl_SetObjResult(interp, returnvalue);    


    return TCL_OK;  
}


int tcl_gumbo_element_get_tag_open _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;    
    GumboNode *node;
    char *handle;  


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr );  
    
    if ( node->type != GUMBO_NODE_ELEMENT ) {
        return TCL_ERROR;
    }    


    GumboElement *element = &node->v.element;
    GumboStringPiece *openTag = &element->original_tag;
    
    returnvalue = Tcl_NewStringObj( openTag->data, -1 );
    Tcl_SetObjResult(interp, returnvalue);
    
      
    return TCL_OK;  
}


int tcl_gumbo_element_get_tag_close _ANSI_ARGS_((ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST obj[]))
{
    Tcl_HashEntry *hashEntryPtr;
    Tcl_Obj *returnvalue;    
    GumboNode *node;
    char *handle;  


    if(objc != 2)
    {
        Tcl_WrongNumArgs(interp, 1, obj, "Gumbo_node");
        return TCL_ERROR;
    }


    handle = Tcl_GetString(obj[1]);
    hashEntryPtr = Tcl_FindHashEntry( gumbo_hashtblPtr, handle );    
    
    if( !hashEntryPtr ) {
        if( interp ) {
            Tcl_Obj *resultObj = Tcl_GetObjResult( interp );

            Tcl_AppendStringsToObj( resultObj, "invalid gumbo node handle ", handle, (char *)NULL );
        }

        return TCL_ERROR;
    }    

    node = (GumboNode *) Tcl_GetHashValue( hashEntryPtr );  
    
    if ( node->type != GUMBO_NODE_ELEMENT ) {
        return TCL_ERROR;
    }    


    GumboElement * element = &node->v.element;
    GumboStringPiece * closeTag = &element->original_end_tag;
    
    returnvalue = Tcl_NewStringObj( closeTag->data, -1 );
    Tcl_SetObjResult(interp, returnvalue);
    
      
    return TCL_OK;  
}
