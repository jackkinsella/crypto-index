import React from 'react'
import PropTypes from 'prop-types'

export default class Hero extends React.Component {
  static propTypes = {
    assets: PropTypes.object,
    children: PropTypes.node,
    containerModifiers: PropTypes.string,
    effects: PropTypes.object,
    modifiers: PropTypes.string,
    subtitle: PropTypes.string,
    subtitleModifiers: PropTypes.string,
    title: PropTypes.string,
    titleModifiers: PropTypes.string
  }

  static defaultProps = {
    assets: {},
    children: {},
    containerModifiers: 'has-text-centered',
    effects: {},
    modifiers: '',
    subtitle: null,
    subtitleModifiers: '',
    title: null,
    titleModifiers: ''
  }

  render() {
    const modifier = this.props.assets.backgroundImage ? 'has-background-image' : ''
    const children = React.Children.toArray(this.props.children)
    const navbar = children.find(child => child.type.displayName === 'Navbar')

    return (
      <section className={`hero ${modifier} ${this.props.modifiers}`}
        style={this._backgroundImageStyle()}>
        {navbar && this._heroHead(navbar)}

        <div className="hero-body">
          <div className={`container ${this.props.containerModifiers}`}>
            {this.props.title && this._title()}
            {this.props.subtitle && this._subtitle()}

            {children.filter(child => child.type.displayName !== 'Navbar')}
          </div>
        </div>

        {this.props.effects.rain && this._rain()}
      </section>
    )
  }

  _rain() {
    return [...Array(100)].map((_, i) =>
      <i key={i} className="rain" />
    )
  }

  _heroHead(navbar) {
    return (
      <div className="hero-head">
        {navbar}
      </div>
    )
  }

  _title() {
    const modifier = this.props.assets.backgroundImage ? 'has-text-white' : ''
    return (
      <h1 className={`title ${this.props.titleModifiers} ${modifier}`}>
        <span>{this.props.title}</span>
      </h1>
    )
  }

  _subtitle() {
    const modifier = this.props.assets.backgroundImage ? 'has-text-white' : ''
    return (
      <h2 className={`subtitle ${this.props.subtitleModifiers} ${modifier}`}>
        <span>{this.props.subtitle}</span>
      </h2>
    )
  }

  _backgroundImageStyle() {
    return this.props.assets.backgroundImage ? {
      backgroundImage:
        'linear-gradient(rgba(0, 0, 0, 0.2), rgba(0, 0, 0, 0.5)), ' +
        `url(${this.props.assets.backgroundImage})`
    } : {}
  }
}
