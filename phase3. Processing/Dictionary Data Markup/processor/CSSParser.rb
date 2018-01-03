#----------------------------------------------------------------
class CSSParser
	def parse(_node)
		@m_node=_node
	
	end
	def initialize(_node, _DOM)
		@m_node=_node
		@m_DOM=_DOM
	end	 
	def get_prop_val(_prop_name)
		# Description: Access css property value 
		# regardless of its location(inline or centralized)
		# Algorithm:
		# => 0. Parse inline css
		# => 1. Get inline property value
		# => 2. If nothing was found
		# => 3. then get centralized property value
		puts "\n\t***\nIn get_prop_val\n"
		# 0.
		@m_node['style']
		# 1.
		val = @m_node.styles[_prop_name]
		if val == nil
			val = get_centralized_prop_val(_prop_name)
		end
		#<debub>
		puts "Property Name: " + _prop_name
		puts "Property Value: \n" + val.to_s
		#</debug>
		val.to_s
	end
	def get_centralized_prop_val(_prop_name)
		# Description: Access css property value 
		# from centralized css data store(i.e. <style> tag)
		# Algorithm:
		# => 1. temporarily save inline css rules
		# => 2. assign centralized css rules enstead of inline
		# => 3. parse using nokogiri-styles
		# => 4. get property value
		# => 5. restore inline css data
		# => 6. return property value

		# 1.
		tmp = @m_node['style']
		# 2.
		@m_node['style'] = self.get_centralized_rules
		# 3.
		@m_node['style']			
		# 4. 
		val = @m_node.styles[_prop_name]
		# 5.
		@m_node['style'] = tmp
		# 6.
		val
	end
	def show_rules()


	end
	def get_rules()
		# Access CSS rules both inline(from style att) 
		# and centralized(from style tag)

		#1
		centralized_css_str = self.get_centralized_rules()
		#2
		inline_css_str =  self.get_inline_rules()
		#<debug>
		puts "In get_rules: \n Inline css rules: \n" + inline_css_str
		char = gets
		#</debug>
		css_str = inline_css_str+";" + centralized_css_str
	end
	def get_inline_rules()
		# uses nokogiri-styles, simple inline css parser
		# returns inline css rules found in @style attribute's value
		style_inline = @m_node['style'].to_str

	end	
	def get_centralized_rules()
		# Algorithm:
		# 1. get all centralized css data from the dedicated style tag
		# 2. get _node's class_name
		# 3. get only css relating to the node's class name
		# 4. get only css rules
		# 5. convert them to string data type and remove curly bracket and formatting chars
		#1
		css_data = get_style_tag()
		#2
		class_name = @m_node["class"].to_str
		#3
		css_data_arr = css_data.scan(/p.MsoBodyText[\w|\W]+?\}/)
		        # here (above line) must be used class_name in regex
		        # css_data is an array
		#4
		css_data_str = arr_to_str(css_data_arr)
		css_rules_arr  = css_data_str.scan(/\{[\w|\W]+\}/)# works
		#5
		css_rules_str = arr_to_str(css_rules_arr).delete "{}\n\r\t"

		#<debug>
		puts "In get_centralized_rules: \n node's centralized css rules: \n" + css_rules_str
		ch = gets
		#</debug>
		css_rules_str
	end
	def get_style_tag()
		# returns css data found in <style> tag's value
		#
		style_nodes=@m_DOM.xpath("/html//style")
		css_str= style_nodes[0].content	

	end
	
end
