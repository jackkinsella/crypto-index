import React from 'react'
import PropTypes from 'prop-types'
import camelcaseKeys from 'camelcase-keys'

export default class Transactions extends React.Component {
  static propTypes = {
    children: PropTypes.node,
    helpers: PropTypes.object.isRequired,
    infoBox: PropTypes.string,
    title: PropTypes.string,
    transactions: PropTypes.array.isRequired
  }

  static defaultProps = {
    infoBox: null,
    title: null
  }

  constructor(props) {
    Object.assign(
      props.transactions, props.transactions.map(item => camelcaseKeys(item))
    )
    super(props)
  }

  render() {
    const {title, infoBox, transactions} = this.props

    return (
      <section className="transactions">
        {title && this._title(title)}
        {infoBox && this._infoBox(infoBox)}

        <table className="table is-fullwidth">
          <tbody>
            {transactions.map(item => this._transaction(item))}
          </tbody>
        </table>
      </section>
    )
  }

  _title(title) {
    return (
      <h1 className="title">{title}</h1>
    )
  }

  _infoBox(infoBox) {
    return (
      <pre className="box">{infoBox}</pre>
    )
  }

  _transaction(transaction) {
    const {helpers} = this.props

    return (
      <tr key={transaction.transactionHash}>
        <td>
          <span className="icon is-medium">
            {transaction.value ?
              <img src={helpers.assets['images/icons/currencies/eth.svg']} /> :
              <img src={helpers.assets['images/icons/indexes/m10.svg']} />
            }
          </span>
        </td>

        {transaction.value &&
          <td>
            {transaction.value} ETH
          </td>
        }

        <td>
          {transaction.confirmedAtInWords} ago &nbsp;
          {transaction.value &&
            <span className="tag is-success">confirmed</span>
          }
        </td>
      </tr>
    )
  }
}
