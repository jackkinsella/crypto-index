import React from 'react'
import PropTypes from 'prop-types'

export default class Indexes extends React.Component {
  static propTypes = {
    helpers: PropTypes.object.isRequired,
    items: PropTypes.array.isRequired,
    title: PropTypes.string
  }

  static defaultProps = {
    title: null
  }

  render() {
    return (
      <section className="section indexes">
        {this.props.title && this._title()}
        {this.props.items.map(item => this._item(item))}
      </section>
    )
  }

  _title() {
    return (
      <h1 className="title">{this.props.title}</h1>
    )
  }

  _item(item) {
    const {helpers} = this.props
    const iconPath = helpers.assets[
      `images/icons/indexes/${item.symbol.toLowerCase()}.svg`
    ]

    return (
      <div key={item.symbol} className="box item">
        <a
          className="title"
          href={helpers.paths.index.replace(':id', item.name)}
        >
          <span className="icon is-large">
            <img src={iconPath} />
          </span>

          {item.title}
        </a>

        <p className="description">{item.description}</p>
      </div>
    )
  }
}
