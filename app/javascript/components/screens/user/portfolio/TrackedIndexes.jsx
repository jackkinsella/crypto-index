import React from 'react'
import PropTypes from 'prop-types'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import Currencies from '../../../Currencies'
import withMainMenu from '../../../wrappers/withMainMenu'

class TrackedIndexesSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    indexes: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {indexes, helpers} = this.props

    return (
      indexes.length === 0 ?
        <section className="section">
          <h1 className="title">Tracked indexes</h1>
          <p>
            You are investing in the{' '}
            <a href={helpers.paths.index.replace(':id', 'market10')}>Market10</a>
            {' '}index.
          </p>

          <hr />

          <a href={helpers.paths.transactionsDeposits}>
            <button className="button is-info is-outlined">
              Make your first deposit
            </button>
          </a>
        </section> :
        <Currencies
          title="Tracked indexes"
          headers={{title: 'Name', percentage: 'Percentage'}}
          items={indexes}
          sortColumn="title"
          sortOrder="asc"
          helpers={helpers}
        />
    )
  }
}

const TrackedIndexesSectionWithMenu = withMainMenu(TrackedIndexesSection)

export default class TrackedIndexes extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    indexes: PropTypes.array.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="tracked-indexes">
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

          <TrackedIndexesSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
