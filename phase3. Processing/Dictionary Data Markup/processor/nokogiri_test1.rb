require 'nokogiri'
require 'open-uri'
require 'nokogiri-styles'

def DelimitLines(oDOM)
        x_element = oDOM.xpath("/html/body/div/p/span[@style=\"color:red\"]")
	counter = 0
	        x_element.each() do |i|
		        i.add_next_sibling "<br>"
	        end
	puts "Lines Marked Up: " + counter.to_s
end
#==========================================================================
def MarkupDictData(oDOM)
	x_element = oDOM.xpath("/html/body/div")
	x_element.each() do |node|
		#i.add_next_sibling "<br>"
		i =  x_element.index(node)
		# i= n-1
		if (i+1)%4 == 0
			puts "Div Token: " + (i+1).to_s
			node["class"]="DictData"
			puts "Set class name to: " +  node.attribute("class").to_s
		end
        end
end
#==========================================================================
def MarkupPageColumns(o_div)
	p_elems = o_div.children()# select everything inside div
	first_p = p_elems[0]
	first_p.add_previous_sibling "<div class = 'LeftColumn'/>"
	first_p.add_previous_sibling "<div class = 'RightColumn' style = 'margin-left:150'/>"
	o_div.to_html()
	rightColumn = first_p.previous_sibling
	leftColumn = rightColumn.previous_sibling
	o_div.to_html()
	flag = 0
	p_elems.each() do |node|
		if  node.styles['margin-top'].to_s.delete("pt").delete("in").to_f> 3 		
			flag+=1 
			puts "++++++++++++++++++++COLUMN BREAK HAS BEEN FOUND++++++++++++++++++++++++++++"		
		end
		if flag == 1
			node.parent = leftColumn			
			puts "placed to leftColumn"
		end
		if flag == 2
			node.parent = rightColumn
			puts "placed to rightColumn"
		else 	if flag > 2
			throw "Error: Too many columns in one page"
			puts "*************************Error: " + flag.to_s()
			end			
		end		
	        puts "Token reached: " + (p_elems.index(node) +1).to_s()              			
		if node.styles['margin-top'].to_s == "" then
			puts "margin-top:\tnil"
		else 
			#puts "\tmargin-top:\t" + node.styles['margin-top'].to_s().delete("pt").delete("in")
			puts "\tmargin-top:\t" + node.styles['margin-top'].to_s()
		end
	end
	#leftColumn.next_sibling = rightColumn
end
def ColumnsMarkup(_oDOM)
# Recieves dictionary with marked DictData divs
	dicDataPages = _oDOM.xpath("/html/body/div[@class = 'DictData']")	
	dicDataPages.each() do |node|
		MarkupPageColumns(node)
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

#DelimitLines(oDOM)
MarkupDictData(oDOM)
ColumnsMarkup(oDOM)
#dicDataPages = oDOM.xpath("/html/body/div[@class = 'DictData']")
#MarkupPageColumns(dicDataPages[0])
#puts "\n NEXT PAGE GOES HERE========================================="
#MarkupPageColumns(dicDataPages[11])

# Output1: doesn't preserve turkish and kyrgyz specific letter
oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

# Output2: below doesn't preserve content text at all
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
