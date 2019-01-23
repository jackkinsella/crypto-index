import React from 'react'
import PropTypes from 'prop-types'

export default class Dropdown extends React.Component {
  static propTypes = {
    items: PropTypes.object.isRequired,
    title: PropTypes.string.isRequired
  }

  render() {
    return (
      <div className="dropdown is-hoverable">
        <div className="dropdown-trigger">
          <button className="button">
            <span>{this.props.title}</span>
            <span className="icon is-small">
              <i className="fas fa-angle-down"></i>
            </span>
          </button>
        </div>

        <div className="dropdown-menu" id="dropdown-menu">
          <div className="dropdown-content">
            {Object.entries(this.props.items).map(item => this._item(item))}
          </div>
        </div>
      </div>
    )
  }

  _item(item) {
    const [title, path] = item
    return (
      <a key={title} className="dropdown-item" href={path}>{title}</a>
    )
  }
}
