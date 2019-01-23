import React from 'react'
import PropTypes from 'prop-types'

export default class Footer extends React.Component {
  static propTypes = {
    assets: PropTypes.object.isRequired,
    brand: PropTypes.string.isRequired,
    items: PropTypes.object,
    modifiers: PropTypes.string
  }

  static defaultProps = {
    items: null,
    modifiers: ''
  }

  render() {
    return (
      <footer className={`footer ${this.props.modifiers}`}>
        <div className="container">
          <div className="columns">
            <div className="column">
              <img className="logo" src={this.props.assets.logo}
                width="28" height="28" />
              <small>{this.props.brand}</small>
            </div>

            {this.props.items && this._items()}
          </div>
        </div>
      </footer>
    )
  }

  _items() {
    return Object.entries(this.props.items).map(item => this._item(item))
  }

  _item(item) {
    const [label, list] = item
    return (
      <div key={label} className="column">
        <nav className="menu">
          <p className="menu-label">
            {label}
          </p>

          <ul className="menu-list">
            {Object.entries(list).map(listItem => this._listItem(listItem))}
          </ul>
        </nav>
      </div>
    )
  }

  _listItem(listItem) {
    const [title, path] = listItem
    return (
      <li key={title}>
        <a href={path}>{title}</a>
      </li>
    )
  }
}
