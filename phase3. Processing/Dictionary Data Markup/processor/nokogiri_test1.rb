require 'nokogiri'
require 'open-uri'
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
	@doc.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

	# output below doesn't preserve content text at all
	#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
	# end

end
#*********************************************************************
def checkXPath(_current, _XPath)
	output = _current.xpath(_XPath)
end
#--------------------------------------------------------------------
def test_checkXPath(_oDOM)
	# some testing
	

	node = _oDOM.xpath("/html/body/div[4]/p[5]")
	puts checkXPath(node, "./h1")
	# end			
end
#***********************************************************************************
def getLine(_entry_token, _line_num)

	#token = _entry_token.clone # doesn't copy anything
	token = _entry_token.dup # this does
	fragment = _entry_token.fragment(_entry_token.to_html)

	line_breaks = _entry_token.xpath(".//node()[@style=\"color:red\"]")
	children = _entry_token.children
	if line_breaks.count==1	
		puts "Children in token:\t" + children.count.to_s	
		puts "Lines in token:\t\t" + line_breaks.count.to_s
		node = 	line_breaks[1]
		puts "Line Break:\t"	+ node.to_s
		index_ch = children.index(node)
		puts "Line Break Index:\t"	+ index_ch.to_s
		
	end		
	direct_sel = token.xpath(".//node()[@style=\"color:red\"][1]/following::node()")
	puts _entry_token
	puts fragment
	#puts direct_sel		
end
#-----------------------------------------------------------------++++
def test_getLine(_oDOM)
	entry_tokens = _oDOM.xpath("/html/body/div[4]/p[5]")
	getLine(entry_tokens[0], 2)
end
#***********************************************************************************
def DelimitLines(oDOM)
x_element = oDOM.xpath("/html/body/div/p/span[@style=\"color:red\"]")
	x_element.each() do |i|
		i.add_next_sibling "<br>"
	end
end

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
######################################################################
# MAIN FUNCTION
	# input	
	# creating input object
	html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')
	# end
	# creating DOM object from input object
	oDOM = Nokogiri::HTML(html_data)
	# some testing
	fileIO_issue_fix(oDOM)
	# end
	# output 
	# doesn't preserve turkish and kyrgyz specific letter
	#oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

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
