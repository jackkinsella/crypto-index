require('@babel/polyfill')
require.context('../../assets', true, /\.(js|svg|png|jpg|gif)$/)

require('@fortawesome/fontawesome-svg-core')
require('@fortawesome/free-regular-svg-icons')
require('@fortawesome/free-solid-svg-icons')
require('@fortawesome/free-brands-svg-icons')

require('typeface-nunito')
require('typeface-inconsolata')

require('../../views/layouts/application')

require('../services/freshchat')

const axios = require('axios')
const csrfTokenMetaTag = document.querySelector('meta[name="csrf-token"]')
if (csrfTokenMetaTag) {
  axios.defaults.headers.common = {
    'X-CSRF-TOKEN': csrfTokenMetaTag.getAttribute('content')
  }
}

const WOW = require('wowjs')
new WOW.WOW().init()

const requireContext = require.context('components', true, /(?<!\.scss)$/)
const ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(requireContext)
