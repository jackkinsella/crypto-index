import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import Transactions from '../../../Transactions'
import withMainMenu from '../../../wrappers/withMainMenu'

class DepositsSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    depositAddress: PropTypes.string.isRequired,
    helpers: PropTypes.object.isRequired,
    transactions: PropTypes.array.isRequired
  }

  static defaultProps = {}

  componentDidMount() {
    const refresh = () => window.location.reload()
    setTimeout(refresh, 5000)
  }

  render() {
    const {transactions} = this.props

    return (
      <section className="section">
        <h1 className="title">Deposits</h1>

        {transactions.length > 0 && this._default()}
        {transactions.length === 0 && this._blank()}
      </section>
    )
  }

  _default() {
    const {helpers, depositAddress, transactions} = this.props

    return (
      <div>
        <pre className="box">
          Your ETH deposit address: {depositAddress}
        </pre>

        <small>
          <span className="icon">
            <i className="fas fa-spinner fa-spin" />
          </span>{' '}
          Any deposit made to this address will be tracked automatically and
          credited to your CryptoIndex account.
        </small>

        <hr />

        <h2 className="subtitle">Deposit History</h2>

        <Transactions
          transactions={transactions}
          helpers={helpers}
        />
      </div>
    )
  }

  _blank() {
    const {depositAddress} = this.props

    return (
      <div>
        <div className="notification is-light">
          Make your first deposit:<br />
          <small>Send between 1.0 ETH (minimum) and 10.0 ETH (maximum) to your deposit address.</small>
        </div>

        <pre className="box">
          Your ETH deposit address: {depositAddress}
        </pre>

        <small>
          <span className="icon">
            <i className="fas fa-spinner fa-spin" />
          </span>{' '}
          Any deposit made to this address will be tracked automatically and
          credited to your CryptoIndex account.
        </small>
      </div>
    )
  }
}

const DepositsSectionWithMenu = withMainMenu(DepositsSection)

export default class Deposits extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    depositAddress: PropTypes.string.isRequired,
    helpers: PropTypes.object.isRequired,
    transactions: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="deposits">
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

          <DepositsSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
