import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import Currencies from '../../../Currencies'
import withMainMenu from '../../../wrappers/withMainMenu'

class CurrencyHoldingsSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    holdings: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {holdings, helpers} = this.props

    return (
      holdings.length === 0 ?
        <section className="section">
          <h1 className="title">Currency holdings</h1>
          <p>
            You don&apos;t have any holdings yet.
          </p>

          <hr />

          <a href={helpers.paths.transactionsDeposits}>
            <button className="button is-info is-outlined">
              Make your first deposit
            </button>
          </a>
        </section> :
        <Currencies
          title="Currency holdings"
          headers={{title: 'Name', size: 'Size'}}
          items={holdings}
          sortColumn="title"
          sortOrder="asc"
          helpers={helpers}
        />
    )
  }
}

const CurrencyHoldingsSectionWithMenu = withMainMenu(CurrencyHoldingsSection)

export default class CurrencyHoldings extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    holdings: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="currency-holdings">
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
            assets={{
              logo: helpers.assets['images/logos/crypto_index.svg']
            }}
            paths={{home: helpers.paths.account}}
            helpers={helpers}
          />

          <CurrencyHoldingsSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
