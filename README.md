# Pointwise 'Down Select' Glyph Script

The purpose of this script is to allow the user to easily _down select_ on
provided entities. What this means is that _lower order_ entities are
returned/selected by the script; i.e., if a domain is provided, all connectors
that define the domain are returned by the script and will be the current
active selection in Pointwise when it completes. Or, if a block is provided,
all associated domains will be returned and actively selected by the script.

For completeness, if a model is passed to the script, its quilts are selected,
and if a quilt or quilts are provided, associated database boundaries are
selected.  The database functionality of this script is a little more
complicated and less used/tested.
