// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.ts.

const channels = require.context(".", true, /_channel\.ts$/)
channels.keys().forEach(channels)
