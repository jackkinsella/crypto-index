import React from 'react'
import PropTypes from 'prop-types'

export default class Navbar extends React.Component {
  static displayName = 'Navbar'
  static propTypes = {
    assets: PropTypes.object.isRequired,
    brand: PropTypes.string.isRequired,
    helpers: PropTypes.object,
    items: PropTypes.object,
    paths: PropTypes.object.isRequired
  }

  static defaultProps = {
    helpers: {},
    items: {}
  }

  constructor(props) {
    super(props)

    this.state = {
      isActive: false
    }
  }

  render() {
    return (
      <nav className="navbar">
        <div className="navbar-brand">
          <a className="navbar-item" href={this.props.paths.home}>
            <img src={this.props.assets.logo} width="28" height="28" />
            <h2>{this.props.brand}</h2>
          </a>

          {this._burger()}
        </div>

        {this._menu()}
      </nav>
    )
  }

  handleClick = () => {
    this.setState((prevState, props) => {
      return {isActive: !prevState.isActive}
    })
  }

  _burger() {
    const modifier = this.state.isActive ? 'is-active' : ''
    return (
      <a className={`navbar-burger ${modifier}`} onClick={this.handleClick}>
        <span/>
        <span/>
        <span/>
      </a>
    )
  }

  _menu() {
    const modifier = this.state.isActive ? 'is-active' : ''
    return (
      <div className={`navbar-menu ${modifier}`}>
        <div className="navbar-end">
          {Object.entries(this.props.items).map(item => this._item(item))}
        </div>
      </div>
    )
  }

  _item(item) {
    const [text, path] = item
    const currentPath =
      (this.props.helpers.paths || {}).current ||
      this.props.paths.current || ''
    const modifiers = currentPath.startsWith(path) ? 'is-current' : ''
    return (
      <a key={text} href={path} className={`navbar-item ${modifiers}`}>
        {text}
      </a>
    )
  }
}
