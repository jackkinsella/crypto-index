import React from 'react'
import PropTypes from 'prop-types'

export default class Field extends React.Component {
  static propTypes = {
    children: PropTypes.node.isRequired
  }

  render() {
    const {children} = this.props
    const childrenCount = React.Children.count(children)
    const modifiers = childrenCount > 1 ? 'is-grouped' : ''

    return (
      <div className={`field ${modifiers}`}>
        {React.Children.map(children, item => this._control(item))}
      </div>
    )
  }

  _control(item) {
    return (
      <div className="control">
        {item}
      </div>
    )
  }
}
