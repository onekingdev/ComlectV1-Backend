$(document).on 'change', '.form-timesheet .timesheet_time_logs_hours input', (e) ->
  $hours = $('#js-timesheet-total-hours')
  totalHours = 0
  $('.timesheet_time_logs_hours input').each ->
    totalHours += parseFloat($(this).val())
  $hours.html "#{totalHours} Hours"

  $due = $('#js-timesheet-total-due')
  if $due.length > 0
    rate = parseFloat($due.parent().data('rate'))
    $due.html accounting.formatMoney rate * totalHours
