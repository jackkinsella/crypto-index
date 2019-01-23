import React from 'react'
import PropTypes from 'prop-types'
import axios from 'axios'

export default class Form extends React.Component {
  static propTypes = {
    beforeSubmit: PropTypes.func,
    children: PropTypes.node.isRequired,
    method: PropTypes.string,
    onError: PropTypes.func,
    onUpdate: PropTypes.func,
    onSuccess: PropTypes.func,
    url: PropTypes.string.isRequired
  }

  static defaultProps = {
    beforeSubmit: () => {},
    method: 'post',
    onError: () => {},
    onUpdate: () => {},
    onSuccess: () => {}
  }

  handleSubmit = (event) => {
    const form = event.target
    const isSubmitting = form.checkValidity()

    if (isSubmitting) {
      this.props.beforeSubmit()
      event.preventDefault()

      const formData = new FormData()
      for (const element of Object.values(form.elements)) {
        formData.set(element.name, element.value)
      }

      axios({
        method: this.props.method,
        url: this.props.url,
        data: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }}
      ).then((response) => {
        this._gotSuccess(response, formData)
        this._handleRedirects(response)
      }).catch((error) => {
        this._gotError(error)
      })
    }

    this.props.onUpdate({isSubmitting})
  }

  render() {
    return (
      <form className="form" onSubmit={this.handleSubmit}>
        {this.props.children}
      </form>
    )
  }

  _gotSuccess(response, formData) {
    this.setState((prevState, props) => {
      return {isSuccess: true}
    })
    this.props.onSuccess && this.props.onSuccess(response, formData)
  }

  _gotError(error) {
    this.props.onUpdate({isSubmitting: false})
    this.props.onError(error)
  }

  _handleRedirects(response) {
    const redirect = response.
      headers['X-Redirect-To'.toLowerCase()]
    if (redirect) {
      window.location.replace(redirect)
    }
  }
}
