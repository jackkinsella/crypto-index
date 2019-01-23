import React from 'react'
import PropTypes from 'prop-types'

import Form from './form/Form'

export default class Signup extends React.Component {
  static propTypes = {
    buttonTitle: PropTypes.string.isRequired,
    emailPlaceholder: PropTypes.string,
    paths: PropTypes.object.isRequired,
    thankYouMessage: PropTypes.string.isRequired
  }

  static defaultProps = {
    emailPlaceholder: ''
  }

  constructor(props) {
    super(props)

    this.state = {
      isSubmitting: false,
      hasResult: false,
      errorMessages: []
    }
  }

  render() {
    return (
      <div className="signup">
        <div className="box">
          {this.state.hasResult ? this._submissionResult() : this._form()}
        </div>

        <small>
          Already using CryptoIndex? <a href="/login">Log in</a>.
        </small>
      </div>
    )
  }

  onSuccess = () => {
    this.setState((prevState, props) => {
      return {hasResult: true, isSubmitting: false}
    })
  }

  onError = error => {
    const {errorMessages} = error.response.data
    this.setState((prevState, props) => {
      return {
        hasResult: true,
        isSubmitting: false,
        errorMessages
      }
    })
  }

  // TODO: Add Field component eventually
  // TODO: Can we pass isSubmitting props to Field components?
  _form() {
    return (
      <Form
        onSuccess={this.onSuccess}
        onError={this.onError}
        url={this.props.paths.signup}>
        <div className="field has-addons">
          <div className="control">
            <input
              className="input"
              name="user[email]"
              type="email"
              required
              placeholder={this.props.emailPlaceholder}
              readOnly={this.state.isSubmitting}
            />
          </div>

          <div className="control">
            <button
              className="button is-success"
              type="submit"
              disabled={this.state.isSubmitting}>
              {this.props.buttonTitle}
            </button>
          </div>
        </div>
      </Form>
    )
  }

  _submissionResult() {
    return this._isError() ? this._displayErrors() : this._thankYou()
  }

  _thankYou() {
    return (
      <div className="thank-you">
        <span className="icon">
          <i className="far fa-paper-plane" />
        </span>
        {this.props.thankYouMessage}
      </div>
    )
  }

  _displayErrors() {
    return (
      <div id="error-messages">
        <span className="icon">
          <i className="fas fa-exclamation-triangle" />
        </span>
        {this.state.errorMessages.map(errorMessage => (
          <p className="has-text-danger" key={errorMessage}>
            {errorMessage}
          </p>
        ))}
      </div>
    )
  }

  _isError() {
    return this.state.errorMessages.some(error => error)
  }
}
