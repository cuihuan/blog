/* jshint undef: true, esversion: 6, -W097 */
/* global require, hexo */



"use strict";

const renderer = require("./lib/renderer");

hexo.extend.renderer.register("scss", "css", renderer);
hexo.extend.renderer.register("sass", "css", renderer);
