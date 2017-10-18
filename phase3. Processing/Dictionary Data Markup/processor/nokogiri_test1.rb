require 'nokogiri'
require 'open-uri'
require 'nokogiri-styles'

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
        #puts o_div.to_s()
	p_elems = o_div.xpath("./p")
	p_elems.each() do |node|
                puts "element: " + (p_elems.index(node) +1).to_s()                  
		#puts node["style"]
		puts "margin-top:\t" + node.styles['margin-top'].to_s()
		if node.styles['margin-top']== "4.1pt"
			puts "++++++++++++++++++++COLUMN BREAK HAS BEEN FOUND++++++++++++++++++++++++++++"		
		end
	end

end
def ParsingOfAttrValues(_oDOM)

	node = _oDOM.xpath("/html/body/div[3]/p[0]")
	# ...

	# Get styles
	node['style']         # => 'width: 400px; color: blue'
	node.styles['width']  # => '400px'
	node.styles['color']  # => 'blue'

	# Update styles
	style = node.styles
	style['width']  = '500px'
	style['height'] = '300px'
	style['color']  = nil
	node.styles = style
	node['style']         # => 'width: 500xp; height: 300px'

	# Modify classes
	node['class']         # => 'foo bar'
	node.classes          # => ['foo', 'bar']
	node.classes = ['foo']
	node['class']         # => 'foo'

end
#==========================================================================
# Main
# creating io object
html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')

# creating DOM object from io object
oDOM = Nokogiri::HTML(html_data)

div_set = oDOM.xpath("/html/body/div")
MarkupColumns(div_set[3])
puts "\n NEXT PAGE GOES HERE========================================="
MarkupColumns(div_set[7])

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
