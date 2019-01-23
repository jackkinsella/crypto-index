import React from 'react'
import PropTypes from 'prop-types'

export default class DataTable extends React.Component {
  static propTypes = {
    items: PropTypes.array.isRequired
  }

  render() {
    return (
      <section className="section data-table">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              {this._headers().map((header, i) => <th key={i}>{header}</th>)}
            </tr>
          </thead>

          <tbody>
            {this.props.items.map(item => this._item(item))}
          </tbody>
        </table>
      </section>
    )
  }

  _headers() {
    return Object.keys(this.props.items[0])
  }

  _item(item) {
    const identifier = this._sanitizedItemIdentifier(item)
    return (
      <tr key={identifier} id={identifier}>
        {Object.values(item).map((value, i) => <td key={i}>{value}</td>)}
      </tr>
    )
  }

  _sanitizedItemIdentifier(item) {
    const identifier = item.id || item.symbol || item.name
    return identifier.toString().replace(/\*$/, '')
  }
}
