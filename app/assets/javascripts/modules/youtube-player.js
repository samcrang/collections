window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  "use strict";

  Modules.YouTubePlayer = function () {
    if (window.GOVUK.cookie('global_bar_seen')) {

      if (window.location.pathname === '/coronavirus' || '/transition') {
        // Provide CSS hook for when cookies are accepted.
        let youTubeLogo = document.querySelector(".youtube__video-wrapper");
        youTubeLogo.classList.add("youtube__video-wrapper--cookies-accepted");
      }
    }
  }
})(window.GOVUK.Modules)
