import React from 'react'
import PropTypes from 'prop-types'
import Form from 'components/form/Form'
import Field from 'components/form/Field'
import querystring from 'querystring'

export default class Login extends React.Component {
  static propTypes = {
    paths: PropTypes.object.isRequired
  }

  constructor(props) {
    super(props)

    this.state = {
      isSubmitting: false,
      loginFailed: false
    }
  }

  render() {
    return (
      <div className="login">
        {this._form()}
        <p>
          Don&apos;t already have an account?{' '}
          <a href={`${this.props.paths.home}#signup`}>Sign up</a>.
        </p>
      </div>
    )
  }

  _form() {
    let email = ''
    if (typeof window !== 'undefined') {
      email = querystring.parse(window.location.search.substring(1)).email
    }

    return (
      <Form
        url={this.props.paths.login}
        onError={() => {
          this.setState({loginFailed: true})
        }}
        onUpdate={({isSubmitting}) => {
          this.setState({isSubmitting, loginFailed: false})
        }}>
        {this.state.loginFailed && this._failureNotification()}
        <Field>
          <input
            className="input"
            name="user[email]"
            type="email"
            placeholder="Your email"
            value={email}
            autoFocus={!email}
            required
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <input
            className="input"
            name="user[password]"
            type="password"
            placeholder="Your password"
            autoFocus={!!email}
            required
            pattern=".{8,}"
            title="Please enter at least 8 characters."
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <button
            className="button is-outlined is-info"
            type="submit"
            disabled={this.state.isSubmitting}>
            Log in ›
          </button>
        </Field>
      </Form>
    )
  }

  _failureNotification() {
    return (
      <div className="notification is-danger">
        We were unable to log you in. Please try again.
      </div>
    )
  }
}
