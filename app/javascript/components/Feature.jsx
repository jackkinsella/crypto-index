import React from 'react'
import PropTypes from 'prop-types'
import Remarkable from 'remarkable'

export default class Feature extends React.Component {
  static propTypes = {
    assets: PropTypes.object.isRequired,
    text: PropTypes.string.isRequired
  }

  render() {
    return (
      <section className="section feature">
        <div className="container">
          <div className="columns">
            <div className="column is-3">
              {this._image()}
            </div>

            <div className="column is-6">
              {this._markdown(this.props.text)}
            </div>
          </div>
        </div>
      </section>
    )
  }

  _image() {
    return (
      <img src={this.props.assets.image} />
    )
  }

  _markdown(text) {
    const markdown = new Remarkable()
    return (
      <div className="content"
        dangerouslySetInnerHTML={{__html: markdown.render(text)}} />
    )
  }
}
