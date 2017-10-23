require 'nokogiri'
require 'open-uri'
require 'nokogiri-styles'

#**************************************************************************
def enable_style_tag(_oDOM)
	node = _oDOM.at_xpath("/html/head/style")
	s=node.inner_html.to_s
	s.delete("<![CDATA[")
	# needs a further look
	s.delete("\<\!--")
	s.delete("\/* Font Definitions *\/")
	s.delete("--\>")
	s.delete("--\>")
	s.delete("]]>")
	node.inner_html = s

end
def nested_spans_fix(_token)
	node_set = _token.xpath(".//span/child::span[1]")
	node_set.each() do |node|
		#passStyleToChildren(node)
		nested = node.parent.inner_html
		node.parent.after(nested)
		node.parent.content = ""
		node['note'] = "nested_span"
		puts "nested span fix performed:"
		puts _token.css_path.to_s + node.path.to_s
		#puts node.to_html
		
	end

end

def test_nested_spans_fix(_oDOM)
	node_set = _oDOM.xpath("/html/body/div[4]")
	nested_spans_fix(node_set[0])
	nested_spans_fix(node_set[0])
	enable_style_tag(_oDOM)
	_oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')
end
#**********************************************************************
def fileIO_issue_fix(_oDOM)
	file_content=_oDOM.to_html
	if ! file_content.valid_encoding?
		s = file_content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
		puts "Encoding fix performed"
	end
	@doc = Nokogiri::HTML::DocumentFragment.parse s
	# output 
	# doesn't preserve turkish and kyrgyz specific letter
	_oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

	# output below doesn't preserve content text at all
	#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
	# end

end

#**************************************************************************
def evalXPath(_current, _XPath)
	@doc = Nokogiri::HTML::DocumentFragment.parse _current.to_html
	output = @doc.xpath(_XPath)

end
#--------------------------------------------------------------------
def test_evalXPath(_oDOM)
	# some testing	
	curr_node = _oDOM.xpath("/html/body/div[4]/p[5]")
	nodes = evalXPath(curr_node, ".//node()[@style=\"color:red\"][1]/preceding::text()")
	puts nodes.to_s
	puts nodes.to_s.length

	# end			
end
#***********************************************************************************
def getLine(_entry_token, _line_num)

	line_markups = _entry_token.xpath(".//node()[@style=\"color:red\"]")
	if _line_num==1	
		nodes = evalXPath(_entry_token, ".//node()[@style=\"color:red\"][1]/preceding::text()")
		puts "line selected:\t" + nodes.to_s
		puts "line length:\t" + nodes.to_s.length.to_s
	else
		nodes = evalXPath(_entry_token, ".//node()[@style=\"color:red\"][1]/following::text()")
		puts "line selected:\t" + nodes.to_s
		puts "line length:\t" + nodes.to_s.length.to_s
	end					
end
#-----------------------------------------------------------------++++
def test_getLine(_oDOM)
	entry_tokens = _oDOM.xpath("/html/body/div[4]/p[5]")
	getLine(entry_tokens[0], 1)
end
#***********************************************************************************
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



	# output below doesn't preserve content text at all
	#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
	# end


######################################################################
# CODE SNIPPETS
=begin
# code snippet from: https://stackoverflow.com/questions/24086304/nokogiri-write-html-to-oddness
# No1:
#File.write('write_html_to.html', doc.to_html(encoding: 'UTF-8'))
# No2:
#html_data.write_xhtml_to(File.new('write_xhtml_to.html', 'w'), :encoding => 'UTF-8')
# No3:
# modules.each do |url, klass|
=end
