#= require best_in_place
#= require jquery-ui
#= require jquery-ui-timepicker-addon

TIMEZONES = $.parseJSON("[{\"value\":\"-11:00\",\"label\":\"American Samoa\"},{\"value\":\"-11:00\",\"label\":\"International Date Line West\"},{\"value\":\"-11:00\",\"label\":\"Midway Island\"},{\"value\":\"-11:00\",\"label\":\"Samoa\"},{\"value\":\"-10:00\",\"label\":\"Hawaii\"},{\"value\":\"-09:00\",\"label\":\"Alaska\"},{\"value\":\"-08:00\",\"label\":\"Pacific Time (US \\u0026 Canada)\"},{\"value\":\"-08:00\",\"label\":\"Tijuana\"},{\"value\":\"-07:00\",\"label\":\"Arizona\"},{\"value\":\"-07:00\",\"label\":\"Chihuahua\"},{\"value\":\"-07:00\",\"label\":\"Mazatlan\"},{\"value\":\"-07:00\",\"label\":\"Mountain Time (US \\u0026 Canada)\"},{\"value\":\"-06:00\",\"label\":\"Central America\"},{\"value\":\"-06:00\",\"label\":\"Central Time (US \\u0026 Canada)\"},{\"value\":\"-06:00\",\"label\":\"Guadalajara\"},{\"value\":\"-06:00\",\"label\":\"Mexico City\"},{\"value\":\"-06:00\",\"label\":\"Monterrey\"},{\"value\":\"-06:00\",\"label\":\"Saskatchewan\"},{\"value\":\"-05:00\",\"label\":\"Bogota\"},{\"value\":\"-05:00\",\"label\":\"Eastern Time (US \\u0026 Canada)\"},{\"value\":\"-05:00\",\"label\":\"Indiana (East)\"},{\"value\":\"-05:00\",\"label\":\"Lima\"},{\"value\":\"-05:00\",\"label\":\"Quito\"},{\"value\":\"-04:30\",\"label\":\"Caracas\"},{\"value\":\"-04:00\",\"label\":\"Atlantic Time (Canada)\"},{\"value\":\"-04:00\",\"label\":\"Georgetown\"},{\"value\":\"-04:00\",\"label\":\"La Paz\"},{\"value\":\"-04:00\",\"label\":\"Santiago\"},{\"value\":\"-03:30\",\"label\":\"Montevideo\"},{\"value\":\"-03:30\",\"label\":\"Newfoundland\"},{\"value\":\"-03:00\",\"label\":\"Brasilia\"},{\"value\":\"-03:00\",\"label\":\"Buenos Aires\"},{\"value\":\"-03:00\",\"label\":\"Greenland\"},{\"value\":\"-02:00\",\"label\":\"Mid-Atlantic\"},{\"value\":\"-01:00\",\"label\":\"Azores\"},{\"value\":\"-01:00\",\"label\":\"Cape Verde Is.\"},{\"value\":\"+00:00\",\"label\":\"Casablanca\"},{\"value\":\"+00:00\",\"label\":\"Dublin\"},{\"value\":\"+00:00\",\"label\":\"Edinburgh\"},{\"value\":\"+00:00\",\"label\":\"Lisbon\"},{\"value\":\"+00:00\",\"label\":\"London\"},{\"value\":\"+00:00\",\"label\":\"Monrovia\"},{\"value\":\"+00:00\",\"label\":\"UTC\"},{\"value\":\"+01:00\",\"label\":\"Amsterdam\"},{\"value\":\"+01:00\",\"label\":\"Belgrade\"},{\"value\":\"+01:00\",\"label\":\"Berlin\"},{\"value\":\"+01:00\",\"label\":\"Bern\"},{\"value\":\"+01:00\",\"label\":\"Bratislava\"},{\"value\":\"+01:00\",\"label\":\"Brussels\"},{\"value\":\"+01:00\",\"label\":\"Budapest\"},{\"value\":\"+01:00\",\"label\":\"Copenhagen\"},{\"value\":\"+01:00\",\"label\":\"Ljubljana\"},{\"value\":\"+01:00\",\"label\":\"Madrid\"},{\"value\":\"+01:00\",\"label\":\"Paris\"},{\"value\":\"+01:00\",\"label\":\"Prague\"},{\"value\":\"+01:00\",\"label\":\"Rome\"},{\"value\":\"+01:00\",\"label\":\"Sarajevo\"},{\"value\":\"+01:00\",\"label\":\"Skopje\"},{\"value\":\"+01:00\",\"label\":\"Stockholm\"},{\"value\":\"+01:00\",\"label\":\"Vienna\"},{\"value\":\"+01:00\",\"label\":\"Warsaw\"},{\"value\":\"+01:00\",\"label\":\"West Central Africa\"},{\"value\":\"+01:00\",\"label\":\"Zagreb\"},{\"value\":\"+02:00\",\"label\":\"Athens\"},{\"value\":\"+02:00\",\"label\":\"Bucharest\"},{\"value\":\"+02:00\",\"label\":\"Cairo\"},{\"value\":\"+02:00\",\"label\":\"Harare\"},{\"value\":\"+02:00\",\"label\":\"Helsinki\"},{\"value\":\"+02:00\",\"label\":\"Istanbul\"},{\"value\":\"+02:00\",\"label\":\"Jerusalem\"},{\"value\":\"+02:00\",\"label\":\"Kyiv\"},{\"value\":\"+02:00\",\"label\":\"Pretoria\"},{\"value\":\"+02:00\",\"label\":\"Riga\"},{\"value\":\"+02:00\",\"label\":\"Sofia\"},{\"value\":\"+02:00\",\"label\":\"Tallinn\"},{\"value\":\"+02:00\",\"label\":\"Vilnius\"},{\"value\":\"+03:00\",\"label\":\"Baghdad\"},{\"value\":\"+03:00\",\"label\":\"Kuwait\"},{\"value\":\"+03:00\",\"label\":\"Minsk\"},{\"value\":\"+03:00\",\"label\":\"Moscow\"},{\"value\":\"+03:00\",\"label\":\"Nairobi\"},{\"value\":\"+03:00\",\"label\":\"Riyadh\"},{\"value\":\"+03:00\",\"label\":\"St. Petersburg\"},{\"value\":\"+03:00\",\"label\":\"Volgograd\"},{\"value\":\"+03:30\",\"label\":\"Tehran\"},{\"value\":\"+04:00\",\"label\":\"Abu Dhabi\"},{\"value\":\"+04:00\",\"label\":\"Baku\"},{\"value\":\"+04:00\",\"label\":\"Muscat\"},{\"value\":\"+04:00\",\"label\":\"Tbilisi\"},{\"value\":\"+04:00\",\"label\":\"Yerevan\"},{\"value\":\"+04:30\",\"label\":\"Kabul\"},{\"value\":\"+05:00\",\"label\":\"Ekaterinburg\"},{\"value\":\"+05:00\",\"label\":\"Islamabad\"},{\"value\":\"+05:00\",\"label\":\"Karachi\"},{\"value\":\"+05:00\",\"label\":\"Tashkent\"},{\"value\":\"+05:30\",\"label\":\"Chennai\"},{\"value\":\"+05:30\",\"label\":\"Kolkata\"},{\"value\":\"+05:30\",\"label\":\"Mumbai\"},{\"value\":\"+05:30\",\"label\":\"New Delhi\"},{\"value\":\"+05:30\",\"label\":\"Sri Jayawardenepura\"},{\"value\":\"+05:45\",\"label\":\"Kathmandu\"},{\"value\":\"+06:00\",\"label\":\"Almaty\"},{\"value\":\"+06:00\",\"label\":\"Astana\"},{\"value\":\"+06:00\",\"label\":\"Dhaka\"},{\"value\":\"+06:00\",\"label\":\"Novosibirsk\"},{\"value\":\"+06:00\",\"label\":\"Urumqi\"},{\"value\":\"+06:30\",\"label\":\"Rangoon\"},{\"value\":\"+07:00\",\"label\":\"Bangkok\"},{\"value\":\"+07:00\",\"label\":\"Hanoi\"},{\"value\":\"+07:00\",\"label\":\"Jakarta\"},{\"value\":\"+07:00\",\"label\":\"Krasnoyarsk\"},{\"value\":\"+08:00\",\"label\":\"Beijing\"},{\"value\":\"+08:00\",\"label\":\"Chongqing\"},{\"value\":\"+08:00\",\"label\":\"Hong Kong\"},{\"value\":\"+08:00\",\"label\":\"Irkutsk\"},{\"value\":\"+08:00\",\"label\":\"Kuala Lumpur\"},{\"value\":\"+08:00\",\"label\":\"Perth\"},{\"value\":\"+08:00\",\"label\":\"Singapore\"},{\"value\":\"+08:00\",\"label\":\"Taipei\"},{\"value\":\"+08:00\",\"label\":\"Ulaanbaatar\"},{\"value\":\"+09:00\",\"label\":\"Osaka\"},{\"value\":\"+09:00\",\"label\":\"Sapporo\"},{\"value\":\"+09:00\",\"label\":\"Seoul\"},{\"value\":\"+09:00\",\"label\":\"Tokyo\"},{\"value\":\"+09:00\",\"label\":\"Yakutsk\"},{\"value\":\"+09:30\",\"label\":\"Adelaide\"},{\"value\":\"+09:30\",\"label\":\"Darwin\"},{\"value\":\"+10:00\",\"label\":\"Brisbane\"},{\"value\":\"+10:00\",\"label\":\"Canberra\"},{\"value\":\"+10:00\",\"label\":\"Guam\"},{\"value\":\"+10:00\",\"label\":\"Hobart\"},{\"value\":\"+10:00\",\"label\":\"Magadan\"},{\"value\":\"+10:00\",\"label\":\"Melbourne\"},{\"value\":\"+10:00\",\"label\":\"Port Moresby\"},{\"value\":\"+10:00\",\"label\":\"Sydney\"},{\"value\":\"+10:00\",\"label\":\"Vladivostok\"},{\"value\":\"+11:00\",\"label\":\"New Caledonia\"},{\"value\":\"+11:00\",\"label\":\"Solomon Is.\"},{\"value\":\"+12:00\",\"label\":\"Auckland\"},{\"value\":\"+12:00\",\"label\":\"Fiji\"},{\"value\":\"+12:00\",\"label\":\"Kamchatka\"},{\"value\":\"+12:00\",\"label\":\"Marshall Is.\"},{\"value\":\"+12:00\",\"label\":\"Wellington\"},{\"value\":\"+12:45\",\"label\":\"Chatham Is.\"},{\"value\":\"+13:00\",\"label\":\"Nuku'alofa\"},{\"value\":\"+13:00\",\"label\":\"Tokelau Is.\"}]");

