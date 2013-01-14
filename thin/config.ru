require 'sinatra'

$:.unshift File.join(Dir.pwd, '')

#Sinatra::Application.default_options.merge!(
#  :run => false,
#  :env => :production
#)

require 'init'
run WuFileServer.new
