// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Author: jdtang@google.com (Jonathan Tang)
// Author (TCL): Moritz Wilhelmy, mw at barfooze dot de
//
// Retrieves the title of a page.
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tcl.h>
#include <gumbo.h>

#ifndef CONST84
#	define CONST84
#endif

volatile static char const rcsid[] = "$Id: htmltitle.C,v 1.3.1.1 2014/01/01 19:17:17 nerv Exp nerv $";

Tcl_CmdProc Tcl_htmltitle;
int Htmltitle_Init(Tcl_Interp *interp);

int Htmltitle_Init(Tcl_Interp *interp)
{
	Tcl_PkgProvide(interp, "Htmltitle", "1");
	Tcl_CreateCommand(interp, "htmltitle", Tcl_htmltitle, NULL, NULL);

	if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
		return TCL_ERROR;
	}

	return TCL_OK;
}

#if 1 /* part of the gumbo examples folder */
#define assert(x) if (!(x)) return "";
static const char* find_title(const GumboNode* root) {
  assert(root->type == GUMBO_NODE_ELEMENT);
  assert(root->v.element.children.length >= 2);

  const GumboVector* root_children = &root->v.element.children;
  GumboNode* head = NULL;
  for (int i = 0; i < root_children->length; ++i) {
    GumboNode* child = root_children->data[i];
    if (child->type == GUMBO_NODE_ELEMENT &&
        child->v.element.tag == GUMBO_TAG_HEAD) {
      head = child;
      break;
    }
  }
  assert(head != NULL);

  GumboVector* head_children = &head->v.element.children;
  for (int i = 0; i < head_children->length; ++i) {
    GumboNode* child = head_children->data[i];
    if (child->type == GUMBO_NODE_ELEMENT &&
        child->v.element.tag == GUMBO_TAG_TITLE) {
      if (child->v.element.children.length != 1) {
        return "";
      }
      GumboNode* title_text = child->v.element.children.data[0];
      assert(title_text->type == GUMBO_NODE_TEXT);
      return title_text->v.text.text;
    }
  }
  return "";
}
#undef assert
#endif

int Tcl_htmltitle(ClientData dummy, Tcl_Interp *interp, int argc, CONST84 char *argv[])
{
	char const error[] = "Wrong # args: usage is \"htmltitle str\"";

	if (argc != 2) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(error, -1));
		return TCL_ERROR;
	}

	size_t input_length = strlen(argv[1]);
	GumboOutput* output = gumbo_parse_with_options(
			&kGumboDefaultOptions, argv[1], input_length);
	const char* title = find_title(output->root);

	Tcl_SetObjResult(interp, Tcl_NewStringObj(title, -1));

	gumbo_destroy_output(&kGumboDefaultOptions, output);

	return TCL_OK;
}

