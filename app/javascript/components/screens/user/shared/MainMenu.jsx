import React from 'react'
import PropTypes from 'prop-types'
import Link from '../../../elements/Link'

export default class MainMenu extends React.Component {
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
      <aside className={`main-menu menu ${modifier}`}>
        {this._burger()}

        <p className="menu-label">Account</p>
        <ul className="menu-list">
          <li>
            <Link href="/account/dashboard" helpers={helpers}>
              Dashboard
            </Link>
          </li>
        </ul>

        <p className="menu-label">Portfolio</p>
        <ul className="menu-list">
          <li>
            <Link href="/portfolio/currencies" helpers={helpers}>
              Currencies
            </Link>
          </li>
          <li>
            <Link href="/portfolio/indexes" helpers={helpers}>
              Indexes
            </Link>
          </li>
        </ul>

        <p className="menu-label">Transactions</p>
        <ul className="menu-list">
          <li>
            <Link href="/transactions/deposits" helpers={helpers}>
              Deposits
            </Link>
          </li>
          <li>
            <Link href="/transactions/rebalancings" helpers={helpers}>
              Rebalancings
            </Link>
          </li>
          <li>
            <Link href="/transactions/withdrawals" helpers={helpers}>
              Withdrawals
            </Link>
          </li>
          <li>
            <Link href="/transactions/report" helpers={helpers}>
              Report <i className="fas fa-download" />
            </Link>
          </li>
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
        <span />
        <span />
        <span />
      </a>
    )
  }
}
