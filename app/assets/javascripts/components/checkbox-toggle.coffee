$(document).on 'click', 'input[type=checkbox][data-toggle-all]', (e) ->
  $this = $(this)
  selector = "input[name=\"#{$this.data('toggle-all')}\"]"
  $(selector)
    .prop 'checked', $this.is(':checked')
    .attr 'checked', if $this.is(':checked') then 'checked' else null
    .change ->
      all = $("#{selector}:checked").length == $("#{selector}").length
      $this.prop 'checked', all
