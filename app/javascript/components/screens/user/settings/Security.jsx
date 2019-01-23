import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import withSettingsMenu from '../../../wrappers/withSettingsMenu'

class SecuritySection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    depositAddress: PropTypes.string.isRequired,
    helpers: PropTypes.object.isRequired
  }

  static defaultProps = {}

  render() {
    const {depositAddress} = this.props

    return (
      <section className="section">
        <h1 className="title">Security</h1>

        <hr />

        <h2 className="subtitle">Deposits</h2>

        <pre className="box">
          Your ETH deposit address: {depositAddress}
        </pre>

        <small>
          Please make sure to deposit only to your deposit address above.
        </small>

        <hr />

        <h2 className="subtitle">Withdrawals</h2>

        <p>
          <span className="icon">
            <i className="fas fa-lock"></i>
          </span>
          {' '}
          Withdrawals are usually released 24 hours after being requested.
        </p>
      </section>
    )
  }
}

const SecuritySectionWithMenu = withSettingsMenu(SecuritySection)

export default class Security extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    depositAddress: PropTypes.string.isRequired,
    helpers: PropTypes.object.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="settings phone">
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

          <SecuritySectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
