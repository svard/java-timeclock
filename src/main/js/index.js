'use strict';

require('blaze/dist/blaze.min.css');
require('blaze/dist/blaze.colors.min.css');
require('font-awesome/css/font-awesome.min.css');
require('../resources/public/css/styles.css');
// require('../resources/public/index.html');

var Elm = require('../elm/App.elm');
var mountNode = document.getElementById('app');

// The third value on embed are the initial values for incoming ports into Elm
var app = Elm.App.embed(mountNode);