require 'nokogiri'
require 'open-uri'
require 'nokogiri-styles'
#----------------------------------------------------------------
def get_CSS_by_class(_tag_node)
	class_str= _tag_node["class"].to_str
	puts "class:\t" + class_str
	style_str = _tag_node['style'].to_str
	puts "css:\t" + style_str
end
#----------------------------------------------------------------
def DelimitLines(oDOM)
x_element = oDOM.xpath("/html/body/div/p/span[@style=\"color:red\"]")
	x_element.each() do |i|
		i.add_next_sibling "<br>"
	end
end
#----------------------------------------------------------------
def MarkupDictData(oDOM)
	x_element = oDOM.xpath("/html/body/div")
	x_element.each() do |node|
		#i.add_next_sibling "<br>"
		i =  x_element.index(node)
		# i= n-1
		if (i+1)%4 == 0
			puts i+1
			node["class"]="DictData"
			puts node.attribute("class")
		end

end

end
###MAIN###########################################################
# creating io object
html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')

# creating DOM object from io object
oDOM = Nokogiri::HTML(html_data)

tag_set = oDOM.xpath("/html/body/div[4]/p[5]")
tag_node=tag_set[0]
puts tag_node
puts tag_node.content
get_CSS_by_class(tag_node)

# output below doesn't preserve turkish and kyrgyz specific letter
oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

# output below doesn't preserve content text at all
#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
##################################################################



=begin
# code snippet from: https://stackoverflow.com/questions/24086304/nokogiri-write-html-to-oddness
# No1:
#File.write('write_html_to.html', doc.to_html(encoding: 'UTF-8'))
# No2:
#html_data.write_xhtml_to(File.new('write_xhtml_to.html', 'w'), :encoding => 'UTF-8')
# No3:
# modules.each do |url, klass|
=end
