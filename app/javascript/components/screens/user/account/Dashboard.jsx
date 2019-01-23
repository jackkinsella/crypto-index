import React from 'react'
import PropTypes from 'prop-types'
import NumberFormat from 'react-number-format'
import Hero from '../../../layout/Hero'
import Navbar from '../../../Navbar'
import FinancialChart from '../../../FinancialChart'
import withMainMenu from '../../../wrappers/withMainMenu'

class DashboardSection extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    depositsCount: PropTypes.number.isRequired,
    performanceValuesUSD: PropTypes.object.isRequired,
    portfolioLastRebalancedAtInWords: PropTypes.string,
    portfolioReturnOnInvestment: PropTypes.string,
    portfolioValueETH: PropTypes.string,
    portfolioValueUSD: PropTypes.string,
    helpers: PropTypes.object.isRequired,
    rebalancingsCount: PropTypes.number.isRequired,
    withdrawalsCount: PropTypes.number.isRequired
  }

  static defaultProps = {
    portfolioLastRebalancedAtInWords: null
  }

  render() {
    const {depositsCount} = this.props

    return (
      <section className="section">
        <h1 className="title">Dashboard</h1>

        {depositsCount > 0 && this._default()}
        {depositsCount === 0 && this._blank()}
      </section>
    )
  }

  _default() {
    const {
      depositsCount,
      performanceValuesUSD,
      portfolioLastRebalancedAtInWords,
      portfolioReturnOnInvestment,
      portfolioValueETH,
      portfolioValueUSD,
      helpers,
      rebalancingsCount,
      withdrawalsCount
    } = this.props

    return (
      <div>
        <div className="tile is-ancestor">
          <div className="tile is-parent">
            <div className="tile is-child box">
              Status: &nbsp;
              <span className="tag is-success">Level 1</span>
              <p>
                <small>Current limit: 10.0 ETH</small>
              </p>
            </div>
          </div>

          <div className="tile is-parent">
            <div className="tile is-child box">
              <p>{depositsCount} deposit{depositsCount > 1 ? 's' : ''}</p>
            </div>
          </div>

          <div className="tile is-parent">
            <div className="tile is-child box">
              {rebalancingsCount === 0 &&
                <p>No rebalancings</p>
              }
              {rebalancingsCount > 0 &&
                <p>{rebalancingsCount} rebalancing{rebalancingsCount > 1 ? 's' : ''}</p>
              }
            </div>
          </div>

          <div className="tile is-parent">
            <div className="tile is-child box">
              {withdrawalsCount === 0 &&
                <p>No withdrawals</p>
              }
              {withdrawalsCount > 0 &&
                <p>{withdrawalsCount} withdrawal{withdrawalsCount > 1 ? 's' : ''}</p>
              }
            </div>
          </div>
        </div>

        {Object.keys(performanceValuesUSD).length > 0 &&
          <div className="tile is-ancestor">
            <div className="tile is-parent">
              <div className="tile is-child notification is-dark">
                <small>Current Value</small>
                <p>
                  <strong>
                    ${this._number(portfolioValueUSD, {suffix: ' USD'})}
                  </strong>
                  {' '}
                  ({this._number(
                    portfolioValueETH, {decimalScale: 2, suffix: ' ETH'}
                  )})
                </p>
              </div>
            </div>

            <div className="tile is-parent">
              <div className={`
                tile is-child notification
                ${portfolioReturnOnInvestment >= 0 ? 'is-success' : 'is-danger'}
              `}>
                <small>Return on Investment</small>
                <p>
                  <strong>
                    {this._number(
                      portfolioReturnOnInvestment * 100,
                      {decimalScale: 2, suffix: '%'}
                    )}
                  </strong>
                </p>
              </div>
            </div>

            <div className="tile is-parent">
              <div className="tile is-child notification is-light">
                <small>Last Rebalanced</small>

                <p>{portfolioLastRebalancedAtInWords ?
                  `${portfolioLastRebalancedAtInWords} ago` : 'Never'}</p>
              </div>
            </div>
          </div>
        }

        {Object.keys(performanceValuesUSD).length === 0 &&
          <div>
            <hr />

            <div className="notification is-info">
              <span className="icon">
                <i className="fas fa-spinner fa-spin" />
              </span>{' '}
              Your portfolio performance is being calculated…<br />
              <small>
                This process might take up to an hour.
              </small>
            </div>
          </div>
        }

        {Object.keys(performanceValuesUSD).length >= 3 &&
          <div>
            <hr />

            <h2 className="subtitle">Portfolio Performance</h2>

            <FinancialChart
              labels={Object.keys(performanceValuesUSD)}
              values={Object.values(performanceValuesUSD)}
              settings={{
                currencySymbol: '$',
                displayScales: false,
                theme: 'light'
              }}
              helpers={helpers}
            />
          </div>
        }
      </div>
    )
  }

  _blank() {
    const {helpers} = this.props

    return (
      <div>
        <div className="tile is-ancestor">
          <div className="tile is-parent">
            <div className="tile is-child box">
              Status: &nbsp;
              <span className="tag is-success">Level 1</span>
              <p>
                <small>Current limit: 10.0 ETH</small>
              </p>
            </div>
          </div>

          <div className="tile is-parent">
            <div className="tile is-child box">
              <p>No deposits</p>
            </div>
          </div>

          <div className="tile is-parent">
            <div className="tile is-child box">
              <p>No rebalancings</p>
            </div>
          </div>

          <div className="tile is-parent">
            <div className="tile is-child box">
              <p>No withdrawals</p>
            </div>
          </div>
        </div>

        <hr />

        <a href={helpers.paths.transactionsDeposits}>
          <button className="button is-info is-outlined">
            Make your first deposit
          </button>
        </a>
      </div>
    )
  }

  _number(value, options = {}) {
    return value &&
      <NumberFormat displayType="text" value={value} thousandSeparator={true}
        isNumericString={true} decimalScale={options.decimalScale || 0}
        prefix={options.prefix} suffix={options.suffix} />
  }
}

const DashboardSectionWithMenu = withMainMenu(DashboardSection)

export default class Dashboard extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    performanceValuesUSD: PropTypes.object.isRequired,
    helpers: PropTypes.object.isRequired
  }

  static defaultProps = {}

  render() {
    const {helpers} = this.props

    return (
      <div className="dashboard">
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

          <DashboardSectionWithMenu {...this.props} />
        </Hero>
      </div>
    )
  }
}
