import React from 'react'
import PropTypes from 'prop-types'
import NumberFormat from 'react-number-format'
import camelcaseKeys from 'camelcase-keys'

export default class Currencies extends React.Component {
  static propTypes = {
    headers: PropTypes.object,
    helpers: PropTypes.object.isRequired,
    items: PropTypes.array.isRequired,
    sortColumn: PropTypes.string,
    sortOrder: PropTypes.string,
    title: PropTypes.string
  }

  static defaultProps = {
    headers: null,
    title: null
  }

  constructor(props) {
    Object.assign(
      props.items, props.items.map(item => camelcaseKeys(item))
    )
    super(props)

    this.state = {
      sortColumn: props.sortColumn,
      sortOrder: props.sortOrder
    }
  }

  handleHeaderClick = (name) => {
    this.setState({
      sortColumn: name,
      sortOrder: this.state.sortOrder === 'asc' ? 'desc' : 'asc'
    })
  }

  render() {
    return (
      <section className="section currencies">
        {this.props.title && this._title()}

        <table className="table is-fullwidth">
          {this.props.headers && this._head()}

          <tbody>
            {this._sortedItems().map(item => this._item(item))}
          </tbody>
        </table>
      </section>
    )
  }

  _title() {
    return (
      <h1 className="title">{this.props.title}</h1>
    )
  }

  _head() {
    const {sortColumn, sortOrder} = this.state

    return (
      <thead>
        <tr>
          <th></th>
          {
            Object.keys(this.props.headers).map(columnName =>
              <SortableHeader
                key={columnName}
                columnName={columnName}
                text={this.props.headers[columnName]}
                sortOrder={sortColumn === columnName ? sortOrder : null}
                handleClick={this.handleHeaderClick}
              />
            )
          }
        </tr>
      </thead>
    )
  }

  _item(item) {
    const {headers, helpers} = this.props
    const isIndex = item.symbol === 'M10'
    const itemPath = helpers.paths[isIndex ? 'index' : 'currency']
    const iconFolder = isIndex ? 'indexes' : 'currencies'
    const iconPath = helpers.assets[
      `images/icons/${iconFolder}/${item.symbol.toLowerCase()}.svg`
    ]

    return (
      <tr key={item.symbol} id={item.symbol}>
        <td>
          <span className="icon is-medium">
            <img src={iconPath} />
          </span>
        </td>

        <td>
          <a href={itemPath.replace(':id', item.name)}>
            {item.title}
          </a>
        </td>

        {Object.keys(headers).map(
          attribute => this._cell(item, attribute)
        )}
      </tr>
    )
  }

  _cell(item, attribute) {
    if (attribute === 'title') { return }
    const withSign = attribute === 'priceChange24hPercent'
    const sign = item[attribute] >= 0 ? '+' : '-'
    return (
      <td key={attribute} data-sign={withSign && sign}>
        {this._number(item[attribute], this._numberOptions(item, attribute))}
      </td>
    )
  }

  _numberOptions(item, attribute) {
    return {
      circulatingSupply: {suffix: ` ${item.symbol}`},
      marketCapUsd: {prefix: '$'},
      percentage: {decimalScale: 2, suffix: '%'},
      priceChange24hPercent: {decimalScale: 2, suffix: '%'},
      priceUsd: {decimalScale: 2, prefix: '$'},
      size: {decimalScale: 2, suffix: ` ${item.symbol}`},
      weightPercent: {decimalScale: 2, suffix: '%'}
    }[attribute]
  }

  _sortedItems() {
    const {items} = this.props
    const {sortColumn, sortOrder} = this.state
    const direction = sortOrder === 'asc' ? 1 : -1

    return items.sort(
      (a, b) => {
        return direction * (
          this._columnType(sortColumn) === 'string' ?
            a[sortColumn].localeCompare(b[sortColumn]) :
            isNaN(parseFloat(a[sortColumn])) ? -1 :
              isNaN(parseFloat(b[sortColumn])) ? 1 :
                parseFloat(a[sortColumn]) - parseFloat(b[sortColumn])
        )
      }
    )
  }

  _columnType(columnName) {
    return columnName === 'title' ? 'string' : 'numeric'
  }

  _number(value, options = {}) {
    return value &&
      <NumberFormat displayType="text" value={value} thousandSeparator={true}
        isNumericString={true} decimalScale={options.decimalScale || 0}
        prefix={options.prefix} suffix={options.suffix} />
  }
}

class SortableHeader extends React.Component {
  static propTypes = {
    columnName: PropTypes.string.isRequired,
    handleClick: PropTypes.func,
    sortOrder: PropTypes.string,
    text: PropTypes.string.isRequired
  }

  render() {
    const {columnName, handleClick, sortOrder, text} = this.props

    return (
      <th onClick={() => handleClick(columnName)}> {text}
        {sortOrder && <i className={`fas ${this._iconName()}`}></i>}
      </th>
    )
  }

  _iconName() {
    return `fa-caret-${this.props.sortOrder === 'desc' ? 'down' : 'up'}`
  }
}
