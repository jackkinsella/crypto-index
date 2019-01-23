import React from 'react'
import PropTypes from 'prop-types'
import Chart from 'chart.js'

export default class FinancialChart extends React.Component {
  static propTypes = {
    labels: PropTypes.array.isRequired,
    modifiers: PropTypes.string,
    settings: PropTypes.object,
    values: PropTypes.array.isRequired
  }

  static defaultProps = {
    modifiers: '',
    settings: {
      currencySymbol: '$',
      displayScales: false,
      theme: 'light'
    }
  }

  componentDidMount() {
    new Chart(this._chartContext(), this._config())
  }

  render() {
    return (
      <div className={`financial-chart ${this.props.modifiers}`}>
        <canvas id="canvas"></canvas>
      </div>
    )
  }

  _config() {
    return {
      type: 'line',
      data: this._data(),
      options: this._options()
    }
  }

  _data() {
    const {labels, values, settings} = this.props
    const gradient = this._chartContext().
      createLinearGradient(0, 0, 0, window.innerHeight * 0.6)
    gradient.addColorStop(0, '#4bb4f9')
    gradient.addColorStop(1, settings.theme === 'light' ? '#e8eff8' : '#141d27')

    return {
      labels,
      datasets: [{
        label: '',
        data: values,
        spanGaps: true,
        fill: true,
        lineTension: 0,
        pointRadius: 0,
        borderWidth: 1,
        borderColor: '#469ce8',
        backgroundColor: gradient
      }]
    }
  }

  _options() {
    return {
      responsive: true,

      legend: {
        display: false
      },

      tooltips: {
        mode: 'nearest',
        intersect: false,
        displayColors: false,
        backgroundColor: '#e8eff8',
        borderColor: '#e8e8e8',
        borderWidth: 1,
        xPadding: 18,
        yPadding: 18,

        titleFontFamily: 'Nunito',
        titleFontSize: 14,
        titleFontStyle: 'normal',
        titleFontColor: '#333333',

        bodyFontFamily: 'Nunito',
        bodyFontSize: 24,
        bodyFontStyle: 'normal',
        bodyFontColor: '#469ce8',

        callbacks: {
          title: this._dateLabel,
          label: this._tooltipLabel.bind(this)
        }
      },

      scales: {
        xAxes: [{
          display: this.props.settings.displayScales,
          gridLines: {
            display: false
          },
          ticks: {
            padding: 20,
            maxTicksLimit: 10
          }
        }],

        yAxes: [{
          display: this.props.settings.displayScales,
          gridLines: {
            display: false
          },
          ticks: {
            padding: 15,
            maxTicksLimit: 10,
            callback: this._tickLabel.bind(this)
          }
        }]
      }
    }
  }

  _dateLabel(tooltipItem, data) {
    const label = tooltipItem[0].xLabel
    return new Date(parseInt(label)).toDateString()
  }

  _tickLabel(value, index, values) {
    return this.props.settings.currencySymbol + value.toFixed(2)
  }

  _tooltipLabel(tooltipItem, data) {
    return this.props.settings.currencySymbol + tooltipItem.yLabel.toFixed(2).
      replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  }

  _chartContext() {
    return document.getElementById('canvas').getContext('2d')
  }
}
