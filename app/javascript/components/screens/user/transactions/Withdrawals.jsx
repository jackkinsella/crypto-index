import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import Transactions from '../../../Transactions'
import withMainMenu from '../../../wrappers/withMainMenu'

class WithdrawalsSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    transactions: PropTypes.array.isRequired,
    withdrawalAddress: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers, transactions} = this.props

    return (
      transactions.length === 0 ?
        <section className="section">
          <h1 className="title">Withdrawals</h1>

          <p>
            No withdrawals have been requested so far.
          </p>

          <hr />

          <button className="button is-light" disabled>
            Request Withdrawal
          </button>

          <small>
            Withdrawals can be requested 24 hours after the first deposit.
          </small>
        </section> :
        <Transactions
          title="Withdrawals"
          infoBox={`You'll receive withdrawals from: ${this.props.withdrawalAddress || 'PLEASE WAIT'}`}
          transactions={transactions}
          helpers={helpers}
        />
    )
  }
}

const WithdrawalsSectionWithMenu = withMainMenu(WithdrawalsSection)

export default class Withdrawals extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    transactions: PropTypes.array.isRequired,
    withdrawalAddress: PropTypes.string.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="withdrawals">
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

          <WithdrawalsSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
