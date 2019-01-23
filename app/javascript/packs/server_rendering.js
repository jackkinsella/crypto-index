require('@babel/polyfill')

const requireContext = require.context('components', true, /(?<!\.scss)$/)
const ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(requireContext)
