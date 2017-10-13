require 'nokogiri'
require 'open-uri'

html_data = File.read('index.html')

nokogiri_object = Nokogiri::HTML(html_data)

x_element = nokogiri_object.xpath("/html/body/div[340]/p[16]/span[15]")
