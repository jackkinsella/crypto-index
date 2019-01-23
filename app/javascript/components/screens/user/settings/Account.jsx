import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import withSettingsMenu from '../../../wrappers/withSettingsMenu'

class AccountSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    postalAddress: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {postalAddress} = this.props

    return (
      <section className="section">
        <h1 className="title">Account</h1>

        <hr />

        <h2 className="subtitle">Account Status</h2>

        Status: &nbsp;

        <span className="tag is-success">Level 1</span>
        <p>
          <small>Current limit: 10.0 ETH</small>
        </p>

        <hr />

        <h2 className="subtitle">Postal Address</h2>

        <p>
          {postalAddress}
        </p>

        <small className="has-text-gray">
          For security reasons, your full postal address is not displayed.
        </small>
      </section>
    )
  }
}

const AccountSectionWithMenu = withSettingsMenu(AccountSection)

export default class Account extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    postalAddress: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="settings account">
        <Hero
          modifiers="is-fullheight is-top"
          containerModifiers="is-fullhd"
        >
          <Navbar
            brand="CryptoIndex"
            items={{
              'Settings': helpers.paths.settings,
              'Log out': helpers.paths.logout
            }}
            assets={{logo: helpers.assets['images/logos/crypto_index.svg']}}
            paths={{home: helpers.paths.account}}
            helpers={helpers}
          />

          <AccountSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
