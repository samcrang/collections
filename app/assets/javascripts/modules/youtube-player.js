window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  Modules.YouTubePlayer = function () {
    this.start = function ($element) {
      var consentCookie = window.GOVUK.getConsentCookie()
      if (consentCookie && consentCookie.usage) {
        $element.addClass('youtube__video-wrapper--cookies-accepted')
      }
    }
  }
})(window.GOVUK.Modules)
