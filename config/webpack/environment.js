const {environment} = require('@rails/webpacker')
const merge = require('webpack-merge')

const fileLoader = environment.loaders.get('file')
const fileLoaderOptions = {
  context: 'app/assets/',
  name: '[path][name].[ext]'
}
const fileLoaderEntry = fileLoader.use.find(el => el.loader === 'file-loader')

fileLoader.test = /\.(svg|png|gif|jpg)$/i
fileLoaderEntry.options = merge(fileLoaderEntry.options, fileLoaderOptions)

environment.loaders.append('font', {
  test: /\.(eot|ttf|woff|woff2)|webfont\.svg$/i,
  use: [{
    loader: 'file-loader',
    options: {
      name: 'fonts/[name].[ext]'
    }
  }]
})

module.exports = environment
