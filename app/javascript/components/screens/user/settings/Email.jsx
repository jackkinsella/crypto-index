import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import withSettingsMenu from '../../../wrappers/withSettingsMenu'

class EmailSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    email: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {email} = this.props

    return (
      <section className="section">
        <h1 className="title">Email</h1>

        <hr />

        <p>
          {email} &nbsp;
          <span className="tag is-success">Verified</span>
        </p>

        <small className="has-text-gray">
          For security reasons, your full email is not displayed.
        </small>
      </section>
    )
  }
}

const EmailSectionWithMenu = withSettingsMenu(EmailSection)

export default class Email extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    email: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="settings email">
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

          <EmailSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
