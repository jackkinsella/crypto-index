import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import withSettingsMenu from '../../../wrappers/withSettingsMenu'

class PhoneSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    phone: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {phone} = this.props

    return (
      <section className="section">
        <h1 className="title">Phone</h1>

        <hr />

        <p>
          {phone} &nbsp;
          <span className="tag is-success">Verified</span>
        </p>

        <small className="has-text-gray">
          For security reasons, your full phone number is not displayed.
        </small>

        <hr />

        <h2 className="subtitle">
          Multi-Factor Authentication &nbsp;
          <span className="tag is-success">Active</span>
        </h2>

        <p>
          Confirmation codes will be sent to your phone number.
        </p>
      </section>
    )
  }
}

const PhoneSectionWithMenu = withSettingsMenu(PhoneSection)

export default class Phone extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    phone: PropTypes.string.isRequired
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

          <PhoneSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
