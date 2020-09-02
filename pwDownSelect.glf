package require PWI_Glyph
pw::Script loadTk

# This procedure returns all the connectors that make up the domain(s) passed
# in domainList.
proc DownSelectDomains { domainList } {

  set edges [list]
  foreach d $domainList {
    lappend edges {*}[$d getEdges]
    #puts "domain $d contains edges: [$d getEdges]"
  }

  set connectors [list]
  foreach e $edges {
  # This strange syntax creates a flat list.
    lappend connectors {*}[$e getConnectors]
    #puts "edge $e contains connectors: [$e getConnectors]"
  }

  #pw::Display setSelectedEntities $connectors
  #pw::Display update

  return [lsort -unique $connectors]
}

# This procedure returns all the domains that make up the block(s) passed in
# blockList.
proc DownSelectBlocks { blockList } {

  set faces [list]
  foreach b $blockList {
    lappend faces {*}[$b getFaces]
    #puts "block $b contains faces: [$b getFaces]"
  }

  set domains [list]
  foreach f $faces {
  # This strange syntax creates a flat list.
    lappend domains {*}[$f getDomains]
    #puts "face $f contains domains: [$f getDomains]"
  }

  #pw::Display setSelectedEntities $domains
  #pw::Display update

  return [lsort -unique $domains]
}

#
# Use selected entity or prompt user for selection if nothing is selected at
# run time. Currently only Blocks, Domains, and Databases are supported.
#
set mask [pw::Display createSelectionMask -requireDomain {} -requireBlock {} -requireDatabase {} -blockConnector {} -blockSpacing {} -blockSource {}]

if { !([pw::Display getSelectedEntities -selectionmask $mask selection]) } {
  # No entity was selected at runtime; prompt for one now.

  if { !([pw::Display selectEntities \
         -selectionmask $mask \
         -description "Select entity/entities" \
       selection]) } {

    puts "Error: Unsuccessfully selected entity... exiting"
    exit
  }
}

# Get all selected entities.
set domains    $selection(Domains)
set blocks     $selection(Blocks)
set databases  $selection(Databases)

# Get entity counts.
set nDomains   [llength $domains]
set nBlocks    [llength $blocks]
set nDatabases [llength $databases]

puts "Selection summary"
puts "###########################################################################"
puts "Number of domains:   $nDomains"
puts "Number of blocks:    $nBlocks"
puts "Number of databases: $nDatabases"
puts "###########################################################################"

# TODO: implement a way for the user to specify what type of entity they want
# to 'select down' with. I.e., if they've selected multiple types of entities,
# present them with a dialog to let them select which the want to use.

# This variable holds the grid/database entities that well be 'selected' when
# this script completes.
set downSelection [list]

# For now, only act on the first list with anything in it. It is possible that
# several different types of entities have been selected and passed to this
# script.
if { $nDomains > 0 } {
  puts "Down selecting Domains..."
  set downSelection [DownSelectDomains $domains]
  puts "     selected [llength $downSelection] connectors"
} elseif { $nBlocks > 0 } {
  puts "Down selecting Blocks..."
  set downSelection [DownSelectBlocks $blocks]
  puts "     selected [llength $downSelection] domains"
} elseif { $nDatabases > 0 } {
  puts "TODO: Processing Databases..."
  exit
} else {
  puts "ERROR: No valid entities to operate on, exiting"
  exit
}

pw::Display setSelectedEntities $downSelection
pw::Display update

exit

# vim: set ft=tcl:
