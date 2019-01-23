import React from 'react'
import PropTypes from 'prop-types'
import Link from '../../../elements/Link'

export default class SettingsMenu extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired
  }

  static defaultProps = {}

  constructor(props) {
    super(props)

    this.state = {
      isActive: false
    }
  }

  render() {
    const {helpers} = this.props
    const modifier = this.state.isActive ? 'is-active' : ''

    return (
      <aside className={`settings-menu menu ${modifier}`}>
        {this._burger()}

        <p className="menu-label">
          Settings
        </p>
        <ul className="menu-list">
          <li><Link href="/settings/account" helpers={helpers}>Account</Link></li>
          <li><Link href="/settings/email" helpers={helpers}>Email</Link></li>
          <li><Link href="/settings/phone" helpers={helpers}>Phone</Link></li>
          <li><Link href="/settings/security" helpers={helpers}>Security</Link></li>
        </ul>
      </aside>
    )
  }

  handleClick = () => {
    this.setState((prevState, props) => {
      return {isActive: !prevState.isActive}
    })
  }

  _burger() {
    const modifier = this.state.isActive ? 'is-active' : ''

    return (
      <a className={`navbar-burger ${modifier}`} onClick={this.handleClick}>
        <span/>
        <span/>
        <span/>
      </a>
    )
  }
}
