import React from 'react'
import PropTypes from 'prop-types'

export default class Link extends React.Component {
  static propTypes = {
    children: PropTypes.node.isRequired,
    helpers: PropTypes.object.isRequired,
    href: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {children, helpers: _, ...attributes} = this.props
    const modifiers = this._isCurrent() ? 'is-current' : ''

    return (
      <a className={`link ${modifiers}`} {...attributes}>
        {children}
      </a>
    )
  }

  _isCurrent() {
    const {helpers} = this.props
    return helpers.paths.current.startsWith(this.props.href)
  }
}
