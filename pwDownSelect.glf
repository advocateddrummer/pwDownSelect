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

# This procedure returns all the quilts that make up the model(s) passed in
# modelList.
proc DownSelectModels { modelList } {
  set quilts [list]
  foreach m $modelList {
    lappend quilts {*}[$m getQuilts]
    #puts "model $m contains quilts: [$m getQuilts]"
  }

  return [lsort -unique $quilts]
}

# This procedure returns all the boundaries that make up the quilt(s) passed in
# quiltList.
proc DownSelectQuilts { quiltList } {
  set boundaries [list]
  foreach q $quiltList {
    lappend boundaries {*}[$q getBoundaries]
    #puts "quilt $q contains boundaries: [$q getBoundaries]"
  }

  return [lsort -unique $boundaries]
}

# This procedure filters the database(s) pass in databaseList and calls either
# the DownSelectModels or DownSelectQuilts procedure, bases on what it finds
# therein. Models are preferred to quilts.
proc DownSelectDatabases { databaseList } {

  set nModels 0
  set models [list]
  set nQuilts 0
  set quilts [list]

  foreach d $databaseList {
    set type [$d getType]
    if { $type == "pw::Model" } {
      incr nModels
      lappend models $d
    } elseif { $type == "pw::Quilt" } {
      incr nQuilts
      lappend quilts $d
    }
  }
  #puts "     found $nModels models and $nQuilts quilts"

  set selection [list]

  # Models override quilts for now...
  if { $nModels > 0 } {
    #puts "          Down selecting models"
    set selection [lsort -unique [DownSelectModels $models]]
    puts "     selected [llength $selection] quilts"
  } elseif { $nQuilts > 0 } {
    #puts "          Down selecting quilts"
    set selection [lsort -unique [DownSelectQuilts $quilts]]
    puts "     selected [llength $selection] boundaries"
  } else {
    puts "Error: something went wrong in DownSelectDatabases"
  }

  return $selection
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
# present them with a dialog to let them select which they want to use.

# This variable holds the grid/database entities that will be 'selected' when
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
  puts "Down selecting Databases..."
  set downSelection [DownSelectDatabases $databases]
} else {
  puts "ERROR: No valid entities to operate on, exiting"
  exit
}

pw::Display setSelectedEntities $downSelection
pw::Display update

exit

# vim: set ft=tcl:
