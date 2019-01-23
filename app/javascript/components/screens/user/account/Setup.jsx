import React from 'react'
import PropTypes from 'prop-types'
import axios from 'axios'
import Form from '../../../form/Form'
import Field from '../../../form/Field'
import Navbar from '../../../Navbar'
import Hero from '../../../layout/Hero'

export default class Setup extends React.Component {
  static propTypes = {
    defaultCountryCode: PropTypes.string,
    initialStep: PropTypes.number,
    phoneCountryCodes: PropTypes.array.isRequired,
    phone: PropTypes.string,
    countries: PropTypes.object.isRequired,
    helpers: PropTypes.object.isRequired
  }

  static defaultProps = {
    initialStep: 1
  }

  constructor(props) {
    super(props)

    this.state = {
      step: props.initialStep,
      errorMessages: [],
      flashMessages: [],
      isSubmitting: false,
      phone: null
    }
  }

  render() {
    return (
      <div className="setup">
        <Hero modifiers="is-fullheight is-info">
          <Navbar
            brand="CryptoIndex"
            assets={{
              logo: this.props.helpers.assets['images/logos/crypto_index.svg']
            }}
            paths={{current: ''}}
          />

          <div className="columns">
            <div className="column">
              <h2 className="title">
                {this.state.step}. {this._title()}
              </h2>

              <p className="subtitle">
                <span className="icon is-small">
                  <i className={this._icon()} />
                </span>{' '}
                {this._subtitle()}
              </p>
            </div>

            <div className="column">
              <div className="box">{this._form()}</div>

              <progress
                className="progress"
                value={this._progressPercent()}
                max="100">
                {this._progressPercent()}%
              </progress>
            </div>
          </div>
        </Hero>
      </div>
    )
  }

  onSuccess = (response, formData) => {
    // TODO: We need a better general solution for getting access to submitted,
    // data from forms
    let phone = this.props.phone
    if (formData) {
      const phoneCountryCode = formData.get('user[phone_country_code]')
      const phoneNumber = formData.get('user[phone_number]')
      phone = `+${phoneCountryCode}${phoneNumber}`
    }

    this.setState((prevState, props) => {
      return {
        step: prevState.step + 1,
        isSubmitting: false,
        phone,
        errorMessages: []
      }
    })
  }

  onError = error => {
    let errorMessages = []
    if (error.response) {
      errorMessages = error.response.data.errorMessages || errorMessages
    }
    this.setState((prevState, props) => {
      return {flashMessages: [], errorMessages, isSubmitting: false}
    })
  }

  // TODO: Adding a beforeSubmit was a stop-gap measure to enable us to re-use
  // the Form component with minimal refactoring. We might consider
  // re-architecting the AccountSetup component such that this isn't necessary.
  beforeSubmit = () => {
    if (this.state.step === 5) {
      window.location.replace(this.props.helpers.paths.accountDashboard)
      return
    }
  }

  editPhoneNumber = () => {
    this.setState((prevState, props) => {
      return {
        step: prevState.step - 1
      }
    })
  }

  resendPhoneConfirmationCode = event => {
    event.preventDefault()

    axios({
      method: 'get',
      url: this.props.helpers.paths.resendPhoneConfirmationCode,
      // TODO: Can these headers be moved globally? They are repeated in
      // multiple files.
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
      .then(response => {
        const flashMessages = response.data.flashMessages || []
        this.setState((prevState, props) => {
          return {flashMessages}
        })
      })
      .catch(error => this.onError(error))
  }

  _form() {
    return (
      <Form
        url={this.props.helpers.paths.signup}
        method={'patch'}
        beforeSubmit={this.beforeSubmit}
        onSuccess={this.onSuccess}
        onError={this.onError}>
        {this.state.step === 1 && this._step1()}
        {this.state.step === 2 && this._step2()}
        {this.state.step === 3 && this._step3()}
        {this.state.step === 4 && this._step4()}
        {this.state.step === 5 && this._step5()}
      </Form>
    )
  }

  _title() {
    return {
      1: 'Get started',
      2: 'Add phone number',
      3: 'Confirm phone number',
      4: 'Enter postal address',
      5: 'Welcome on board'
    }[this.state.step]
  }

  _subtitle() {
    return {
      1: 'Choose a password to secure your account.',
      2: 'Enable 2-factor authentication for enhanced protection.',
      3: 'Enter the 4-digit confirmation code we just sent you.',
      4: 'Make sure your financial reports are compiled correctly.',
      5: 'You are now ready to deposit into your account.'
    }[this.state.step]
  }

  _icon() {
    return {
      1: 'fas fa-lock',
      2: 'fas fa-mobile-alt',
      3: 'fas fa-key',
      4: 'fas fa-address-card',
      5: 'fas fa-check-circle'
    }[this.state.step]
  }

  _step1() {
    return (
      <div className="step-1">
        <div className="field">
          <div className="control">
            <input
              className="input"
              type="password"
              autoFocus
              required
              pattern=".{8,}"
              title="Please enter at least 8 characters."
              name="user[password]"
              placeholder="Enter password"
            />
          </div>
        </div>

        <div className="field">
          <div className="control">
            <button
              className="button is-outlined is-info"
              type="submit"
              disabled={this.state.isSubmitting}>
              Continue ›
            </button>
          </div>
        </div>
      </div>
    )
  }

  _step2() {
    return (
      <div className="step-2">
        <div className="field has-addons">
          <p className="control">
            <span className="button is-static">+</span>
          </p>

          <div className="control">
            <div className="select">
              <select name="user[phone_country_code]">
                {this.props.phoneCountryCodes.map(code => (
                  <option key={code} value={code}>
                    {code}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="control is-expanded">
            <input
              className="input"
              type="tel"
              autoFocus
              required
              pattern="\d{5,}"
              title="Please enter your phone number using digits only (e.g. 100200555)"
              name="user[phone_number]"
              placeholder="100200555"
            />
          </div>
        </div>

        <div className="field">
          <div className="control">
            <button
              className="button is-outlined"
              type="submit"
              disabled={this.state.isSubmitting}>
              Request confirmation code ›
            </button>
          </div>
        </div>
        {this._displayErrorsIfPresent()}
      </div>
    )
  }

  _step3() {
    return (
      <div className="step-3">
        {this._displayFlashIfPresent()}
        <div className="field">
          <div className="control has-icons-left">
            <span className="icon is-left">
              <i className="fas fa-key" />
            </span>
            <input
              className="input"
              type="text"
              autoFocus
              required
              pattern="\d{4}"
              title="Please enter the correct 4-digit confirmation code."
              name="user[phone_confirmation_code]"
              placeholder="Enter confirmation code"
            />
          </div>
        </div>

        <div className="field is-grouped">
          <div className="control">
            <button
              className="button is-outlined is-back-button"
              onClick={this.editPhoneNumber}
              disabled={this.state.isSubmitting}>
              ‹ Back
            </button>
          </div>
          <div>
            <button
              className="button is-outlined is-info"
              type="submit"
              disabled={this.state.isSubmitting}>
              Continue ›
            </button>
          </div>
        </div>
        <div className="field">
          <a
            id="resend-phone-confirmation-code"
            onClick={this.resendPhoneConfirmationCode}>
            Resend confirmation code
          </a>{' '}
          to {this.state.phone || this.props.phone}
        </div>
        {this._displayErrorsIfPresent()}
      </div>
    )
  }

  _step4() {
    return (
      <div className="step-4">
        <Field>
          <input
            className="input"
            type="text"
            autoFocus
            required
            name="user[first_name]"
            placeholder="First name"
            readOnly={this.state.isSubmitting}
          />
          <input
            className="input"
            type="text"
            required
            name="user[last_name]"
            placeholder="Last name"
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <input
            className="input"
            type="text"
            required
            name="postal_address[street_line_1]"
            placeholder="Street line 1"
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <input
            className="input"
            type="text"
            name="postal_address[street_line_2]"
            placeholder="Street line 2 (optional)"
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <input
            className="input"
            type="text"
            required
            name="postal_address[zip_code]"
            placeholder="Zip code"
            readOnly={this.state.isSubmitting}
          />

          <input
            className="input"
            type="text"
            required
            name="postal_address[city]"
            placeholder="City"
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <input
            className="input"
            type="text"
            name="postal_address[region]"
            placeholder="Region (optional)"
            readOnly={this.state.isSubmitting}
          />
        </Field>

        <Field>
          <div className="select">
            <select name="postal_address[country_alpha2_code]">
              {Object.keys(this.props.countries).map(countryName => {
                const code = this.props.countries[countryName]
                return (
                  <option
                    key={code}
                    value={code}
                    selected={
                      this.props.defaultCountryCode === code ? 'selected' : ''
                    }>
                    {countryName}
                  </option>
                )
              })}
            </select>
          </div>
        </Field>

        <small>
          By creating a CryptoIndex account, I agree to the{' '}
          <a href="/terms" className="">
            terms and conditions
          </a>
          .
        </small>

        <div className="field">
          <div className="control">
            <input type="hidden" name="user[terms_accepted]" value="1" />

            <button
              className="button is-outlined is-info"
              type="submit"
              disabled={this.state.isSubmitting}>
              Create account ›
            </button>
          </div>
        </div>
        {this._displayErrorsIfPresent()}
      </div>
    )
  }

  _step5() {
    const {helpers} = this.props

    return (
      <div className="step-5">
        <div className="columns">
          <div className="column is-5">
            <figure className="image is-96x96">
              <img src={helpers.assets['images/icons/accounts/safe.svg']} />
            </figure>
          </div>

          <div className="column is-7 content">
            <p>
              <strong>Congratulations!</strong>
            </p>

            <p>Your CryptoIndex account has been activated.</p>

            <p>
              Your status:&nbsp; <span className="tag is-success">Level 1</span>
            </p>
          </div>
        </div>

        <ul>
          <li>
            <span className="icon">
              <i className="fas fa-check-circle" />
            </span>
            Deposit up to 10.0 ETH
          </li>

          <li>
            <span className="icon">
              <i className="fas fa-check-circle" />
            </span>
            Deposit and withdraw anytime
          </li>

          <li>
            <span className="icon">
              <i className="fas fa-check-circle" />
            </span>
            All security features enabled
          </li>
        </ul>

        <div className="field">
          <div className="control">
            <button
              className="button is-outlined is-success"
              type="submit"
              disabled={this.state.isSubmitting}>
              Go to dashboard ›
            </button>
          </div>
        </div>
      </div>
    )
  }

  _displayFlashIfPresent() {
    return (
      this._isFlash() && (
        <div id="flash-messages">
          {this.state.flashMessages.map(flashMessage => (
            <p className="has-text-info" key={flashMessage}>
              {flashMessage}
            </p>
          ))}
        </div>
      )
    )
  }

  _displayErrorsIfPresent() {
    return (
      this._isError() && (
        <div id="error-messages">
          {this.state.errorMessages.map(errorMessage => (
            <p className="has-text-danger" key={errorMessage}>
              {errorMessage}
            </p>
          ))}
        </div>
      )
    )
  }

  _progressPercent() {
    return this.state.step * 20
  }

  _isError() {
    return this.state.errorMessages.some(error => error)
  }

  _isFlash() {
    return this.state.flashMessages.some(error => error)
  }
}
