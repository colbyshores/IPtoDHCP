#!/bin/env /usr/local/bin/ruby
require 'rubygems'
require 'sinatra/activerecord'
require 'sinatra'
require 'net/ldap'
require 'socket'
require 'timeout'
require 'sinatra/session'
require 'yaml'
require 'uri'
require 'unix_crypt'
$config = YAML.load_file('/etc/IPtoDHCP.conf')
require "#{$config[:path]}/baseengine/auth.rb"
Dir["#{$config[:path]}/baseengine/*.rb"].each {|file| require file }
