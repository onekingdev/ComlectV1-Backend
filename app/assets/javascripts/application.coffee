#= require jquery
#= require jquery_ujs
#= require cocoon
#= require bootstrap/_loader
#= require bootstrap-multiselect/dist/js/bootstrap-multiselect
#= require pickadate/lib/picker
#= require pickadate/lib/picker.date
#= require pickadate/lib/picker.time
#= require bootbox.js/bootbox
#= require bootstrap3-typeahead/bootstrap3-typeahead
#= require jquery-mask-plugin/dist/jquery.mask
#= require ion.rangeSlider/js/ion.rangeSlider
#= require percircle/src/js/percircle
#= require accounting.js/accounting
#= require_self
#= require_tree ./utilities
#= require_tree ./components
#= require_tree ./application

# Custom content ready handler to encompass DOM and ajax loads
$.onContentReady = (callback) ->
  $ -> callback($(document))
  # Fire $(document).trigger('newContent', $parent) to trigger this
  # Alternatively: $(document).trigger('newContent', [$parent, {opt: 'abc', ...}]) to trigger this
  $(document).on 'newContent', (e, $parent, data) ->
    # Make sure it's jQuery object as sometimes we get in unwrapped
    callback $($parent), data

# $.onContentReady ($parent) ->
#   $.initializeOnce $parent.find('.my-element'), 'data-attr-to-store-init-status', ($myele) ->
#     $myele.customFunction()
$.initializeOnce = ($el, plugin, callback) ->
  dataName = "#{plugin}-initialized"
  return if $el.length == 0 || $el.data(dataName)
  callback $el
  $el.data dataName, true
