$(document).on 'change', '#project_type_one_off, #project_type_full_time', (e) ->
  $this = $(this)
  $this.parents('form').attr('data-project-type', $this.val())

$(document).on 'change', '#project_pricing_type_hourly, #project_pricing_type_fixed', (e) ->
  $this = $(this)
  $this.parents('.project-pricing').attr('data-pricing-type', $this.val())

$(document).on 'change', '#project_location_type', (e) ->
  $this = $(this)
  $this.parents('.project-details').attr('data-location-type', $this.val())

do ->
  one_day = 86400000
  parents = ['.project_fixed_payment_schedule', '.project_hourly_payment_schedule']
  selector = '.multiselect-container input[type=radio][value=%value]'
  $(document).on 'change', '#project_starts_on, #project_ends_on', (e) ->
    starts = $("#project_starts_on").pickadate('picker').get('select')
    ends = $("#project_ends_on").pickadate('picker').get('select')
    return unless starts? && ends?

    diff = ends.obj - starts.obj
    # .project_fixed|hourly_payment_schedule
    parentSelector = ".project_#{$('.project-pricing[data-pricing-type]').attr('data-pricing-type')}_payment_schedule"
    for parent in parents
      $(parent).find(selector.replace('%value', 'upon-completion')).parents('li').removeClass('hidden')
      $(parent).find(selector.replace('%value', 'monthly')).parents('li').removeClass('hidden')
    if diff < (one_day * 14)
      for parent in parents
        $(parent).find(selector.replace('%value', 'monthly')).parents('li').addClass('hidden')
    if diff > (one_day * 30)
      for parent in parents
        $(parent).find(selector.replace('%value', 'upon-completion')).parents('li').addClass('hidden')

# Skills tag selection
$.onContentReady ($parent) ->
  $typeahead = $parent.find('#project_skill_selector')
  return if $typeahead.length == 0 || $typeahead.data('typeahead-initialized')
  selected = {}
  $tags = $parent
            .find('.skills-required')
            .on 'click', '.remove', ->
              $this = $(this)
              selected[$this.data('skill')] = undefined
              $this.parents('li').remove()
  inputTpl = "<li><input type='hidden' name='project[skill_names][]' value='%VALUE%' /><span>%LABEL%</span><span data-skill='%VALUE%' class='remove'>x</span></li>"

  $typeahead.typeahead
    delay: 200
    source: (query, process) ->
      $.getJSON $typeahead.data('source'), { q: query }, (data) ->
        pound = if query[0] == '#' then '' else '#'
        name = "#{pound}#{query}"
        exists = (i for i in data when i.name is name)[0]
        data = [{ name: name }].concat(data) unless exists
        # Remove items already selected
        data = (i for i in data when selected[i.name] is undefined)
        process data
    updater: (item) ->
      $input = $(inputTpl.replace('%LABEL%', item.name).replace('%VALUE%', item.name))
      selected[item.name] = true
      $tags.append $input
      return # Don't display anything on the input

  $typeahead.data 'typeahead-initialized', true
