$(document).on 'confirm', '[data-confirm]', (e) ->
  e.stopImmediatePropagation()
  $this = $(this)
  options =
    message: $this.data('confirm')
    backdrop: true
    closeButton: if $this.data('close-button')? then $this.data('close-button') else true
    className: 'confirm'
    buttons:
      cancel:
        label: $this.data('cancel-label') || 'Cancel'
        className: 'btn-default btn-md'
      confirm:
        label: $this.data('confirm-label') || 'Ok'
        className: 'btn-primary btn-md'
        callback: ->
          $.rails.handleMethod($this)

  options.title = $this.attr('title') if $this.attr('title') && $this.attr('title').length > 0
  bootbox.dialog options
  return false
