import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import Transactions from '../../../Transactions'
import withMainMenu from '../../../wrappers/withMainMenu'

class RebalancingsSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    rebalancings: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {rebalancings} = this.props

    return (
      <section className="section">
        <h1 className="title">Rebalancings</h1>

        {rebalancings.length > 0 && this._default()}
        {rebalancings.length === 0 && this._blank()}
      </section>
    )
  }

  _default() {
    const {helpers, rebalancings} = this.props

    return (
      <Transactions
        transactions={rebalancings}
        helpers={helpers}
      />
    )
  }

  _blank() {
    return (
      <p>
        Your portfolio has not yet been rebalanced.
      </p>
    )
  }
}

const RebalancingsSectionWithMenu = withMainMenu(RebalancingsSection)

export default class Rebalancings extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    rebalancings: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="rebalancings">
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

          <RebalancingsSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
