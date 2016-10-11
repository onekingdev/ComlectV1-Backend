$(document).on 'change', '#stripe_account_account_type_individual, #stripe_account_account_type_business', (e) ->
  $this = $(this)
  $this.parents('form').attr('data-account-type', $this.val())

$(document).on 'click', '.js-specialist-payment-settings', (e) ->
  e.preventDefault()
  _Modal.showPlain $('#specialist-payment-choose-country')
  handleDisabledCompanyType()

individualOnlyCountries = ['AT', 'BE', 'DE', 'DK', 'ES', 'FI', 'FR', 'GB', 'IE', 'IT', 'LU', 'NL', 'NO', 'PT', 'SE', 'SG']

handleDisabledCompanyType = ->
  $country = $('#specialist-payment-choose-country #stripe_account_country')
  if individualOnlyCountries.indexOf($country.val()) >= 0
    $('#stripe_account_account_type')
      .multiselect 'select', 'individual'
      .multiselect 'disable'
  else
    $('#stripe_account_account_type')
      .multiselect 'enable'

$(document).on 'change', '#specialist-payment-choose-country #stripe_account_country', handleDisabledCompanyType