datetime =
  "datetime" :
    activateForm: ->
      that      = this

      _defaults =
          dateFormat: "yy-mm-dd"
          timeFormat: "HH:mm:ss z"
          showTimezone: true
          timezoneList: TIMEZONES
          timezone: "-08:00"
          parse: 'loose'
          onClose: ->
            that.update()
      overrideOptions = jQuery(this.element[0]).data('datetimepicker-options')
      options = $.extend {}, _defaults, overrideOptions

      output    = jQuery(document.createElement('form'))
                  .addClass('form_in_place')
                  .attr('action', 'javascript:void(0);')
                  .attr('style', 'display:inline')
      input_elt = jQuery(document.createElement('input'))
                  .attr('type', 'text')
                  .attr('name', this.attributeName)
                  .attr('value', this.sanitizeValue(this.display_value))

      if (this.inner_class != null)
        input_elt.addClass(this.inner_class)

      output.append(input_elt)

      this.element.html(output)
      this.setHtmlAttributes()
      this.element.find('input')[0].select()
      this.element.find("form").bind('submit', {editor: this}, BestInPlaceEditor.forms.input.submitHandler)
      this.element.find("input").bind('keyup', {editor: this}, BestInPlaceEditor.forms.input.keyupHandler)

      this.element.find('input')
        .datetimepicker(options)
        .datepicker('show')
    ,

    getValue: ->
      this.sanitizeValue(this.element.find("input").val())
    ,

    submitHandler : (event)  ->
      event.data.editor.update()
    ,

    keyupHandler : (event) ->
      if (event.keyCode == 27)
        event.data.editor.abort()

$.extend BestInPlaceEditor.forms, datetime