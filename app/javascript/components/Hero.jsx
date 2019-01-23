import React from 'react'
import PropTypes from 'prop-types'
import Navbar from './Navbar'
import Signup from './Signup'
import Login from './Login'

// TODO: Remove this component in favor of `layout/Hero`
// Progress: AccountSetup has been updated
//
export default class Hero extends React.Component {
  static version = '0.0.0'

  static propTypes = {
    assets: PropTypes.object,
    children: PropTypes.object,
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
    return (
      <section className={`hero ${modifier} ${this.props.modifiers}`}
        style={this._backgroundImageStyle()}>
        {this.props.children.navbar && this._heroHead()}

        <div className="hero-body">
          <div className={`container ${this.props.containerModifiers}`}>
            {this.props.title && this._title()}
            {this.props.subtitle && this._subtitle()}

            {this.props.children.signup && this._signup()}
            {this.props.children.login && this._login()}
            {this.props.children.dashboard && this._dashboard()}
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

  _heroHead() {
    return (
      <div className="hero-head">
        <Navbar {...this.props.children.navbar} />
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

  _signup() {
    return (
      <Signup {...this.props.children.signup} />
    )
  }

  _login() {
    return (
      <Login {...this.props.children.login} />
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
