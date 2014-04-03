#!/usr/bin/ruby

require 'rubygems'
require "pit"
require 'gcalapi'

ENV["EDITOR"] ||= "vim"
config = Pit.get("add_schedule.rb", :require => {
  "mail" => "input your login mail address",
  "pass" => "input your password",
  "feed" => "input your feed address",
})

srv = GoogleCalendar::Service.new(config["mail"], config["pass"])
cal = GoogleCalendar::Calendar::new(srv, config["feed"])
st_hour = ARGV[5] 
st_min = ARGV[6] 
en_hour = ARGV[7] 
en_min = ARGV[8] 

if ARGV.length > 9 then
  st_min += ARGV[9].to_i
  while st_min < 0 do
    st_hour -= 1
    st_min += 60
  end
  while st_min >= 60 do
    st_hour += 1
    st_min -= 60
  end
end
event = cal.create_event
event.title = ARGV[0]
event.desc = ARGV[0]
event.where = ARGV[1]
event.st =  Time.mktime(ARGV[2], ARGV[3], ARGV[4], st_hour, st_min, 0)
event.en =  Time.mktime(ARGV[2], ARGV[3], ARGV[4], en_hour, en_min, 0)
event.save!
