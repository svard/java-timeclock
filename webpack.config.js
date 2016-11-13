var path = require("path");

module.exports = {
  entry: {
    index: [
      './src/main/js/index.js'
    ],
    login: [
      './src/main/js/login.js'
    ]
  },

  output: {
    path: path.resolve(__dirname + '/src/main/resources/public/js/compiled'),
    publicPath: '/js/compiled/',
    filename: '[name].js',
  },

  module: {
    loaders: [
      {
        test: /\.(css|scss)$/,
        loaders: [
          'style-loader',
          'css-loader',
        ]
      },
      {
        test:    /\.html$/,
        exclude: /node_modules/,
        loader:  'file?name=[name].[ext]',
      },
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack',
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&minetype=application/font-woff',
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader',
      },
    ],

    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
    stats: { colors: true },
    proxy: {
      '/**': {
        target: 'http://localhost:8086',
        secure: false
      }
    }
  },

};