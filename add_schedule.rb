#!/usr/bin/ruby

mail = "foo@gmail.com"
pass = "bar"
feed = "http://www.google.com/calendar/feeds/foo%40gmail.com/private/full"
srv = GoogleCalendar::Service.new(mail, pass)
cal = GoogleCalendar::Calendar::new(srv, feed)
case ARGV[5] 
when "1" then
  st_hour = 9
  st_min = 0
  en_hour = 10
  en_min = 30
when "2" then
  st_hour = 10
  st_min = 40
  en_hour = 12
  en_min = 10
when "3" then
  st_hour = 13
  st_min = 0
  en_hour = 14
  en_min = 30
when "4" then
  st_hour = 14
  st_min = 50
  en_hour = 16
  en_min = 20
when "5" then
  st_hour = 16
  st_min = 30
  en_hour = 18
  en_min = 0
when "6" then
  st_hour = 18
  st_min = 10
  en_hour = 19
  en_min = 40
end
event = cal.create_event
event.title = ARGV[0]
event.desc = ARGV[0]
event.where = ARGV[1]
event.st =  Time.mktime(ARGV[2], ARGV[3], ARGV[4], st_hour, st_min, 0)
event.en =  Time.mktime(ARGV[2], ARGV[3], ARGV[4], en_hour, en_min, 0)
event.save!
