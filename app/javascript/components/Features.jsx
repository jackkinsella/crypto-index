import React from 'react'
import PropTypes from 'prop-types'

export default class Features extends React.Component {
  static propTypes = {
    columns: PropTypes.array.isRequired,
    iconModifiers: PropTypes.string,
    modifiers: PropTypes.string,
    textModifiers: PropTypes.string,
    titleModifiers: PropTypes.string
  }

  static defaultProps = {
    iconModifiers: '',
    modifiers: '',
    textModifiers: '',
    titleModifiers: ''
  }

  render() {
    return (
      <section className="section features">
        <div className="container">
          <div className="columns">
            {this.props.columns.map(column => this._column(column))}
          </div>
        </div>
      </section>
    )
  }

  _column(column) {
    return (
      <div key={column.title} className={`column ${this.props.modifiers}`}>
        {column.title && this._columnTitle(column)}
        {column.text && this._columnText(column)}
      </div>
    )
  }

  _columnTitle(column) {
    return (
      <h2 className={`title ${this.props.titleModifiers}`}>
        {column.titleIcon && this._columnTitleIcon(column)}
        {column.title}
      </h2>
    )
  }

  _columnTitleIcon(column) {
    return (
      <div className={`icon ${this.props.iconModifiers}`}>
        <i className={column.titleIcon} />
      </div>
    )
  }

  _columnText(column) {
    return (
      <p className={this.props.textModifiers}>
        {column.text}
      </p>
    )
  }
}
