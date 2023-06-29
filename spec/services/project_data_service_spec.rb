# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectDataService, type: :service do
  let(:org) { Organization.create! name: 'artsy' }
  let(:profile) { org.profiles.create!(basic_password: 'foo') }
  let(:project) do
    org.projects.create!(name: 'candela', criticality: 1, tags: ['engineering']).tap do |p|
      p.stages.create!(name: 'main', profile: profile)
      p.stages.create!(name: 'production', profile: profile)
    end
  end

  # rubocop:disable Layout/LineLength
  let(:github_package_json_response) do
    { name: 'package.json', path: 'package.json', sha: 'f60926f5c61ea9b354783673c21c2eb2830dca32', size: 6153, url: 'https://api.github.com/repos/artsy/metaphysics/contents/package.json?ref=main', html_url: 'https://github.com/artsy/metaphysics/blob/main/package.json', git_url: 'https://api.github.com/repos/artsy/metaphysics/git/blobs/f60926f5c61ea9b354783673c21c2eb2830dca32', download_url: 'https://raw.githubusercontent.com/artsy/metaphysics/main/package.json', type: 'file', content: "ewogICJuYW1lIjogIm1ldGFwaHlzaWNzIiwKICAidmVyc2lvbiI6ICIwLjAu\nMSIsCiAgImRlc2NyaXB0aW9uIjogIiIsCiAgIm1haW4iOiAiaW5kZXguanMi\nLAogICJyZXBvc2l0b3J5IjogImh0dHBzOi8vZ2l0aHViLmNvbS9hcnRzeS9t\nZXRhcGh5c2ljcyIsCiAgImVuZ2luZXMiOiB7CiAgICAibm9kZSI6ICIxMiIs\nCiAgICAibnBtIjogIjUuNi4wIiwKICAgICJ5YXJuIjogIjEuKiIKICB9LAog\nICJzY3JpcHRzIjogewogICAgImJ1aWxkOmZpeHR1cmVzIjogImNwIHNyYy9s\naWIvKi5qc29uIGJ1aWxkL3NyYy9saWIvIiwKICAgICJidWlsZDppbmRleCI6\nICJiYWJlbCBpbmRleC5qcyAtcyBpbmxpbmUgLWQgYnVpbGQiLAogICAgImJ1\naWxkOmxpYiI6ICJiYWJlbCBzcmMgLS1jb3B5LWZpbGVzIC0tZXh0ZW5zaW9u\ncyAnLnRzLC5qcycgLS1pZ25vcmUgc3JjL3Rlc3Qsc3JjL2ludGVncmF0aW9u\nLHNyYy8qKi9fX3Rlc3RzX18gLXMgaW5saW5lIC1kIGJ1aWxkL3NyYyIsCiAg\nICAiYnVpbGQ6cmVtb3RlLXNjaGVtYXMiOiAiY3Agc3JjL2RhdGEvKi5ncmFw\naHFsIGJ1aWxkL3NyYy9kYXRhLyIsCiAgICAiYnVpbGQiOiAieWFybiBidWls\nZDpsaWIgJiYgeWFybiBidWlsZDppbmRleCAmJiB5YXJuIGJ1aWxkOmZpeHR1\ncmVzICYmIHlhcm4gYnVpbGQ6cmVtb3RlLXNjaGVtYXMiLAogICAgImNpIjog\nInlhcm4gdGVzdCIsCiAgICAiZGV2IjogIkRFQlVHPWluZm8sd2FybixlcnJv\nciBuZiBzdGFydCAtLXByb2NmaWxlIFByb2NmaWxlLmRldiAtdyIsCiAgICAi\nZHVtcC1zY2hlbWEiOiAiYmFiZWwtbm9kZSAtLWV4dGVuc2lvbnMgJy50cywu\nanMnIC4vc2NyaXB0cy9kdW1wLXNjaGVtYS50cyIsCiAgICAiZHVtcDpsb2Nh\nbCI6ICJ5YXJuIGR1bXAtc2NoZW1hIHYxIF9zY2hlbWEuZ3JhcGhxbCAmIHlh\ncm4gZHVtcC1zY2hlbWEgdjIgX3NjaGVtYVYyLmdyYXBocWwgJiB3YWl0IiwK\nICAgICJkdW1wOnN0YWdpbmciOiAibm9kZSBzY3JpcHRzL2R1bXAtc3RhZ2lu\nZy1zY2hlbWEuanMiLAogICAgImxpbnQiOiAiZXNsaW50IC4gLS1leHQgdHMi\nLAogICAgImxpbnQ6Zml4IjogImVzbGludCAuIC0tZml4IC0tZXh0IHRzIiwK\nICAgICJwcmVwYXJlIjogInBhdGNoLXBhY2thZ2UiLAogICAgInByZXR0aWVy\nLXByb2plY3QiOiAicHJldHRpZXIgLS13cml0ZSAnc3JjLyoqLyoue2pzLHRz\nLHRzeCxtZCxncmFwaHFsfSciLAogICAgInNjaGVtYS1kcmlmdCI6ICJiYWJl\nbC1ub2RlIC0tbm8td2FybmluZ3MgLS1leHRlbnNpb25zICcudHMsLmpzJyAu\nL3NjcmlwdHMvc2NoZW1hLWRyaWZ0LnRzIiwKICAgICJzdGFydCI6ICJ5YXJu\nIHJ1biBkZXYiLAogICAgInRlc3Q6dmFsaWRRdWVyaWVzIjogImJhYmVsLW5v\nZGUgLS1leHRlbnNpb25zICcudHMsLmpzJyBzcmMvaW50ZWdyYXRpb24vX190\nZXN0c19fL3J1blN0b3JlZFF1ZXJ5VGVzdHMudHMiLAogICAgInRlc3QiOiAi\neWFybiB0eXBlLWNoZWNrICYmIHlhcm4gbGludCAmJiBqZXN0IiwKICAgICJ0\neXBlLWNoZWNrIjogInRzYyAtLW5vRW1pdCAtLXByZXR0eSIsCiAgICAidmVy\nYm9zZS1kZXYiOiAiREVCVUc9dmVyYm9zZSxpbmZvLGVycm9yIG5mIHN0YXJ0\nIC0tcHJvY2ZpbGUgUHJvY2ZpbGUuZGV2IiwKICAgICJ3YXRjaCI6ICJqZXN0\nIC0td2F0Y2giCiAgfSwKICAiYXV0aG9yIjogIkFydC5zeSBJbmMiLAogICJs\naWNlbnNlIjogIk1JVCIsCiAgImRlcGVuZGVuY2llcyI6IHsKICAgICJAYXJ0\nc3kveGFwcCI6ICIxLjAuNSIsCiAgICAiQGJhYmVsL2NsaSI6ICI3LjQuNCIs\nCiAgICAiQGJhYmVsL2NvcmUiOiAiNy40LjUiLAogICAgIkBiYWJlbC9ub2Rl\nIjogIjcuNC41IiwKICAgICJAYmFiZWwvcGx1Z2luLXByb3Bvc2FsLW51bGxp\nc2gtY29hbGVzY2luZy1vcGVyYXRvciI6ICI3LjguMyIsCiAgICAiQGJhYmVs\nL3BsdWdpbi1wcm9wb3NhbC1vcHRpb25hbC1jaGFpbmluZyI6ICI3LjkuMCIs\nCiAgICAiQGJhYmVsL3ByZXNldC1lbnYiOiAiNy40LjUiLAogICAgIkBiYWJl\nbC9wcmVzZXQtdHlwZXNjcmlwdCI6ICI3LjMuMyIsCiAgICAiQGJhYmVsL3Jl\nZ2lzdGVyIjogIjcuNC40IiwKICAgICJAZ3JhcGhxbC10b29scy9kZWxlZ2F0\nZSI6ICI2LjAuMTAiLAogICAgIkBoZXJva3UvZm9yZW1hbiI6ICIyLjAuMiIs\nCiAgICAiYWNjb3VudGluZyI6ICIwLjQuMSIsCiAgICAiYXBvbGxvLWxpbmsi\nOiAiMS4yLjEiLAogICAgImFwb2xsby1saW5rLWNvbnRleHQiOiAiMS4wLjgi\nLAogICAgImFwb2xsby1saW5rLWh0dHAiOiAiMS41LjQiLAogICAgImFwb2xs\nby1zZXJ2ZXItZXhwcmVzcyI6ICIyLjQuOCIsCiAgICAiYXBwbWV0cmljcyI6\nICI1LjEuMSIsCiAgICAiYXJ0c3ktbW9yZ2FuIjogImdpdDovL2dpdGh1Yi5j\nb20vYXJ0c3kvYXJ0c3ktbW9yZ2FuLmdpdCIsCiAgICAiYmFiZWwtY29yZSI6\nICI3LjAuMC1icmlkZ2UuMCIsCiAgICAiYmFiZWwtcGx1Z2luLW1vZHVsZS1y\nZXNvbHZlciI6ICIzLjEuMSIsCiAgICAiYmFzaWMtYXV0aCI6ICIxLjEuMCIs\nCiAgICAiYmx1ZWJpcmQiOiAiMy41LjEiLAogICAgImJvZHktcGFyc2VyIjog\nIjEuMTguMiIsCiAgICAiY29tcHJlc3Npb24iOiAiMS43LjIiLAogICAgImNv\ncnMiOiAiMi44LjQiLAogICAgImRhdGFsb2FkZXIiOiAiMS4zLjAiLAogICAg\nImRkLXRyYWNlIjogIjAuMjEuMCIsCiAgICAiZGVidWciOiAiMi42LjkiLAog\nICAgImV4cHJlc3MiOiAiNC4xNi4yIiwKICAgICJleHByZXNzLWZvcmNlLXNz\nbCI6ICIwLjMuMiIsCiAgICAiZXhwcmVzcy1ncmFwaHFsIjogIjAuOS4wIiwK\nICAgICJleHByZXNzLWlwZmlsdGVyIjogIjAuMy4xIiwKICAgICJleHByZXNz\nLXJhdGUtbGltaXQiOiAiMy4yLjAiLAogICAgImdyYXBoaXFsIjogIjAuMTEu\nMTEiLAogICAgImdyYXBocWwiOiAiMTQuNS40IiwKICAgICJncmFwaHFsLWRl\ncHRoLWxpbWl0IjogIjEuMS4wIiwKICAgICJncmFwaHFsLWV4dGVuc2lvbnMi\nOiAiMC41LjciLAogICAgImdyYXBocWwtbWlkZGxld2FyZSI6ICIxLjIuNiIs\nCiAgICAiZ3JhcGhxbC1yZWxheSI6ICIwLjUuNCIsCiAgICAiZ3JhcGhxbC10\nb29scyI6ICI0LjAuNSIsCiAgICAiZ3JhcGhxbC10eXBlLWpzb24iOiAiMC4x\nLjQiLAogICAgImhlYXBkdW1wIjogIjAuMy4xNSIsCiAgICAiaG90LXNob3Rz\nIjogIjUuNi4xIiwKICAgICJodHRwLXNodXRkb3duIjogIjEuMi4xIiwKICAg\nICJpIjogIjAuMy42IiwKICAgICJpbnZhcmlhbnQiOiAiMi4yLjQiLAogICAg\nImlwIjogIjEuMS41IiwKICAgICJqd3Qtc2ltcGxlIjogIjAuNS42IiwKICAg\nICJsb2Rhc2giOiAiNC4xNy4xMyIsCiAgICAibG9uZ2pvaG4iOiAiMC4yLjEy\nIiwKICAgICJtYXJrZWQiOiAiMC4zLjE4IiwKICAgICJtZW1jYWNoZWQiOiAi\nMi4yLjIiLAogICAgIm1vbWVudCI6ICIyLjI2LjAiLAogICAgIm1vbWVudC10\naW1lem9uZSI6ICIwLjUuMzEiLAogICAgIm5vZGUtZmV0Y2giOiAiMS43LjMi\nLAogICAgIm51bWVyYWwiOiAiMS41LjYiLAogICAgIm9wZW50cmFjaW5nIjog\nIjAuMTQuMSIsCiAgICAicGF0Y2gtcGFja2FnZSI6ICI2LjIuMiIsCiAgICAi\ncGVyZm9ybWFuY2Utbm93IjogIjIuMS4wIiwKICAgICJwb3N0aW5zdGFsbC1w\ncmVwYXJlIjogIjEuMC4xIiwKICAgICJxcyI6ICI2LjkuMSIsCiAgICAicmF0\nZS1saW1pdC1tZW1jYWNoZWQiOiAiMC42LjAiLAogICAgInJhdmVuIjogIjIu\nNC4yIiwKICAgICJyZWFjdCI6ICIxNS42LjIiLAogICAgInJlYWN0LWRvbSI6\nICIxNS42LjIiLAogICAgInJlbGF5LWN1cnNvci1wYWdpbmciOiAiMC4yLjAi\nLAogICAgInJlcXVlc3QiOiAiMi44My4wIiwKICAgICJydW50eXBlcyI6ICI0\nLjIuMCIsCiAgICAic291cmNlLW1hcC1zdXBwb3J0IjogIjAuNC4xOCIsCiAg\nICAidXJsLWpvaW4iOiAiNC4wLjAiLAogICAgInV1aWQiOiAiMy4xLjAiCiAg\nfSwKICAicmVzb2x1dGlvbnMiOiB7CiAgICAiYmFiZWwtY29yZSI6ICI3LjAu\nMC1icmlkZ2UuMCIKICB9LAogICJkZXZEZXBlbmRlbmNpZXMiOiB7CiAgICAi\nQGFydHN5L2V4cHJlc3MtcmVsb2FkYWJsZSI6ICIxLjQuOCIsCiAgICAiQGFy\ndHN5L3VwZGF0ZS1yZXBvIjogIjAuMS41IiwKICAgICJAZ3JhcGhxbC1pbnNw\nZWN0b3IvY29yZSI6ICIxLjI3LjAiLAogICAgIkB0eXBlcy9leHByZXNzLXJh\ndGUtbGltaXQiOiAiMi45LjMiLAogICAgIkB0eXBlcy9ncmFwaHFsLXJlbGF5\nIjogIjAuNC45IiwKICAgICJAdHlwZXMvaW52YXJpYW50IjogIjIuMi4yOSIs\nCiAgICAiQHR5cGVzL2plc3QiOiAiMjMuMy4yIiwKICAgICJAdHlwZXMvbG9k\nYXNoIjogIjQuMTQuODYiLAogICAgIkB0eXBlcy9ub2RlIjogIjguMC41MyIs\nCiAgICAiQHR5cGVzL25vZGUtZmV0Y2giOiAiMi4xLjciLAogICAgIkB0eXBl\ncy9xcyI6ICI2LjUuMSIsCiAgICAiQHR5cGVzL3JlcXVlc3QiOiAiMi4wLjgi\nLAogICAgIkB0eXBlc2NyaXB0LWVzbGludC9lc2xpbnQtcGx1Z2luIjogIjIu\nMTAuMCIsCiAgICAiQHR5cGVzY3JpcHQtZXNsaW50L3BhcnNlciI6ICIyLjEw\nLjAiLAogICAgImJhYmVsLWVzbGludCI6ICIxMC4wLjEiLAogICAgImJhYmVs\nLWplc3QiOiAiMjQuOC4wIiwKICAgICJkYW5nZXIiOiAiNy4wLjE0IiwKICAg\nICJkZWVwLWVxdWFsIjogIjEuMC4xIiwKICAgICJkaWZmIjogIjQuMC4xIiwK\nICAgICJkb3RlbnYiOiAiNS4wLjEiLAogICAgImVzbGludCI6ICI2LjcuMiIs\nCiAgICAiZXNsaW50LWltcG9ydC1yZXNvbHZlci10eXBlc2NyaXB0IjogIjIu\nMC4wIiwKICAgICJlc2xpbnQtcGx1Z2luLWltcG9ydCI6ICIyLjE4LjIiLAog\nICAgImVzbGludC1wbHVnaW4tcHJvbWlzZSI6ICI0LjAuMSIsCiAgICAiZXhw\nZWN0LmpzIjogIjAuMy4xIiwKICAgICJodXNreSI6ICIzLjEuMCIsCiAgICAi\namVzdCI6ICIyNC45LjAiLAogICAgImxpbnQtc3RhZ2VkIjogIjcuMy4wIiwK\nICAgICJwcmV0dGllciI6ICIyLjAuNSIsCiAgICAic2lub24iOiAiMS4xNy43\nIiwKICAgICJzdXBlcmFnZW50IjogIjMuOC4zIiwKICAgICJzdXBlcnRlc3Qi\nOiAiMy4xLjAiLAogICAgInR5cGVzY3JpcHQiOiAiMy44LjMiCiAgfSwKICAi\namVzdCI6IHsKICAgICJzZXR1cEZpbGVzQWZ0ZXJFbnYiOiBbCiAgICAgICI8\ncm9vdERpcj4vc3JjL3Rlc3QvaGVscGVyLmpzIgogICAgXSwKICAgICJ0ZXN0\nUGF0aElnbm9yZVBhdHRlcm5zIjogWwogICAgICAiL25vZGVfbW9kdWxlcy8i\nLAogICAgICAiL2J1aWxkLyIsCiAgICAgICIvc3JjL3Rlc3QvaGVscGVyLmpz\nIiwKICAgICAgIi9zcmMvdGVzdC91dGlscy5qcyIsCiAgICAgICIvc3JjL3Rl\nc3QvZ3FsLmpzIiwKICAgICAgIi9zcmMvdGVzdC9fX21vY2tzX18iLAogICAg\nICAic3JjL3NjaGVtYS92Mi9fX3Rlc3RzX18vZWNvbW1lcmNlLyIKICAgIF0s\nCiAgICAidHJhbnNmb3JtIjogewogICAgICAiXi4rXFwuKGpzfHRzKSQiOiAi\nYmFiZWwtamVzdCIKICAgIH0sCiAgICAibW9kdWxlRmlsZUV4dGVuc2lvbnMi\nOiBbCiAgICAgICJqcyIsCiAgICAgICJqc3giLAogICAgICAianNvbiIsCiAg\nICAgICJ0cyIsCiAgICAgICJ0c3giCiAgICBdLAogICAgInRlc3RSZWdleCI6\nICIoLnRlc3QpXFwuKGpzfHRzKSQiLAogICAgImNvdmVyYWdlRGlyZWN0b3J5\nIjogImNvdmVyYWdlIiwKICAgICJjb2xsZWN0Q292ZXJhZ2UiOiB0cnVlLAog\nICAgImNvdmVyYWdlUmVwb3J0ZXJzIjogWwogICAgICAibGNvdiIsCiAgICAg\nICJ0ZXh0LXN1bW1hcnkiCiAgICBdCiAgfSwKICAicHJldHRpZXIiOiB7CiAg\nICAic2VtaSI6IGZhbHNlLAogICAgInNpbmdsZVF1b3RlIjogZmFsc2UsCiAg\nICAidHJhaWxpbmdDb21tYSI6ICJlczUiLAogICAgImJyYWNrZXRTcGFjaW5n\nIjogdHJ1ZQogIH0sCiAgImxpbnQtc3RhZ2VkIjogewogICAgIiouQChqc29u\nfG1kfHRzfGdyYXBocWwpIjogWwogICAgICAieWFybiBwcmV0dGllciAtLXdy\naXRlIiwKICAgICAgImdpdCBhZGQiCiAgICBdLAogICAgIiouQChqcykiOiBb\nCiAgICAgICJlc2xpbnQgLS1maXgiLAogICAgICAieWFybiBwcmV0dGllciAt\nLXdyaXRlIiwKICAgICAgImdpdCBhZGQiCiAgICBdCiAgfSwKICAiaHVza3ki\nOiB7CiAgICAiaG9va3MiOiB7CiAgICAgICJwcmUtY29tbWl0IjogImxpbnQt\nc3RhZ2VkOyB5YXJuIGR1bXA6c3RhZ2luZzsgZ2l0IGFkZCBfc2NoZW1hLmdy\nYXBocWwgX3NjaGVtYVYyLmdyYXBocWwiLAogICAgICAicHJlLXB1c2giOiAi\neWFybiBydW4gdHlwZS1jaGVjayIKICAgIH0KICB9Cn0K\n", encoding: 'base64', _links: { self: 'https://api.github.com/repos/artsy/metaphysics/contents/package.json?ref=main', git: 'https://api.github.com/repos/artsy/metaphysics/git/blobs/f60926f5c61ea9b354783673c21c2eb2830dca32', html: 'https://github.com/artsy/metaphysics/blob/main/package.json' } }
  end
  let(:github_nvmrc_response) do
    { name: '.nvmrc', path: '.nvmrc', sha: 'dae199aecb18022d9c525b7af95f6cd1bb44f43a', size: 4, url: 'https://api.github.com/repos/artsy/metaphysics/contents/.nvmrc?ref=main', html_url: 'https://github.com/artsy/metaphysics/blob/main/.nvmrc', git_url: 'https://api.github.com/repos/artsy/metaphysics/git/blobs/dae199aecb18022d9c525b7af95f6cd1bb44f43a', download_url: 'https://raw.githubusercontent.com/artsy/metaphysics/main/.nvmrc', type: 'file', content: "djEyCg==\n", encoding: 'base64', _links: { self: 'https://api.github.com/repos/artsy/metaphysics/contents/.nvmrc?ref=main', git: 'https://api.github.com/repos/artsy/metaphysics/git/blobs/dae199aecb18022d9c525b7af95f6cd1bb44f43a', html: 'https://github.com/artsy/metaphysics/blob/main/.nvmrc' } }
  end
  let(:github_ruby_response) do
    { name: '.ruby-version', path: '.ruby-version', sha: '35d16fb1a74c5b135d4278c6a69edd3cfa0d9a74', size: 6, url: 'https://api.github.com/repos/artsy/gravity/contents/.ruby-version?ref=main', html_url: 'https://github.com/artsy/gravity/blob/main/.ruby-version', git_url: 'https://api.github.com/repos/artsy/gravity/git/blobs/35d16fb1a74c5b135d4278c6a69edd3cfa0d9a74', download_url: 'https://raw.githubusercontent.com/artsy/gravity/main/.ruby-version?token=AAEEFFHK6TGTBOY7HJLJVWK66UJRS', type: 'file', content: "Mi41LjcK\n", encoding: 'base64', _links: { self: 'https://api.github.com/repos/artsy/gravity/contents/.ruby-version?ref=main', git: 'https://api.github.com/repos/artsy/gravity/git/blobs/35d16fb1a74c5b135d4278c6a69edd3cfa0d9a74', html: 'https://github.com/artsy/gravity/blob/main/.ruby-version' } }
  end
  let(:github_circle_response) do
    { name: 'config.yml', path: '.circleci/config.yml', sha: 'efe34e82768fbd0142420c93b436064741cf39ef', size: 2552, url: 'https://api.github.com/repos/artsy/metaphysics/contents/.circleci/config.yml?ref=main', html_url: 'https://github.com/artsy/metaphysics/blob/main/.circleci/config.yml', git_url: 'https://api.github.com/repos/artsy/metaphysics/git/blobs/efe34e82768fbd0142420c93b436064741cf39ef', download_url: 'https://raw.githubusercontent.com/artsy/metaphysics/main/.circleci/config.yml', type: 'file', content: "dmVyc2lvbjogMi4xCgpvcmJzOgogIGNvZGVjb3Y6IGNvZGVjb3YvY29kZWNv\ndkAxLjEuMAogIGhva3VzYWk6IGFydHN5L2hva3VzYWlAMC43LjQKICBob3Jp\nem9uOiBhcnRzeS9yZWxlYXNlQDAuMC4xCiAgbm9kZTogY2lyY2xlY2kvbm9k\nZUAzLjAuMAogIHlhcm46IGFydHN5L3lhcm5ANS4xLjMKCm5vdF9zdGFnaW5n\nX29yX3JlbGVhc2U6ICZub3Rfc3RhZ2luZ19vcl9yZWxlYXNlCiAgZmlsdGVy\nczoKICAgIGJyYW5jaGVzOgogICAgICBpZ25vcmU6CiAgICAgICAgLSBzdGFn\naW5nCiAgICAgICAgLSByZWxlYXNlCgpvbmx5X21hc3RlcjogJm9ubHlfbWFz\ndGVyCiAgY29udGV4dDogaG9rdXNhaQogIGZpbHRlcnM6CiAgICBicmFuY2hl\nczoKICAgICAgb25seTogbWFzdGVyCgpvbmx5X3JlbGVhc2U6ICZvbmx5X3Jl\nbGVhc2UKICBjb250ZXh0OiBob2t1c2FpCiAgZmlsdGVyczoKICAgIGJyYW5j\naGVzOgogICAgICBvbmx5OiByZWxlYXNlCgpvbmx5X2RldmVsb3BtZW50OiAm\nb25seV9kZXZlbG9wbWVudAogIGZpbHRlcnM6CiAgICBicmFuY2hlczoKICAg\nICAgaWdub3JlOgogICAgICAgIC0gc3RhZ2luZwogICAgICAgIC0gcmVsZWFz\nZQogICAgICAgIC0gbWFzdGVyCgpqb2JzOgogIHB1c2gtc2NoZW1hLWNoYW5n\nZXM6CiAgICBleGVjdXRvcjoKICAgICAgbmFtZTogbm9kZS9kZWZhdWx0CiAg\nICAgIHRhZzogIjEyLjE0IgogICAgc3RlcHM6CiAgICAgIC0gcnVuOgogICAg\nICAgICAgbmFtZTogTGV0IGhva3VzYWkgbW9kaWZ5IC91c3IvbG9jYWwvYmlu\nCiAgICAgICAgICBjb21tYW5kOiBzdWRvIGNobW9kIC1SIDc3NyAvdXNyL2xv\nY2FsL2JpbgogICAgICAtIGNoZWNrb3V0CiAgICAgIC0gaG9rdXNhaS9pbnN0\nYWxsLWF3cy1pYW0tYXV0aGVudGljYXRvcgogICAgICAtIHJ1bjoKICAgICAg\nICAgIG5hbWU6IEluc3RhbGwgaG9rdXNhaQogICAgICAgICAgY29tbWFuZDog\nfAogICAgICAgICAgICBzdWRvIGFwdCB1cGRhdGUKICAgICAgICAgICAgc3Vk\nbyBhcHQgaW5zdGFsbCAtLWFzc3VtZS15ZXMgcHl0aG9uLXBpcAogICAgICAg\nICAgICBwaXAgaW5zdGFsbCBhd3NjbGkgLS11cGdyYWRlCiAgICAgICAgICAg\nIHBpcCBpbnN0YWxsIGhva3VzYWkKICAgICAgLSBob2t1c2FpL2NvbmZpZ3Vy\nZS1ob2t1c2FpCiAgICAgIC0geWFybi9sb2FkX2RlcGVuZGVuY2llcwogICAg\nICAtIHlhcm4vaW5zdGFsbAogICAgICAtIHlhcm4vc2F2ZV9kZXBlbmRlbmNp\nZXMKICAgICAgLSBydW46CiAgICAgICAgICBuYW1lOiBwdXNoIHNjaGVtYSBj\naGFuZ2VzCiAgICAgICAgICBjb21tYW5kOiBub2RlIHNjcmlwdHMvcHVzaC1z\nY2hlbWEtY2hhbmdlcy5qcwoKd29ya2Zsb3dzOgogIGRlZmF1bHQ6CiAgICBq\nb2JzOgogICAgICAjIGZvciBQUnMKICAgICAgLSB5YXJuL3VwZGF0ZS1jYWNo\nZToKICAgICAgICAgIDw8OiAqb25seV9kZXZlbG9wbWVudAoKICAgICAgIyBw\ncmUtc3RhZ2luZwogICAgICAtIGhva3VzYWkvdGVzdDoKICAgICAgICAgIG5h\nbWU6IHRlc3QKICAgICAgICAgIDw8OiAqbm90X3N0YWdpbmdfb3JfcmVsZWFz\nZQogICAgICAgICAgcG9zdC1zdGVwczoKICAgICAgICAgICAgLSBydW46IG1r\nZGlyIC1wIC4vY292ZXJhZ2UKICAgICAgICAgICAgLSBydW46CiAgICAgICAg\nICAgICAgICBuYW1lOiBDb3B5IGNvdmVyYWdlIGFydGlmYWN0cwogICAgICAg\nICAgICAgICAgY29tbWFuZDogZG9ja2VyIGNwIGhva3VzYWlfbWV0YXBoeXNp\nY3NfMTovYXBwL2NvdmVyYWdlIC4vCiAgICAgICAgICAgICAgICB3aGVuOiBh\nbHdheXMKICAgICAgICAgICAgLSBjb2RlY292L3VwbG9hZDoKICAgICAgICAg\nICAgICAgIGZpbGU6IC4vY292ZXJhZ2UvbGNvdi5pbmZvCgogICAgICAjIHN0\nYWdpbmcKICAgICAgLSBob2t1c2FpL3B1c2g6CiAgICAgICAgICBuYW1lOiBw\ndXNoLXN0YWdpbmctaW1hZ2UKICAgICAgICAgIDw8OiAqb25seV9tYXN0ZXIK\nICAgICAgICAgIHJlcXVpcmVzOgogICAgICAgICAgICAtIHRlc3QKCiAgICAg\nIC0gaG9rdXNhaS9kZXBsb3ktc3RhZ2luZzoKICAgICAgICAgIG5hbWU6IGRl\ncGxveS1zdGFnaW5nCiAgICAgICAgICA8PDogKm9ubHlfbWFzdGVyCiAgICAg\nICAgICBwcm9qZWN0LW5hbWU6IG1ldGFwaHlzaWNzCiAgICAgICAgICByZXF1\naXJlczoKICAgICAgICAgICAgLSBwdXNoLXN0YWdpbmctaW1hZ2UKCiAgICAg\nIC0gcHVzaC1zY2hlbWEtY2hhbmdlczoKICAgICAgICAgIDw8OiAqb25seV9t\nYXN0ZXIKICAgICAgICAgIGNvbnRleHQ6IGhva3VzYWkKICAgICAgICAgIHJl\ncXVpcmVzOgogICAgICAgICAgICAtIHB1c2gtc3RhZ2luZy1pbWFnZQogICAg\nICAgICAgICAtIGRlcGxveS1zdGFnaW5nCgogICAgICAjIHJlbGVhc2UKICAg\nICAgLSBob3Jpem9uL2Jsb2NrOgogICAgICAgICAgPDw6ICpvbmx5X3JlbGVh\nc2UKICAgICAgICAgIGNvbnRleHQ6IGhvcml6b24KICAgICAgICAgIHByb2pl\nY3RfaWQ6IDE4CgogICAgICAtIGhva3VzYWkvZGVwbG95LXByb2R1Y3Rpb246\nCiAgICAgICAgICA8PDogKm9ubHlfcmVsZWFzZQogICAgICAgICAgcmVxdWly\nZXM6CiAgICAgICAgICAgIC0gaG9yaXpvbi9ibG9jawo=\n", encoding: 'base64', _links: { self: 'https://api.github.com/repos/artsy/metaphysics/contents/.circleci/config.yml?ref=main', git: 'https://api.github.com/repos/artsy/metaphysics/git/blobs/efe34e82768fbd0142420c93b436064741cf39ef', html: 'https://github.com/artsy/metaphysics/blob/main/.circleci/config.yml' } }
  end
  # rubocop:enable Layout/LineLength

  before do
    allow_any_instance_of(Octokit::Client).to receive(:contents)
      .with(project.github_repo.to_s, path: '.circleci/config.yml')
      .and_return(github_circle_response)
    allow_any_instance_of(Octokit::Client).to receive(:contents)
      .with(project.github_repo.to_s, path: 'package.json')
      .and_return(github_package_json_response)
    allow_any_instance_of(Octokit::Client).to receive(:contents)
      .with(project.github_repo.to_s, path: '.nvmrc')
      .and_return(github_nvmrc_response)
    allow_any_instance_of(Octokit::Client).to receive(:contents)
      .with(project.github_repo.to_s, path: '.ruby-version')
      .and_return(github_ruby_response)
    allow_any_instance_of(Octokit::Client).to receive(:contents)
      .with(project.github_repo.to_s, path: 'Gemfile')
      .and_return({ content: '' })
    allow_any_instance_of(Octokit::Client).to receive(:contents)
      .with(project.github_repo.to_s, path: 'renovate.json')
      .and_return({ content: '' })

    allow(Horizon)
      .to receive(:config)
      .and_return({
                    minimum_version_ruby: '2.6.6',
                    minimum_version_node: '12.0.0'
                  })
  end

  describe 'refresh_data_for_org' do
    it 'updates all projects' do
      allow(project).to receive(:update)
      ProjectDataService.refresh_data_for_org(org)
      expect(project).to have_received(:update)
        .with({
                ci_provider: 'circleci',
                renovate: true,
                orbs: %w[hokusai release yarn]
              })
      expect(project.dependencies.first.name).to eq('ruby')
      expect(project.dependencies.first.version).to eq('2.5.7')
      expect(project.dependencies.last.name).to eq('node')
      expect(project.dependencies.last.version).to eq('12')
    end
  end

  describe 'update_dependency' do
    it 'updates an existing dependency' do
      Dependency.create(name: 'ruby', version: '2.2.2', project_id: project.id)
      ProjectDataService.new(project).update_dependency('ruby', '2.4.3')
      expect(Dependency.count).to eq(1)
      expect(project.dependencies.first.version).to eq('2.4.3')
      expect(project.dependencies.first.update_required?).to be_truthy
    end

    it 'creates a dependency if none exists' do
      Dependency.create(name: 'ruby', version: '2.2.2', project_id: project.id)
      ProjectDataService.new(project).update_dependency('node', 'v12')
      expect(Dependency.count).to eq(2)
      expect(project.dependencies.last.name).to eq('node')
      expect(project.dependencies.last.version).to eq('v12')
      expect(project.dependencies.last.update_required?).to be_falsey
    end
  end

  describe 'update_dependencies' do
    it 'calls update_dependency with ruby and node' do
      allow(Horizon.dogstatsd).to receive(:gauge)
      ProjectDataService.new(project).update_dependencies

      expect(project.dependencies.first.name).to eq('ruby')
      expect(project.dependencies.first.version).to eq('2.5.7')
      expect(project.dependencies.last.name).to eq('node')
      expect(project.dependencies.last.version).to eq('12')
      expect(Horizon.dogstatsd).to have_received(:gauge).with(
        'runtime.version_status',
        -1,
        tags: [
          'runtime:ruby',
          'project:candela',
          'criticality:1',
          'team:engineering'
        ]
      ).once
      expect(Horizon.dogstatsd).to have_received(:gauge).with(
        'runtime.version_status',
        1,
        tags: [
          'runtime:node',
          'project:candela',
          'criticality:1',
          'team:engineering'
        ]
      ).once
    end
  end

  describe 'ruby_version' do
    it 'returns version when provided' do
      version = ProjectDataService.new(project).ruby_version
      expect(version).to eq('2.5.7')
    end

    it 'returns unknown when no .ruby-version but Gemfile is present' do
      allow_any_instance_of(Octokit::Client).to receive(:contents)
        .with(project.github_repo.to_s, path: '.ruby-version')
        .and_return(nil)
      version = ProjectDataService.new(project).ruby_version
      expect(version).to eq('unknown version')
    end

    it 'returns nothing if no .ruby-version or Gemfile' do
      allow_any_instance_of(Octokit::Client).to receive(:contents).and_return(nil)
      version = ProjectDataService.new(project).ruby_version
      expect(version).to eq(nil)
    end
  end

  describe 'node_version' do
    it 'returns version from package.json when provided' do
      version = ProjectDataService.new(project).node_version
      expect(version).to eq('12')
    end

    it 'returns version from .nvmrc when provided' do
      allow(JSON).to receive(:parse).and_return({})
      version = ProjectDataService.new(project).node_version
      expect(version).to eq('v12')
    end

    it 'returns unknown when version not listed' do
      allow(JSON).to receive(:parse).and_return({})
      allow_any_instance_of(Octokit::Client).to receive(:contents)
        .with(project.github_repo.to_s, path: '.nvmrc')
        .and_return(nil)
      version = ProjectDataService.new(project).node_version
      expect(version).to eq('unknown version')
    end

    it 'returns nothing if no package.json' do
      allow_any_instance_of(Octokit::Client).to receive(:contents).and_return(nil)
      version = ProjectDataService.new(project).node_version
      expect(version).to eq(nil)
    end
  end

  describe 'orbs' do
    it 'returns an array with orbs if present in ci config' do
      orbs = ProjectDataService.new(project).orbs
      expect(orbs).to eq(%w[hokusai release yarn])
    end
  end
end
