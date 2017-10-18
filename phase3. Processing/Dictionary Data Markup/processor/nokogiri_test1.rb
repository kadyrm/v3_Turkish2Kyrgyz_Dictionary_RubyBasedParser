require 'nokogiri'
require 'open-uri'

def DelimitLines(oDOM)
        x_element = oDOM.xpath("/html/body/div/p/span[@style=\"color:red\"]")
	        x_element.each() do |i|
		        i.add_next_sibling "<br>"
	        end
end
#==========================================================================
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
#==========================================================================
def MarkupColumns(o_div)
        puts o_div.to_s()
	p_elems = o_div.xpath("./p")
	p_elems.each() do |node|
                puts p_elems.index(node) +1
                #puts node.to_html()
		puts node.attribute("style")
	end

end
#==========================================================================
# Main
# creating io object
html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')

# creating DOM object from io object
oDOM = Nokogiri::HTML(html_data)

div_set = oDOM.xpath("/html/body/div")
MarkupColumns(div_set[3])

# output below doesn't preserve turkish and kyrgyz specific letter
oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

# output below doesn't preserve content text at all
#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))




=begin
# code snippet from: https://stackoverflow.com/questions/24086304/nokogiri-write-html-to-oddness
# No1:
#File.write('write_html_to.html', doc.to_html(encoding: 'UTF-8'))
# No2:
#html_data.write_xhtml_to(File.new('write_xhtml_to.html', 'w'), :encoding => 'UTF-8')
# No3:
# modules.each do |url, klass|
=end
