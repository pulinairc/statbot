# rss.tcl
#
#	RSS parser for Tcl
#
# Copyright (c) 2003, Tomoyasu Kobayashi, ether@users.sourceforge.jp
#
# For information on usage and redistribution, and for a DISCLAIMER OF ALL
# WARRANTIES, see the file "LICENSE.txt" in this distribution.  
#
# $Id: rss.tcl,v 1.6 2003/06/28 11:11:49 cvs Exp $
#

package provide rss 0.1

package require dom
package require struct
package require mime

namespace eval rss {
	variable domdoc
	variable channelcount 0
	variable itemcount 0
	variable imagecount 0
	variable textinputcount 0

	variable namespaces {
		rss {http://purl.org/rss/1.0/}
		rdf {http://www.w3.org/1999/02/22-rdf-syntax-ns#}
		dc	{http://purl.org/dc/elements/1.1/}
	}

	variable tree [struct::tree]

	proc makeproc {token} {
		proc $token {method args} [format {
			if {[catch "methods %s $method $args" result]} {
				return -code error $result
			} else {
				return $result
			}
		} $token]
	}

	proc innertext {node} {
		set ret {}
		foreach textnode [::dom::selectNode $node .//text()] {
			append ret [::dom::node cget $textnode -nodeValue]
		}
		return $ret
	}

	proc getliteral {node property} {
		variable namespaces
		set first [::dom::selectNode $node "$property\[1\]" -namespaces $namespaces]
		if {$first == ""} {
			return ""
		} else {
			return [innertext $first]
		}
	}

	proc parse {rawrss} {
		variable tree
		variable namespaces
		variable channelcount
		variable itemcount
		variable imagecount
		variable textinputcount

		set domdoc [::dom::DOMImplementation parse $rawrss]

		set root [::dom::document cget $domdoc -documentElement]
		set rootnodename [::dom::node cget $root -nodeName]

		if {$rootnodename == "rss"} {
			set xpath(channel)		{/rss/channel[1]}
			set xpath(title)		{title}
			set xpath(link)			{link}
			set xpath(description)	{description}
			set xpath(language)		{/rss/channel/language[1]}
			set xpath(url)			{url}
			set xpath(name)			{name}
			set xpath(items)		{/rss/channel/item}
			set xpath(item)			{/rss/channel/item[%s]}
			set xpath(image)		{/rss/channel/image[1]}
			set xpath(textinput)	{/rss/channel/textInput[1]}
		} elseif {$rootnodename == "RDF"} {
			set xpath(channel)		{/rdf:RDF/rss:channel[1]}
			set xpath(title)		{rss:title}
			set xpath(link)			{rss:link}
			set xpath(description)	{rss:description}
			set xpath(language)		{/rdf:RDF/rss:channel/dc:language[1]}
			set xpath(url)			{rss:url}
			set xpath(name)			{rss:name}
			set xpath(items)		{rss:items/rdf:Seq/rdf:li}
			set xpath(item)			{//rss:item[@rdf:about=/rdf:RDF/rss:channel/rss:items/rdf:Seq/rdf:li[%s]/@rdf:resource][1]}
			set xpath(image)		{//rss:image[@rdf:about=/rdf:RDF/rss:channel/rss:image/@rdf:resource[1]][1]}
			set xpath(textinput)	{//rss:textinput[@rdf:about=/rdf:RDF/rss:channel/rss:textinput/@rdf:resource[1]][1]}
		} else {
			error "invalid RSS: the root element must be either rss or rdf:RDF."
		}

		set channel [::dom::selectNode $domdoc $xpath(channel) -namespaces $namespaces]

		if {$channel == ""} {return ""}

		incr channelcount
		makeproc channel.$channelcount
		$tree insert root end channel.$channelcount
		$tree unset channel.$channelcount
		$tree set channel.$channelcount -key title [getliteral $channel $xpath(title)]
		$tree set channel.$channelcount -key link [getliteral $channel $xpath(link)]
		$tree set channel.$channelcount -key description [getliteral $channel $xpath(description)]
		$tree set channel.$channelcount -key language [getliteral $channel $xpath(language)]

		set numitems [llength [::dom::selectNode $channel $xpath(items) -namespaces $namespaces]]
		for {set i 1} {$i <= $numitems} {incr i} {
			set item [::dom::selectNode $channel [format $xpath(item) $i] -namespaces $namespaces]
			if {$item != ""} {
				incr itemcount
				makeproc item.$itemcount
				$tree insert channel.$channelcount end item.$itemcount
				$tree unset item.$itemcount
				$tree set item.$itemcount -key title [getliteral $item $xpath(title)]
				$tree set item.$itemcount -key link [getliteral $item $xpath(link)]
				$tree set item.$itemcount -key description [getliteral $item $xpath(description)]
			}
		}
		set image [::dom::selectNode $channel $xpath(image) -namespaces $namespaces]
		if {$image != ""} {
			incr imagecount
			makeproc image.$imagecount
			$tree insert channel.$channelcount end image.$imagecount
			$tree unset image.$imagecount
			$tree set image.$imagecount -key title [getliteral $image $xpath(title)]
			$tree set image.$imagecount -key url [getliteral $image $xpath(url)]
			$tree set image.$imagecount -key link [getliteral $image $xpath(link)]
		}
		set textinput [::dom::selectNode $channel $xpath(textinput) -namespaces $namespaces]
		if {$textinput != ""} {
			incr textinputcount
			makeproc textinput.$textinputcount
			$tree insert channel.$channelcount end textinput.$textinputcount
			$tree unset textinput.$textinputcount
			$tree set textinput.$textinputcount -key title [getliteral $textinput $xpath(title)]
			$tree set textinput.$textinputcount -key description [getliteral $textinput $xpath(description)]
			$tree set textinput.$textinputcount -key name [getliteral $textinput $xpath(name)]
			$tree set textinput.$textinputcount -key link [getliteral $textinput $xpath(link)]
		}

		return [namespace current]::channel.$channelcount
	}

	proc parsefile {rssfile} {
		set f [open $rssfile]
		fconfigure $f -encoding binary
		set initial [read $f 200]
		if {[regexp {^\s*<\?xml.*encoding="([^"]+)".*\?>} $initial match iana]} {
			set tclenc [::mime::reversemapencoding $iana]
			if {[string compare -nocase $iana "utf-8"] == 0} {
				set tclenc utf-8
			}
			if {$tclenc == ""} {
				error "Unknown character encoding: $iana"
			}
			fconfigure $f -encoding $tclenc
		} else {
			fconfigure $f -encoding utf-8
		}
		seek $f 0 start
		set rss [read $f]
		close $f
		regsub {^\s*<\?xml.*\?>} $rss {} rss
		return [parse $rss]
	}

	proc genRSS0.91node {domnode treenode} {
		variable tree

		set tagname(channel) channel
		set tagname(item) item
		set tagname(image) image
		set tagname(textinput) textinput

		set tagname(title) title
		set tagname(link) link
		set tagname(description) description
		set tagname(language) language
		set tagname(url) url
		set tagname(name) name

		regexp {^([A-Za-z]+)\.} $treenode match prefix

		set this [::dom::tcl::document createElement $domnode $tagname($prefix)]
		foreach {key value} [$tree getall $treenode] {
			if {$value != ""} {
				::dom::tcl::document createTextNode [::dom::tcl::document createElement $this $tagname($key)] $value
			}
		}

		if {![$tree isleaf $treenode]} {
			foreach child [$tree children $treenode] {
				genRSS0.91node $this $child
			}
		}
	}

	proc methods {token method args} {
		variable tree
		variable namespaces
		set argc [llength $args]

		if {$method == "delete"} {
			$tree delete $token
			return
		}

		switch -regexp $token {
			{^channel\.} {
				switch $method {
					title -
					link -
					description - 
					language {
						if {$argc == 0} {
							return [$tree get $token -key $method]
						} elseif {$argc == 1} {
							return [$tree set $token -key $method [lindex $args 0]]
						} else {
							return -code error "wrong # args: should be \"$token $method ?value?\""
						}
					}
					items {
						if {$argc == 0} {
							set children [$tree children $token]
							set items [list]
							foreach node $children {
								if {[regexp {^item\.} $node]} {
									lappend items [namespace current]::$node
								}
							}
							return $items
						} else {
							return -code error "wrong # args: should be \"$token $method\""
						}
					}
					image -
					textinput {
						if {$argc == 0} {
							set children [$tree children $token]
							foreach node $children {
								if {[regexp ^$method\\. $node]} {
									return [namespace current]::$node
								}
							}
							return ""
						} else {
							return -code error "wrong # args: should be \"$token $method\""
						}
					}
					serialize {
						switch [lindex $args 0] {
							rss0.91 {
								set doc [::dom::tcl::DOMImplementation createDocument {} rss {}]
								::dom::tcl::createDocumentType $doc rss {-//Netscape Communications//DTD RSS 0.91//EN} {http://my.netscape.com/publish/formats/rss-0.91.dtd} {}
								set root [::dom::tcl::document cget $doc -documentElement]
								::dom::tcl::element setAttribute $root version "0.91"
								genRSS0.91node $root $token
								return [::dom::tcl::DOMImplementation serialize $doc]
							}
							rss1.0 {
								return -code error "serialize as RSS1.0: not implemented yet."
							}
							default {
								return -code error "bad option \"[lindex $args 0]\": must be rss0.91 or rss1.0"
							}
						}
					}
				}
			}
			{^item\.} {
				switch $method {
					title -
					link -
					description {
						set argc [llength $args]
						if {$argc == 0} {
							return [$tree get $token -key $method]
						} elseif {$argc == 1} {
							return [$tree set $token -key $method [lindex $args 0]]
						} else {
							return -code error "wrong # args: should be \"$token $method ?value?\""
						}
					}
				}
			}
			{^image\.} {
				switch $method {
					title -
					url -
					link {
						set argc [llength $args]
						if {$argc == 0} {
							return [$tree get $token -key $method]
						} elseif {$argc == 1} {
							return [$tree set $token -key $method [lindex $args 0]]
						} else {
							return -code error "wrong # args: should be \"$token $method ?value?\""
						}
					}
				}
			}
			{^textinput\.} {
				switch $method {
					title -
					description -
					name -
					link {
						set argc [llength $args]
						if {$argc == 0} {
							return [$tree get $token -key $method]
						} elseif {$argc == 1} {
							return [$tree set $token -key $method [lindex $args 0]]
						} else {
							return -code error "wrong # args: should be \"$token $method ?value?\""
						}
					}
				}
			}
		}
	}
}
