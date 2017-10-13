require 'nokogiri'
require 'open-uri'

html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')

nokogiri_object = Nokogiri::HTML(html_data)

x_element = nokogiri_object.xpath("/html/body/div/p/span[@style=\"color:red\"]")
File.write('../output/write_html_to.html', nokogiri_object.to_html(encoding: 'UTF-8'))
=begin
# code snippet from: https://stackoverflow.com/questions/24086304/nokogiri-write-html-to-oddness
# No1:
#File.write('write_html_to.html', doc.to_html(encoding: 'UTF-8'))
# No2:
#html_data.write_xhtml_to(File.new('write_xhtml_to.html', 'w'), :encoding => 'UTF-8')
# No3:
# modules.each do |url, klass|
=end
